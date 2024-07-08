import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class MyChatApp extends StatelessWidget {
  final String email;

  MyChatApp({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MessageMe Chat App',
      home: ChatScreen(email: email),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String email;

  ChatScreen({Key? key, required this.email}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageTextController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser;
  String receiverName = 'Unknown Receiver';

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getReceiverName();
  }

  void getCurrentUser() {
    _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          currentUser = user;
        });
      }
    });
  }

  void getReceiverName() async {
    var userDocs = await _firestore
        .collection('users')
        .where('email', isEqualTo: widget.email)
        .get();
    var storeDocs = await _firestore
        .collection('stores')
        .where('email', isEqualTo: widget.email)
        .get();

    if (userDocs.docs.isNotEmpty) {
      setState(() {
        receiverName = userDocs.docs.first.data()['username'];
      });
    } else if (storeDocs.docs.isNotEmpty) {
      setState(() {
        receiverName = storeDocs.docs.first.data()['storeName'];
      });
    }
  }

  void sendMessage() async {
    if (currentUser?.email == null || messageTextController.text.isEmpty) {
      print("No email or message is empty");
      return;
    }

    String senderName = 'Unknown User';
    var userDoc =
        await _firestore.collection('users').doc(currentUser!.uid).get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      senderName = userData['userType'] == 'store'
          ? userData['storeName']
          : userData['username'];
    }

    var storeDoc = await _firestore
        .collection('stores')
        .where('email', isEqualTo: currentUser!.email)
        .get();
    if (storeDoc.docs.isNotEmpty) {
      Map<String, dynamic> storeData =
          storeDoc.docs.first.data() as Map<String, dynamic>;
      senderName = storeData['storeName'];
    }

    try {
      await _firestore.collection('messages').add({
        'text': messageTextController.text.trim(),
        'sender': currentUser!.email,
        'senderName': senderName,
        'receiver': widget.email,
        'receiverName': receiverName,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      messageTextController.clear();
    } catch (e) {
      print("Failed to send message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDFABBB),
        title: Text('Message with $receiverName'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: MessagesStream(
                firestore: _firestore,
                currentUser: currentUser,
                chatPartnerEmail: widget.email,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFDFABBB), width: 2.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        decoration: InputDecoration(
                          hintText: "اكتب رسالتك هنا...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Color(0xFFDFABBB)),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final FirebaseFirestore firestore;
  final User? currentUser;
  final String chatPartnerEmail;

  MessagesStream({
    required this.firestore,
    this.currentUser,
    required this.chatPartnerEmail,
  });

  @override
  Widget build(BuildContext context) {
    Stream<List<DocumentSnapshot>> messagesStream = Rx.combineLatest2(
        firestore
            .collection('messages')
            .where('sender', isEqualTo: currentUser?.email)
            .where('receiver', isEqualTo: chatPartnerEmail)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        firestore
            .collection('messages')
            .where('receiver', isEqualTo: currentUser?.email)
            .where('sender', isEqualTo: chatPartnerEmail)
            .orderBy('timestamp', descending: true)
            .snapshots(), (QuerySnapshot sent, QuerySnapshot received) {
      List<DocumentSnapshot> combined = [...sent.docs, ...received.docs];
      combined.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      return combined;
    });

    return StreamBuilder<List<DocumentSnapshot>>(
      stream: messagesStream,
      builder: (BuildContext context,
          AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<MessageBubble> messages = snapshot.data!.map((doc) {
          bool isMe = doc['sender'] == currentUser?.email;
          return MessageBubble.fromDocument(doc, isMe, currentUser?.email);
        }).toList();

        if (messages.isEmpty) {
          return Center(child: Text("No messages"));
        }

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) => messages[index],
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String senderName;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  MessageBubble({
    Key? key,
    required this.senderName,
    required this.text,
    required this.isMe,
    required this.timestamp,
  }) : super(key: key);

  factory MessageBubble.fromDocument(
      DocumentSnapshot doc, bool isMe, String? currentEmail) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String senderName = data['senderName'] ?? 'Unknown Sender';
    String text = data['text'] ?? '';
    DateTime timestamp;

    if (data['timestamp'] is Timestamp) {
      timestamp = (data['timestamp'] as Timestamp).toDate();
    } else {
      timestamp = DateTime.now();
    }

    return MessageBubble(
      senderName: senderName,
      text: text,
      isMe: isMe,
      timestamp: timestamp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(senderName, style: TextStyle(fontSize: 12, color: Colors.grey)),
          Material(
            elevation: 5,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
            color: isMe ? Color(0xFFDFABBB) : Colors.grey[300],
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Text(text,
                  style: TextStyle(
                      color: isMe ? Colors.white : Colors.black, fontSize: 15)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              DateFormat('yyyy-MM-dd – kk:mm').format(timestamp),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

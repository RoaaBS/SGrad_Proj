import 'package:flutter/material.dart';

class commentS extends StatelessWidget {
  // Dummy data for comments (you can replace with your actual data)
  final List<Map<String, String>> comments = [
    {"name": "hala_BS", "comment": "  رائع"},
    // {"name": "Lana", "comment": " متجر مميز "},
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'تعليقات المتجر',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFDFABBB), // لون خلفية العنوان باك جراوند
        ),
        body: CommentsList(comments: comments),
      ),
    );
  }
}

class CommentsList extends StatelessWidget {
  final List<Map<String, String>> comments;

  const CommentsList({required this.comments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200], // لون الخلفية للمستطيل
            borderRadius: BorderRadius.circular(10), // حواف مستديرة للمستطيل
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comments[index]['name']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                comments[index]['comment']!,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}

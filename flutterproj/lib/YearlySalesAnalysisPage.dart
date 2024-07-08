import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class YearlySalesAnalysisPage extends StatefulWidget {
  @override
  _YearlySalesAnalysisPageState createState() =>
      _YearlySalesAnalysisPageState();
}

class _YearlySalesAnalysisPageState extends State<YearlySalesAnalysisPage> {
  late Future<List<SalesData>> futureSalesData;

  @override
  void initState() {
    super.initState();
    futureSalesData = fetchYearlySales();
  }

  Future<List<SalesData>> fetchYearlySales() async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      throw Exception('Token not found');
    }
    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/stores/yearlysalesperformance'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      // Check if the decoded response is a list or a map containing a list
      if (jsonData is Map && jsonData.containsKey('salesData')) {
        // If the API returns a map with the data list nested under a key
        List<dynamic> salesList = jsonData['salesData'];
        return salesList.map((data) => SalesData.fromJson(data)).toList();
      } else if (jsonData is List) {
        // If the API directly returns a list of data
        return jsonData.map((data) => SalesData.fromJson(data)).toList();
      } else {
        throw Exception('Unexpected JSON format');
      }
    } else {
      throw Exception(
          'Failed to load yearly sales, status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yearly Sales Analysis"),
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: Center(
        child: FutureBuilder<List<SalesData>>(
          future: futureSalesData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              return Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: SalesPieChart(salesData: snapshot.data!),
                  ),
                  MonthLegend(),
                ],
              );
            } else {
              return Text("No data available");
            }
          },
        ),
      ),
    );
  }
}

class SalesData {
  final int month;
  final double totalSales;

  SalesData({required this.month, required this.totalSales});

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      month: json['month'],
      totalSales: json['totalSales'].toDouble(),
    );
  }
}

class SalesPieChart extends StatelessWidget {
  final List<SalesData> salesData;

  static const List<Color> monthColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.pink,
    Colors.teal,
    Colors.brown,
    Colors.cyan,
    Colors.lime,
    Colors.indigo
  ];

  SalesPieChart({required this.salesData});

  @override
  Widget build(BuildContext context) {
    double total = salesData.fold(0, (sum, item) => sum + item.totalSales);
    return PieChart(
      PieChartData(
        sections: salesData.map((data) {
          final percentage = (data.totalSales / total) * 100;
          return PieChartSectionData(
            color: monthColors[data.month - 1],
            value: data.totalSales,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            titlePositionPercentageOffset: 0.55,
          );
        }).toList(),
        centerSpaceRadius: 45,
        sectionsSpace: 2,
      ),
    );
  }
}

class MonthLegend extends StatelessWidget {
  static const List<Map<String, dynamic>> monthInfo = [
    {"abbr": "Jan", "color": Colors.red},
    {"abbr": "Feb", "color": Colors.blue},
    {"abbr": "Mar", "color": Colors.green},
    {"abbr": "Apr", "color": Colors.orange},
    {"abbr": "May", "color": Colors.purple},
    {"abbr": "Jun", "color": Colors.yellow},
    {"abbr": "Jul", "color": Colors.pink},
    {"abbr": "Aug", "color": Colors.teal},
    {"abbr": "Sep", "color": Colors.brown},
    {"abbr": "Oct", "color": Colors.cyan},
    {"abbr": "Nov", "color": Colors.lime},
    {"abbr": "Dec", "color": Colors.indigo}
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70), // Reduced padding
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10.0, // Reduced spacing
        runSpacing: 15.0, // Reduced run spacing
        children: monthInfo.map((month) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: month['color'],
                radius: 5,
              ),
              SizedBox(width: 5),
              Text(
                month['abbr'],
                style: TextStyle(fontSize: 12),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

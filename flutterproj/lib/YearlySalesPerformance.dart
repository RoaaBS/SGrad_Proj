import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'package:http/http.dart' as http;

class YearlySalesPerformanceScreen extends StatefulWidget {
  @override
  _YearlySalesPerformanceScreenState createState() =>
      _YearlySalesPerformanceScreenState();
}

class _YearlySalesPerformanceScreenState
    extends State<YearlySalesPerformanceScreen> {
  late Future<List<BarChartGroupData>> _chartData;
  List<String> monthLabels = [];

  @override
  void initState() {
    super.initState();
    _chartData = fetchSalesData();
  }

  Future<List<BarChartGroupData>> fetchSalesData() async {
    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/stores/yearbarlysalesperformance'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success' &&
          jsonResponse.containsKey('salesData')) {
        List<dynamic> salesData = jsonResponse['salesData'];
        monthLabels = salesData.map<String>((data) {
          return data['month'] ?? '';
        }).toList();

        double maxY = salesData
            .map<double>((data) => data['totalSales'].toDouble())
            .reduce(max);
        return List.generate(salesData.length, (index) {
          var monthData = salesData[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: monthData['totalSales'].toDouble(),
                color: Colors.blue,
              )
            ],
            showingTooltipIndicators: [0],
          );
        });
      } else {
        throw Exception('Unexpected response structure or status');
      }
    } else {
      throw Exception(
          'Failed to load sales data, status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تحليل المبيعات السنوي"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<BarChartGroupData>>(
          future: _chartData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: snapshot.data!
                          .map((e) => e.barRods.first.toY)
                          .reduce(max) *
                      1.6, // Slightly scale up the y-axis
                  barGroups: snapshot.data!,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(index < monthLabels.length
                                ? monthLabels[index]
                                : ''),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blue,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY}',
                          TextStyle(
                            color: Colors.white,
                            fontSize: 12, // Smaller font size
                          ),
                        );
                      },
                      tooltipPadding: const EdgeInsets.all(4),
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                    ),
                    enabled: true,
                  ),
                ),
              );
            }
            return Center(child: Text('No data available'));
          },
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutterproj/auth_storage.dart';
import 'package:flutterproj/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SalesPerformanceScreen extends StatefulWidget {
  @override
  _SalesPerformanceScreenState createState() => _SalesPerformanceScreenState();
}

class _SalesPerformanceScreenState extends State<SalesPerformanceScreen> {
  late Future<List<BarChartGroupData>> _chartData;
  List<String> dateLabels = [];
  DateTime? startDate;
  DateTime? endDate;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _chartData = fetchSalesData();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (picked != null && picked != (isStart ? startDate : endDate)) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<List<BarChartGroupData>> fetchSalesData() async {
    if (startDate == null || endDate == null) {
      throw Exception('Please select a start date and end date');
    }

    final token = await AuthStorage.getStoreToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse(
          '${Constants.apiUrl}/stores/performance?startDate=${formatter.format(startDate!)}&endDate=${formatter.format(endDate!)}'),
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
        dateLabels = salesData
            .map<String>((data) =>
                DateFormat('MMM d').format(DateTime.parse(data['date'])))
            .toList();
        double maxY = salesData
            .map<double>((data) => data['totalSales'].toDouble())
            .reduce(max);
        return List.generate(salesData.length, (index) {
          var dayData = salesData[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: dayData['totalSales'].toDouble(),
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

  void _fetchData() {
    setState(() {
      _chartData = fetchSalesData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تحليل المبيعات للفترة المحددة"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'تاريخ البداية',
                      hintText:
                          startDate != null ? formatter.format(startDate!) : '',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'تاريخ النهاية',
                      hintText:
                          endDate != null ? formatter.format(endDate!) : '',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, false),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _fetchData,
                  child: Text('عرض'),
                ),
              ],
            ),
            Expanded(
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
                                  child: Text(index < dateLabels.length
                                      ? dateLabels[index]
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
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartScreen extends StatelessWidget {
  final Map<String, double> dataMap;

  PieChartScreen({required this.dataMap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sales Pie Chart"),
        backgroundColor: Color(0xFFDFABBB),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PieChart(
                  dataMap: dataMap,
                  animationDuration: Duration(milliseconds: 800),
                  chartLegendSpacing: 32,
                  chartRadius: MediaQuery.of(context).size.width / 3.2,
                  colorList: [
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.yellow,
                    Colors.orange,
                    Colors.purple,
                    Colors.deepPurple,
                    Colors.teal,
                    Colors.indigo,
                    Colors.brown,
                    Colors.lightBlueAccent,
                    Colors.pink,
                  ],
                  initialAngleInDegree: 0,
                  chartType: ChartType.ring,
                  ringStrokeWidth: 50,
                  centerText: "Sales",
                  legendOptions: LegendOptions(
                    showLegendsInRow: false,
                    legendPosition: LegendPosition.right,
                    showLegends: true,
                    legendShape: BoxShape.circle,
                    legendTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  chartValuesOptions: ChartValuesOptions(
                    showChartValueBackground: false,
                    showChartValues: true,
                    showChartValuesInPercentage: false,
                    showChartValuesOutside: true,
                    decimalPlaces: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class Charts extends StatefulWidget {
  const Charts({super.key});

  @override
  State<Charts> createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<String> categoryNames = [];
  List<double> categoryExpenses = [];
  List<String> subCategoryNames = [];
  List<double> subCategoryExpenses = [];

  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    getCategoryData();
    getSubCategoryData();
  }

  Future<void> getCategoryData() async {
    QuerySnapshot snapshot = await db.collection('Gastos').get();

    Map<String, double> categoryTotals = {};
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime gastoFecha = (data['fecha'] as Timestamp).toDate();
      String categoryId = data['idCategoria'];
      double amount = data['monto']?.toDouble() ?? 0.0;

      if (selectedDateRange == null ||
          (gastoFecha.isAfter(selectedDateRange!.start) &&
              gastoFecha.isBefore(selectedDateRange!.end))) {
        categoryTotals.update(categoryId, (value) => value + amount, ifAbsent: () => amount);
      }
    }

    for (var categoryId in categoryTotals.keys) {
      DocumentSnapshot categorySnapshot = await db.collection('Categorias').doc(categoryId).get();
      if (categorySnapshot.exists) {
        String categoryName = categorySnapshot['nombre'];
        categoryNames.add(categoryName);
        categoryExpenses.add(categoryTotals[categoryId]!);
      }
    }
    setState(() {});
  }

  Future<void> getSubCategoryData() async {
    QuerySnapshot snapshot = await db.collection('Gastos').get();

    Map<String, double> subCategoryTotals = {};
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime gastoFecha = (data['fecha'] as Timestamp).toDate();
      String subCategoryId = data['idSubCategoria'];
      double amount = data['monto']?.toDouble() ?? 0.0;

      if (selectedDateRange == null ||
          (gastoFecha.isAfter(selectedDateRange!.start) &&
              gastoFecha.isBefore(selectedDateRange!.end))) {
        subCategoryTotals.update(subCategoryId, (value) => value + amount, ifAbsent: () => amount);
      }
    }

    for (var subCategoryId in subCategoryTotals.keys) {
      DocumentSnapshot subCategorySnapshot = await db.collection('SubCategorias').doc(subCategoryId).get();
      if (subCategorySnapshot.exists) {
        String subCategoryName = subCategorySnapshot['nombre'];
        subCategoryNames.add(subCategoryName);
        subCategoryExpenses.add(subCategoryTotals[subCategoryId]!);
      }
    }
    setState(() {});
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: selectedDateRange,
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      getCategoryData();
      getSubCategoryData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gráficas de Gastos"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: categoryNames.isEmpty || subCategoryNames.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Gastos por Categoría",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 38,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < categoryNames.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8.0,
                                child: Text(
                                  categoryNames[index],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    barGroups: _createBarGroups(categoryNames, categoryExpenses),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Gastos por SubCategoría",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 300,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: subCategoryNames.length * 80,
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 38,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < subCategoryNames.length) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 8.0,
                                    child: Text(
                                      subCategoryNames[index],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        barGroups: _createBarGroups(subCategoryNames, subCategoryExpenses),
                        barTouchData: BarTouchData(enabled: false),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _selectDateRange(context);
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.date_range, color: Colors.pinkAccent),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(List<String> labels, List<double> values) {
    return List.generate(labels.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: values[index],
            color: _getBarColor(index),
            width: 25,
            borderRadius: BorderRadius.circular(8),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: values.reduce((a, b) => a + b) * 1.1,
              color: Colors.grey[300]!,
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  Color _getBarColor(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }
}







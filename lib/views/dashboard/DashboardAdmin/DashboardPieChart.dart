import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/services/market/productService.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:Athlify/services/club.dart';
import 'package:Athlify/services/trainer.dart';
import 'package:Athlify/services/getUserType.dart';

class DashboardAnalyticsCard extends StatefulWidget {
  const DashboardAnalyticsCard({super.key});

  @override
  State<DashboardAnalyticsCard> createState() => _DashboardAnalyticsCardState();
}

class _DashboardAnalyticsCardState extends State<DashboardAnalyticsCard> {
  int userCount = 0;
  int clubCount = 0;
  int trainerCount = 0;
  int productCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final clubs = await ClubService().getClubs();
      final trainers = await TrainerService().getTrainers();
      final users = await UserService().getAllUsers();
      final products = await ProductService().getProducts();
      setState(() {
        clubCount = clubs.length;
        trainerCount = trainers.length;
        userCount = users.length;
        productCount = products.length;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  double getPercentage(int part, int total) =>
      total == 0 ? 0 : (part / total) * 100;

  @override
  Widget build(BuildContext context) {
    final total = clubCount + trainerCount + productCount;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: PrimaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: SecondaryContainerText,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Users\n$userCount",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Orders\n number",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🟠 Pie Chart inside Card
          SizedBox(
            height: 60,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(23),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 230,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: clubCount.toDouble(),
                          title:
                              '${getPercentage(clubCount, total).toStringAsFixed(1)}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        PieChartSectionData(
                          color: Colors.blue,
                          value: trainerCount.toDouble(),
                          title:
                              '${getPercentage(trainerCount, total).toStringAsFixed(1)}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        PieChartSectionData(
                          color: Colors.orange,
                          value: productCount.toDouble(),
                          title:
                              '${getPercentage(productCount, total).toStringAsFixed(1)}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 👇 البيانات التفصيلية (اسم + عدد + Progress Bar)
                detailItem("Clubs", clubCount, Colors.green,
                    getPercentage(clubCount, total)),
                detailItem("Trainers", trainerCount, Colors.blue,
                    getPercentage(trainerCount, total)),
                detailItem("Products", productCount, Colors.orange,
                    getPercentage(productCount, total)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget detailItem(String label, int value, Color color, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(radius: 6, backgroundColor: color),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text("$label ($value)"),
          ),
          Expanded(
            flex: 5,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

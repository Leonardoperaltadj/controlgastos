import 'package:controlgastos/Bills.dart';
import 'package:controlgastos/Budgets.dart';
import 'package:controlgastos/Category.dart';
import 'package:controlgastos/Charts.dart';
import 'package:flutter/material.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Container(
        decoration:const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
           const DrawerHeader(
                decoration:  BoxDecoration(
                  color: Colors.pinkAccent,
                ),
                child: Column(
                  children: [
                    Text(
                      "Menú",
                      style:  TextStyle(color: Colors.white),
                    ),
                  ],
                )),
            ListTile(
              leading: const Icon(Icons.account_tree),
              title: const Text('Categorias'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Category()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Presupuesto'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Budgets()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on_rounded),
              title: const Text('Gastos'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Bills()),
                );
                setState(() {
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Graficas'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Charts()),
                );
                setState(() {
                });
              },
            ),
          ],
        ),
      ),

    );
  }
}

import 'package:controlgastos/NewBudgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Budgets extends StatefulWidget {
  const Budgets({super.key});

  @override
  State<Budgets> createState() => _BudgetsState();
}

class _BudgetsState extends State<Budgets> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getBudgets() async {
    List<Map<String, dynamic>> budgets = [];
    CollectionReference collectionReference = db.collection("Presupuestos");
    QuerySnapshot queryCategory = await collectionReference.get();

    for (var documento in queryCategory.docs) {
      Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
      data['id'] = documento.id;

      var names = await getCategoryNames(data["idCategoria"] ?? "");
      data['nombreCategoria'] = names["category"];

      budgets.add(data);
    }
    return budgets;
  }

  Future<Map<String, String>> getCategoryNames(String categoryId) async {
    String categoryName = "No especificada";

    if (categoryId.isNotEmpty) {
      DocumentSnapshot categorySnapshot = await db.collection("Categorias").doc(categoryId).get();
      if (categorySnapshot.exists) {
        categoryName = categorySnapshot["nombre"];
      }
    }

    return {
      "category": categoryName,
    };
  }

  Future<void> deleteBudgets(String uid) async {
    await db.collection("Presupuestos").doc(uid).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Presupuestos"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getBudgets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay registros.'));
            }

            final bills = snapshot.data!;

            return ListView.builder(
              itemCount: bills.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(bills[index]["id"]),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Icon(Icons.delete)],
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("¿Está seguro de eliminar?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Sí, estoy seguro"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    await deleteBudgets(bills[index]["id"]);
                    setState(() {
                      bills.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Registro eliminado")),
                    );
                  },
                  child: SizedBox(
                    height: 150,
                    child: InkWell(
                      onTap: () async{
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewBudgets(
                              uid: bills[index]["id"],
                              uidCategory: bills[index]["idCategoria"] ?? "",
                              amount: bills[index]["monto"] ?? null,
                              date: (bills[index]["fecha_inicial"] as Timestamp?)?.toDate() ?? null,
                              dateEnd: (bills[index]["fecha_final"] as Timestamp?)?.toDate() ?? null,

                            ),
                          ),
                        );
                        setState(() {});
                      },
                      child: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(

                                children: [
                                  Text(
                                    "Fecha inicial: ${(bills[index]["fecha_inicial"] as Timestamp?)?.toDate().toLocal().toString().split(' ')[0] ?? "No especificada"}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Fecha final: ${(bills[index]["fecha_final"] as Timestamp?)?.toDate().toLocal().toString().split(' ')[0] ?? "No especificada"}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Monto: ${bills[index]["monto"]?.toString() ?? ""}",
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Categoría: ${bills[index]["nombreCategoria"] ?? "No especificada"}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewBudgets(
                uid: "",
                uidCategory: "",
                amount: null,
                date: null,
                dateEnd: null,
              ),
            ),
          );
          setState(() {});
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.pinkAccent),
      ),
    );
  }
}

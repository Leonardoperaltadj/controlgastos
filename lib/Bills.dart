import 'package:controlgastos/NewBills.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Bills extends StatefulWidget {
  const Bills({super.key});

  @override
  State<Bills> createState() => _BillsState();
}

class _BillsState extends State<Bills> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<Map<String, String>> getCategoryAndSubcategoryNames(String categoryId, String subcategoryId) async {
    String categoryName = "No especificada";
    String subcategoryName = "No especificada";


    if (categoryId.isNotEmpty) {
      DocumentSnapshot categorySnapshot = await db.collection("Categorias").doc(categoryId).get();
      if (categorySnapshot.exists) {
        categoryName = categorySnapshot["nombre"];
      }
    }


    if (subcategoryId.isNotEmpty) {
      DocumentSnapshot subcategorySnapshot = await db.collection("SubCategorias").doc(subcategoryId).get();
      if (subcategorySnapshot.exists) {
        subcategoryName = subcategorySnapshot["nombre"];
      }
    }

    return {
      "category": categoryName,
      "subcategory": subcategoryName,
    };
  }

  Future<List<Map<String, dynamic>>> getBills() async {
    List<Map<String, dynamic>> bills = [];
    CollectionReference collectionReference = db.collection("Gastos");
    QuerySnapshot queryCategory = await collectionReference.get();

    for (var documento in queryCategory.docs) {
      Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
      data['id'] = documento.id;

      var names = await getCategoryAndSubcategoryNames(data["idCategoria"] ?? "", data["idSubCategoria"] ?? "");
      data['nombreCategoria'] = names["category"];
      data['nombreSubcategoria'] = names["subcategory"];

      bills.add(data);
    }
    return bills;
  }

  Future<void> deleteBill(String uid) async {
    await db.collection("Gastos").doc(uid).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gastos"),
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
          future: getBills(),
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
                    await deleteBill(bills[index]["id"]);
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
                            builder: (context) => NewBills(
                              uid: bills[index]["id"],
                              uidCategory: bills[index]["idCategoria"] ?? "",
                              uidSubCategory: bills[index]["idSubCategoria"] ?? "",
                              amount: bills[index]["monto"] ?? null,
                              date: (bills[index]["fecha"] as Timestamp?)?.toDate() ?? null,
                              detail: bills[index]["observaciones"] ?? "",
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
                                    "Monto: ${bills[index]["monto"]?.toString() ?? ""}",
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Categoría: ${bills[index]["nombreCategoria"] ?? "No especificada"}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "Subcategoría: ${bills[index]["nombreSubcategoria"] ?? "No especificada"}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "Fecha: ${(bills[index]["fecha"] as Timestamp?)?.toDate().toLocal().toString().split(' ')[0] ?? "No especificada"}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Detalles: ${bills[index]["observaciones"]?.toString() ?? "No hay detalles"}",
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
              builder: (context) => const NewBills(
                uid: "",
                uidCategory: "",
                uidSubCategory: "",
                amount: null,
                date: null,
                detail: "",
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





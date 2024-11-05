import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class NewBills extends StatefulWidget {
  final String uid;
  final String uidCategory;
  final String uidSubCategory;
  final double? amount;
  final DateTime? date;
  final String detail;

  const NewBills({
    super.key,
    required this.uid,
    required this.uidCategory,
    required this.uidSubCategory,
    required this.amount,
    required this.date,
    required this.detail,
  });

  @override
  State<NewBills> createState() => _NewBillsState();
}
class _NewBillsState extends State<NewBills> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController txtAmount = TextEditingController();
  final TextEditingController txtDetail = TextEditingController();

  DateTime? dateSelected;
  DateTime? dateSelected1;
  DateTime? dateSelected2;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> category = [];
  List<Map<String, dynamic>> subCategory = [];
  String? selectedCategory;
  String? selectedSubCategory;
  double? amountBudgets = 0;
  double? amountView;
  Color color = Colors.white;
  String? message;
  bool isButtonDisabled = false;
  bool isTextDisabled = true;
  String? idSubCategory;
  String? idBudgets;
  DateTime? date;

  Future<void> updateBudgets(String uid, String category, double amount) async {
    DocumentSnapshot documentSnapshot = await db.collection("Presupuestos").doc(uid).get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> currentData = documentSnapshot.data() as Map<String, dynamic>;

      await db.collection("Presupuestos").doc(uid).update({
        "idCategoria": category,
        "monto": amount,
        "fecha_inicial": currentData['fecha_inicial'],
        "fecha_final": currentData['fecha_final'],
      });
    }
  }


  Future<void> getBudgetsByCategory(String categoryId) async {
    List<Map<String, dynamic>> subCategory = [];

    if (categoryId.isNotEmpty) {
      QuerySnapshot categorySnapshot = await db
          .collection("Presupuestos")
          .where("idCategoria", isEqualTo: categoryId)
          .get();
      categorySnapshot.docs.forEach((documento) {
        Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
        data['id'] = documento.id;
        subCategory.add(data);
      });
      setState(() {
        subCategory.forEach((value) {
          if (value.isNotEmpty) {
            print(value['monto']);
            amountBudgets = amountBudgets! + value['monto'];
            amountView = amountBudgets;
            //message = 'Saldo disponible:${amountView ?? ''} ';
            color = Colors.white;
            idSubCategory = value["idCategoria"];
            idBudgets = value['id'];
            dateSelected1 = value['fecha_inicial'].toDate();
            dateSelected = dateSelected1;
            dateSelected2 = value['fecha_final'].toDate();
          }
        });
      });
    }
  }


  Future<void> addBills(String category, String subcategory, double amount,
      DateTime date, String details) async {
    await db.collection("Gastos").add({
      "idCategoria": category,
      "idSubCategoria": subcategory,
      "monto": amount,
      "fecha": DateTime(date.year, date.month, date.day),
      "observaciones": details,
    });
  }

  Future<void> updateBills(String uid, String category, String subcategory,
      double amount, DateTime date, String details) async {
    await db.collection("Gastos").doc(uid).set({
      "idCategoria": category,
      "idSubCategoria": subcategory,
      "monto": amount,
      "fecha": DateTime(date.year, date.month, date.day),
      "observaciones": details,
    });
  }

  Future<void> getCategory() async {
    CollectionReference collectionReferenceCategory = db.collection("Categorias");
    QuerySnapshot queryCategory = await collectionReferenceCategory.get();

    setState(() {
      category = queryCategory.docs.map((documento) {
        Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
        data['id'] = documento.id;
        return data;
      }).toList();
    });
  }

  Future<void> getSubCategory(String idCategory) async {
    CollectionReference collectionReferenceSubCategory = db.collection("SubCategorias");
    QuerySnapshot querySubCategory = await collectionReferenceSubCategory.where('idCategoria', isEqualTo: idCategory).get();

    setState(() {
      subCategory = querySubCategory.docs.map((documento) {
        Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
        data['id'] = documento.id;
        return data;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getBudgetsByCategory(widget.uidCategory);
    getCategory().then((_) {
      if (widget.uid.isNotEmpty) {
        setState(() {
          txtAmount.text = widget.amount.toString();
          txtDetail.text = widget.detail;
          selectedCategory = widget.uidCategory;
          selectedSubCategory = widget.uidSubCategory;
          dateSelected = widget.date;
          getSubCategory(widget.uidCategory);
          print(amountBudgets);
          print('${amountBudgets! -double.parse(widget.amount.toString()) }');
          message = 'Saldo disponible:${amountBudgets! -double.parse(widget.amount.toString()) }';
        });
      }
    });
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Gastos',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Selecciona una Categoría',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: category.map((value) {
                    return DropdownMenuItem<String>(
                      value: value['id'],
                      child: Text(value['nombre']),
                    );
                  }).toList(),
                  onChanged: (newValue) async {
                    setState(() {
                      selectedCategory = newValue;
                      amountBudgets = 0;
                      amountView = 0;
                      selectedSubCategory = null;
                    });
                    await getSubCategory(newValue!);
                    await getBudgetsByCategory(newValue);
                    setState(() {
                      print("es:${amountBudgets.toString()}");
                    });
                  },
                ),
                const SizedBox(height: 25),
                DropdownButtonFormField<String>(
                  value: selectedSubCategory,
                  decoration: InputDecoration(
                    labelText: 'Selecciona una subcategoría',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: subCategory.map((value) {
                    return DropdownMenuItem<String>(
                      value: value['id'],
                      child: Text(value['nombre']),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedSubCategory = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione una opción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: () async {
                    setState(() {

                    });
                    dateSelected = await showOmniDateTimePicker(context: context);
                    amountView = amountBudgets;
                    if (dateSelected != null) {
                      dateSelected = DateTime(dateSelected!.year, dateSelected!.month, dateSelected!.day);
                      print("Fecha seleccionada: $dateSelected");

                      if (dateSelected!.isBefore(dateSelected1!) || dateSelected!.isAfter(dateSelected2!)) {
                        setState(() {
                          message = 'No hay presupuesto en el rango de fecha seleccionado';
                          color = Colors.red;
                          isButtonDisabled = true;
                          isTextDisabled = false;
                        }
                        );
                      } else {
                        setState(() {
                          message = 'Saldo disponible:${amountView ?? ''} ';
                          color = Colors.white;
                          isButtonDisabled = false;
                          isTextDisabled = true;
                        });
                      }

                      setState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      dateSelected != null
                          ? 'Fecha: ${dateSelected!.toLocal().toString().split(' ')[0]}'
                          : 'Seleccione Fecha y Hora',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: txtAmount,
                  decoration: InputDecoration(
                    labelText: 'Monto',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  enabled: isTextDisabled,
                  onChanged: (value) {
                      setState(() {});
                      if (value.isEmpty) {
                        color = Colors.white;
                        amountView = amountBudgets;
                        message = 'Saldo disponible:${amountView ?? ''} ';
                        isButtonDisabled = false;
                      } else {
                        double d = double.parse(value);
                        if (d <= amountBudgets!) {
                          color = Colors.white;
                          amountView = amountBudgets! - d;
                          message = 'Saldo disponible:${amountView ?? ''} ';
                          isButtonDisabled = false;
                        } else {
                          color = Colors.red;
                          amountView = amountBudgets! - d;
                          message =
                          'Ingresa un monto menor o igual a tu presupuesto: $amountBudgets';
                          isButtonDisabled = false;
                        }
                      }

                      setState(() {});
                    },
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, llene este campo';
                    }
                    return null;
                  },
                ),

                Text(
                  message ?? "",
                  style: TextStyle(
                    color: color,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: txtDetail,
                  decoration: InputDecoration(
                    labelText: 'Observaciones',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, llene este campo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isButtonDisabled
                      ? null
                      : () {
                    if (_formKey.currentState!.validate()) {
                      if (widget.uid.isEmpty) {
                        addBills(
                          selectedCategory!,
                          selectedSubCategory!,
                          double.parse(txtAmount.text),
                          dateSelected!,
                          txtDetail.text,
                        );
                        print(idSubCategory);
                        updateBudgets(idBudgets!, idSubCategory!, amountView!);
                      } else {
                        updateBills(
                          widget.uid,
                          selectedCategory!,
                          selectedSubCategory!,
                          double.parse(txtAmount.text),
                          dateSelected!,
                          txtDetail.text,
                        );
                        updateBudgets(idBudgets!, idSubCategory!, amountView!);
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    widget.uid.isEmpty ? 'Aceptar' : 'Actualizar',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


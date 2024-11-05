import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';


class NewBudgets extends StatefulWidget {
  final String uid;
  final String uidCategory;
  final double? amount;
  final DateTime? date;
  final DateTime? dateEnd;

  const NewBudgets({
    super.key,
    required this.uid,
    required this.uidCategory,
    this.amount,
    this.date,
    this.dateEnd
  });

  @override
  State<NewBudgets> createState() => _NewBudgetsState();
}

class _NewBudgetsState extends State<NewBudgets> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController txtAmount = TextEditingController();

  DateTime? dateSelected;
  DateTime? dateSelected2;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> category = [];
  String? selectedCategory;

  Future<void> addBudgets(String category, double amount, DateTime fecha1, DateTime fecha2) async {
    await db.collection("Presupuestos").add({
      "idCategoria": category,
      "monto": amount,
      "fecha_inicial": fecha1,
      "fecha_final": fecha2,
    });
  }

  Future<void> updateBudgets(String uid, String category, double amount,fecha1, DateTime fecha2) async {
    await db.collection("Presupuestos").doc(uid).set({
      "idCategoria": category,
      "monto": amount,
      "fecha_inicial": fecha1,
      "fecha_final": fecha2,
    });
  }

  Future<void> getCategory() async {
    CollectionReference collectionReferenceCategory = db.collection("Categorias");
    QuerySnapshot queryCategory = await collectionReferenceCategory.get();

    setState(() {
      category = queryCategory.docs.map((document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        data['id'] = document.id;
        return data;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getCategory().then((_) {
      if (widget.uid.isNotEmpty) {
        setState(() {
          txtAmount.text = widget.amount.toString();
          selectedCategory = widget.uidCategory;
          dateSelected = widget.date;
          dateSelected2 = widget.dateEnd;
        });
      }
    });
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Presupuestos',
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
                    labelStyle: TextStyle(color: Colors.white),
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
                  onChanged: (newValue) {
                    setState(() {
                      selectedCategory = newValue;
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
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, llene este campo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    dateSelected =
                    await showOmniDateTimePicker(context: context);
                    print("Fecha seleccionada: $dateSelected");
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      dateSelected != null
                          ? 'Fecha: ${dateSelected!.toLocal().toString().split(' ')[0]}'
                          : 'Seleccione Fecha y Hora inicial',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    dateSelected2 =
                    await showOmniDateTimePicker(context: context);
                    print("Fecha seleccionada: $dateSelected2");
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      dateSelected2 != null
                          ? 'Fecha: ${dateSelected2!.toLocal().toString().split(' ')[0]}'
                          : 'Seleccione Fecha y Hora final',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: () async {
                    double? amount;
                    if (txtAmount.text.isNotEmpty) {
                      amount = double.tryParse(txtAmount.text);
                    }

                    if (amount == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Por favor ingrese un monto válido')),
                      );
                      return;
                    }

                    if (widget.uid.isNotEmpty) {
                      await updateBudgets(
                        widget.uid,
                        selectedCategory!,
                        amount,
                        dateSelected, dateSelected2!
                      ).then((_) {
                        Navigator.pop(context);
                      });
                    } else {
                      await addBudgets(
                        selectedCategory!,
                        amount,dateSelected!, dateSelected2!
                      ).then((_) {
                        Navigator.pop(context);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.pinkAccent,
                  ),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

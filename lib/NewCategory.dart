import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewCategory extends StatefulWidget {
  final String uid;
  final String name;
  const NewCategory({super.key, required this.uid, required this.name});

  @override
  State<NewCategory> createState() => _NewCategoryState();
}

class _NewCategoryState extends State<NewCategory> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController txtNombre = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> addCategory(String name) async{
    await db.collection("Categorias").add({ "nombre": name});
  }

  Future<void> updateCategory(String uid, String name)  async {
    await db.collection("Categorias").doc(uid).set({ "nombre": name});
  }

  @override
  void initState() {
    super.initState();
    if (widget.uid != "") {
      setState(() {
        txtNombre.text = widget.name;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categoria"),
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
                  'Categoria',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: txtNombre,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
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
                  onPressed: () async {
                    if (widget.uid != "") {
                      await updateCategory(widget.uid,txtNombre.text).then((_){
                        Navigator.pop(context);
                      });
                    }else{
                      await addCategory(txtNombre.text).then((_){
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

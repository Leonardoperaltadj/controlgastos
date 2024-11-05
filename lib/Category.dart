import 'package:controlgastos/NewCategory.dart';
import 'package:controlgastos/SubCategory.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Category extends StatefulWidget {
  const Category({super.key});
  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getCategory() async {
    List<Map<String, dynamic>> category = [];
    CollectionReference CollectionReferenceCategory = db.collection("Categorias");
    QuerySnapshot querycategory = await CollectionReferenceCategory.get();

    querycategory.docs.forEach((documento) {
      Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
      data['id'] = documento.id;
      category.add(data);
    });

    return category;
  }

  Future<void> deleteCategory(String uid)async{
    await db.collection("Categorias").doc(uid).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categorias"),
      ),
      body: Container(
        decoration:const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder(
          future: getCategory(),
          builder:(context,snapshot){
            if(snapshot.hasData){
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context,index){
                  return Dismissible(
                    onDismissed: (direction) async{
                      await deleteCategory(snapshot.data?[index]["id"]);
                      snapshot.data?.removeAt(index);
                    },
                    confirmDismiss: (direction) async{
                      if (direction == DismissDirection.endToStart){
                      bool result = false;
                      result = await showDialog(context: context, builder: (context){
                        return  AlertDialog(
                          title: const Text("¿Está seguro de eliminar?"),
                          actions: [
                            TextButton(onPressed: (){
                              return Navigator.pop(
                                context,
                                false,
                              );
                            }, child: const Text("Cancelar")),
                            TextButton(onPressed: (){
                              return Navigator.pop(
                                context,
                                true,
                              );
                            }, child: const Text("Si, estoy seguro"))
                          ],
                        );
                      });
                      return result;
                      }else if (direction == DismissDirection.startToEnd) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubCategory(idCategory:snapshot.data?[index]["id"]),
                          ),
                        );
                        return false;
                      }
                      return false;
                    },
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 30),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                        children:[
                           Icon(Icons.delete)
                        ]
                      ),
                    ),

                    key: Key(snapshot.data?[index]["id"]),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    title: Text(
                        snapshot.data?[index]["nombre"],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    onTap: () async{
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewCategory(uid: snapshot.data?[index]["id"], name: snapshot.data?[index]["nombre"]?.toString() ?? ""),
                        ),
                      );
                      setState(() {
                      });
                    },
                  ),
                  ),
                  );
                },
              );
            }else{
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),),
        floatingActionButton:
             FloatingActionButton(
          onPressed: () async {
           await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NewCategory(uid: "",name: "",)),
            );
           setState(() {
           });
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.add, color: Colors.pinkAccent),
        ),

    );
  }
}

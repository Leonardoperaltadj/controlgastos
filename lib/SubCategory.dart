import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:controlgastos/NewSubCategory.dart';
import 'package:flutter/material.dart';

class SubCategory extends StatefulWidget {
  final String idCategory;
  const SubCategory({super.key,required this.idCategory});

  @override
  State<SubCategory> createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getSubCategory() async {
    List<Map<String, dynamic>> subCategory = [];
    CollectionReference CollectionReferenceCategory = db.collection("SubCategorias");
    QuerySnapshot querycategory = await CollectionReferenceCategory.where('idCategoria', isEqualTo: widget.idCategory).get();

    querycategory.docs.forEach((documento) {
      Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
      data['id'] = documento.id;
      subCategory.add(data);
    });

    return subCategory;
  }

  Future<void> deleteCategory(String uid)async{
    await db.collection("SubCategorias").doc(uid).delete();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sub Categorias"),
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
              future: getSubCategory(),
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
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete),
                        ),
                        direction: DismissDirection.endToStart,
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
                                  builder: (context) => NewSubCategory(uid: snapshot.data?[index]["id"], name: snapshot.data?[index]["nombre"]?.toString() ?? "",idCategory: widget.idCategory),
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
                  builder: (context) =>  NewSubCategory(uid: "",name: "",idCategory: widget.idCategory)),
            );
            setState(() {
            });
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.add, color: Colors.pinkAccent),
        )
    );
  }
}


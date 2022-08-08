import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barbershop/model/image_model.dart';

Future<List<ImageModel>> getLookbook() async{
  List<ImageModel> result= List<ImageModel>.empty(growable: true);
  CollectionReference bannerRef=FirebaseFirestore.instance.collection('Lookbook');
  QuerySnapshot snapshot=await bannerRef.get();
  snapshot.docs.forEach((element) {
    result.add(ImageModel.fromJson(element.data() as Map<String,dynamic>));
  });
  return result;
}
import 'package:cloud_firestore/cloud_firestore.dart';

class BarberModel {
  String  name='';
  String? docId='';
  double raiting=0;
  int raitingTimes=0;
  DocumentReference? reference;


  BarberModel();



  /*BarberModel.empty(){
    this.docId=null;
  }*/

  BarberModel.fromJson(Map<String, dynamic> json) {
    //userName = json['userName'];
    name = json['name'];
    raiting=double.parse(json['raiting']==null?'0':json['raiting'].toString());
    raitingTimes=int.parse(json['raitingTimes']==null?'0':json['raitingTimes'].toString());
  }

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data=new Map<String,dynamic>();
    //data['userName']=this.userName;
    data['name'] =this.name;
    data['raiting'] =this.raiting;
    data['raitingTimes'] =this.raitingTimes;
    return data;
  }
}

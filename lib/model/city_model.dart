import 'package:flutter/cupertino.dart';

class CityModel {
  String name='';

  CityModel({required this.name});

  /*CityModel.empty(){
    this.name=null;
  }*/

  CityModel.fromJson(Map<String, dynamic> json) {
    //address = json['address'];
    name = json['name'];
  }

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data=new Map<String,dynamic>();
    //data['address']=this.address;
    data['name'] =this.name;
    return data;
  }

  @override
  int get hashCode {
    //return hashValues(name, i) для нескольких переменных
    return name.hashCode;
  }

  @override
  bool operator ==(Object other) =>
    other is CityModel &&
        other.runtimeType == runtimeType &&
        other.name == name;

}
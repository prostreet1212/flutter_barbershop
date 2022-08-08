import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_barbershop/model/barber_model.dart';
import 'package:flutter_barbershop/model/salon_model.dart';
import 'package:flutter_barbershop/state/state_management.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../model/booking_model.dart';
import '../model/city_model.dart';

Future<List<CityModel>> getCities() async {
  var cities = new List<CityModel>.empty(growable: true);
  var cityRef = FirebaseFirestore.instance.collection('AllSalon');
  var snapshot = await cityRef.get();
  snapshot.docs.forEach((element) {
    cities.add(CityModel.fromJson(element.data()));
  });
  return cities;
}

Future<List<SalonModel>> getSalonByCity(String cityName) async {
  var salons = new List<SalonModel>.empty(growable: true);
  var salonRef = FirebaseFirestore.instance
      .collection('AllSalon')
      .doc(cityName.replaceAll(' ', ''))
      .collection('Branch');
  var snapshot = await salonRef.get();
  snapshot.docs.forEach((element) {
    var salon = SalonModel.fromJson(element.data());
    salon.docId = element.id;
    salon.reference = element.reference;
    salons.add(salon);
  });
  return salons;
}

Future<List<BarberModel>> getBarberBySalon(SalonModel salon) async {
  var barbers = new List<BarberModel>.empty(growable: true);
  var barberRef = salon.reference!.collection('Barber');
  var snapshot = await barberRef.get();
  snapshot.docs.forEach((element) {
    var barber = BarberModel.fromJson(element.data());
    barber.docId = element.id;
    barber.reference = element.reference;
    barbers.add(barber);
  });
  return barbers;
}

Future<List<int>> getTimeslotOfBarber(
    BarberModel barberModel, String date) async {
  List<int> result = new List<int>.empty(growable: true);
  var bookingRef = barberModel.reference!.collection(date);
  QuerySnapshot snapshot = await bookingRef.get();
  snapshot.docs.forEach((element) {
    result.add(int.parse(element.id));
  });
  return result;
}

Future<bool> checkStaffOfThisSalon(BuildContext context) async {
  DocumentSnapshot barberSnapshot = await FirebaseFirestore.instance
      .collection('AllSalon')
      .doc('${context.read(selectedCity).state.name}')
      .collection('Branch')
      .doc(context.read(selectedSalon).state.docId)
      .collection('Barber')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  return barberSnapshot.exists;
}

Future<List<int>> getBookingSlotOfBarber(
    BuildContext context, String date) async {
  var barberDocument = FirebaseFirestore.instance
      .collection('AllSalon')
      .doc('${context.read(selectedCity).state.name}')
      .collection('Branch')
      .doc(context.read(selectedSalon).state.docId)
      .collection('Barber')
      .doc(FirebaseAuth.instance.currentUser!.uid);
  List<int> result = List<int>.empty(growable: true);
  var bookingRef = barberDocument.collection((date));
  QuerySnapshot snapshot = await bookingRef.get();
  snapshot.docs.forEach((element) {
    result.add(int.parse(element.id));
  });
  return result;
}

Future<BookingModel> getDetailBooking(
    BuildContext context, int timeSlot) async {
  CollectionReference userRef = FirebaseFirestore.instance
      .collection('AllSalon')
      .doc(context.read(selectedCity).state.name)
      .collection('Branch')
      .doc(context.read(selectedSalon).state.docId)
      .collection('Barber')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection(
          DateFormat('dd_MM_yyyy').format(context.read(selectedDate).state));
  DocumentSnapshot snapshot = await userRef.doc(timeSlot.toString()).get();
  if (snapshot.exists) {
    var bookingModel =
        BookingModel.fromJson(json.decode(json.encode(snapshot.data())));
    bookingModel.docId = snapshot.id;
    bookingModel.reference = snapshot.reference;
    context.read(selectedBooking).state = bookingModel;
    return bookingModel;
  } else
    return BookingModel(
        totalPrice: 0,
        customerName: '',
        time: '',
        timeStamp: 0,
        slot: 0,
        done: false,
        barberName: '',
        salonName: '',
        salonId: '',
        salonAddress: '',
        customerPhone: '',
        cityBook: '',
        barberId: '',
        customerId: '');
}

Future<List<BookingModel>> getBarberBookingHistory(
    BuildContext context, DateTime dateTime) async {
  var listBooking = List<BookingModel>.empty(growable: true);
  var barberDocument = FirebaseFirestore.instance
      .collection('AllSalon')
      .doc('${context.read(selectedCity).state.name}')
      .collection('Branch')
      .doc('${context.read(selectedSalon).state.docId}')
      .collection('Barber')
      .doc('${FirebaseAuth.instance.currentUser!.uid}')
      .collection(DateFormat('dd_MM_yyyy').format(dateTime));
  var snapshot = await barberDocument.get();
  snapshot.docs.forEach((element) {
    var barberBooking = BookingModel.fromJson(element.data());
    barberBooking.docId = element.id;
    barberBooking.reference = element.reference;
    listBooking.add(barberBooking);
  });
  return listBooking;
}

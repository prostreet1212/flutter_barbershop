
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_barbershop/model/barber_model.dart';
import 'package:flutter_barbershop/model/booking_model.dart';
import 'package:flutter_barbershop/model/city_model.dart';
import 'package:flutter_barbershop/model/salon_model.dart';
import 'package:flutter_barbershop/model/service_model.dart';
import 'package:flutter_barbershop/model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final userLogged=StateProvider((ref)=>FirebaseAuth.instance.currentUser);
final userToken=StateProvider((ref)=>'');
final forceReload=StateProvider((ref)=>false);

final userInformation=StateProvider((ref)=>UserModel(name: '', address: ''));


//Booking state
final currentStep=StateProvider((ref)=>1);
final selectedCity=StateProvider((ref)=>CityModel(name: ''));
final selectedSalon=StateProvider((ref)=>SalonModel(name: '', address: ''));
final selectedBarber=StateProvider((ref)=>BarberModel());
final selectedDate=StateProvider((ref)=>DateTime.now());
final selectedTimeSlot=StateProvider((ref)=>-1);
final selectedTime=StateProvider((ref)=>'');

//Delete BookingModel
StateProvider<bool> deleteFlagRefresh=StateProvider((ref)=>false);

//Staff
StateProvider<int> staffStep=StateProvider((ref)=>1);
final selectedBooking=StateProvider((ref)=>BookingModel(totalPrice: 0,
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
    customerId: '')
);




final selectedServices=
StateProvider((ref)=>List<ServiceModel>.empty(growable: true));

//Loading
final isLoading=StateProvider((ref)=>false);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auth_ui/flutter_auth_ui.dart';
import 'package:flutter_barbershop/fcm/fcm_notification_handler.dart';
import 'package:flutter_barbershop/screens/booking_screen.dart';
import 'package:flutter_barbershop/screens/done_services_screen.dart';
import 'package:flutter_barbershop/screens/home_screen.dart';
import 'package:flutter_barbershop/screens/staff_home_screen.dart';
import 'package:flutter_barbershop/screens/user_history_screen.dart';

import 'package:flutter_barbershop/state/state_management.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'fcm/fcm_background_handler.dart';
import 'screens/barber_booking_history_screen.dart';
import 'utils/utils.dart';

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
AndroidNotificationChannel? channel;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  //Flutter Local Notifications
flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();
channel=const AndroidNotificationChannel('prostreet1212.com', 'andoid chanel','?',
    importance: Importance.max);
await flutterLocalNotificationsPlugin!
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
  .createNotificationChannel(channel!);

await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  alert: true, badge: true, sound: true
);
  runApp(ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return PageTransition(
                settings: settings,
                child: HomePage(),
                type: PageTransitionType.fade);

          case '/staffHome':
            return PageTransition(
                settings: settings,
                child: StaffHome(),
                type: PageTransitionType.fade);

          case '/doneService':
            return PageTransition(
                settings: settings,
                child: DoneService(),
                type: PageTransitionType.fade);

          case '/history':
            return PageTransition(
                settings: settings,
                child: UserHystoryScreen(),
                type: PageTransitionType.fade);
          case '/booking':
            return PageTransition(
                settings: settings,
                child: BookingScreen(),
                type: PageTransitionType.fade);

          case '/bookingHistory':
            return PageTransition(
                settings: settings,
                child: BarberHistoryScreen(),
                type: PageTransitionType.fade);
          default:
            return null;
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}


class MyHomePage extends StatefulWidget{

  @override
  MyHomePageState createState() =>MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>{
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  @override
  void initState() {
    super.initState();
    //get token
    FirebaseMessaging.instance.getToken()
    .then((value) => print('Token: $value'));

    if(FirebaseAuth.instance.currentUser!=null){
      FirebaseMessaging.instance.subscribeToTopic(FirebaseAuth.instance.currentUser!.uid)
    .then((value) => print('Success'));
    }

    
    //message display
    initFirebaseMessagingHandler(channel!);


  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
        key: scaffoldState,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/my_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width,
                child: FutureBuilder(
                  future: checkLoginState(context, false, scaffoldState),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    else {
                      var userState = snapshot.data as LOGIN_STATE;
                      if (userState == LOGIN_STATE.LOGGED) {
                        return Container();
                      } else {
                        return ElevatedButton.icon(
                          onPressed: () => processLogin(context),
                          icon: Icon(
                            Icons.phone,
                            color: Colors.white,
                          ),
                          label: Text(
                            'LOGIN WITH PHONE',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(Colors.black)),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        )
      // This trailing comma makes auto-formatting nicer for build methods.
    ),
    );
  }

  processLogin(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      FlutterAuthUi.startUi(items: [AuthUiProvider.phone],
          tosAndPrivacyPolicy: TosAndPrivacyPolicy(
              tosUrl: 'https://google.com',
              privacyPolicyUrl: 'https://google.com'),
          androidOption:AndroidOption(
              enableSmartLock: false,
              showLogo: true,
              overrideTheme: true
          )).then((value) async{
        context.read(userLogged).state = FirebaseAuth.instance.currentUser;
        await checkLoginState(context, true, scaffoldState);
      })
      /*FirebaseAuthUi.instance()
          .launchAuth([AuthProvider.phone()]).then((firebaseUser) async {
        context.read(userLogged).state = FirebaseAuth.instance.currentUser;
        await checkLoginState(context, true, scaffoldState);
      })*/
          .catchError((e) {

        /*if (e is PlatformException) if (e.code ==
            FirebaseAuthUi.kUserCancelledError)
          ScaffoldMessenger.of(scaffoldState.currentContext!)
              .showSnackBar(SnackBar(content: Text('${e.message}')));
        else*/
        ScaffoldMessenger.of(scaffoldState.currentContext!)
            .showSnackBar(  SnackBar(content: Text('${e.toString()}')));
      });
    } else {
      print('${context.read(userLogged).state!.phoneNumber}');
    }
  }

  Future<LOGIN_STATE> checkLoginState(BuildContext context, bool fromLogin,
      GlobalKey<ScaffoldState> scaffoldState) async {
    if(!context.read(forceReload).state){
      await Future.delayed(Duration(seconds: fromLogin == true ? 0 : 3))
          .then((value) => {
        FirebaseAuth.instance.currentUser!
            .getIdToken()
            .then((token) async {
          print('$token');
          context.read(userToken).state = token;
          CollectionReference userRef =
          FirebaseFirestore.instance.collection('User');
          DocumentSnapshot snapshotUser = await userRef
              .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
              .get();
          context.read(forceReload).state = true;
          if (snapshotUser.exists) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          } else {
            //show register dialog
            var nameController = TextEditingController();
            var addresssController = TextEditingController();
            Alert(
                context: context,
                title: 'UPDATE PROFILES',
                content: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          icon: Icon(Icons.account_circle),
                          labelText: 'Name'),
                      controller: nameController,
                    ),
                    TextField(
                      decoration: InputDecoration(
                          icon: Icon(Icons.home), labelText: 'Address'),
                      controller: addresssController,
                    ),
                  ],
                ),
                buttons: [
                  DialogButton(
                      child: Text('CANCEL'),
                      onPressed: () => Navigator.pop(context)),
                  DialogButton(
                      child: Text('UPDATE'),
                      onPressed: () {
                        userRef
                            .doc(FirebaseAuth
                            .instance.currentUser!.phoneNumber)
                            .set({
                          'name': nameController.text,
                          'address': addresssController.text
                        }).then((value) async {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(
                              scaffoldState.currentContext!)
                              .showSnackBar(SnackBar(
                              content: Text(
                                  'UPDATE PROFILES SUCCESSFULLY')));
                          await Future.delayed(Duration(seconds: 1), () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/home', (route) => false);
                          });
                        }).catchError((e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(
                              scaffoldState.currentContext!)
                              .showSnackBar(
                              SnackBar(content: Text('${e}')));
                        });
                      })
                ]).show();
          }
        })
      });
    }
    return FirebaseAuth.instance.currentUser != null
        ? LOGIN_STATE.LOGGED
        : LOGIN_STATE.NOT_LOGIN;
  }
}

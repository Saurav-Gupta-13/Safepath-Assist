import 'dart:math';

import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safepath_assist/db/db_services.dart';
import 'package:safepath_assist/widgets/home_widgets/CustomCarouel.dart';
import 'package:safepath_assist/widgets/home_widgets/custom_appBar.dart';
import 'package:safepath_assist/widgets/home_widgets/emergency.dart';
import 'package:safepath_assist/widgets/home_widgets/live_safe.dart';
import 'package:safepath_assist/widgets/home_widgets/safehome/SafeHome.dart';
import 'package:shake/shake.dart';

import '../../model/contactsm.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // const HomeScreen({super.key});
  int qIndex = 2;

  Position? _currentPosition;
  String? _currentAddress;
  LocationPermission? permission;

  _getPermission() async => await [Permission.sms].request();

  _isPermissionGranted() async => await Permission.sms.status.isGranted;

  _sendSms(String phoneNumber, String message, {int? simSlot}) async {
    try {
      var status = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber,
        message: message,
        simSlot: simSlot,
      );

      if (status == SmsStatus.sent) {
        Fluttertoast.showToast(msg: "Sent");
      } else {
        Fluttertoast.showToast(msg: "Failed");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed with an error: $e");
    }
  }

  _getCurrentLocation() async {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      Fluttertoast.showToast(msg: "Location permissions are  denied");
      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(
            msg: "Location permissions are permanently denied");
      }
    }
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print(_currentPosition!.latitude);
        _getAddressFromLatLon();
      });
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  _getAddressFromLatLon() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.locality},${place.postalCode},${place.street}";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  getRandomQuote() {
    Random random = Random();

    setState(() {
      qIndex = random.nextInt(6);
    });
  }

  getAndSendSms() async {
    List<Tcontact> contactList = await DatabaseHelper().getContactList();

    String messageBody =
        "https://maps.google.com/?daddr=${_currentPosition!.latitude}.${_currentPosition!.longitude}";
    if (await _isPermissionGranted()) {
      contactList.forEach((element) {
        _sendSms("${element.number}",
            "I am in trouble please reach me out at $messageBody");
      });
    } else {
      Fluttertoast.showToast(msg: "Something wrong");
    }
  }

  @override
  void initState() {
    getRandomQuote();
    super.initState();
    _getPermission();
    _getCurrentLocation();
    //// Shake Feature ////
    ShakeDetector.autoStart(
      onPhoneShake: () {
        getAndSendSms();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shake!'),
          ),
        );
        // Do stuff on phone shake
      },
      minimumShakeCount: 2,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
    );
    // To close: detector.stopListening();
    // ShakeDetector.waitForStart() waits for user to call detector.startListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            CustomAppBar(
                quoteIndex: qIndex,
                onTap: () {
                  getRandomQuote();
                }),
            Expanded(
                child: ListView(
              shrinkWrap: true,
              children: [
                CustomCarouel(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Emergency",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Emergency(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Explore LiveSafe",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                LiveSafe(),
                SafeHome()
              ],
            ))
          ]),
        ),
      ),
    );
  }
}

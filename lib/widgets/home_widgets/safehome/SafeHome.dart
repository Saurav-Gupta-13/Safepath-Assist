import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safepath_assist/components/PrimaryButton.dart';
import 'package:safepath_assist/db/db_services.dart';
import 'package:safepath_assist/model/contactsm.dart';

class SafeHome extends StatefulWidget {
  @override
  State<SafeHome> createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
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

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions')));
      return false;
    }
    return true;
  }

  _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
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
  /*permission = await Geolocator.checkPermission();
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
    });*/

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

  @override
  void initState() {
    super.initState();
    _getPermission();
    _getCurrentLocation();
  }

  showModelSafeHome(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.4,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "SEND YOUR CUURENT LOCATION IMMEDIATELY TO YOU EMERGENCY CONTACTS",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                if (_currentPosition != null) Text(_currentAddress!),
                PrimaryButton(
                    title: "GET LOCATION",
                    onPressed: () {
                      _getCurrentLocation();
                    }),
                SizedBox(height: 10),
                PrimaryButton(
                    title: "SEND ALERT",
                    onPressed: () async {
                      List<Tcontact> contactList =
                          await DatabaseHelper().getContactList();
                      String recipients = "";
                      int i = 1;
                      for (Tcontact contact in contactList) {
                        recipients += contact.number;
                        if (i != contactList.length) {
                          recipients += ";";
                          i++;
                        }
                      }
                      String messageBody =
                          "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude}%2C${_currentPosition!.longitude}. $_currentAddress";
                      if (await _isPermissionGranted()) {
                        contactList.forEach((element) {
                          _sendSms("${element.number}",
                              "I am in trouble please reach me out at $messageBody");
                        });
                      } else {
                        Fluttertoast.showToast(msg: "Something wrong");
                      }
                    }),
              ],
            ),
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModelSafeHome(context),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 180,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  ListTile(
                    title: Text("Send Location"),
                    subtitle: Text("Share Location"),
                  ),
                ],
              )),
              ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/route.jpg')),
            ],
          ),
        ),
      ),
    );
  }
}

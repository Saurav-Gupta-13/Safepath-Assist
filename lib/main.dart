import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safepath_assist/child/bottom_page.dart';
import 'package:safepath_assist/child/child_login_screen.dart';
import 'package:safepath_assist/db/share_pref.dart';
import 'package:safepath_assist/parent/parent_home_screen.dart';
import 'package:safepath_assist/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MySharedPrefference.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        // scaffoldMessengerKey: navigatorkey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.firaSansTextTheme(
            Theme.of(context).textTheme,
          ),
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
          future: MySharedPrefference.getUserType(),
         
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if (snapshot.data=="") {
              return LoginScreen();
            }
            if (snapshot.data=="Child") {
              return BottomPage();
            }
            if (snapshot.data=="Parent") {
              return ParentHomeScreen();
            }
            return progressIndicator(context);
          },
        )
        
        );
  }
}

//class CheckAuth extends StatelessWidget {
  //const CheckAuth({Key? key}) : super(key: key);

  //checkData() {
  //  if (MySharedPrefference.getUserType() == 'Parent') {}
  //}

  //@override
 // Widget build(BuildContext context) {
   // return Scaffold();
  //}
//}

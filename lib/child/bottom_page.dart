import 'package:flutter/material.dart';
import 'package:safepath_assist/child/bottom_screens/add_contacts.dart';
import 'package:safepath_assist/child/bottom_screens/chat_page.dart';
import 'package:safepath_assist/child/bottom_screens/child_home_page.dart';
import 'package:safepath_assist/child/bottom_screens/profile_page.dart';
import 'package:safepath_assist/child/bottom_screens/review_page.dart';

class BottomPage extends StatefulWidget {
  const BottomPage({Key? key}) : super(key: key);

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int currentIndex = 0;
  List<Widget> pages = [
    HomeScreen(),
    AddContactsPage(),
    ChatPage(),
    ProfilePage(),
    ReviewPage(),
  ];

  onTapped(int index){
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: onTapped,
        items: [
          BottomNavigationBarItem(
            label: 'home',
              icon: Icon(
            Icons.home,
          )),
          BottomNavigationBarItem(
            label: 'contacts',
              icon: Icon(
            Icons.contacts,
          )),
          BottomNavigationBarItem(
            label: 'chats',
              icon: Icon(
            Icons.chat,
          )),
          BottomNavigationBarItem(
            label: 'Search',
              icon: Icon(
            Icons.search,
          )),
          BottomNavigationBarItem(
            label: 'reviews',
              icon: Icon(
            Icons.reviews,
          ))
        ],
      ),
    );
  }
}

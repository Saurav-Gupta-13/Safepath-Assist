import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../chat_module/chat_screen.dart';
import '../child/child_login_screen.dart';
import '../utils/constants.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("ParentHomeScreen build method executed");

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Container(),
            ),
            ListTile(
              title: TextButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    goTO(context, LoginScreen());
                  } on FirebaseAuthException catch (e) {
                    dialogBox(context, e.toString());
                  }
                },
                child: Text("Sign Out"),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text("SELECT CHILD"),
      ),
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!authSnapshot.hasData || authSnapshot.data == null) {
            return Center(child: Text("User not authenticated"));
          }

          final currentUser = authSnapshot.data!;
          final currentUserEmail = currentUser.email;

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('Type', isEqualTo: 'Child')
                .where('Parent E-mail', isEqualTo: currentUserEmail)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                print("No data available in StreamBuilder");
                return Center(child: progressIndicator(context));
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  final d = snapshot.data!.docs[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Color.fromARGB(255, 250, 163, 192),
                      child: ListTile(
                        onTap: () {
                          print("Current User ID before navigating to ChatScreen: ${currentUser.uid}");
                          goTO(
                            context,
                            ChatScreen(
                              currentUserId: currentUser.uid,
                              friendId: d.id,
                              friendName: d['Name'],
                            ),
                          );
                        },
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(d['Name']),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

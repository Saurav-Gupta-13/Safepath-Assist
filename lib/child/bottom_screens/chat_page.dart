import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safepath_assist/utils/constants.dart';

import '../../chat_module/chat_screen.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? childEmail = FirebaseAuth.instance.currentUser!.email;
    print("Child Email: $childEmail");
    String? parentName; // Variable to store the parent's name

    // Fetch the parent's information based on the child's email
    FirebaseFirestore.instance
        .collection('users')
        .where('Type', isEqualTo: 'Parent')
        .where('Child E-Mail', isEqualTo: childEmail)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // If there is at least one matching parent document
        parentName = querySnapshot.docs[0]['Parent E-mail'];
        print("Parent Name: $parentName"); // Add this line for debugging
      } else {
        print("No matching parent found.");
      }
    }).catchError((error) {
      print(
          "Error fetching parent details: $error"); // Add this line for debugging
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Select Guardian"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('Type', isEqualTo: 'Parent')
            .where('Child E-Mail',
                isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            print("No data available in the snapshot");
            return Center(child: progressIndicator(context));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Snapshot is still waiting");
            return Center(child: progressIndicator(context));
          }

          if (snapshot.hasError) {
            print("Snapshot has error: ${snapshot.error}");
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          print("Number of documents: ${snapshot.data!.docs.length}");

          // Log document data
          for (final document in snapshot.data!.docs) {
            print("Document data: ${document.data()}");
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
                      goTO(
                        context,
                        ChatScreen(
                          currentUserId: FirebaseAuth.instance.currentUser!.uid,
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
      ),
    );
  }
}






import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safepath_assist/db/db_services.dart';
import 'package:safepath_assist/model/contactsm.dart';
import 'package:safepath_assist/utils/constants.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  DatabaseHelper _databaseHelper = DatabaseHelper();

  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    askPermissions();
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  filterContact() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((element) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlattren = flattenPhoneNumber(searchTerm);
        String contactName = element.displayName!.toLowerCase();
        bool nameMatch = contactName.contains(searchTerm);
        if (nameMatch == true) {
          return true;
        }
        if (searchTermFlattren.isEmpty) {
          return false;
        }
        var phone = element.phones!.firstWhere((p) {
          String phnFLattered = flattenPhoneNumber(p.value!);
          return phnFLattered.contains(searchTermFlattren);
        });
        return phone.value != null;
      });
    }
    setState(() {
      contactsFiltered = _contacts;
    });
  }

  Future<void> askPermissions() async {
    PermissionStatus permissionStatus = await getContactsPermissions();
    if (permissionStatus == PermissionStatus.granted) {
      getAllContacts();
      searchController.addListener(() {
        filterContact();
      });
    } else {
      handInvaliedPermissions(permissionStatus);
    }
  }

  handInvaliedPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      dialogBox(context, "Access to the contacts denied by the user");
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      dialogBox(context, "May contact does exist in this device");
    }
  }

  Future<PermissionStatus> getContactsPermissions() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  getAllContacts() async {
    List<Contact> _contacts =
        await ContactsService.getContacts(withThumbnails: false);
    setState(() {
      contacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearchIng = searchController.text.isNotEmpty;
    bool listItemExit = (contactsFiltered.length > 0 || contacts.length > 0);
    return Scaffold(
      body: contacts.length == 0
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autofocus: true,
                      controller: searchController,
                      decoration: InputDecoration(
                          labelText: "search Contact",
                          prefixIcon: Icon(Icons.search)),
                    ),
                  ),
                  listItemExit == true
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: isSearchIng == true
                                ? contactsFiltered.length
                                : contacts.length,
                           itemBuilder: (BuildContext context, int index) {
  Contact contact = isSearchIng == true
      ? contactsFiltered[index]
      : contacts[index];
  return ListTile(
    title: Text(contact.displayName ?? 'No Name'),
    leading: contact.avatar != null && contact.avatar!.length > 0
        ? CircleAvatar(
            backgroundColor: primaryColor,
            backgroundImage: MemoryImage(contact.avatar!),
          )
        : CircleAvatar(
            backgroundColor: primaryColor,
            child: Text(contact.initials()),
          ),
    onTap: () {
      if (contact.phones != null && contact.phones!.length > 0) {
        final String phoneNum = contact.phones!.elementAt(0).value ?? '';
        final String name = contact.displayName ?? 'No Name';
        _addContact(Tcontact(phoneNum, name));
      } else {
        Fluttertoast.showToast(
          msg: "Oops! Phone number of this contact does not exist",
        );
      }
    },
  );
},

                          ),
                        )
                      : Container(
                          child: Text("searching"),
                        ),
                ],
              ),
            ),
    );
  }

  void _addContact(Tcontact newContact) async {
    int result = await _databaseHelper.insertContact(newContact);
    if (result != 0) {
      Fluttertoast.showToast(msg: "contact added successfully");
    } else {
      Fluttertoast.showToast(msg: "Failed to add contacts");
    }
    Navigator.of(context).pop(true);
  }
}

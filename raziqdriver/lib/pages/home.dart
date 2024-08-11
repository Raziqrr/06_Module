import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raziqdriver/pages/add.dart';
import 'package:raziqdriver/widgets/PrimaryButton.dart';
import 'package:raziqdriver/widgets/RideCard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.uid});
  final String uid;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> categories = ["pending", "completed"];
  final Stream<QuerySnapshot> userStream =
      FirebaseFirestore.instance.collection('Rides').snapshots();
  final db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    final user = db.collection("Users").doc(widget.uid).get();

    void Logout() async {
      final _prefs = await SharedPreferences.getInstance();
      await _prefs.remove("ic");
      await _prefs.remove("password");
      Navigator.pop(context);
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                  child: PrimaryButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return AddPage(
                            myId: widget.uid,
                          );
                        }));
                      },
                      text: "Schedule Ride")),
            ],
          ),
        ),
        appBar: AppBar(
          leading: FutureBuilder(
            future: user,
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.hasError) {
                return Center(child: const Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: const CircularProgressIndicator());
              }

              final userData = snapshot.data!.data();
              if (userData != null) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGreen),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(userData["userImage"]))),
                  ),
                );
              } else {
                return Container(
                  decoration: BoxDecoration(color: Colors.grey),
                );
              }
            },
          ),
          elevation: 1,
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
                onPressed: () {
                  Logout();
                },
                child: Text(
                  "Logout",
                  style: GoogleFonts.montserrat(
                      color: Colors.red, fontWeight: FontWeight.w600),
                ))
          ],
          title: Text(
            "Kongsi Kereta",
            style: GoogleFonts.montserrat(
                color: CupertinoColors.systemGreen,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: StreamBuilder(
              stream: userStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: const Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: const CircularProgressIndicator());
                }

                final myRides = snapshot.data!.docs.where((doc) {
                  return (doc["driverId"] == widget.uid &&
                      categories.contains(doc["status"]));
                }).toList();
                if (myRides != null) {
                  if (myRides == []) {
                    return Center(child: Text("No rides"));
                  } else {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RawChip(
                              checkmarkColor: Colors.white,
                                side: BorderSide.none,
                                selectedColor: CupertinoColors.systemYellow,
                                backgroundColor: CupertinoColors.systemYellow,
                                selected: categories.contains("pending"),
                                onPressed: () {
                                  print(categories);
                                  if (categories.contains("pending")) {
                                    setState(() {
                                      categories.remove("pending");
                                    });
                                  } else {
                                    setState(() {
                                      categories.add("pending");
                                    });
                                  }
                                  print(categories);
                                },
                                label: Text(
                                  "Pending",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                            SizedBox(width: 10,),
                            RawChip(
                                checkmarkColor: Colors.white,
                                side: BorderSide.none,
                                selectedColor: CupertinoColors.systemGreen,
                                backgroundColor: CupertinoColors.systemGreen,
                                selected: categories.contains("completed"),
                                onPressed: () {
                                  print(categories);
                                  if (categories.contains("completed")) {
                                    setState(() {
                                      categories.remove("completed");
                                    });
                                  } else {
                                    setState(() {
                                      categories.add("completed");
                                    });
                                  }
                                  print(categories);
                                },
                                label: Text(
                                  "Completed",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: myRides.length,
                            itemBuilder: (BuildContext context, int index) {
                              return RideCard(
                                rideId: myRides[index].id,
                                myId: widget.uid,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                } else {
                  return Center(child: Text("No Rides"));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

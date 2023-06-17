import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../providers/user_provider.dart';

class ScheduleSelectorScreen extends StatefulWidget {
  const ScheduleSelectorScreen({super.key, required this.callback});

  final void Function(List<TimeOfDay>) callback;

  @override
  State<ScheduleSelectorScreen> createState() => _ScheduleSelectorScreenState();
}

class _ScheduleSelectorScreenState extends State<ScheduleSelectorScreen> {
  final List<TimeOfDay?> _schedule = List.filled(14, null, growable: false);
  bool _isValid = false;

  final List<String> _days = List.from([
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ]);

  void Function(TimeOfDay) generateCallback(int index) {
    return (TimeOfDay time) {
      _schedule[index] = time;
      int count = 0;
      for (int i = 0; i < 14; i++) {
        if (_schedule[i] == null) count++;
      }
      if (count == 0) {
        setState(() {
          _isValid = true;
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  height: height * 0.06,
                ),
                Row(
                  children: [
                    FloatingActionButton.small(
                      heroTag: "smallbtn",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.cyan,
                      ),
                    ),
                    Container(
                      width: width * 0.1,
                    ),
                    const Icon(
                      Icons.person,
                      color: Colors.blueGrey,
                      size: 50,
                    ),
                    Container(
                      width: width * 0.02,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<CurrUser>(
                          future: UserProvider.getUserData(uid, FirebaseDatabase.instance),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (!snapshot.hasData) {
                              return const Text('Error fetching data');
                            }
                            CurrUser user = snapshot.data!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.username, // Display the user's name
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                                Text(user.bio,
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Lato',
                                    ))
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Container(height: height*0.015),
                for (int i = 0; i < _days.length; i++) ...[
                  Text(_days[i],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),),
                  SizedBox(height:height*0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int j = 0; j < 2; j++)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TimeSelector(callback: generateCallback(2 * i + j)),
                            SizedBox(width: width*0.3),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height:height*0.015),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: _isValid,
    child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
        child: FloatingActionButton(
          onPressed: () {
            widget.callback(_schedule.whereType<TimeOfDay>().toList());
            Navigator.of(context).pop();
          },
          backgroundColor: Colors.cyan,
          child: const Icon(Icons.add),
        ),
    ),
      ),
    );
  }
}

class TimeSelector extends StatefulWidget {
  const TimeSelector({super.key, required this.callback});

  final void Function(TimeOfDay) callback;

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  String _text = "Select hour";

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        TimeOfDay? time = await showTimePicker(
            context: context, initialTime: TimeOfDay.now());
        if (time != null) {
          widget.callback(time);
          setState(() {
            _text = '${time.hour}:${time.minute}';
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(
            color: Colors.cyan, // Set the border color to cyan
            width: 2.0, // Set the border width
          ),
        ),
      ),
      child: Text(_text, style: const TextStyle(color: Colors.cyan ))
    );
  }
}

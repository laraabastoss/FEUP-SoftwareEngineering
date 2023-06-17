import 'package:brain_box/providers/tags_provider.dart';
import 'package:brain_box/screens/schedule_selector_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data_modifiers/place_writer.dart';
import '../providers/user_provider.dart';
import 'location_selector_screen.dart';

class PlaceSuggestingScreen extends StatefulWidget {
  static final _formKey = GlobalKey<FormState>();

  const PlaceSuggestingScreen({super.key});

  @override
  State<PlaceSuggestingScreen> createState() => _PlaceSuggestingScreenState();
}

class _PlaceSuggestingScreenState extends State<PlaceSuggestingScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  late final PlaceWriter writer;

  late double _latitude, _longitude;
  late List<TimeOfDay> _schedule;
  final List<Tag> _tags = [];
  String? _tagText;

  bool _hasLocation = false;
  bool _hasSchedule = false;

  void locationCallback(double latitude, double longitude) {
    setState(() {
      _latitude = latitude;
      _longitude = longitude;
      _hasLocation = true;
    });
  }

  void scheduleCallback(List<TimeOfDay> schedule) {
    setState(() {
      _schedule = schedule;
      _hasSchedule = true;
    });
  }

  void selectTag(Tag tag) {
    if (_tags.contains(tag)) {
      _tags.remove(tag);
      setState(() {
        _tagText = "Tag ${tag.name} has been deselected";
      });
    } else {
      _tags.add(tag);
      setState(() {
        _tagText = "Tag ${tag.name} has been selected";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  height: height * 0.05,
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
                      width: width * 0.15,
                    ),
                    const Icon(
                      Icons.person,
                      color: Colors.blueGrey,
                      size: 50,
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
                Form(
                  key: PlaceSuggestingScreen._formKey,
                  child: Column(
                    children: [
                      Container(
                        height: height * 0.05,
                      ),
                      const Text("Suggest a place:",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lato',
                              color: Colors.black),
                          textAlign: TextAlign.start),
                      Container(
                        height: height * 0.05,
                      ),
                      SizedBox(
                        width: 0.8*width,
                        child: TextFormField(
                          key: const Key('name'),
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Name',
                            filled: true,
                            fillColor: const Color.fromRGBO(241, 240, 240, 1),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide.none
                            ),
                          ),
                        ),),
                      Container(
                        height: height * 0.05,
                      ),
                      SizedBox(
                        width: 0.8*width,
                        child: TextFormField(
                          key: const Key('city'),
                          controller: _cityController,
                          decoration: InputDecoration(
                            hintText: 'City',
                            filled: true,
                            fillColor: const Color.fromRGBO(241, 240, 240, 1),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide.none
                            ),
                          ),
                        ),),
                    ],
                  ),
                ),
                Container(
                  height: height * 0.05,
                ),
            Container(
              width: 0.8*width,
              height: 0.08 * height,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(241, 240, 240, 1),
                borderRadius: BorderRadius.circular(20.0),
              ),
                child: ChangeNotifierProvider<AllTagsModel>(
                  create: (_) => AllTagsModel(),
                  child: Consumer<AllTagsModel>(
                    builder: (context, model, child) {
                      List<Tag> tags = model.tags;
                      if (tags.isEmpty) {
                        return const CircularProgressIndicator();
                      }
                      return Column(
                        children: [

                          Autocomplete<Tag>(

                            optionsBuilder: (TextEditingValue value) {
                              if (value.text == '') {
                                return const Iterable<Tag>.empty();
                              }
                              return tags.where(
                                (Tag element) {
                                  return element.name
                                      .toLowerCase()
                                      .contains(value.text.toLowerCase());
                                },
                              );
                            },
                            onSelected: (Tag selection) {
                              selectTag(selection);
                            },
                            fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                              return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: TextField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                    hintText: 'Tags', // Change the placeholder text here
                                  ),
                                  onSubmitted: (_) => onFieldSubmitted(),
                                  ),
                               );
                            },
                          ),
                          Text(_tagText ?? '')
                        ],
                      );
                    },
                  ),
                ),
              ),
                Container(
                  height: height * 0.05,
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (BuildContext context) {
                        return LocationSelectorScreen(
                            callback: locationCallback);
                      },
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      )),
                  child:
                  Text(_hasLocation
                      ? '$_latitude $_longitude'
                      : "Select location"),
                ),
                Container(
                  height: height * 0.05,
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (BuildContext context) {
                        return ScheduleSelectorScreen(
                            callback: scheduleCallback);
                      },
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      )),
                  child: Text(_hasSchedule
                      ? "Schedule picked!"
                      : "Pick a schedule?"),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: _hasLocation,
        child: FloatingActionButton(
          backgroundColor: Colors.cyan,
          onPressed: () {
            if (PlaceSuggestingScreen._formKey.currentState!.validate() &&
                _hasLocation) {
              writer = PlaceWriter(
                  name: _nameController.text,
                  city: _cityController.text,
                  latitude: _latitude,
                  longitude: _longitude,
                  db: FirebaseDatabase.instance);
              writer.createPlace();
              writer.addTags(_tags);
              if (_hasSchedule) writer.addSchedule(_schedule);
              Navigator.of(context).pop();
            }
          },
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 0,
          child: const Icon(Icons.check),
        ),
      ),
    );
  }
}

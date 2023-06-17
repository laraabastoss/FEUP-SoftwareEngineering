import 'package:brain_box/providers/schedule_provider.dart';
import 'package:brain_box/providers/tags_provider.dart';
import 'package:brain_box/screens/reviews_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import '../providers/comment_provider.dart';
import '../providers/location_provider.dart';
import '../providers/user_provider.dart';

class LocationScreen extends StatelessWidget {
  final Place place;
  late List<Comment> _comments;
  late List<Schedule> _schedule;
  late List<Tag> _tags;
  String? _placemark;
  List<Widget> available = <Widget>[];
  LocationScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScheduleModel>(
          create: (_) => ScheduleModel(place.key, FirebaseDatabase.instance.ref()),
        ),
        ChangeNotifierProvider<CommentModel>(
          create: (_) => CommentModel(place.key, FirebaseDatabase.instance.ref()),
        ),
        ChangeNotifierProvider<TagModel>(
          create: (_) => TagModel(place.key),
        ),
      ],
      child: Scaffold(
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
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Share.share("Hi! I'm going to ${place.name}");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text("Share"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: height * 0.02,
                  ),
                  Container(
                    clipBehavior: Clip.hardEdge,
                    width: width * 0.85,
                    height: height * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: SfMaps(
                      layers: [
                        MapTileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          initialFocalLatLng:
                              MapLatLng(place.latitude, place.longitude),
                          initialZoomLevel: 15,
                          initialMarkersCount: 1,
                          markerBuilder: (BuildContext context, int index) {
                            return MapMarker(
                              latitude: place.latitude,
                              longitude: place.longitude,
                              iconColor: Colors.deepOrange,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: height * 0.05,
                  ),
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Lato',
                    ),
                  ),
                  Container(
                    height: height * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                      ),
                      SizedBox(
                        width: width * 0.05,
                      ),
                      FutureBuilder<List<Placemark>>(
                        future: placemarkFromCoordinates(place.latitude, place.longitude),
                        builder: (BuildContext context, AsyncSnapshot<List<Placemark>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            print("Placemark data: ${snapshot.data}");
                            print("Placemark error: ${snapshot.error}");
                            if (snapshot.hasData) {
                              final placemark = snapshot.data![1];
                              _placemark = placemark.street;
                              if (snapshot.data!.length >= 2) {
                                final placemark = snapshot.data![1];
                                _placemark = placemark.street;
                              }
                              final address = "${placemark.street}";
                              return Expanded(
                                flex: 1,
                                child: Text(
                                  address,
                                  style: const TextStyle(fontSize: 16.0),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            } else {
                              return const Text("Could not fetch address");
                            }
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      Container(
                        width: width * 0.01,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                        ),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: _placemark ?? ""));
                        },
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.cyan,
                    height: 50,
                    thickness: 1.3,
                    indent: 75,
                    endIndent: 75,
                  ),
                  Consumer<CommentModel>(builder: (context, model, child) {
                    _comments = model.comments;
                    int n = _comments.length;
                    double rating = 0;
                    for (int i = 0; i < n; i++) {
                      rating = rating + _comments[i].rating;
                    }
                    if (n == 0) {
                      rating = 0;
                    } else {
                      rating /= n;
                    }
                    String r = rating.toStringAsFixed(2);
                    return Column(
                      children: [
                        Text(
                          r,
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 24,
                            fontFamily: 'Lato',
                          ),
                        ),
                        Container(
                          height: height * 0.01,
                        ),
                        RatingBarIndicator(
                          itemBuilder: (content, index) =>
                              const Icon(Icons.star, color: Colors.cyan),
                          itemCount: 5,
                          itemSize: 30,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                          rating: rating,
                        ),
                      ],
                    );
                  }),
                  Container(
                    height: 0.02 * height,
                  ),
                  ElevatedButton(
                    key: const Key('Reviews'),
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (BuildContext context) {
                            return ReviewScreen(place: place);
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        )),
                    child: const Text(
                      "Reviews",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Lato',
                      ),
                    ),
                  ),
                  Container(
                    height: 0.05 * height,
                  ),
                  Consumer<ScheduleModel>(
                    builder: (context, model, child) {
                      _schedule = model.schedule;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: width * 0.05,
                          ),
                          const Icon(
                            Icons.access_time,
                            color: Colors.cyan,
                          ),
                          Container(width: 0.05 * width),
                          Column(
                            children: [
                              Consumer<ScheduleModel>(
                                builder: (context, model, child) {
                                  _schedule = model.schedule;
                                  if (_schedule.isEmpty) {
                                    return const Text(
                                        "No information about the schedule");
                                  }
                                  return DefaultTextStyle(
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Lato',
                                    ),
                                    child: Row(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text("Monday"),
                                            Text("Tuesday"),
                                            Text("Wednesday"),
                                            Text("Thursday"),
                                            Text("Friday"),
                                            Text("Saturday"),
                                            Text("Sunday"),
                                          ],
                                        ),
                                        Container(
                                          width: width * 0.1,
                                        ),
                                        Column(
                                          children: [
                                            Row(children: [
                                              Text(_schedule[0].starthour),
                                              const Text(" | "),
                                              Text(_schedule[0].endhour)
                                            ]),
                                            Row(children: [
                                              Text(_schedule[1].starthour),
                                              const Text(" | "),
                                              Text(_schedule[1].endhour)
                                            ]),
                                            Row(children: [
                                              Text(_schedule[2].starthour),
                                              const Text(" | "),
                                              Text(_schedule[2].endhour)
                                            ]),
                                            Row(children: [
                                              Text(_schedule[3].starthour),
                                              const Text(" | "),
                                              Text(_schedule[3].endhour)
                                            ]),
                                            Row(children: [
                                              Text(_schedule[4].starthour),
                                              const Text(" | "),
                                              Text(_schedule[4].endhour)
                                            ]),
                                            Row(children: [
                                              Text(_schedule[5].starthour),
                                              const Text(" | "),
                                              Text(_schedule[5].endhour)
                                            ]),
                                            Row(children: [
                                              Text(_schedule[6].starthour),
                                              const Text(" | "),
                                              Text(_schedule[6].endhour)
                                            ]),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  Container(
                    height: 0.05 * height,
                  ),
                  Row(children: [
                    Container(
                      width: width * 0.0625,
                    ),
                    const Text(
                      "What this place offers:",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lato',
                          color: Colors.blueGrey),
                      textAlign: TextAlign.left,
                    ),
                  ]),
                  Container(
                    height: height * 0.03,
                  ),
                  Consumer<TagModel>(
                    builder: (context, model, child) {
                      _tags = model.tags;
                      for (int i = 0; i < _tags.length; i++) {
                          available.add(Container(
                              width: 0.35 * width,
                              height: 0.025 * height,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.cyan,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                _tags[i].name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Lato',
                                  fontSize: 13,
                                ),
                              )));
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: width * 0.0625,
                          ),
                          Expanded(
                            child: Wrap(
                              spacing: width * 0.05,
                              runSpacing: 20,
                              //alignment: WrapAlignment.center,
                              children: available,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

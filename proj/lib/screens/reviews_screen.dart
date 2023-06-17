import 'package:brain_box/providers/comment_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../providers/user_provider.dart';
import 'comment_writing_screen.dart';

class ReviewScreen extends StatelessWidget {
  ReviewScreen({super.key, required this.place});

  final Place place;
  late List<Comment> _comments;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    return ChangeNotifierProvider<CommentModel>(
        create: (_) => CommentModel(place.key, FirebaseDatabase.instance.ref()),
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
                    ],
                  ),
                  Container(
                    height: height * 0.02,
                  ),
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Lato',
                    ),
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
                      rating = rating / n;
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
                        Text(
                          "based on $n reviews",
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ],
                    );
                  }),
                  const Divider(
                    color: Colors.cyan,
                    height: 50,
                    thickness: 1.2,
                    indent: 75,
                    endIndent: 75,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: width * 0.4,
                      height: height * 0.04,
                      child: (FirebaseAuth.instance.currentUser?.isAnonymous ?? false) ? null : ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute<void>(
                              builder: (BuildContext context) {
                                return CommentWritingScreen(place: place);
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.message,
                              color: Colors.white,
                            ),
                            Container(
                              width: width * 0.03,
                            ),
                            const Text(
                              "Write a review",
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Lato',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Consumer<CommentModel>(
                    builder: (context, model, child) {
                      _comments = model.comments;
                      return  Expanded(
                        child: ListView.builder(
                          itemCount: _comments.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.blueGrey,
                                      size: 40,
                                    ),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FutureBuilder<CurrUser>(
                                            future: UserProvider.getUserData(_comments[index].uid, FirebaseDatabase.instance),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              }
                                              if (!snapshot.hasData) {
                                                return const Text('Error fetching data');
                                              }
                                              CurrUser user = snapshot.data!;
                                              return Text(
                                                user.username, // Display the user's name
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Lato',
                                                ),
                                              );
                                            },
                                          ),
                                          Container(
                                            height: height * 0.003,
                                          ),
                                          Row(
                                            children: [
                                              RatingBar.builder(
                                                initialRating: _comments[index]
                                                    .rating
                                                    .toDouble(),
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                ignoreGestures: true,
                                                itemCount: 5,
                                                itemSize: 25,
                                                itemPadding: EdgeInsets.zero,
                                                itemBuilder: (context, _) =>
                                                    const Icon(
                                                  Icons.star,
                                                  color: Colors.cyan,
                                                ),
                                                onRatingUpdate: (rating) {
                                                  print(
                                                      _comments[index].rating);
                                                },
                                              ),
                                              Container(
                                                width: 20,
                                              ),
                                              Text(
                                                _comments[index]
                                                    .rating
                                                    .toString(),
                                                style: const TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Lato',
                                                ),
                                              ),
                                            ],
                                          )
                                        ]),
                                  ]),
                                  Container(
                                    height: 0.01 * height,
                                  ),
                                  Container(
                                    width: width,
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.grey.shade300,
                                    ),
                                    child: Text(
                                      _comments[index].text,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Lato',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              )),
        ));
  }
}

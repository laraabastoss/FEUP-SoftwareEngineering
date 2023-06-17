import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../data_modifiers/comment_writer.dart';
import '../providers/comment_provider.dart';
import '../providers/location_provider.dart';
import '../providers/user_provider.dart';

class CommentWritingScreen extends StatefulWidget {
  const CommentWritingScreen({super.key, required this.place});
  final Place place;

  static final _formKey = GlobalKey<FormState>();

  @override
  State<CommentWritingScreen> createState() => _CommentWritingScreenState();
}

class _CommentWritingScreenState extends State<CommentWritingScreen> {
  int _rating = 0;

  bool oldCommentLoaded = false;

  final TextEditingController _textController = TextEditingController();

  Comment? currentComment;

  void initComment() async {
    currentComment = await CommentModel.getUserComment(widget.place.key, FirebaseDatabase.instance, FirebaseAuth.instance);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    return FutureBuilder<Comment?>(
        future: CommentModel.getUserComment(widget.place.key, FirebaseDatabase.instance, FirebaseAuth.instance),
        builder: (context, snapshot) {
          currentComment = snapshot.data;
          String ratingText = currentComment == null
              ? "How would you rate this place?"
              : "Edit your review:";
          String buttonText =
              currentComment == null ? "Add review" : "Edit review";
          int initialRating =
              currentComment == null ? 0 : currentComment!.rating;
          _rating = currentComment == null ? _rating : initialRating;
          String initialText =
              currentComment == null ? "" : currentComment!.text;
          if (!oldCommentLoaded && initialText.isNotEmpty) {
            _textController.text = initialText;
            oldCommentLoaded = true;
          }
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
                    widget.place.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const Divider(
                    color: Colors.cyan,
                    height: 50,
                    thickness: 1.2,
                    indent: 75,
                    endIndent: 75,
                  ),
                  Container(
                    height: 0.02 * height,
                  ),
                  Text(
                    ratingText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Lato',
                    ),
                  ),
                  Container(
                    height: 0.05 * height,
                  ),
                  RatingBar.builder(
                    initialRating: initialRating.toDouble(),
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.cyan,
                    ),
                    onRatingUpdate: (rating) {
                      _rating = rating.toInt();
                    },
                  ),
                  Container(
                    height: 0.02 * height,
                  ),
                  Form(
                    key: CommentWritingScreen._formKey,
                    child: Container(
                      color: Colors.white,
                      child: Column(children: [
                        TextFormField(
                          controller: _textController,
                          maxLines: 4,
                          minLines: 4,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(15),
                            border: OutlineInputBorder(),
                            hintText: 'Write a comment',
                          ),
                        ),
                        Container(
                          height: 0.05 * height,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (currentComment == null) {
                              ChangeNotifierProvider<LocationModel>(
                                  create: (_) => LocationModel(),
                                  child: Consumer<LocationModel>(
                                      builder: (context, model, child) {
                                    incrementcomments(widget.place);
                                    return Container();
                                  }));
                            }
                            if (CommentWritingScreen._formKey.currentState!
                                .validate()) {
                              CommentWriter writer = CommentWriter(
                                  placeKey: widget.place.key,
                                  db: FirebaseDatabase.instance,
                                  auth: FirebaseAuth.instance);
                              writer.writeComment(_textController.text, _rating,
                                  currentComment);
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )),
                          child: Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontFamily: 'Lato',
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          )));
        });
  }
}

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/alltags_provider.dart';
import '../providers/location_provider.dart';
import 'location_screen.dart';

class SearchMenu extends StatefulWidget {
  const SearchMenu({super.key});

  @override
  State<SearchMenu> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchMenu> with AutomaticKeepAliveClientMixin {
  late List<Place> _places;
  late List<Widget> results=<Widget>[];
  bool search=false;
  bool filter=false;
  late List<String> filters=<String>[];
  late TextEditingController _textController;
  int rating=0;
  late List<AllTag> alltags=<AllTag>[];
  late List<Widget> tags=<Widget>[];
  List<bool> _isSelected_rating = [false, false, false, false, false];
  final List<bool> _isSelected_tags = [false, false, false, false, false];
  @override
  Widget build(BuildContext context) {
    super.build(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    _textController = TextEditingController();
    return  MultiProvider(
        key: Key('search_screen'),
        providers: [
          ChangeNotifierProvider<LocationModel>(
            create: (_) => LocationModel(),
          ),
          ChangeNotifierProvider<AllTagModel>(
            create: (_) => AllTagModel(FirebaseDatabase.instance.ref()),
          ),
        ],
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                child: Consumer<LocationModel>(builder: (context, model, child){
                  _places = model.places;
                  return Consumer<AllTagModel>(builder: (context,model,child){
                    alltags=model.tags;
                    if (alltags.isEmpty) return CircularProgressIndicator();
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                          children: [
                            Container(
                              height: height * 0.06,
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Material(
                                      child: Localizations(
                                          locale: const Locale('en', 'US'),
                                          delegates: const <LocalizationsDelegate<dynamic>>[
                                            DefaultWidgetsLocalizations.delegate,
                                            DefaultMaterialLocalizations.delegate,],
                                          child: SizedBox(
                                              height: 0.05*height,
                                              width: 0.65*width,
                                              child: TextField(
                                                  controller: _textController,
                                                  decoration: InputDecoration(
                                                    contentPadding: const EdgeInsets.all(10),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(20.0),
                                                      borderSide: BorderSide.none,
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.grey.shade300,
                                                    hintText: "Search a place",
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(20.0),
                                                      borderSide: BorderSide.none,
                                                    ),
                                                    prefixIcon: const Icon(
                                                        Icons.search,
                                                        color:Colors.blueGrey
                                                    ),
                                                    suffixIcon: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          search = !search; // toggle the search state
                                                        });

                                                        if ((search && filter) == false) {
                                                          results.clear();
                                                          for (int i = 0; i < _places.length; i++) {
                                                            if (_places[i].name.toLowerCase().contains(_textController.text.toLowerCase())) {
                                                              results.add(
                                                                Container(
                                                                  width: width * 0.9,
                                                                  height: 0.1 * height,
                                                                  child: ElevatedButton(
                                                                    onPressed: () {
                                                                      Navigator.of(context).push(
                                                                        CupertinoPageRoute<void>(
                                                                          builder: (BuildContext context) {
                                                                            return LocationScreen(place: _places[i]);
                                                                          },
                                                                        ),
                                                                      );
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Colors.white70.withOpacity(0.78),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(20.0),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Row(
                                                                          children: [
                                                                            const Icon(
                                                                              Icons.pin_drop_rounded,
                                                                              color: Colors.cyan,
                                                                              size: 50,
                                                                            ),
                                                                            Container(width: width * 0.04),
                                                                            Expanded(
                                                                              child:Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  _places[i].name,
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  textAlign: TextAlign.left,
                                                                                  style: const TextStyle(
                                                                                    fontSize: 25,
                                                                                    fontWeight: FontWeight.w700,
                                                                                    fontFamily: 'Lato',
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  _places[i].city,
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  textAlign: TextAlign.left,
                                                                                  style: const TextStyle(
                                                                                    fontSize: 13,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    fontFamily: 'Lato',
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            )),
                                                                          ],
                                                                        ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                          _textController.clear();
                                                        }
                                                      },
                                                      icon: const Icon(Icons.arrow_forward, color: Colors.blueGrey),
                                                    ),
                                                  )))
                                      )),
                                  Container(
                                    width: 0.05*width,
                                  ),
                                  FloatingActionButton.small(
                                    key: Key("filter-action"),
                                    onPressed: () {
                                      setState(() {
                                        filter=true;
                                        results=results;
                                        search=true;
                                      });

                                    },
                                    backgroundColor: Colors.white,
                                    child: const Icon(
                                      Icons.filter_list,
                                      color: Colors.blueGrey,
                                    ),
                                  ),

                                ]
                            ),
                            Visibility(
                              visible:filter,
                              child:Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children:[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(height:height*0.1),
                                        const Text("Study Spot Filter",style:TextStyle(
                                            fontSize: 30, fontFamily: 'Lato',color:Colors.cyan
                                        )),
                                        Container(width:width*0.1),
                                        ElevatedButton(
                                            onPressed: (){
                                              print(filters.length);
                                              print(rating);
                                              setState(() {
                                                filter=false;
                                                results=results;
                                                search=true;
                                                tags.clear();
                                              });
                                              if(filter==false){
                                                results.clear();
                                                bool p=false;
                                                for(int i=0;i<_places.length;i++){
                                                  print(_places[i].name);
                                                  List<String> newTags=<String>[];
                                                  if(_places[i].tags!="none"){
                                                    newTags = _places[i].tags.split(",");}
                                                  if(_places[i].rate>=rating){
                                                    for(int i=0;i<filters.length;i++){
                                                      if(p==false && i!=0) {
                                                        break;
                                                      }
                                                      for(int j=0;j<newTags.length;j++){
                                                        print(newTags[i]);
                                                        print(filters[i]);
                                                        if(filters[i]==newTags[j]){
                                                          p=true;
                                                          break;
                                                            }}
                                                    }
                                                          if(p==true || (filters.isEmpty)){results.add(Container(
                                                            width: width*0.9,
                                                            height: 0.1*height,
                                                            child: ElevatedButton(
                                                                onPressed: () =>{
                                                                  Navigator.of(context).push(
                                                                    CupertinoPageRoute<void>(
                                                                      builder: (BuildContext context) {
                                                                        return LocationScreen(place: _places[i]);
                                                                      },
                                                                    ),
                                                                  ), },
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor: Colors.white70.withOpacity(0.78),
                                                                    //side: BorderSide(color: Colors.cyan, width: 5),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(20.0),)),
                                                                child: Row(

                                                                children: [
                                                                const Icon(
                                                                Icons.pin_drop_rounded,
                                                                  color: Colors.cyan,
                                                                  size: 50,
                                                                ),
                                                              Container(width: width * 0.04),
                                                                  Flexible(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    _places[i].name,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 1,
                                                                    textAlign: TextAlign.left,
                                                                    style: const TextStyle(
                                                                      fontSize: 25,
                                                                      fontWeight: FontWeight.w700,
                                                                      fontFamily: 'Lato',
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    _places[i].city,
                                                                    maxLines: 1,
                                                                    textAlign: TextAlign.left,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: const TextStyle(
                                                                      fontSize: 13,
                                                                      fontWeight: FontWeight.w500,
                                                                      fontFamily: 'Lato',
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )),
                                                              ],
                                                            )
                                                                , ),));p=false;}}
                                                            }
                                                } _textController.clear();

                                              },
                                            style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.cyan,
                                        //side: BorderSide(color: Colors.cyan, width: 5),
                                                 shape: RoundedRectangleBorder(
                                                   borderRadius: BorderRadius.circular(20.0),)),
                                                child: const Text('Filter')),
                                      ],),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                const Text("Category",textAlign: TextAlign.center,style: TextStyle(color:Colors.blueGrey, fontSize:20)),
                                                Container(width:width*0.02),
                                                const Icon(Icons.discount_outlined,color:Colors.blueGrey)
                                              ],
                                            ),

                                            Container(height: 0.015*height),
                                            SizedBox(
                                                    width: width*0.5,
                                                    height: height*0.05,
                                                    child: ElevatedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            if (_isSelected_tags[0]==true){
                                                              filters.remove(alltags[0].name);
                                                              _isSelected_tags[0]=false;
                                                            }
                                                            else{
                                                              _isSelected_tags[0]=true;
                                                              if (!filters.contains(alltags[0].name)){
                                                                filters.add(alltags[0].name);
                                                              }}});
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            foregroundColor: _isSelected_tags[0] ? Colors.white : Colors.blueGrey, backgroundColor: _isSelected_tags[0] ? Colors.blueGrey : Colors.white70,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(30.0),

                                                            )
                                                        ),
                                                        child:Text(alltags[0].name,style: TextStyle(color:_isSelected_tags[0] ? Colors.white : Colors.blueGrey, fontSize:20)),)),
                                            Container(height: 0.01*height),
                                            SizedBox(
                                                      width: width*0.5,
                                                      height: height*0.05,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            if (_isSelected_tags[1]==true){
                                                              filters.remove(alltags[1].name);
                                                              _isSelected_tags[1]=false;
                                                            }
                                                            else{
                                                              _isSelected_tags[1]=true;
                                                              if (!filters.contains(alltags[1].name)){
                                                                filters.add(alltags[1].name);
                                                              }}
                                                          });
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            foregroundColor: _isSelected_tags[1] ? Colors.white : Colors.blueGrey, backgroundColor: _isSelected_tags[1] ? Colors.blueGrey : Colors.white70,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(30.0),

                                                            )
                                                        ),
                                                        child:Text(alltags[1].name,style: TextStyle(color:_isSelected_tags[1] ? Colors.white : Colors.blueGrey, fontSize:20)),)),
                                            Container(height: 0.01*height),
                                            SizedBox(
                                                    width: width*0.5,
                                                    height: height*0.05,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          if (_isSelected_tags[2]==true){
                                                            filters.remove(alltags[2].name);
                                                            _isSelected_tags[2]=false;
                                                          }
                                                          else{
                                                            _isSelected_tags[2]=true;
                                                            if (!filters.contains(alltags[2].name)){
                                                              filters.add(alltags[2].name);
                                                            }}

                                                        });
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                          foregroundColor: _isSelected_tags[2] ? Colors.white : Colors.blueGrey, backgroundColor: _isSelected_tags[2] ? Colors.blueGrey : Colors.white70,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(30.0),

                                                          )
                                                      ),
                                                      child:Text(alltags[2].name,style: TextStyle(color:_isSelected_tags[2] ? Colors.white : Colors.blueGrey, fontSize:20)),)),
                                            Container(height: 0.01*height),
                                            SizedBox(
                                                width: width*0.5,
                                                height: height*0.05,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      if (_isSelected_tags[3]==true){
                                                        filters.remove(alltags[3].name);
                                                        _isSelected_tags[3]=false;
                                                      }
                                                      else{
                                                      _isSelected_tags[3]=true;
                                                      if (!filters.contains(alltags[3].name)){
                                                      filters.add(alltags[3].name);
                                                      }}

                                                    });
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      foregroundColor: _isSelected_tags[3] ? Colors.white : Colors.blueGrey, backgroundColor: _isSelected_tags[3] ? Colors.blueGrey : Colors.white70,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(30.0),

                                                      )
                                                  ),
                                                  child:Text(alltags[3].name,style: TextStyle(color:_isSelected_tags[3] ? Colors.white : Colors.blueGrey, fontSize:20)),)),
                                            Container(height: 0.01*height),
                                            SizedBox(
                                                width: width*0.5,
                                                height: height*0.05,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                        if (_isSelected_tags[4]==true){
                                                            filters.remove(alltags[4].name);
                                                            _isSelected_tags[4]=false;
                                                          }
                                                      else{
                                                        _isSelected_tags[4]=true;
                                                         if (!filters.contains(alltags[4].name)){
                                                        filters.add(alltags[4].name);
                                                         }}
                                                    });
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      foregroundColor: _isSelected_tags[4] ? Colors.white : Colors.blueGrey, backgroundColor: _isSelected_tags[4] ? Colors.blueGrey : Colors.white70,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(30.0),

                                                      )
                                                  ),
                                                  child:Text(alltags[4].name,style: TextStyle(color:_isSelected_tags[4] ? Colors.white : Colors.blueGrey, fontSize:20)),))]),
                                            VerticalDivider(
                                            color:Colors.black,
                                            width:width*0.1,
                                          ),
                                          Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                                children:[
                                                  const Text("Rating",style: TextStyle(color:Colors.blueGrey, fontSize:20)),
                                                  Container(width:width*0.02),
                                                  const Icon(Icons.star_border,color:Colors.blueGrey)]),
                                            Container(height: height*0.005),
                                            ElevatedButton(
                                                onPressed: (){
                                                  setState(() {
                                                    if (_isSelected_rating[0]){
                                                      _isSelected_rating = [false, false, false, false, false];
                                                      rating=0;
                                                      tags.clear();
                                                    }
                                                    else{
                                                      rating=5;
                                                      _isSelected_rating = [true, false, false, false, false];
                                                      tags.clear();
                                                    }

                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    foregroundColor: _isSelected_rating[0] ? Colors.white : Colors.blueGrey, backgroundColor: _isSelected_rating[0] ? Colors.blueGrey : Colors.white70,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(30.0),
                                                    )
                                                ),
                                                child:Text("5",style: TextStyle(color:_isSelected_rating[0] ? Colors.white : Colors.blueGrey, fontSize:20))),
                                            Container(height: height*0.005),
                                            ElevatedButton(
                                                onPressed: (){
                                                  setState(() {
                                                    if (_isSelected_rating[1]){
                                                      _isSelected_rating = [false, false, false, false, false];
                                                      rating=0;tags.clear();
                                                    }
                                                    else{
                                                      rating=4;
                                                      _isSelected_rating = [false, true, false, false, false];
                                                      tags.clear();
                                                    }

                                                  });

                                                },
                                                style: ElevatedButton.styleFrom(
                                                    foregroundColor: _isSelected_rating[1] ? Colors.white : Colors.blueGrey, backgroundColor: _isSelected_rating[1] ? Colors.blueGrey : Colors.white70,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(30.0),
                                                    )
                                                ),
                                                child:Text("4",style: TextStyle(color:_isSelected_rating[1] ? Colors.white : Colors.blueGrey, fontSize:20))),
                                            Container(height: height*0.005),
                                            ElevatedButton(
                                                onPressed: (){
                                                  setState(() {
                                                    if (_isSelected_rating[2]){
                                                      _isSelected_rating = [false, false, false, false, false];
                                                      rating=0;
                                                      tags.clear();
                                                    }
                                                    else{
                                                      rating=3;
                                                      _isSelected_rating = [false, false, true, false, false];
                                                      tags.clear();
                                                    }


                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    foregroundColor: _isSelected_rating[2] ? Colors.white : Colors.blueGrey, backgroundColor: _isSelected_rating[2] ? Colors.blueGrey : Colors.white70,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(30.0),
                                                    )
                                                ),
                                                child:Text("3",style: TextStyle(color:_isSelected_rating[2] ? Colors.white : Colors.blueGrey, fontSize:20))),
                                            Container(height: height*0.005),
                                            ElevatedButton(
                                                onPressed: (){
                                                  setState(() {
                                                    if (_isSelected_rating[3]){
                                                      _isSelected_rating = [false, false, false, false, false];
                                                      rating=0;
                                                      tags.clear();
                                                    }
                                                    else{
                                                      rating=2;
                                                      _isSelected_rating = [false, false, false, true, false];
                                                      tags.clear();
                                                    }
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    foregroundColor: _isSelected_rating[3] ? Colors.white : Colors.blueGrey, backgroundColor: _isSelected_rating[3] ? Colors.blueGrey : Colors.white70,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(30.0),
                                                    )
                                                ),
                                                child:Text("2",style: TextStyle(color:_isSelected_rating[3] ? Colors.white : Colors.blueGrey, fontSize:20))),
                                            Container(height: height*0.005),
                                            ElevatedButton(
                                                onPressed: (){
                                                  setState(() {
                                                    if (_isSelected_rating[4]){
                                                      _isSelected_rating = [false, false, false, false, false];
                                                      rating=0;
                                                      tags.clear();
                                                    }
                                                    else{
                                                      rating=1;
                                                      _isSelected_rating = [false, false, false, false, true];
                                                      tags.clear();
                                                    }

                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    foregroundColor: _isSelected_rating[4] ? Colors.white : Colors.blueGrey, backgroundColor: _isSelected_rating[4] ? Colors.blueGrey : Colors.white70,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(30.0),
                                                    )
                                                ),
                                                child:Text("1",style: TextStyle(color:_isSelected_rating[4] ? Colors.white : Colors.blueGrey, fontSize:20))),
                                          ],
                                        )
                                      ],
                                    )])),
                                  Container(
                                    height: height * 0.0600,
                                  ),
                                  Row(
                                children:[
                                  Container(width: 0.06*width),
                                  const Icon(Icons.trending_up_rounded, color: Colors.blueGrey, size: 40,),
                                  Container(width: 0.04*width),
                                  const Text("Best Results", style: TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'Lato',
                                  ),),
                                ]),
                                  Container(
                              height: height * 0.05,
                            ),
                                Material(
                                child: Localizations(
                                    locale: const Locale('en', 'US'),
                                    delegates: const <LocalizationsDelegate<dynamic>>[
                                      DefaultWidgetsLocalizations.delegate,
                                      DefaultMaterialLocalizations.delegate,],
                                    child:
                                    Consumer<LocationModel>(builder: (context, model, child) {
                                      if(filter==false && search==false && results.isEmpty){
                                        for(int i=0;i<_places.length;i++) {
                                          results.add(Container(
                                            width: width*0.9,
                                            height: 0.1*height,
                                            color: Colors.white,
                                            child: ElevatedButton(
                                                onPressed: () =>{
                                                  Navigator.of(context).push(
                                                    CupertinoPageRoute<void>(
                                                      builder: (BuildContext context) {
                                                        return LocationScreen(place: _places[i]);
                                                      },
                                                    ),
                                                  ), },style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white70.withOpacity(0.78),
                                                //side: BorderSide(color: Colors.cyan, width: 5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0),)),
                                                child:
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.pin_drop_rounded,
                                                          color: Colors.cyan,
                                                          size: 50,
                                                        ),
                                                        Container(width: width * 0.04),
                                                        Flexible (
                                                            child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              _places[i].name,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              textAlign: TextAlign.left,
                                                              style: const TextStyle(
                                                                fontSize: 25,
                                                                fontWeight: FontWeight.w700,
                                                                fontFamily: 'Lato',
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                            Text(
                                                              _places[i].city,
                                                              maxLines: 1,
                                                              textAlign: TextAlign.left,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: const TextStyle(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w500,
                                                                fontFamily: 'Lato',
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                      ],
                                                    )
                                                ,),
                                          ));
                                        }
                                      }

                                      if(results.isNotEmpty) {
                                        return Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children:[
                                              Flexible(
                                                child: Wrap(
                                                  spacing: height * 0.05,
                                                  runSpacing: 20,
                                                  alignment: WrapAlignment.center,
                                                  children: results,
                                                ),
                                              ),
                                            ]);
                                      } else {
                                        return const Text("No results found");
                                      }
                                    }))),

                              ]));});}))));
  }
  @override
  bool get wantKeepAlive  => false;
}



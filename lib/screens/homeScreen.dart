import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:random_color/random_color.dart';
import 'dart:io';
import 'package:wallpaperhub/apiDataFromJson/pexelsData.dart';
import 'package:wallpaperhub/screens/errorScreen.dart';
import 'package:wallpaperhub/screens/imageScreen.dart';
import 'package:wallpaperhub/apiDataFromJson/pixabayData.dart';
import 'package:wallpaperhub/apiDataFromJson/unSplashData.dart';
import 'package:connectivity/connectivity.dart';
import 'package:wallpaperhub/constants.dart';
import 'package:wallpaperhub/apiKeys.dart'; // Create this File containing your own API keys
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController searchTextController;
  String searchText;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showSearchBar = false;

  double categoryItemBorder = 0.0;

  List<String> source;
  int currSource;

  List<String> urlList;

  List<Future<http.Response>> httpRequestList;
  var connectivityResult, networkSubscription;
  signOut() async {
    _auth.signOut();

    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  checkConnectivity() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connected to Mobile Network");
      //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context)=>HomeScreen()));
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Connected to WiFi");
      //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context)=>HomeScreen()));
    } else {
      print("Unable to connect. Please Check Internet Connection");
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => ErrorScreen()));
    }
  }

  @override
  void initState() {
    super.initState();

    checkConnectivity();
    bool isRenew = false;
    networkSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      print("Connection Status has Changed\n\n$result");

      if (result == ConnectivityResult.none) {
        isRenew = true;
        Fluttertoast.showToast(
          msg: 'NO INTERNET CONNECTION',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else if ((result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi) &&
          isRenew == true) {
        isRenew = false;

        Fluttertoast.showToast(
          msg: 'INTERNET IS BACK',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    });

    searchTextController = TextEditingController();
    searchText = 'wallpaper';

    currSource = 0;
    source = ['Pexels', 'UnSplash', 'Pixabay'];

    urlList = [
      'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
      //'https://api.pexels.com/v1/search?query=$searchText',
      //'https://api.unsplash.com/search/photos?query=$searchText',
      'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
      'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
    ];

    /*List<String> apiKeyList = [
      /*'PUT YOUR PEXELS_API_KEY HERE',*/
      /*'PUT YOUR UNSPLASH_API_KEY HERE',*/
      /*'PUT YOUR PIXABAY_API_KEY HERE',*/
    ];*/
  }

  @override
  void dispose() {
    super.dispose();

    networkSubscription.cancel();
    searchTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'RESOLUTION :: size${window.physicalSize}  width${window.physicalSize.width} X height${window.physicalSize.height}');

    httpRequestList = [
      http.get(
        // 'https://api.pexels.com/v1/search?query=people',
        // 'https://api.pexels.com/v1/search?query=$searchText',
        Uri.parse(urlList[0]),

        // Send authorization headers to the backend.
        headers: {
          HttpHeaders.authorizationHeader: apiKeyList[0],
        },
      ),
      http.get(Uri.parse('${urlList[1]}&client_id=${apiKeyList[1]}')),
      http.get(Uri.parse('${urlList[2]}&key=${apiKeyList[2]}')),
    ];

    return SafeArea(
      child: Scaffold(
        drawer: buildDrawer(),
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Wallpaper bazar',
            style: TextStyle(
              color: Colors.black,
              // fontFamily: 'Carrington',
              fontSize: 15.0,
            ),
          ),
          // actions: <Widget>[
          //   IconButton(
          //     onPressed: () {
          //       setState(() {
          //         showSearchBar = !showSearchBar;
          //         // Clearing off searchTextController when not in use
          //         searchTextController.clear();
          //       });
          //     },
          //     icon: Icon(Icons.search),
          //   ),
          // ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // SEARCH BAR

            (showSearchBar)
                ? Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: TextField(
                        controller: searchTextController,
                        onSubmitted: (value) {
                          setState(() {
                            searchText = searchTextController.text
                                .toString()
                                .trim()
                                .replaceAll(' ', '+');
                            urlList.replaceRange(0, urlList.length, [
                              'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
                              //'https://api.pexels.com/v1/search?query=$searchText',
                              //'https://api.unsplash.com/search/photos?quer
                              // y=$searchText',
                              'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
                              'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
                            ]);
                            // setting all Category Items as unselected
                            for (int i = 0;
                                i < (isCategorySelectedList.length);
                                i++) isCategorySelectedList[i] = false;
                            print(
                                '$searchText  ${urlList[currSource]}  $urlList');
                          });
                        },
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            //gapPadding: 20.0,
                            //borderSide: new BorderSide(),
                          ),
                          hintText: 'Search here..',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: () {
                              setState(() {
                                searchText = searchTextController.text
                                    .toString()
                                    .replaceAll(' ', '+');
                                urlList.replaceRange(0, urlList.length, [
                                  'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
                                  //'https://api.pexels.com/v1/search?query=$searchText',
                                  //'https://api.unsplash.com/search/photos?query=$searchText',
                                  'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
                                  'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
                                ]);
                                print(
                                    '$searchText  ${urlList[currSource]}  $urlList');
                                FocusScope.of(context).requestFocus(
                                    FocusNode()); // for hiding keyboard after use

                                // setting all Category Items as unselected
                                for (int i = 0;
                                    i < (isCategorySelectedList.length);
                                    i++) isCategorySelectedList[i] = false;
                              });
                            },
                          ),
                        ),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                  )
                : Container(),

            // CATEGORY LIST

            Expanded(
              flex: 1,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 6.0),
                        child: Container(
                          // Building a RandomColored Placeholder Container for Category items until Image.network is fetched in case of slow network.
                          height: 60.0,
                          width: 85.0,
                          decoration: BoxDecoration(
                            color: RandomColor().randomColor(),
                            border: Border.all(
                              color: Colors.teal, //RandomColor().randomColor(),
                              width:
                                  (isCategorySelectedList[index]) ? 4.0 : 0.0,
                            ),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              categoryUrlList[index],
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${categoryList[index]}',
                            style: TextStyle(
                              // fontFamily: 'Carrington',
                              fontSize: 15.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            searchText = categoryList[index];
                            urlList.replaceRange(0, urlList.length, [
                              'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
                              //'https://api.pexels.com/v1/search?query=$searchText',
                              //'https://api.unsplash.com/search/photos?query=$searchText',
                              'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
                              'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
                            ]);
                            // setting all Category Items as unselected
                            for (int i = 0;
                                i < (isCategorySelectedList.length);
                                i++) isCategorySelectedList[i] = false;
                            isCategorySelectedList[index] = true;
                            // Clearing off searchTextController when not in use
                            searchTextController.clear();
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            Expanded(
              flex: 10,
              child: FutureBuilder(
                future: httpRequestList[currSource],
                builder: (BuildContext context, AsyncSnapshot snap) {
                  if (networkSubscription == ConnectivityResult.none)
                    return Image.asset('images/no_internet_connection.jpeg');
                  else if (snap.connectionState == ConnectionState.waiting)
                    return Center(
                        child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.black),
                      strokeWidth: 2.0,
                    ));
                  else if (snap.connectionState == ConnectionState.done)
                    return photoGrid(snap);
                  else
                    return Text('ERROR');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.blueGrey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 20.0, left: 20.0, top: 40.0),
              child: Text(
                'Wallpaper sources:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  Container(
                    color:
                        (currSource == 0) ? Colors.black : Colors.transparent,
                    child: ListTile(
                      leading: Image.asset(
                        'images/icon_pexels.png',
                        color: (currSource == 0) ? Colors.white : Colors.black,
                        width: 40.0,
                        height: 40.0,
                      ),
                      title: Text(
                        'Pexels',
                        style: TextStyle(
                          color:
                              (currSource == 0) ? Colors.white : Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          currSource = 0;
                          searchTextController.text = '';

                          searchText = 'wallpaper';
                          urlList.replaceRange(0, urlList.length, [
                            'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
                            //'https://api.pexels.com/v1/search?query=$searchText',
                            //'https://api.unsplash.com/search/photos?query=$searchText',
                            'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
                            'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
                          ]);

                          // setting all Category Items as unselected
                          for (int i = 0;
                              i < (isCategorySelectedList.length);
                              i++) isCategorySelectedList[i] = false;

                          Navigator.of(context)
                              .pop(); // it slides back drawer on clicking any option
                        });
                      },
                    ),
                  ),
                  Container(
                    color:
                        (currSource == 1) ? Colors.black : Colors.transparent,
                    child: ListTile(
                      leading: Image.asset(
                        'images/icon_unsplash.png',
                        color: (currSource == 1) ? Colors.white : Colors.black,
                        width: 40.0,
                        height: 40.0,
                      ),
                      title: Text(
                        'Unsplash',
                        style: TextStyle(
                          color:
                              (currSource == 1) ? Colors.white : Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          currSource = 1;
                          searchTextController.text = '';

                          searchText = 'wallpaper';
                          urlList.replaceRange(0, urlList.length, [
                            'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
                            //'https://api.pexels.com/v1/search?query=$searchText',
                            //'https://api.unsplash.com/search/photos?query=$searchText',
                            'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
                            'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
                          ]);

                          // setting all Category Items as unselected
                          for (int i = 0;
                              i < (isCategorySelectedList.length);
                              i++) isCategorySelectedList[i] = false;

                          Navigator.of(context)
                              .pop(); // it slides back drawer on clicking any option
                        });
                      },
                    ),
                  ),
                  Container(
                    color:
                        (currSource == 2) ? Colors.black : Colors.transparent,
                    child: ListTile(
                        leading: Image.asset(
                          'images/icon_pixabay.png',
                          color:
                              (currSource == 2) ? Colors.white : Colors.black,
                          width: 40.0,
                          height: 40.0,
                        ),
                        title: Text(
                          'Pixabay',
                          style: TextStyle(
                            color:
                                (currSource == 2) ? Colors.white : Colors.black,
                            fontSize: 15,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            currSource = 2;
                            searchTextController.text = '';

                            searchText = 'wallpaper';
                            urlList.replaceRange(0, urlList.length, [
                              'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
                              //'https://api.pexels.com/v1/search?query=$searchText',
                              //'https://api.unsplash.com/search/photos?query=$searchText',
                              'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
                              'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
                            ]);

                            // setting all Category Items as unselected
                            for (int i = 0;
                                i < (isCategorySelectedList.length);
                                i++) isCategorySelectedList[i] = false;

                            Navigator.of(context)
                                .pop(); // it slides back drawer on clicking any option
                          });
                        }),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  RaisedButton(
                    padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                    onPressed: signOut,
                    child: Text('Signout',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold)),
                    color: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  RaisedButton(
                    padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                    onPressed: () => exit(0),
                    child: Text('Exit from App',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold)),
                    color: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  photoGrid(AsyncSnapshot snap) {
    http.Response response = snap.data;

    //print('TEST snap.data:: ${snap.data}');
    //print('TEST snap.data.runtimeType:: ${snap.data.runtimeType}');
    //print(urlList);
    print(urlList[currSource]);
    //print('TEST response.body.toString():: ${response.body.toString()}');

    //final photoUnits = pexelsUnitsFromJson(response.body.toString());

    var photoUnits;
    int itemCount;
    if (currSource == 0) {
      photoUnits = pexelsUnitsFromJson(response.body.toString());
      photoUnits.photos..shuffle();
      itemCount = photoUnits.photos.length;
    } else if (currSource == 1) {
      photoUnits = unSplashUnitsFromJson(response.body.toString());
      photoUnits.results..shuffle();
      itemCount = photoUnits.results.length;
    } else if (currSource == 2) {
      photoUnits = pixabayUnitsFromJson(response.body.toString());
      photoUnits.hits..shuffle();
      itemCount = photoUnits.hits.length;
    }

    print('itemCount :: $itemCount');

    return (itemCount == 0)
        ? Center(
            child: Text(
                'No results found for ${searchTextController.text.trim()}.\nPlease try something else.'))
        : StaggeredGridView.countBuilder(
            padding: const EdgeInsets.all(8.0),
            crossAxisCount: 4,
            itemCount: itemCount,
            itemBuilder: (BuildContext context, int index) => InkWell(
              onTap: () {
                var curPhoto;
                if (currSource == 0)
                  curPhoto = photoUnits.photos[index];
                else if (currSource == 1)
                  curPhoto = photoUnits.results[index];
                else if (currSource == 2) curPhoto = photoUnits.hits[index];
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => ImageScreen(
                      currSource: currSource,
                      curPhoto: curPhoto,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.width * 0.7,
                  color: RandomColor().randomColor(),
                  child: Image.network(
                    (currSource == 0)
                        ? photoUnits.photos[index].src.portrait
                        : (currSource == 1)
                            ? photoUnits.results[index].urls.regular
                            : photoUnits.hits[index].webformatUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                /*Image.network(
            photoUnits.photos[index].src.medium,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.width * 0.7,
                color: RandomColor().randomColor(),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes
                        : null,
                  ),
                ),
              );
            },
          )*/
              ),
            ),
            staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          );
  }
}

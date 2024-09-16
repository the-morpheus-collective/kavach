import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavach/components/main_component.dart';
import 'package:kavach/components/my_map.dart';
import 'package:kavach/screens/vishnuScreen.dart';
import 'package:kavach/utils/map.dart';
import 'package:keyboard_detection/keyboard_detection.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kavach/components/reporter.dart' as r;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  var emergencyMode = false;
  var keyboardState = KeyboardState.unknown;
  var _filterEnabled = false;

  void sheetStateListener() {
    if (sheetController.size >= 0.9) {
      if (!emergencyMode) {
        setState(() {
          emergencyTimer();
          emergencyMode = true;
        });
      }
    } else {
      if (emergencyMode) {
        setState(() {
          _timer.cancel();
          emergencySeconds = 5;
          emergencyMode = false;
        });
      }
    }
  }

  Set<TypeFilter> filters = <TypeFilter>{
    TypeFilter.other,
    TypeFilter.children,
    TypeFilter.street,
    TypeFilter.natural,
    TypeFilter.volatile,
    TypeFilter.harassment,
    TypeFilter.theft,
    TypeFilter.physical,
  };

  @override
  void initState() {
    super.initState();
    sheetController.addListener(sheetStateListener);
  }

  final double _sheetPosition = 0.13;

  String? _searchingWithQuery;
  LocData? _selectedLocation;
  late Iterable<LocData> _lastOptions = <LocData>[];

  final snackBar = const SnackBar(
    content: Text('Report Submitted!'),
  );

  var emergencySeconds = 5;
  Timer _timer = Timer(Duration.zero, () {});

  void emergencyTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (emergencySeconds == 0) {
          setState(() {
            timer.cancel();
          });
          launchUrl(Uri.parse("tel:112"));
        } else {
          setState(() {
            emergencySeconds--;
          });
        }
      },
    );
  }

  var _showMarkers = false;

  @override
  Widget build(BuildContext context) {
    final List<FabData> fabData = [
      FabData(
        image: const AssetImage("assets/images/fab/shield.png"),
        text: "Other",
        color: const Color(0xFFB3B3B3),
        onPressed: () async {
          bool successfulReport =
              await r.report(TypeFilter.other, await getCurrentLocation());
          if (context.mounted && successfulReport) {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      ),
      FabData(
        image: const AssetImage("assets/images/fab/children.png"),
        text: "Children in Danger",
        color: const Color(0xFF7196F4),
        onPressed: () async {
          bool successfulReport =
              await r.report(TypeFilter.children, await getCurrentLocation());
          if (context.mounted && successfulReport) {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      ),
      FabData(
        image: const AssetImage("assets/images/fab/street.png"),
        text: "Street Harassment",
        color: const Color(0xFF7FE3E6),
        onPressed: () async {
          bool successfulReport =
              await r.report(TypeFilter.street, await getCurrentLocation());
          if (context.mounted && successfulReport) {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      ),
      FabData(
        image: const AssetImage("assets/images/fab/natural.png"),
        text: "Natural Disasters",
        color: const Color(0xFFE67F80),
        onPressed: () async {
          bool successfulReport =
              await r.report(TypeFilter.natural, await getCurrentLocation());
          if (context.mounted && successfulReport) {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      ),
      FabData(
        image: const AssetImage("assets/images/fab/volatile.png"),
        text: "Volatile Groups",
        color: const Color(0xFF97E67F),
        onPressed: () async {
          bool successfulReport =
              await r.report(TypeFilter.volatile, await getCurrentLocation());
          if (context.mounted && successfulReport) {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      ),
      FabData(
        image: const AssetImage("assets/images/fab/harassment.png"),
        text: "Sexual Harassment",
        color: const Color(0xFFFF66BA),
        onPressed: () async {
          bool successfulReport =
              await r.report(TypeFilter.harassment, await getCurrentLocation());
          if (context.mounted && successfulReport) {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      ),
      FabData(
        image: const AssetImage("assets/images/fab/theft.png"),
        text: "Theft/Pickpocketing",
        color: const Color(0xFFA57FE6),
        onPressed: () async {
          bool successfulReport =
              await r.report(TypeFilter.theft, await getCurrentLocation());
          if (context.mounted && successfulReport) {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      ),
      FabData(
        image: const AssetImage("assets/images/fab/physical.png"),
        text: "Physical Conflict",
        color: const Color(0xFFFFD666),
        onPressed: () async {
          bool successfulReport =
              await r.report(TypeFilter.physical, await getCurrentLocation());
          if (context.mounted && successfulReport) {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      ),
    ];

    final Map<TypeFilter, FabData> fabMap = {
      for (var data in fabData) getTypeFilter(data.text): data,
    };

    List<Widget> getFabElements() {
      var widgetList = <Widget>[];

      // for each element in fabData,
      // create a FloatingActionButton

      // reverse fabData
      var fabDataReversed = fabData.reversed.toList();

      for (var data in fabDataReversed) {
        widgetList.add(
          TextButton(
            onPressed: data.onPressed,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(
                  0xFF242829,
                ),
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      data.text,
                      style: TextStyle(
                        color: data.color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Image(
                      image: data.image,
                      width: 30.0,
                      height: 30.0,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return widgetList;
    }

    return PopScope(
      canPop: false,
      child: KeyboardDetection(
        controller: KeyboardDetectionController(
          onChanged: (value) {
            // print('Keyboard visibility onChanged: $value');
            setState(() {
              keyboardState = value;
            });
          },
        ),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xffffffff),
          drawer: myDrawer,
          appBar: !emergencyMode ? getAppBar(_scaffoldKey) : null,
          floatingActionButtonLocation: ExpandableFab.location,
          body: Center(
            child: Stack(
              children: <Widget>[
                Center(
                  child: MyMap(
                    selectedLocation: _selectedLocation,
                    filters: filters,
                    showMarker: _showMarkers,
                  ),
                ),
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Color(0x00FFFFFF),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Autocomplete<LocData>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) async {
                              _searchingWithQuery = textEditingValue.text;
                              final Iterable<LocData> options =
                                  await _NominatimAPI.search(
                                      _searchingWithQuery!);

                              // If another search happened after this one, throw away these options.
                              // Use the previous options instead and wait for the newer request to
                              // finish.
                              if (_searchingWithQuery !=
                                  textEditingValue.text) {
                                return _lastOptions;
                              }

                              _lastOptions = options;
                              return options;
                            },
                            onSelected: (LocData selection) {
                              setState(() {
                                _selectedLocation = selection;
                                _searchingWithQuery = selection.miniName;
                              });
                              FocusScope.of(context).unfocus();
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: constraints.biggest.width,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.0, 5.0, 0.0, 0.0),
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder: (context, index) {
                                          final option =
                                              options.elementAt(index);
                                          return Column(
                                            children: [
                                              GestureDetector(
                                                child: Container(
                                                  width:
                                                      constraints.biggest.width,
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0),
                                                    border: const Border
                                                        .fromBorderSide(
                                                      BorderSide(
                                                        color: Colors.black,
                                                        width: 2.0,
                                                      ),
                                                    ),
                                                    color: Colors.white,
                                                  ),
                                                  child: Text(
                                                    option.displayName,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  onSelected(option);
                                                },
                                              ),
                                              const SizedBox(height: 5.0),
                                            ],
                                          );
                                        }),
                                  ),
                                ),
                              );
                            },
                            fieldViewBuilder:
                                (context, controller, node, onFieldSubmitted) {
                              return TextFormField(
                                  controller: controller,
                                  focusNode: node,
                                  onFieldSubmitted: (value) {
                                    onFieldSubmitted();
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Where do you want to go',
                                    hintStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                        width: 2.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                        width: 2.0,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20.0, 5.0, 20.0, 5.0),
                                    suffixIcon: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: const Icon(
                                          Icons.search,
                                          color: Color(0xFF242829),
                                          size: 40.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                  onTap: () {});
                            },
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF000000),
                              backgroundColor: const Color(0xFFF1B101),
                              enableFeedback: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                              minimumSize: const Size(0, 0),
                            ),
                            onPressed: () {
                              setState(() {
                                _filterEnabled = !_filterEnabled;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.filter_alt, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  "filter",
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFFFFFFF),
                              backgroundColor: const Color(0xFF242829),
                              enableFeedback: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                              minimumSize: const Size(0, 0),
                            ),
                            onPressed: () async {
                              LatLng currentCoords = await getCurrentLocation();
                              LatLng poPoCoords =
                                  await getNearestPoliceStation(currentCoords);
                              Uri route = getRouteURLToCoordinates(
                                  currentCoords, poPoCoords);
                              launchUrl(route);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.local_police, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  "police station",
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFFFFFFF),
                              backgroundColor: const Color(0xFF242829),
                              enableFeedback: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                              minimumSize: const Size(0, 0),
                            ),
                            onPressed: () async {
                              LatLng currentCoords = await getCurrentLocation();
                              LatLng hospitalCoords =
                                  await getNearestHospital(currentCoords);
                              Uri route = getRouteURLToCoordinates(
                                  currentCoords, hospitalCoords);
                              launchUrl(route);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.local_hospital, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  "hospital",
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _filterEnabled
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: Wrap(
                                  spacing: 5.0,
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: TypeFilter.values.map(
                                    (TypeFilter type) {
                                      FabData fab = fabMap[type]!;

                                      return FilterChip(
                                        avatar:
                                            Image(image: fab.image, width: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        chipAnimationStyle: ChipAnimationStyle(
                                          selectAnimation: AnimationStyle(
                                            duration: const Duration(
                                              milliseconds: 10,
                                            ),
                                            curve: Curves.easeInOut,
                                          ),
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 6, 8, 6),
                                        checkmarkColor: Colors.white,
                                        surfaceTintColor: fab.color,
                                        backgroundColor:
                                            const Color(0xEE242829),
                                        selectedColor: const Color(0xFF242829),
                                        selectedShadowColor: Colors.black,
                                        label: Text(
                                          fab.text,
                                          style: TextStyle(
                                            color: fab.color,
                                            fontFamily:
                                                GoogleFonts.jetBrainsMono()
                                                    .fontFamily,
                                            fontSize: 12,
                                          ),
                                        ),
                                        selected: filters.contains(type),
                                        onSelected: (bool selected) {
                                          setState(() {
                                            if (selected) {
                                              filters.add(type);
                                            } else {
                                              filters.remove(type);
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            )
                          : Container(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ChoiceChip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                          checkmarkColor: Colors.white,
                          backgroundColor: const Color(0xEE242829),
                          selectedColor: const Color(0xFF242829),
                          selectedShadowColor: Colors.black,
                          label: Text(
                            'Show Markers',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily:
                                  GoogleFonts.jetBrainsMono().fontFamily,
                              fontSize: 12,
                            ),
                          ),
                          selected: _showMarkers,
                          onSelected: (bool selected) {
                            setState(() {
                              _showMarkers = selected;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                !(keyboardState == KeyboardState.visible ||
                        keyboardState == KeyboardState.visibling ||
                        keyboardState == KeyboardState.hiding)
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0.0, 90.0),
                        child: ExpandableFab(
                          pos: ExpandableFabPos.right,
                          overlayStyle: ExpandableFabOverlayStyle(
                            color: Colors.black.withOpacity(0.5),
                            blur: 0.2,
                            // borderRadius: BorderRadius.circular(100),
                          ),
                          type: ExpandableFabType.up,
                          distance: 60,
                          openButtonBuilder: FloatingActionButtonBuilder(
                            size: 170,
                            builder: (BuildContext context,
                                void Function()? onPressed,
                                Animation<double> progress) {
                              return Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  width: 110,
                                  decoration: const BoxDecoration(
                                    color: Color(
                                      0xFF242829,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(100)),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(8, 6, 8, 6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          Icons.report,
                                          color: Colors.white,
                                          size: 30.0,
                                        ),
                                        Text(
                                          "Report",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          closeButtonBuilder: FloatingActionButtonBuilder(
                            size: 170,
                            builder: (BuildContext context,
                                void Function()? onPressed,
                                Animation<double> progress) {
                              return Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  width: 46,
                                  decoration: const BoxDecoration(
                                    color: Color(
                                      0xFF242829,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(100)),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                                    child: Icon(
                                      Icons.close,
                                      color: Color(0xFFFF6666),
                                      size: 30.0,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          children: getFabElements(),
                        ),
                      )
                    : Container(),
                DraggableScrollableSheet(
                  controller: sheetController,
                  initialChildSize: _sheetPosition,
                  minChildSize: _sheetPosition,
                  maxChildSize: 1,
                  snap: true,
                  snapSizes: const [1.0],
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6666),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  width: 80,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: const Color(0x1E000000),
                                  ),
                                ),
                              ),
                              !emergencyMode
                                  ? const SizedBox(height: 10.0)
                                  : const SizedBox(height: 80.0),
                              Column(
                                children: [
                                  Center(
                                    child: Text(
                                      "EMERGENCY",
                                      style: GoogleFonts.jetBrainsMono(
                                        textStyle: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: !emergencyMode
                                              ? const Color(0x7F000000)
                                              : const Color(0xFFFFFFFF),
                                          fontSize: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                  emergencyMode
                                      ? Center(
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            "Calling the nearest police station in...",
                                            style: TextStyle(
                                              fontFamily:
                                                  GoogleFonts.jetBrainsMono()
                                                      .fontFamily,
                                              fontSize: 24,
                                              color: const Color(0x7F000000),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  emergencyMode
                                      ? Center(
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            "$emergencySeconds",
                                            style: TextStyle(
                                              fontFamily:
                                                  GoogleFonts.jetBrainsMono()
                                                      .fontFamily,
                                              fontSize: 128,
                                              color: const Color(0xFFFFFFFF),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NominatimAPI {
  // Searches the options, but injects a fake "network" delay.
  static Future<Iterable<LocData>> search(String query) async {
    if (query == '') {
      return const Iterable<LocData>.empty();
    }
    http.Response res = await http.get(
      Uri.parse(
          "https://nominatim.openstreetmap.org/search?q=$query&limit=5&format=json"),
    );
    if (res.statusCode != 200) {
      debugPrint("NON 200 CODE {$res.statusCode}");
      return const Iterable<LocData>.empty();
    }
    return _constructFromAPIResponse(res);
  }

  static Iterable<LocData> _constructFromAPIResponse(http.Response res) {
    debugPrint("Constructing");
    var parsedResponse = jsonDecode(res.body);
    // debugPrint(parsedResponse.toString());

    return (parsedResponse)
        .map<LocData>((dynamic e) => LocData(
              lat: double.parse(e['lat']),
              lon: double.parse(e['lon']),
              boundingBox:
                  e['boundingbox'].map<double>((e) => double.parse(e)).toList(),
              displayName: e['display_name'] as String,
              miniName: e['name'] as String,
            ))
        .toList();
  }
}

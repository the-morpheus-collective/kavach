import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavach/components/main_component.dart';
import 'package:kavach/components/my_map.dart';
import 'package:kavach/screens/vishnuScreen.dart';
import 'package:keyboard_detection/keyboard_detection.dart';

class FabData {
  final AssetImage image;
  final String text;
  final Color color;
  final void Function() onPressed;

  FabData({
    required this.image,
    required this.text,
    required this.color,
    required this.onPressed,
  });
}

final List<FabData> fabData = [
  FabData(
    image: const AssetImage("assets/images/fab/shield.png"),
    text: "Other",
    color: const Color(0xFFB3B3B3),
    onPressed: () {},
  ),
  FabData(
    image: const AssetImage("assets/images/fab/children.png"),
    text: "Children in Danger",
    color: const Color(0xFF7196F4),
    onPressed: () {},
  ),
  FabData(
    image: const AssetImage("assets/images/fab/street.png"),
    text: "Street Harassment",
    color: const Color(0xFF7FE3E6),
    onPressed: () {},
  ),
  FabData(
    image: const AssetImage("assets/images/fab/natural.png"),
    text: "Natural Disasters",
    color: const Color(0xFFE67F80),
    onPressed: () {},
  ),
  FabData(
    image: const AssetImage("assets/images/fab/volatile.png"),
    text: "Volatile Groups",
    color: const Color(0xFF97E67F),
    onPressed: () {},
  ),
  FabData(
    image: const AssetImage("assets/images/fab/harassment.png"),
    text: "Sexual Harassment",
    color: const Color(0xFFFF66BA),
    onPressed: () {},
  ),
  FabData(
    image: const AssetImage("assets/images/fab/theft.png"),
    text: "Theft/Pickpocketing",
    color: const Color(0xFFA57FE6),
    onPressed: () {},
  ),
  FabData(
    image: const AssetImage("assets/images/fab/physical.png"),
    text: "Physical Conflict",
    color: const Color(0xFFFFD666),
    onPressed: () {},
  ),
];

List<Widget> _getFabElements() {
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

  void sheetStateListener() {
    if (sheetController.size >= 0.9) {
      if (!emergencyMode) {
        setState(() {
          emergencyMode = true;
        });
      }
    } else {
      if (emergencyMode) {
        setState(() {
          emergencyMode = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    sheetController.addListener(sheetStateListener);
  }

  final double _sheetPosition = 0.13;

  @override
  Widget build(BuildContext context) {
    return KeyboardDetection(
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
              const Center(
                child: MyMap(),
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
                child: TextFormField(
                    // controller: _controller,
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
                      contentPadding:
                          const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
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
                    onTap: () {}),
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
                        children: _getFabElements(),
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
                builder:
                    (BuildContext context, ScrollController scrollController) {
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
                            const SizedBox(height: 10.0),
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
    );
  }
}

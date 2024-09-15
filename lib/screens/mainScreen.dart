import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavach/components/my_map.dart';
import 'package:kavach/screens/vishnuScreen.dart';

class OptionData {
  final IconData image;
  final String text;
  final Widget route;

  OptionData({required this.image, required this.text, required this.route});
}

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

final List<OptionData> options = <OptionData>[
  OptionData(
    image: Icons.home,
    text: "Home",
    route: const MainScreen(),
  ),
  OptionData(
    image: Icons.share_location,
    text: "Vishnu",
    route: const VishnuScreen(),
  ),
  OptionData(
    image: Icons.report,
    text: "My Reports",
    route: const MainScreen(),
  ),
  OptionData(
    image: Icons.person,
    text: "My Account",
    route: const MainScreen(),
  )
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xffffffff),
      appBar: !emergencyMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.menu,
                  size: 40,
                  color: Color(0xff242829),
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              actions: [
                IconButton(
                  icon: const Center(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          NetworkImage("https://placehold.co/200/png"),
                    ),
                  ),
                  onPressed: () {},
                ),
              ],
              backgroundColor: const Color(0xffffffff),
              title: const Image(
                image: AssetImage("assets/images/title_image.png"),
                height: 50,
              ),
              centerTitle: true,
            )
          : null,
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
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            Padding(
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
                  builder: (BuildContext context, void Function()? onPressed,
                      Animation<double> progress) {
                    return Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 110,
                        decoration: const BoxDecoration(
                          color: Color(
                            0xFF242829,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(8, 6, 8, 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  builder: (BuildContext context, void Function()? onPressed,
                      Animation<double> progress) {
                    return Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 46,
                        decoration: const BoxDecoration(
                          color: Color(
                            0xFF242829,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(100)),
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
            ),
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
      drawer: Drawer(
        shape: const RoundedRectangleBorder(/* border radius = 0 */),
        backgroundColor: const Color(0xFFFFFFFF),
        child: SafeArea(
          child: Column(
            children: [
              const Image(
                image: AssetImage("assets/images/title_image.png"),
                height: 70,
              ),
              Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 20,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: "Hey, "),
                      TextSpan(
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                        text: "Vardhaman",
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Color(0xff000000),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  var option = options[index];
                  return ListTile(
                    leading: Icon(
                      option.image,
                      size: 60,
                      color: const Color(0xff000000),
                    ),
                    title: Text(
                      option.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      // route to option.route widget
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return option.route;
                          },
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(
                  color: Color(0xff000000),
                ),
              ),
              const Divider(
                color: Color(0xff000000),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

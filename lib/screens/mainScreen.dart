import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavach/components/my_map.dart';

class OptionData {
  final IconData image;
  final String text;
  final Widget route;

  OptionData({required this.image, required this.text, required this.route});
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
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

  final List<OptionData> options = <OptionData>[
    OptionData(
      image: Icons.home,
      text: "Home",
      route: const MainScreen(),
    ),
    OptionData(
      image: Icons.share_location,
      text: "Vishnu",
      route: const MainScreen(),
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
            const Text("You only live once. Save yourself."),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 4.0, 90.0),
              child: ExpandableFab(
                // pos: ExpandableFabPos.right,
                type: ExpandableFabType.up,
                distance: 50,
                openButtonBuilder: FloatingActionButtonBuilder(
                  size: 100,
                  builder: (BuildContext context, void Function()? onPressed,
                      Animation<double> progress) {
                    return Container(
                      width: 130,
                      decoration: const BoxDecoration(
                        color: Color(
                          0xFF242829,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.report,
                              color: Colors.white,
                              size: 40.0,
                            ),
                            Text(
                              "Report",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                closeButtonBuilder: FloatingActionButtonBuilder(
                  size: 100,
                  builder: (BuildContext context, void Function()? onPressed,
                      Animation<double> progress) {
                    return Container(
                      width: 64,
                      decoration: const BoxDecoration(
                        color: Color(
                          0xFF242829,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.close,
                          color: Color(0xFFFF6666),
                          size: 40.0,
                        ),
                      ),
                    );
                  },
                ),
                children: [
                  FloatingActionButton.small(
                    heroTag: null,
                    child: const Icon(Icons.edit),
                    onPressed: () {},
                  ),
                  FloatingActionButton.small(
                    heroTag: null,
                    child: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                ],
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

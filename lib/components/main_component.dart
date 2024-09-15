import 'package:flutter/material.dart';
import 'package:kavach/screens/mainScreen.dart';
import 'package:kavach/screens/vishnuScreen.dart';

class OptionData {
  final IconData image;
  final String text;
  final Widget route;

  OptionData({required this.image, required this.text, required this.route});
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

final Widget myDrawer = Drawer(
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
          separatorBuilder: (BuildContext context, int index) => const Divider(
            color: Color(0xff000000),
          ),
        ),
        const Divider(
          color: Color(0xff000000),
        ),
      ],
    ),
  ),
);

AppBar getAppBar(GlobalKey<ScaffoldState> scaffoldKey) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(
        Icons.menu,
        size: 40,
        color: Color(0xff242829),
      ),
      onPressed: () {
        scaffoldKey.currentState?.openDrawer();
      },
    ),
    actions: [
      IconButton(
        icon: const Center(
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage("https://placehold.co/200/png"),
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
  );
}

import 'package:flutter/material.dart';
import 'package:kavach/screens/mainScreen.dart';
import 'package:kavach/screens/vishnuScreen.dart';
import 'package:kavach/screens/reportsScreen.dart';
import 'package:kavach/screens/profileScreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kavach/secrets.dart' as s;

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
    route: const ReportsScreen(),
  ),
  OptionData(
    image: Icons.person,
    text: "My Account",
    route: const ProfileScreen(),
  )
];

final supabaseClient = SupabaseClient(s.supabaseUrl, s.supabaseAnonKey);
final _storage = const FlutterSecureStorage();

Future<String?> getPhoneNumber() async {
  final user = await _storage.read(key: 'user_id');
  print(user);
  return user;
}

Future<String?> getUserName() async {
  final phoneNumber = await getPhoneNumber();
  final response = await supabaseClient
      .from('users')
      .select()
      .eq('phone_number', phoneNumber as Object);

  if (response.length == 0) {
    return null;
  }

  return response[0]['username'] as String;
}

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
          child: FutureBuilder<String?>(
            future: getUserName(),
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 20,
                  ),
                  children: <TextSpan>[
                    const TextSpan(text: "Hey, "),
                    TextSpan(
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                      text: snapshot.data?.split(" ")[0],
                    )
                  ],
                ),
              );
            },
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
        onPressed: () {
          // route to profile screen
          BuildContext context = scaffoldKey.currentContext!;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return options[3].route;
              },
            ),
          );
        },
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

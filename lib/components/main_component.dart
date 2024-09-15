import 'package:flutter/material.dart';
import 'package:kavach/screens/mainScreen.dart';
import 'package:kavach/screens/vishnuScreen.dart';
import 'package:kavach/screens/reportsScreen.dart';
import 'package:kavach/screens/profileScreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kavach/secrets.dart' as s;

class LocData {
  final double lat;
  final double lon;
  final List<double> boundingBox;
  final String displayName;
  final String miniName;

  LocData({
    required this.lat,
    required this.lon,
    required this.boundingBox,
    required this.displayName,
    required this.miniName,
  });

  @override
  String toString() {
    return miniName;
  }
}

enum TypeFilter {
  other,
  children,
  street,
  natural,
  volatile,
  harassment,
  theft,
  physical
}

TypeFilter getTypeFilter(String text) {
  switch (text) {
    case "Other":
      return TypeFilter.other;
    case "Children in Danger":
      return TypeFilter.children;
    case "Street Harassment":
      return TypeFilter.street;
    case "Natural Disasters":
      return TypeFilter.natural;
    case "Volatile Groups":
      return TypeFilter.volatile;
    case "Sexual Harassment":
      return TypeFilter.harassment;
    case "Theft/Pickpocketing":
      return TypeFilter.theft;
    case "Physical Conflict":
      return TypeFilter.physical;
    default:
      throw Exception("Invalid text: $text");
  }
}

// make reverse getTypeFilter
String getTextFromTypeFilter(TypeFilter filter) {
  switch (filter) {
    case TypeFilter.other:
      return "Other";
    case TypeFilter.children:
      return "Children in Danger";
    case TypeFilter.street:
      return "Street Harassment";
    case TypeFilter.natural:
      return "Natural Disasters";
    case TypeFilter.volatile:
      return "Volatile Groups";
    case TypeFilter.harassment:
      return "Sexual Harassment";
    case TypeFilter.theft:
      return "Theft/Pickpocketing";
    case TypeFilter.physical:
      return "Physical Conflict";
    default:
      throw Exception("Invalid filter: $filter");
  }
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
    return "Placeholder User";
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
        FutureBuilder<String?>(
            future: getUserName(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Center(
                child: RichText(
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
                        text: snapshot.data,
                      )
                    ],
                  ),
                ),
              );
            }),
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

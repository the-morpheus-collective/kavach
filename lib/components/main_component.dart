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

Color getColor(TypeFilter fitler) {
  switch (fitler) {
    case TypeFilter.other:
      return const Color(0xFFB3B3B3);
    case TypeFilter.children:
      return const Color(0xFF7196F4);
    case TypeFilter.street:
      return const Color(0xFF7FE3E6);
    case TypeFilter.natural:
      return const Color(0xFFE67F80);
    case TypeFilter.volatile:
      return const Color(0xFF97E67F);
    case TypeFilter.harassment:
      return const Color(0xFFFF66BA);
    case TypeFilter.theft:
      return const Color(0xFFA57FE6);
    case TypeFilter.physical:
      return const Color(0xFFFFD666);
  }
}

String getSafetyContent(String text) {
  if (text.contains("Other")) {
    return "Find a safe place where many people are around. Usually, this is a public place like a store or a restaurant.";
  } else if (text.contains("Children in Danger")) {
    return "If you feel unsafe, stay calm, find a safe place, and tell a trusted adult right away.";
  } else if (text.contains("Street Harassment")) {
    return "If someone harasses you, stay calm, move to a safe area, and seek help from people nearby.";
  } else if (text.contains("Natural Disasters")) {
    return "Stay calm, follow safety plans, and move to a safe area. Listen to authorities for updates.";
  } else if (text.contains("Volatile Groups")) {
    return "Avoid engaging, keep your distance, and move to a safe, well-lit area. Seek help if needed.";
  } else if (text.contains("Sexual Harassment")) {
    return "Say 'no,' leave the situation immediately, and tell a trusted authority for help.";
  } else if (text.contains("Theft/Pickpocketing")) {
    return "Stay calm, don't resist. Memorize details and report the incident later.";
  } else if (text.contains("Physical Conflict")) {
    return "Avoid fighting back, try to leave safely, and seek help from an authority. You can use the SOS feature to alert your contacts.";
  } else {
    return "No Tips Available";
  }
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
            backgroundImage: NetworkImage(
                "https://media.licdn.com/dms/image/v2/D5603AQG_NY3QFhBNbg/profile-displayphoto-shrink_400_400/profile-displayphoto-shrink_400_400/0/1669039087919?e=1732147200&v=beta&t=7hw1GZQLgc6tqXCIuJ7iodUzH3iOQLALrZR0bWdfd0s"),
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

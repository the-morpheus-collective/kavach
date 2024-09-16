import 'package:flutter/material.dart';
import 'package:kavach/components/main_component.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:share_plus/share_plus.dart';

class VishnuScreen extends StatefulWidget {
  const VishnuScreen({super.key});

  @override
  State<VishnuScreen> createState() => _VishnuState();
}

class _VishnuState extends State<VishnuScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final supabaseClient = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  Future<String?> getPhoneNumber() async {
    final user = await _storage.read(key: 'user_id');
    print(user);
    return user;
  }

  Future<String> _getJourneyId() async {
    print("DEBUG: Getting journey id");
    var phoneNumber = await getPhoneNumber();
    final user = await supabaseClient
        .from('users')
        .select()
        .eq('phone_number', phoneNumber as Object);

    return user[0]['user_id'] as String;
  }

  @override
  Widget build(BuildContext context) {
    print("Vishnu Screen");

    const blue = Color(0xFF7196F4);
    const heroIcon = Icon(
      Icons.share_location,
      color: blue,
      size: 192.0,
    );
    const vishnuText = Text(
      "Vishnu",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 64, color: blue, fontWeight: FontWeight.bold),
    );

    const subtitleText = Text(
      "Share your location with your loved ones, ensuring a safe journey",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
    );

    const borderStyling = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
      borderSide: BorderSide(color: Colors.black, width: 2.0),
    );

    var fromTextInput = TextField(
      controller: _fromController,
      decoration: const InputDecoration(
        labelText: "From",
        suffixIcon: Icon(Icons.search),
        enabledBorder: borderStyling,
        focusedBorder: borderStyling,
      ),
    );

    var toTextInput = TextField(
      controller: _toController,
      decoration: const InputDecoration(
          labelText: "To",
          suffixIcon: Icon(Icons.search),
          enabledBorder: borderStyling,
          focusedBorder: borderStyling),
    );

    const space = SizedBox(
      width: 12,
      height: 12,
    );

    const spacer = Spacer();

    Widget shareButtonContainer = GestureDetector(
      onTap: () async {
        print("DEBUG: Share button pressed");

        var journeyId = await _getJourneyId();
        Share.share(
            'You can track my commute here: http://localhost:3000/$journeyId',
            subject: 'Track Me!');
      },
      child: Container(
        height: 64.0,
        width: 128.0,
        decoration: BoxDecoration(
          border: const Border(
            left: BorderSide(color: Colors.black, width: 2.0),
            top: BorderSide(color: Colors.black, width: 2.0),
            right: BorderSide(color: Colors.black, width: 6.0),
            bottom: BorderSide(color: Colors.black, width: 6.0),
          ),
          borderRadius: BorderRadius.circular(16.0),
          color: Color(0xFF95F6A7),
        ),
        child: const Icon(Icons.share, size: 28, color: Colors.black),
      ),
    );

    print("Scafflod key");

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: myDrawer,
      appBar: getAppBar(_scaffoldKey),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            space,
            heroIcon,
            vishnuText,
            subtitleText,
            space,
            fromTextInput,
            space,
            toTextInput,
            spacer,
            shareButtonContainer,
            space,
          ],
        ),
      ),
    );
  }
}

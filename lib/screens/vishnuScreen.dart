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
  // final TextEditingController _fromController = TextEditingController();
  // final TextEditingController _toController = TextEditingController();

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

    String? FROMsearchingWithQuery;
    LocData? FROMselectedLocation;
    late Iterable<LocData> FROMlastOptions = <LocData>[];

    var fromTextInput = LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<LocData>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            FROMsearchingWithQuery = textEditingValue.text;
            final Iterable<LocData> options =
                await NominatimAPI.search(FROMsearchingWithQuery!);

            // If another search happened after this one, throw away these options.
            // Use the previous options instead and wait for the newer request to
            // finish.
            if (FROMsearchingWithQuery != textEditingValue.text) {
              return FROMlastOptions;
            }

            FROMlastOptions = options;
            return options;
          },
          onSelected: (LocData selection) {
            setState(() {
              FROMselectedLocation = selection;
              FROMsearchingWithQuery = selection.miniName;
            });
            FocusScope.of(context).unfocus();
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: constraints.biggest.width,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return Column(
                          children: [
                            GestureDetector(
                              child: Container(
                                width: constraints.biggest.width,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: const Border.fromBorderSide(
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
          fieldViewBuilder: (context, controller, node, onFieldSubmitted) {
            return TextFormField(
                controller: controller,
                focusNode: node,
                onFieldSubmitted: (value) {
                  onFieldSubmitted();
                },
                decoration: InputDecoration(
                  hintText: 'From',
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
                onTap: () {});
          },
        );
      },
    );
    String? TOsearchingWithQuery;
    LocData? TOselectedLocation;
    late Iterable<LocData> TOlastOptions = <LocData>[];

    var toTextInput = LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<LocData>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            TOsearchingWithQuery = textEditingValue.text;
            final Iterable<LocData> options =
                await NominatimAPI.search(TOsearchingWithQuery!);

            // If another search happened after this one, throw away these options.
            // Use the previous options instead and wait for the newer request to
            // finish.
            if (TOsearchingWithQuery != textEditingValue.text) {
              return TOlastOptions;
            }

            TOlastOptions = options;
            return options;
          },
          onSelected: (LocData selection) {
            setState(() {
              TOselectedLocation = selection;
              TOsearchingWithQuery = selection.miniName;
            });
            FocusScope.of(context).unfocus();
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: constraints.biggest.width,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return Column(
                          children: [
                            GestureDetector(
                              child: Container(
                                width: constraints.biggest.width,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: const Border.fromBorderSide(
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
          fieldViewBuilder: (context, controller, node, onFieldSubmitted) {
            return TextFormField(
                controller: controller,
                focusNode: node,
                onFieldSubmitted: (value) {
                  onFieldSubmitted();
                },
                decoration: InputDecoration(
                  hintText: 'To',
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
                onTap: () {});
          },
        );
      },
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
            'You can track my commute here: http://kavach.thepjr.com/$journeyId',
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
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: myDrawer,
      appBar: getAppBar(_scaffoldKey),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: ListView(
          children: <Widget>[
            space,
            heroIcon,
            vishnuText,
            subtitleText,
            space,
            fromTextInput,
            space,
            toTextInput,
            // spacer,
            const SizedBox(
              height: 160,
            ),
            shareButtonContainer,
            space,
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kavach/components/main_component.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:ui';

final List<String> events = [
  "Other",
  "Children in Danger",
  "Street Harassment",
  "Natural Disasters",
  "Volatile Groups",
  "Sexual Harassment",
  "Theft/Pickpocketing",
  "Physical Conflict"
];

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsState();
}

class _ReportsState extends State<ReportsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DropdownMenuItem<String>> simplified_events = events.map((String value) {
    return DropdownMenuItem<String>(value: value, child: Text(value));
  }).toList();
  final supabaseClient = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();
  List<Widget> _report_widgets = [];
  String dropdownValue = events.first;
  bool chosen = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    const space = const SizedBox(
      width: 12,
      height: 12,
    );

    const half_space = const SizedBox(
      width: 8,
      height: 8,
    );
    const red = const Color(0xFFFF6666);
    const gray = const Color(0xFF242829);
    const green = const Color(0xFF95F6A7);
    const hero_icon = const Icon(
      Icons.report,
      color: red,
      size: 192.0,
    );

    void editReport() {
      print("hey!");
      showModalBottomSheet<void>(
        // context and builder are
        // required properties in this widget
        context: context,
        builder: (BuildContext context) {
          const border_styling = const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
            borderSide: BorderSide(color: Colors.black, width: 2.0),
          );

          const additional_details = const TextField(
            decoration: InputDecoration(
              labelText: "Additional Details",
              enabledBorder: border_styling,
              focusedBorder: border_styling,
            ),
          );

          print("isee");
          print(chosen);
          DropdownButton incident_type = DropdownButton(
              items: simplified_events,
              isExpanded: true,
              hint: Text("  " + dropdownValue),
              onChanged: (newValue) {
                setState(() {
                  dropdownValue = newValue;
                  chosen = true;
                });
              });

          Container dropdown_wrapper = Container(
              decoration: BoxDecoration(
                border: const Border(
                  top: BorderSide(color: Colors.black, width: 2),
                  right: BorderSide(color: Colors.black, width: 2),
                  bottom: BorderSide(color: Colors.black, width: 2),
                  left: BorderSide(color: Colors.black, width: 2),
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: DropdownButtonHideUnderline(child: incident_type));

          return SizedBox(
              height: 480,
              child: SizedBox(
                  height: 256,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Editing Report',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 32)),
                        space,
                        additional_details,
                        space,
                        dropdown_wrapper,
                      ],
                    )),
                  )));
        },
      );
    }

    GestureDetector make_report_widget(String location, String date) {
      return GestureDetector(
          onTap: editReport,
          child: Container(
            decoration: BoxDecoration(
              border: const Border(
                top: BorderSide(color: Colors.black, width: 2),
                right: BorderSide(color: Colors.black, width: 2),
                bottom: BorderSide(color: Colors.black, width: 2),
                left: BorderSide(color: Colors.black, width: 2),
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  top: 8.0, bottom: 8.0, left: 18.0, right: 18.0),
              child: Row(
                children: [
                  Text(location, style: TextStyle(fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text(date),
                ],
              ),
            ),
          ));
    }

    const heading_text = const Text(
      "My Reports",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 64, color: red, fontWeight: FontWeight.bold),
    );

    const subtitle_text = const Text(
      "These are the reports you have done in the past, you can update them here",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
    );

    Future<String?> getPhoneNumber() async {
      final user = await _storage.read(key: 'user_id');
      print("Phone No: $user");
      return user;
    }

    Future<String> _getUserId() async {
      print("DEBUG: Getting journey id");
      var phoneNumber = await getPhoneNumber();
      print("DEBUG: Gettong db!");
      final user = await supabaseClient
          .from('users')
          .select()
          .eq('phone_number', phoneNumber as Object);

      print("DEBUG: User" + user[0]['user_id']);
      return user[0]['user_id'] as String;
    }

    void getReports() {
      // setState(() {
      //   const half_space = const SizedBox(
      //     width: 8,
      //     height: 8,
      //   );
      //   _report_widgets.addAll(
      //     <Widget>[make_report_widget("India Gate", "02-09-2024"), half_space],
      //   );
      // });

      setState(() {
        _isLoading = true;
      });

      _getUserId().then((value) {
        print(value);
        supabaseClient
            .from('incidents')
            .select()
            .eq('user_id', value)
            .then((response) {
          print(response);
          if (response.length == 0) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text('No reports found'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
          for (var i = 0; i < response.length; i++) {
            setState(() {
              _report_widgets.addAll([
                make_report_widget(
                    response[i]['created_at'], response[i]['description'])
              ]);
            });
          }
        });
      });

      setState(() {
        _isLoading = false;
      });
    }

    SizedBox add_report_button = SizedBox(
      width: double.infinity,
      child: OutlinedButton(
          onPressed: getReports,
          style: OutlinedButton.styleFrom(
              backgroundColor: green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              side: BorderSide(width: 2.0, color: Colors.black)),
          child: const Row(children: <Widget>[
            const Text('Fetch my reports',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                )),
            const Spacer(),
            const Icon(Icons.add)
          ])),
    );

    if (_report_widgets.length < 1) _report_widgets.add(add_report_button);
    Container all_reports = Container(
      height: 256,
      child: ListView.builder(
        itemCount: _report_widgets.length,
        itemBuilder: (BuildContext context, int index) {
          return _report_widgets[index];
        },
      ),
    );

    return Stack(children: [
      Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        drawer: myDrawer,
        appBar: getAppBar(_scaffoldKey),
        body: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              hero_icon,
              heading_text,
              subtitle_text,
              space,
              all_reports,
            ],
          ),
        ),
      ),
      if (_isLoading)
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: LoadingAnimationWidget.beat(color: Colors.white, size: 50),
            ),
          ),
        ),
    ]);
  }
}

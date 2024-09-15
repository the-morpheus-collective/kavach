import 'package:flutter/material.dart';
import 'package:kavach/components/main_component.dart';
import 'package:kavach/screens/mainScreen.dart';

final List<String> events = fabData.map((event) => event.text).toList();

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsState();
}

class _ReportsState extends State<ReportsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DropdownMenuItem<String>> simplified_events = events.map((String value) {
                return DropdownMenuItem<String>(
                    value: value, child: Text(value));
              }).toList();
  List<Widget> _report_widgets = [];
  String dropdownValue = events.first;
  bool chosen = false;

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

          const report_location = const TextField(
            decoration: InputDecoration(
              labelText: "Report location",
              enabledBorder: border_styling,
              focusedBorder: border_styling,
            ),
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
              hint: Text("  "+dropdownValue),
              onChanged: (newValue) {
                        setState(() {
                        dropdownValue = newValue;
                        chosen = true;
                        });
                    });
              
          Container dropdown_wrapper = Container(
            decoration: BoxDecoration(
              border: Border(
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
                        Text('Editing Report',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 32)),
                        space,
                        report_location,
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
              border: Border(
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

    void _update_report_widgets() {
      setState(() {
        const half_space = const SizedBox(
          width: 8,
          height: 8,
        );
        _report_widgets.addAll(
          <Widget>[make_report_widget("India Gate", "02-09-2024"), half_space],
        );
      });
    }

    SizedBox add_report_button = SizedBox(
      width: double.infinity,
      child: OutlinedButton(
          onPressed: _update_report_widgets,
          style: OutlinedButton.styleFrom(
              backgroundColor: green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              side: BorderSide(width: 2.0, color: Colors.black)),
          child: const Row(children: <Widget>[
            const Text('Add a report',
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
      height: 320,
      child: ListView.builder(
        itemCount: _report_widgets.length,
        itemBuilder: (BuildContext context, int index) {
          return _report_widgets[index];
        },
      ),
    );

    return Scaffold(
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
    );
  }
}

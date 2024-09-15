import 'package:flutter/material.dart';


Container make_contact_widget(String name, int phone_number) {
    return Container (
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: Colors.black, width: 2),
                right: BorderSide(color: Colors.black, width: 2),
                bottom: BorderSide(color: Colors.black, width: 2),
                left: BorderSide(color: Colors.black, width: 2),
            ),
            borderRadius: BorderRadius.circular(16.0)
        ), 
        child: Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 18.0, right: 18.0),
            child:            Row(children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
            Spacer(),
            Text("$phone_number"),
        ],)),
    );
}

class VishnuScreen extends StatefulWidget {
  const VishnuScreen({super.key});

  @override
  State<VishnuScreen> createState() => _VishnuState();
}

class _VishnuState extends State<VishnuScreen> {
  @override
  Widget build(BuildContext context) {
    const blue = const Color(0xFF7196F4);
    const dark_blue = const Color(0xFF0B308E);
    const green = const Color(0xFF95F6A7);
    const hero_icon = const Icon(
      Icons.share_location,
      color: blue,
      size: 192.0,
    );
    const vishnu_text = const Text("Vishnu",
        textAlign: TextAlign.center,
        style:
            TextStyle(fontSize: 64, color: blue, fontWeight: FontWeight.bold));

    const subtitle_text = const Text(
      "Share your location with your loved ones, ensuring a safe journey",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
    );

    const border_styling = const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: Colors.black, width: 2.0));

    const from_text_input = const TextField(
      decoration: InputDecoration(
        labelText: "From",
        suffixIcon: Icon(Icons.search),
        enabledBorder: border_styling,
        focusedBorder: border_styling,
      ),
    );

    const to_text_input = const TextField(
      decoration: InputDecoration(
          labelText: "To",
          suffixIcon: Icon(Icons.search),
          enabledBorder: border_styling,
          focusedBorder: border_styling),
    );

    const space = const SizedBox(
      width: 12,
      height: 12,
    );
    
    const half_space = const SizedBox(
      width: 8,
      height: 8,
    );

    const divider = const Divider(thickness: 2, color: Colors.black);

    List<Widget> contact_widgets = <Widget>[];
    Column contact_holder = Column(
            children: contact_widgets);

    OutlinedButton submit_button = OutlinedButton(
        child: 
        const Row(
            children: <Widget> [
                 const Text('Share Location', style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                ),),
                Spacer(),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white,size: 28,)
            ]
        ),
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ));
    OutlinedButton share_button = OutlinedButton(
        child: Icon(Icons.share, size: 28, color: Colors.black),
        onPressed: (){},
        style: OutlinedButton.styleFrom(
            backgroundColor: green,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            side: BorderSide(color: Colors.black)
        )
    );

    Container submit_button_container = Container(
        height: 64.0,
        width: 272.0,
        decoration:  BoxDecoration(
            border: const Border(
          left: const BorderSide(color: dark_blue, width: 2.0),
          top: const BorderSide(color: dark_blue, width: 2.0),
          right: const BorderSide(color: dark_blue, width: 6.0),
          bottom: const BorderSide(color: dark_blue, width: 6.0),
            ),
            borderRadius: BorderRadius.circular(16.0)
        ),
        child: submit_button
    );

    Container share_button_container = Container(
        height: 64.0,
        decoration:  BoxDecoration(
            border: const Border(
          left: const BorderSide(color: Colors.black, width: 2.0),
          top: const BorderSide(color: Colors.black, width: 2.0),
          right: const BorderSide(color: Colors.black, width: 6.0),
          bottom: const BorderSide(color: Colors.black, width: 6.0),
            ),
            borderRadius: BorderRadius.circular(16.0)
        ),
        child: share_button
    );

    Row bottom_buttons = Row(children: [
        submit_button_container,
        Spacer(),
        share_button_container
    ],);

    SizedBox add_contact_button = SizedBox(
      width: double.infinity,
      child: OutlinedButton(
          onPressed: () {
                contact_holder.children.addAll(
                    <Widget>[
                        make_contact_widget("Pranjal Rastogi", 9910708969),
                        half_space
                    ]
                );
            setState(() {
              
            });
          },
          style: OutlinedButton.styleFrom(
              backgroundColor: green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              side: BorderSide(width: 2.0, color: Colors.black)),
          child: const Row(children: <Widget>[
            const Text('Add contacts',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                )),
            const Spacer(),
            const Icon(Icons.add)
          ])),
    );

    contact_widgets.add(add_contact_button);
    Container all_contacts = Container (
        height: 169,
        child: SingleChildScrollView(
            child: contact_holder));

    return Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.menu),
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  hero_icon,
                  vishnu_text,
                  subtitle_text,
                  space,
                  from_text_input,
                  space,
                  to_text_input,
                  divider,
                  all_contacts,
                  divider,
                  bottom_buttons
                ])));
  }
}

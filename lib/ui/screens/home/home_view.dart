import 'package:cetis30_app_registro/ui/res/colors.dart';
import 'package:cetis30_app_registro/ui/screens/home/popup_menu_widget.dart';
import 'package:cetis30_app_registro/ui/widgets/whatsapp_button.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/menu_button2.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _header(context),
        body: Stack(children: [
          Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: Column(children: [
                _body(context),
              ])),
        ]));
  }

  _header(context) {
    var headerFont = GoogleFonts.lato(
      color: Colors.white.withOpacity(0.8),
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );
    double screenWidth = MediaQuery.of(context).size.width;
    return PreferredSize(
        preferredSize: Size(screenWidth, 130),
        child: Container(
            color: AppColors.primary,
            child: Column(children: [
              SizedBox(height: 40),
              Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "profile");
                        },
                        child: Container(
                            child: CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 30,
                          ),
                        ))),
                    SizedBox(
                      width: 10,
                    ),
                    popupMenu(),
                    SizedBox(
                      width: 10,
                    )
                  ]))),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Image.asset(
                    'assets/img/logo-3.png',
                    color:
                        Colors.white.withOpacity(0.8), //AppColors.morenaColor,
                    width: 40,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "CETIS 30",
                    textAlign: TextAlign.center,
                    style: headerFont,
                    maxLines: 2,
                  )
                ],
              ),
              SizedBox(
                height: 0,
              ),
              Text(
                "Sistema Escolar Inteligente",
                style: TextStyle(color: Colors.white70),
              )
            ])));
  }

  Widget _body(BuildContext ctx) {
    return SingleChildScrollView(
      child: Container(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
              // height: 30,
              ),
          MenuButton2(
            title: "Accesos",
            icon: Icons.account_box_outlined,
            route: "access",
          ),
          MenuButton2(
              title: "Credencial Inteligente",
              // subtitle: "Descarga tu credencial escolar.",
              icon: Icons.ad_units_outlined,
              route: "credential"),
          SizedBox(
              //   height: 12,
              ),
          MenuButton2(
            title: "Recompensas",
            //subtitle: "Premios a la puntualidad y mas.",
            icon: Icons.star,
            route: "rewards",
            incoming: true,
          ),
          SizedBox(
            height: 30,
          ),
          WhatsappHelpBtn(context: ctx)
        ],
      )),
    );
  }
}

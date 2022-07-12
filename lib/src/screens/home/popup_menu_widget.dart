import 'dart:io';

import 'package:cetis32_app_registro/src/utils/constants.dart';
import 'package:cetis32_app_registro/src/utils/notify_ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/SignIn/SignInController.dart';
import '../../services/AuthenticationService.dart';
import '../../widgets/log_out_dialog.dart';

popupMenu() {
  return Align(
      alignment: Alignment.topLeft,
      child: PopupMenuButton(
        //color: Colors.white,
        icon: Icon(
          Icons.more_vert_rounded,
          color: Colors.white,
        ),
        itemBuilder: (BuildContext context2) => [
          _settingsItem(context2),
          _myDevicesItem(context2),
          _whatsapp(context2),
          _logoutItem(context2),
        ],
      ));
}

PopupMenuItem _settingsItem(BuildContext ctx) {
  return PopupMenuItem(
    onTap: () {
      Future.delayed(
          Duration(seconds: 0), () => Navigator.pushNamed(ctx, "settings"));
    },
    child: Row(
      children: [
        Icon(
          Icons.settings,
          color: Colors.black,
        ),
        Text("  Configuración"),
      ],
    ),
  );
}

PopupMenuItem _myDevicesItem(BuildContext ctx) {
  return PopupMenuItem(
    onTap: () {
      Future.delayed(
          Duration(seconds: 0), () => Navigator.pushNamed(ctx, "my-devices"));
    },
    child: Row(
      children: [
        Icon(
          Icons.phone_android_rounded,
          color: Colors.black,
        ),
        Text("  Mis dispositivos"),
      ],
    ),
  );
}

PopupMenuItem _logoutItem(BuildContext ctx) {
  return PopupMenuItem(
    onTap: () {
      Future.delayed(Duration(seconds: 0), () async {
        bool res = await showLogoutDialog(ctx, "main");
        if (res) {
          //   await SignInController().cleanAuthenticationData(ctx);
          //  AuthenticationService().signOut();
        }
      });
    },
    child: Row(
      children: [
        Icon(
          Icons.logout_rounded,
          color: Colors.black,
        ),
        Text("  Salir"),
      ],
    ),
  );
}

PopupMenuItem _whatsapp(BuildContext ctx) {
  return PopupMenuItem(
    onTap: () {
      enviarWhatsapp(ctx);
    },
    child: Row(
      children: [
        Icon(
          Icons.whatsapp_rounded,
          color: Colors.black,
        ),
        Text("  Ayuda Whatsapp"),
      ],
    ),
  );
}

enviarWhatsapp(BuildContext _context) async {
  var url =
      "whatsapp://send?phone=${AppConstants.whatsappNumber}&text=${AppConstants.whatsappText}, ";
  /* var url =
        "${AppConstants.whatsappNumber}?text=${AppConstants.whatsappText}"; */
  if (Platform.isIOS) {
    print('ios1');
    if (await canLaunch('whatsapp://')) {
      await launch(
          "whatsapp://wa.me/${AppConstants.whatsappNumber}?text=${AppConstants.whatsappText},",
          forceSafariVC: false);
    } else {
      print('android');

      await launch(url, forceSafariVC: true);
    }
  } else {
    await canLaunch(url)
        ? launch(url)
        : await NotifyUI.showBasic(_context, 'Aviso', 'WhatsApp no instalado');
  }
  /* await launch(
        "${AppConstants.whatsappNumber}?text=${AppConstants.whatsappText}"); */
}

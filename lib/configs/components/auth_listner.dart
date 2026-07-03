// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter/material.dart';
// import '../routes/routes_name.dart';
//
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
// class AuthListener {
//   static void init() {
//     Supabase.instance.client.auth.onAuthStateChange.listen((data) {
//       final session = data.session;
//
//       if (session != null) {
//         Future.delayed(const Duration(milliseconds: 300), () {
//           navigatorKey.currentState?.pushNamedAndRemoveUntil(
//             RoutesName.navBar,
//                 (route) => false,
//             arguments: "Login successful", // 🔥 message pass
//           );
//         });
//       }
//     });
//   }
// }
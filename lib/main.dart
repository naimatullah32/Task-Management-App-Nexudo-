import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_management/services/notification_service/notification_service.dart';
import 'package:task_management/view/Profile/profileView.dart';

import 'bloc/Home_Bloc/home_bloc.dart';
import 'bloc/Schedule_blocl/schedule_bloc.dart';
import 'bloc/addTask/add_task_bloc.dart';
import 'bloc/auth_bloc/auth_bloc.dart';
import 'bloc/profile_bloc/profile_bloc.dart';
import 'bloc/stats_block/stats_bloc.dart';
import 'bloc/theme_bloc/theme_bloc.dart';
import 'bloc/theme_bloc/theme_state.dart';

import 'configs/routes/routes.dart';
import 'configs/routes/routes_name.dart';
import 'configs/themes/theme_config.dart';

import 'dependency_injection/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://egfzfehewoxjkwiulyvb.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVnZnpmZWhld294amt3aXVseXZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5Nzk3MjAsImV4cCI6MjA5MTU1NTcyMH0.xARXHSvDhZFcs9fc9_lSzWbQKNwQf9UeXx8HoC51ADk',
  );

  /// Setup Dependency Injection
  await setupLocator();

  /// UI Settings
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.scheduleInactivityReminder();
    await notificationService.scheduleStreakWarning();
  } catch (e) {
    print("Notification Setup Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      // 🔥 THE FIX: Sirf tab redirect karo jab user sach mein Login ya Logout kare.
      // App start hone par (initialSession) ye code kuch nahi karega,
      // taake aapki Splash Screen aaram se apni animation poori kar sake!
      if (event == AuthChangeEvent.signedIn) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          RoutesName.navBar,
              (route) => false,
        );
      } else if (event == AuthChangeEvent.signedOut) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          RoutesName.welcome,
              (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (_) => locator<ThemeBloc>()),
        BlocProvider<AuthBloc>(create: (_) => locator<AuthBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => locator<ProfileBloc>()..add(ProfileLoadStarted())),
        BlocProvider<AddTaskBloc>(create: (_) => locator<AddTaskBloc>()),
        BlocProvider<ScheduleBloc>(create: (_) => locator<ScheduleBloc>()),
        BlocProvider<HomeBloc>(create: (_) => locator<HomeBloc>()),
        BlocProvider<StatsBloc>(create: (_) => locator<StatsBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Task Management App',

            themeMode: state.themeMode,
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,

            // 🔥 Ab initial route 100% respect hoga aur seedha Splash par jayega
            initialRoute: RoutesName.splash,
            onGenerateRoute: Routes.generateRoute,
          );
        },
      ),
    );
  }
}
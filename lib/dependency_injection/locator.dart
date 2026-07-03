import 'package:get_it/get_it.dart';
import 'package:task_management/bloc/Home_Bloc/home_bloc.dart';
import 'package:task_management/repository/profile_repository/profile_repo_impl.dart';
import '../bloc/Schedule_blocl/schedule_bloc.dart';
import '../bloc/addTask/add_task_bloc.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/profile_bloc/profile_bloc.dart';
import '../bloc/stats_block/stats_bloc.dart';
import '../repository/auth_repository/auth_repo.dart';
import '../repository/auth_repository/auth_repository_impl.dart';
import '../repository/profile_repository/profile_repo.dart';
import '../services/storage/local_storage.dart';
import '../bloc/theme_bloc/theme_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;

final locator = GetIt.instance;


Future<void> setupLocator() async {
  final supabase = Supabase.instance.client;
  // 1. Services (LocalStorage etc.)
  locator.registerLazySingleton<LocalStorage>(() => LocalStorage());

  // 2. Repositories
  // Humne interface (AuthRepository) ko implementation (AuthRepositoryImpl) ke sath bind kiya hai
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // 3. Blocs
  // ThemeBloc ko LocalStorage chahiye
  locator.registerFactory(() => ThemeBloc(locator<LocalStorage>()));

  // AuthBloc ko AuthRepository chahiye
  locator.registerFactory(() => AuthBloc(locator<AuthRepository>()));

  // --- ProfileBloc Registration ---
  // locator<AuthRepository>() automatically AuthRepositoryImpl inject kar dega
  // Repository
  locator.registerLazySingleton<SupabaseClient>(
          () => Supabase.instance.client);

  // locator.registerLazySingleton<ProfileRepository>(
  //         () => ProfileRepository());


  locator.registerLazySingleton<ProfileRepository>(() => ProfileRepository());

  // 3. BLoCs
  // locator.registerFactory(() => ThemeBloc(locator<LocalStorage>()));
  // locator.registerFactory(() => AuthBloc(locator<AuthRepository>()));
  locator.registerFactory(() => ProfileBloc(
    authRepo: locator<AuthRepository>(),
    profileRepo: locator<ProfileRepository>(),
  ));

  locator.registerFactory(() => AddTaskBloc());
  locator.registerFactory(() => ScheduleBloc());
  locator.registerFactory(() => HomeBloc());
  locator.registerFactory(() => StatsBloc());
}


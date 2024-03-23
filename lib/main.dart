import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khiem_vais_test/bloc/theme/theme_bloc.dart';
import 'package:khiem_vais_test/common/shared_prefs.dart';
import 'package:khiem_vais_test/page/list_task.dart';
import 'package:khiem_vais_test/res/string.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final themeBloc = ThemeBloc();
  bool _isLoadingTheme = true;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLoadingTheme();
    });

    super.initState();
  }

  _initLoadingTheme() {
    SharedPrefs.getIsDarkMode().then((value) {
      if (value) {
        themeBloc.add(ThemeEventToggleToDark());
      } else {
        themeBloc.add(ThemeEventToggleToLight());
      }
      _isLoadingTheme = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => themeBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return _isLoadingTheme
              ? const SizedBox()
              : MaterialApp(
                  debugShowCheckedModeBanner: kDebugMode,
                  title: AppString.titleApp,
                  theme: state.themeData,
                  home: const ListTask(),
                );
        },
      ),
    );
  }
}

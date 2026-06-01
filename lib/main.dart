import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/store.dart';
import 'screens/root_scaffold.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  final store = AppStore();
  await store.init();

  runApp(ListeoApp(store: store));
}

class ListeoApp extends StatelessWidget {
  final AppStore store;
  const ListeoApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: store,
      child: MaterialApp(
        title: 'Listeo',
        debugShowCheckedModeBanner: false,
        theme: LoTheme.themeData(),
        home: const RootScaffold(),
      ),
    );
  }
}

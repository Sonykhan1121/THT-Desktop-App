import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mydesktopapp/pages/mainscreen.dart';
import 'package:mydesktopapp/providers/profileprovider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
      url: 'https://ptkyjfnahmgfussqqsdu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0a3lqZm5haG1nZnVzc3Fxc2R1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU1MDIxMTAsImV4cCI6MjA2MTA3ODExMH0.8hFscrvETmL6hJZ0FKZK3ItDDtQOiPy75eYVK99zWIo',

  );


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}


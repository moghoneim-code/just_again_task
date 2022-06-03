import 'package:flutter/material.dart';
import 'package:justagain_task/Providers/exams_list_provider.dart';
import 'package:justagain_task/Providers/questions_list_providers.dart';
import 'package:justagain_task/Screens/add_newExam/addNewExam.dart';
import 'package:justagain_task/Screens/exams_screen/exams_screen.dart';
import 'package:justagain_task/Screens/main_page_screen/main_page_screen.dart';
import 'package:justagain_task/Screens/profile_screen/profile_screen.dart';
import 'package:justagain_task/Screens/start_exam_screen/start_exam_screen.dart';
import 'package:justagain_task/Screens/take_exam_screen/take_exam_screen.dart';
import 'package:justagain_task/screens/login_screen/login_screen.dart';
import 'package:justagain_task/transition_route_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Providers/user_provider.dart';
import 'Screens/add_new_question/add_new_question.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppUserProvider>(
            create: (_) => AppUserProvider()),
        ChangeNotifierProvider<ExamListProvider>(
            create: (_) => ExamListProvider()),
        ChangeNotifierProvider<QuestionListProvider>(
            create: (_) => QuestionListProvider())
      ],
      child: MaterialApp(
        title: 'Just Again',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.deepPurple,
          textSelectionTheme:
              const TextSelectionThemeData(cursorColor: Colors.indigoAccent),

          /// fontFamily: 'SourceSansPro',
          textTheme: TextTheme(
            headline3: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 45.0,
              // fontWeight: FontWeight.w400,
              color: Colors.orange,
            ),
            button: const TextStyle(
              fontFamily: 'OpenSans',
            ),
            caption: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
              color: Colors.deepPurple[300],
            ),
            headline1: const TextStyle(fontFamily: 'Quicksand'),
            headline2: const TextStyle(fontFamily: 'Quicksand'),
            headline4: const TextStyle(fontFamily: 'Quicksand'),
            headline5: const TextStyle(fontFamily: 'NotoSans'),
            headline6: const TextStyle(fontFamily: 'NotoSans'),
            subtitle1: const TextStyle(fontFamily: 'NotoSans'),
            bodyText1: const TextStyle(fontFamily: 'NotoSans'),
            bodyText2: const TextStyle(fontFamily: 'NotoSans'),
            subtitle2: const TextStyle(fontFamily: 'NotoSans'),
            overline: const TextStyle(fontFamily: 'NotoSans'),
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
              .copyWith(secondary: Colors.deepPurpleAccent),
        ),
        navigatorObservers: [TransitionRouteObserver()],
        initialRoute: (FirebaseAuth.instance.currentUser == null)
            ? LoginScreen.id
            : MainPageScreen.id,
        routes: {
          LoginScreen.id: (context) => const LoginScreen(),
          MainPageScreen.id: (context) => const MainPageScreen(),
          ProfileScreen.id: (context) => const ProfileScreen(),
          ExamsScreen.id: (context) => const ExamsScreen(),
          TakeExamScreen.id: (context) => const TakeExamScreen(),
          // StartExamScreen.id: (context) =>  StartExamScreen(),
        },
      ),
    );
  }
}

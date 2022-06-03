import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Providers/exams_list_provider.dart';
import '../../Providers/questions_list_providers.dart';
import '../../Providers/user_provider.dart';
import '../../widgets/brand_divider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class AddNewQuestion extends StatefulWidget {
  const AddNewQuestion({Key? key, required this.examID}) : super(key: key);
  static const String id = "AddNewExam";
  final String examID;

  @override
  State<AddNewQuestion> createState() => _AddNewQuestionState();
}

class _AddNewQuestionState extends State<AddNewQuestion> {
  String? selectedValue;
  String _answer1 = '';
  String _answer2 = '';
  String _answer3 = '';
  String _answer4 = '';
  String _answer5 = '';
  List<String> _answers = [];


  ExamListProvider? _examListProvider;
  QuestionListProvider? _questionListProvider;

  Color _selectedColor = Colors.deepPurple;
  Color _unselectedColor1 = Colors.black38;
  Color _unselectedColor2 = Colors.black38;
  Color _unselectedColor3 = Colors.black38;
  Color _unselectedColor4 = Colors.black38;
  Color _unselectedColor5 = Colors.black38;
  Color _unselectedColor = Colors.black38;

  String _selectedAnswer = '';
  String _question = '';

  Future<void> _sendToDatabase(context, String examId) async {
    final _user = Provider.of<AppUserProvider>(context, listen: false).appUser;
    if (_question.length < 2) {
      Fluttertoast.showToast(
          msg: "Please write a valid question",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (_selectedAnswer.isEmpty) {
      Fluttertoast.showToast(
          msg: "tab the right mark beside the right valid answer",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    _answers.addAll([
      if (_answer1.isNotEmpty) _answer1,
      if (_answer2.isNotEmpty) _answer2,
      if (_answer3.isNotEmpty) _answer3,
      if (_answer4.isNotEmpty) _answer4,
      if (_answer5.isNotEmpty) _answer5,
    ]);
    DocumentReference newQuesRef =
        FirebaseFirestore.instance.collection('questions').doc();
    Map<String, dynamic> questMap = {
      "answers": _answers.toList(),
      "correct_answer": _selectedAnswer,
      "question": _question,
      "exam_id": examId,
      'created_by': _user!.fullName,
      'created_at': Timestamp.now(),
    };

    newQuesRef.set(questMap);
    //removeValues();

    Fluttertoast.showToast(
        msg: "Success !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepPurpleAccent,
        textColor: Colors.white,
        fontSize: 16.0);

    ///Reloading data into state management
    _examListProvider = ExamListProvider.get(context);
    _examListProvider!.loadExams();
    _questionListProvider = QuestionListProvider.get(context);
    _questionListProvider!.loadQuestions(examID: examId);

    Navigator.pop(context);
  }

  void removeValues() {
    setState(() {
      //_answers.clear();
      _answer1 = '';
      _answer2 = '';
      _answer3 = '';
      _answer4 = '';
      _answer5 = '';
      _selectedAnswer = '';
      _question = '';
      _selectedColor = Colors.deepPurple;
      _unselectedColor1 = Colors.black38;
      _unselectedColor2 = Colors.black38;
      _unselectedColor3 = Colors.black38;
      _unselectedColor4 = Colors.black38;
      _unselectedColor5 = Colors.black38;
      _unselectedColor = Colors.black38;
    });
  }

  @override
  void dispose() {
    removeValues();
    super.dispose();
  }

  AppBar _buildAppBar(ThemeData theme) {
    final backButton = IconButton(
      icon: const Icon(FontAwesomeIcons.trash),
      onPressed: () {
        Navigator.pop(context);
      },
      color: Colors.deepPurple,
    );
    final saveButton = IconButton(
      icon: const Icon(FontAwesomeIcons.download),
      onPressed: () async {
        await _sendToDatabase(context, widget.examID);
      },
      color: Colors.deepPurple,
    );
    final title = Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Hero(
              tag: "logo_",
              child: Image.asset(
                'assets/logo.png',
                filterQuality: FilterQuality.high,
                height: 30,
                width: 30,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                  width: 100,
                  child: Text(
                    "Just Again",
                    style: TextStyle(color: Colors.orangeAccent),
                  )),
            ),
          ),
          // const SizedBox(width: 20),
        ],
      ),
    );
    return AppBar(
      leading: backButton,
      actions: <Widget>[
        saveButton,
      ],
      title: title,
      backgroundColor: theme.primaryColor.withOpacity(.13),
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _user = Provider.of<AppUserProvider>(context, listen: false).appUser;
    return Scaffold(
      appBar: _buildAppBar(theme),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //  Text(_answer1),
              Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _question = value;
                      });
                    },
                    decoration: InputDecoration(
                      label:
                          const Center(child: Text("What is Your Question ?")),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: Colors.deepPurpleAccent,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.deepPurple,
                          width: 2.0,
                        ),
                      ),
                    ),
                  )),

              /// i Could do it using ListView.Builder but i need every text controller separately
              ///
              ///
              ListTile(
                leading: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.check,
                    color: _unselectedColor1,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedAnswer = _answer1;
                      _unselectedColor1 = _selectedColor;
                      _unselectedColor2 = _unselectedColor;
                      _unselectedColor3 = _unselectedColor;
                      _unselectedColor4 = _unselectedColor;
                      _unselectedColor5 = _unselectedColor;
                    });
                  },
                ),
                title: Container(
                  height: 75,
                  width: 400,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _answer1 = value;
                      });
                    },

                    decoration: InputDecoration(
                      label: const Center(child: Text("Answer 1")),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Colors.lightGreen,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.check,
                    color: _unselectedColor2,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedAnswer = _answer2;
                      _unselectedColor1 = _unselectedColor;
                      _unselectedColor2 = _selectedColor;
                      _unselectedColor3 = _unselectedColor;
                      _unselectedColor4 = _unselectedColor;
                      _unselectedColor5 = _unselectedColor;
                    });
                  },
                ),
                title: Container(
                  height: 75,
                  width: 400,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _answer2 = value;
                      });
                    },

                    decoration: InputDecoration(
                      label: const Center(child: Text("Answer 2")),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Colors.lightGreen,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.check,
                    color: _unselectedColor3,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedAnswer = _answer3;
                      _unselectedColor1 = _unselectedColor;
                      _unselectedColor2 = _unselectedColor;
                      _unselectedColor3 = _selectedColor;
                      _unselectedColor4 = _unselectedColor;
                      _unselectedColor5 = _unselectedColor;
                    });
                  },
                ),
                title: Container(
                  height: 75,
                  width: 400,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _answer3 = value;
                      });
                    },

                    decoration: InputDecoration(
                      label: const Center(child: Text("Answer 3")),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Colors.lightGreen,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.check,
                    color: _unselectedColor4,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedAnswer = _answer4;
                      _unselectedColor1 = _unselectedColor;
                      _unselectedColor2 = _unselectedColor;
                      _unselectedColor3 = _unselectedColor;
                      _unselectedColor4 = Colors.deepPurple;
                      _unselectedColor5 = _unselectedColor;
                    });
                  },
                ),
                title: Container(
                  height: 75,
                  width: 400,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _answer4 = value;
                      });
                    },

                    decoration: InputDecoration(
                      label: const Center(child: Text("Answer 4")),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Colors.lightGreen,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.check,
                    color: _unselectedColor5,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedAnswer = _answer5;
                      _unselectedColor1 = _unselectedColor;
                      _unselectedColor2 = _unselectedColor;
                      _unselectedColor3 = _unselectedColor;
                      _unselectedColor4 = _unselectedColor;
                      _unselectedColor5 = _selectedColor;
                    });
                  },
                ),
                title: Container(
                  height: 75,
                  width: 400,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _answer5 = value;
                      });
                    },

                    decoration: InputDecoration(
                      label: const Center(child: Text("Answer 5")),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Colors.lightGreen,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:justagain_task/Providers/questions_list_providers.dart';
import 'package:justagain_task/Screens/add_new_question/add_new_question.dart';
import 'package:justagain_task/widgets/question_tile.dart';

import '../../Providers/user_provider.dart';
import '../../transition_route_observer.dart';
import 'package:fluttertoast/fluttertoast.dart';


class AddNewExam extends StatefulWidget {
  const AddNewExam({Key? key, required this.Examid}) : super(key: key);
  static const String id = "ExamScreen";

  final String Examid;

  @override
  State<AddNewExam> createState() => _AddNewExamState();
}

class _AddNewExamState extends State<AddNewExam> with SingleTickerProviderStateMixin, TransitionRouteAware {
  late Animation<double> _headerScaleAnimation;
  AnimationController? _loadingController;
  static const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);
  final routeObserver = TransitionRouteObserver<PageRoute?>();

  //final FirebaseAuth _auth = FirebaseAuth.instance;

  ScrollController? _scrollController;
  QuestionListProvider? _questionListProvider;
  DocumentReference newExam = FirebaseFirestore.instance.collection('exams').doc();
  TextEditingController examTitleController = TextEditingController();

  @override
  void initState() {
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );
    final _user = Provider.of<AppUserProvider>(context, listen: false).appUser;

    _headerScaleAnimation = Tween<double>(begin: .6, end: 1).animate(CurvedAnimation(
      parent: _loadingController!,
      curve: headerAniInterval,
    ));
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _questionListProvider = QuestionListProvider.get(context);
      _questionListProvider!.loadQuestions(examID: widget.Examid);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>?);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _loadingController!.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) _questionListProvider!.loadMoreQuestions(widget.Examid);
  }

  bool get _isBottom {
    if (!_scrollController!.hasClients) return false;
    final maxScroll = _scrollController!.position.maxScrollExtent;
    final currentScroll = _scrollController!.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  AppBar _buildAppBar(ThemeData theme) {
    final backButton = IconButton(
      icon: const Icon(FontAwesomeIcons.arrowRight),
      color: theme.colorScheme.secondary,
      onPressed: () {
        Navigator.pop(context);
      },
    );
    final title = Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: Hero(
              tag: "tag",
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
      // leading: menuBtn,
      actions: <Widget>[
        backButton,
      ],
      title: title,
      backgroundColor: theme.primaryColor.withOpacity(.1),
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          splashColor: theme.colorScheme.secondary,
          backgroundColor: Colors.white70,
          elevation: 3,
          tooltip: 'Add Question ',
          onPressed: () {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewQuestion(
                  examID: widget.Examid,
                ),
              ),
            );
          },
          child: Icon(
            Icons.add,
            color: theme.colorScheme.primary,
          )),
      appBar: _buildAppBar(theme),
      body: SafeArea(child: Consumer<QuestionListProvider>(
        builder: (context, provider, _) {
          final _questions = provider.questionsList;
          if (_questions == null) {
            return const Center(child: spinkit);
          }
          if (_questions.isEmpty) {
            return const Center(child: Text(" Add Your First Question !"));
          }
          return RefreshIndicator(
            onRefresh: () {
              return _questionListProvider!.loadQuestions(newData: false, examID: widget.Examid);
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 30.0),
              physics: const ScrollPhysics(),
              itemCount: provider.nextPage ? _questions.length + 1 : _questions.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (index >= _questions.length) return _buildLoadingIndicator();
                final _question = _questions[index];
                return Container(
                  color: index.isEven ? Colors.grey[200] : null,
                  child: QuestionTile(
                    questionModel: _question,
                    onPressed: () {},
                  ),
                );
              },
            ),
          );
        },
      )),
    );
  }

  Padding _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(top: 20),
      child: Center(child: spinkit),
    );
  }

  static const spinkit = SpinKitCubeGrid(
    color: Colors.deepPurpleAccent,
    size: 50.0,
  );

  Duration get loadTime => Duration(milliseconds: timeDilation.ceil() * 500);

  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    onPrimary: Colors.white70,
    primary: Colors.deepPurple,
    minimumSize: const Size(100, 50),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
  );

  Future<void> createExam(String examTitle) async {
    final _user = Provider.of<AppUserProvider>(context, listen: false).appUser;

    ///Prepare data to be saved on users table\\\

    Map<String, dynamic> examMap = {
      'created_at': Timestamp.now(),
      'created_by': _user!.fullName,
      'questionsList': [],
      'examTitle': examTitle,
      'taken_by': []
    };
    newExam.set(examMap);
  }
}

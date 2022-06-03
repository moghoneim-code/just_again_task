import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:justagain_task/Providers/answers_checker_provider.dart';
import 'package:provider/provider.dart';

import 'package:justagain_task/Models/qusetion_data.dart';
import 'package:justagain_task/Providers/questions_list_providers.dart';

import '../../Providers/user_provider.dart';
import '../../transition_route_observer.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StartExamScreen extends StatelessWidget {
  final String examId;

  const StartExamScreen({
    Key? key,
    required this.examId,
  }) : super(key: key);

  static const String id = "ExamScreen";

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => AnswersCheckerProvider(),
      child: _StartExamScreenView(examId: examId),
    );
  }
}

class _StartExamScreenView extends StatefulWidget {
  final String examId;

  const _StartExamScreenView({
    Key? key,
    required this.examId,
  }) : super(key: key);

  @override
  State<_StartExamScreenView> createState() => __StartExamScreenViewState();
}

class __StartExamScreenViewState extends State<_StartExamScreenView>
    with SingleTickerProviderStateMixin, TransitionRouteAware {
  late Animation<double> _headerScaleAnimation;
  AnimationController? _loadingController;
  static const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);
  final routeObserver = TransitionRouteObserver<PageRoute?>();

  ScrollController? _scrollController;
  QuestionListProvider? _questionListProvider;
  TextEditingController examTitleController = TextEditingController();

  @override
  void initState() {
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );
    final _user = Provider.of<AppUserProvider>(context, listen: false).appUser;

    _headerScaleAnimation =
        Tween<double>(begin: .6, end: 1).animate(CurvedAnimation(
      parent: _loadingController!,
      curve: headerAniInterval,
    ));
    //  _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _questionListProvider = QuestionListProvider.get(context);
      await _questionListProvider!.loadQuestions(examID: widget.examId);
      context
          .read<AnswersCheckerProvider>()
          .initWithQuestions(_questionListProvider!.questionsList ?? []);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(
        this, ModalRoute.of(context) as PageRoute<dynamic>?);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _loadingController!.dispose();
    super.dispose();
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
      actions: <Widget>[
        backButton,
      ],
      title: title,
      automaticallyImplyLeading: false,
      backgroundColor: theme.primaryColor.withOpacity(.1),
      elevation: 0,
    );
  }

  int totalGrades = 0;
  int grades = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _buildAppBar(theme),
      floatingActionButton: FloatingActionButton(
        child: const Icon(FontAwesomeIcons.gavel),
        onPressed: () {
          if (!context.read<AnswersCheckerProvider>().didAnswerAll()) {
            Fluttertoast.showToast(
                msg: "Please Answer the Remaining Questions !",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black38,
                textColor: Colors.white,
                fontSize: 16.0);
            return;
          }

          setState(() {
            grades = context
                .read<AnswersCheckerProvider>()
                .correctExam()
                .correctAnswers;
            totalGrades = context
                .read<AnswersCheckerProvider>()
                .correctExam()
                .totalQuestions;
          });

          _showResultDialog();

          log(context.read<AnswersCheckerProvider>().didAnswerAll().toString());
          log(context.read<AnswersCheckerProvider>().correctExam().toString());
        },
      ),
      body: SafeArea(
        child: Consumer<QuestionListProvider>(
          builder: (context, provider, _) {
            final _questions = provider.questionsList;
            if (_questions == null) {
              return const Center(child: spinkit);
            }
            if (_questions.isEmpty) {
              return const Center(child: Text(" No Questions Available !"));
            }

            return RefreshIndicator(
              onRefresh: () {
                return _questionListProvider!
                    .loadQuestions(examID: widget.examId);
              },
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 30.0),
                physics: const ScrollPhysics(),
                separatorBuilder: (_, __) => const Divider(),
                itemCount: provider.nextPage
                    ? _questions.length + 1
                    : _questions.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  if (index >= _questions.length)
                    return _buildLoadingIndicator();
                  final _question = _questions[index];
                  return QuestionListTile(
                    onSelected: (value) {
                      log("Answered {$value} for question {${_question.question}}");
                      context.read<AnswersCheckerProvider>().answerQuestion(
                            AnswerModel(
                              questionId: _question.exam_id,
                              correctAnswer: _question.correctAnswer,
                              answer: value,
                            ),
                          );
                    },
                    question: _question,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  _showResultDialog() async {
    final theme = Theme.of(context);
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
              insetPadding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0.0,
              backgroundColor: Colors.white,
              child: Container(
                  height: 200,
                  margin: const EdgeInsets.all(4),
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "You Have earned $grades out of $totalGrades",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                      ),
                      (grades >= 0.5 * totalGrades)
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                "Congratulations ! You have Passed :)",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                'Sorry but you have Failed ):',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 500,
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                style: raisedButtonStyle,
                                child: Text(
                                  "Ok",
                                  style: theme.textTheme.caption!
                                      .copyWith(color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ));
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
}

class QuestionListTile extends StatefulWidget {
  final ValueChanged<String>? onSelected;
  final QuestionModel question;

  const QuestionListTile({
    Key? key,
    this.onSelected,
    required this.question,
  }) : super(key: key);

  @override
  State<QuestionListTile> createState() => _QuestionListTileState();
}

class _QuestionListTileState extends State<QuestionListTile> {
  String? _currentAnswer;

  @override
  Widget build(BuildContext context) {
    final answers = widget.question.answers;
    return Column(
      children: [
        const SizedBox(height: 15),
        Text(
          widget.question.question,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          children: List.generate(answers.length, (index) {
            final answer = answers[index];
            return RadioListTile<String>(
              title: Text(answer),
              value: answer,
              groupValue: _currentAnswer,
              onChanged: (value) {
                _currentAnswer = value;
                widget.onSelected?.call(_currentAnswer!);
                if (mounted) {
                  setState(() {});
                }
              },
            );
          }),
        )
      ],
    );
  }
}

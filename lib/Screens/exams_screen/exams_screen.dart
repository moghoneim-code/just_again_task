import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:justagain_task/Providers/exams_list_provider.dart';
import 'package:justagain_task/Screens/add_newExam/addNewExam.dart';
import 'package:justagain_task/widgets/exams_tile.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../Providers/user_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../transition_route_observer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({Key? key}) : super(key: key);
  static const String id = "ExamScreen";

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen>
    with SingleTickerProviderStateMixin, TransitionRouteAware {
  late Animation<double> _headerScaleAnimation;
  AnimationController? _loadingController;
  static const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);
  final routeObserver = TransitionRouteObserver<PageRoute?>();

  //final FirebaseAuth _auth = FirebaseAuth.instance;

  ScrollController? _scrollController;
  ExamListProvider? _examListProvider;
  DocumentReference newExam =
      FirebaseFirestore.instance.collection('exams').doc();
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
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _examListProvider = ExamListProvider.get(context);
      _examListProvider!.loadExams();
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
    examTitleController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) _examListProvider!.loadMoreExams();
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
      automaticallyImplyLeading: false,
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
          tooltip: 'Add Exam',
          onPressed: () {
            _showDialog();
          },
          child: Icon(
            Icons.add,
            color: theme.colorScheme.primary,
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: _buildAppBar(theme),
      body: SafeArea(child: Consumer<ExamListProvider>(
        builder: (context, provider, _) {
          final _exams = provider.examsList;
          if (_exams == null) {
            return const Center(child: spinkit);
          }
          if (_exams.isEmpty) {
            return const Center(child: Text(" Add Your First Exam !"));
          }
          return RefreshIndicator(
            onRefresh: () {
              return _examListProvider!.loadExams(newData: false);
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 30.0),
              physics: const ScrollPhysics(),
              itemCount:  _exams.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (index >= _exams.length) return _buildLoadingIndicator();
                final _exam = _exams[index];
                return Container(
                  color: index.isEven ? Colors.grey[200] : null,
                  child: ExamTile(
                    examData: _exam,
                    loadingController: _loadingController,
                    onPressed: () {
                      print(_exam.createdBy);
                      Fluttertoast.showToast(
                          msg:
                              "You were supposed to edit the exam but Come on .. it is only a demo !",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    },
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

  _showDialog() async {
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
                  height: 300,
                  margin: const EdgeInsets.all(4),
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Please Specify the Exam Title",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(22.0),
                          child: TextField(
                            controller: examTitleController,
                            decoration: InputDecoration(
                              label:
                                  const Center(child: Text("Enter Exam Title")),
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
                      SizedBox(
                        width: 500,
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (examTitleController.text.length < 3) {
                                  return;
                                }
                                await createExam(examTitleController.text);
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddNewExam(
                                      Examid: newExam.id,
                                    ),
                                  ),
                                );
                              },
                              style: raisedButtonStyle,
                              child: Text(
                                "Enter",
                                style: theme.textTheme.caption!
                                    .copyWith(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('cancel'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ));
  }

  Future<void> createExam(String examTitle) async {
    final _user = Provider.of<AppUserProvider>(context, listen: false).appUser;

    ///Prepare data to be saved on users table\\\

    Map<String, dynamic> examMap = {
      'created_at': Timestamp.now(),
      'created_by': _user!.fullName,
      'questionsList': [],
      'examTitle': examTitle,
      'exam_id': newExam.id,
      'taken_by': []
    };
    newExam.set(examMap);
  }
}

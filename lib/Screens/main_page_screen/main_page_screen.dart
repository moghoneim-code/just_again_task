import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:justagain_task/Screens/exams_screen/exams_screen.dart';
import 'package:justagain_task/Screens/profile_screen/profile_screen.dart';
import 'package:justagain_task/Screens/take_exam_screen/take_exam_screen.dart';
import '../../Providers/user_provider.dart';
import '../../transition_route_observer.dart';
import '../../widgets/animated_numeric_text.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/round_button.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MainPageScreen extends StatefulWidget {
  static const id = 'MainPageScreen';

  const MainPageScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<MainPageScreen>
    with SingleTickerProviderStateMixin, TransitionRouteAware {
  final routeObserver = TransitionRouteObserver<PageRoute?>();
  static const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);
  late Animation<double> _headerScaleAnimation;
  AnimationController? _loadingController;

  @override
  void initState() {
    super.initState();

    ///pre - loading the data into the state management before using it in the profile section
    final _user = Provider.of<AppUserProvider>(context, listen: false).appUser;
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );

    _headerScaleAnimation =
        Tween<double>(begin: .6, end: 1).animate(CurvedAnimation(
      parent: _loadingController!,
      curve: headerAniInterval,
    ));
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

  @override
  void didPushAfterTransition() => _loadingController!.forward();

  AppBar _buildAppBar(ThemeData theme) {
    final menuBtn = IconButton(
      color: theme.colorScheme.secondary,
      icon: const Icon(FontAwesomeIcons.bars),
      onPressed: () {},
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
      leading: FadeIn(
        controller: _loadingController,
        offset: .3,
        curve: headerAniInterval,
        fadeDirection: FadeDirection.startToEnd,
        child: menuBtn,
      ),
      title: title,
      backgroundColor: theme.primaryColor.withOpacity(.1),
      elevation: 0,
    );
  }

  Widget _buildHeader(ThemeData theme) {
    const primaryColor = Colors.orange;
    const accentColor = Colors.orangeAccent;
    final linearGradient = LinearGradient(colors: [
      primaryColor.shade800,
      accentColor.shade200,
    ]).createShader(const Rect.fromLTWH(0.0, 0.0, 418.0, 78.0));

    return ScaleTransition(
      scale: _headerScaleAnimation,
      child: FadeIn(
        controller: _loadingController,
        curve: headerAniInterval,
        fadeDirection: FadeDirection.bottomToTop,
        offset: .5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 5),
                AnimatedNumericText(
                  initialValue: 14,
                  targetValue: 3467.00,
                  curve: const Interval(0, .5, curve: Curves.easeOut),
                  controller: _loadingController!,
                  style: theme.textTheme.headline3!.copyWith(
                    foreground: Paint()..shader = linearGradient,
                  ),
                ),
              ],
            ),
            Text('Number of Problems Solved', style: theme.textTheme.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      {Widget? icon,
      String? label,
      required Interval interval,
      required final VoidCallback onPressed}) {
    return RoundButton(
      icon: icon,
      label: label,
      loadingController: _loadingController,
      interval: Interval(
        interval.begin,
        interval.end,
        curve: const ElasticOutCurve(0.42),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildDashboardGrid() {
    final _user = Provider.of<AppUserProvider>(context, listen: false).appUser;

    const step = 0.04;
    const aniInterval = 0.75;
    return GridView.count(
      padding: const EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: 20,
      ),
      childAspectRatio: .9,
      // crossAxisSpacing: 5,
      crossAxisCount: 3,
      children: [
        /// Profile Button
        _buildButton(
            icon: const Icon(FontAwesomeIcons.user),
            label: 'Profile',
            interval: const Interval(0, aniInterval),
            onPressed: () {
              Navigator.pushNamed(context, ProfileScreen.id);
            }),
        _buildButton(
            icon: const Icon(Icons.add),
            label: 'Add Exam',
            interval: const Interval(step, aniInterval + step),
            onPressed: () {
              if(_user!.role!='teacher'){
                Fluttertoast.showToast(
                    msg: "Please login as Admin !",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.deepPurpleAccent,
                    textColor: Colors.white,
                    fontSize: 16.0);
                return;
              }
              Navigator.pushNamed(context, ExamsScreen.id);
            }),
        _buildButton(
            icon: const Icon(FontAwesomeIcons.clock),
            label: 'History',
            interval: const Interval(step * 2, aniInterval + step * 2),
            onPressed: () {}),

        ///settings Button
        _buildButton(
            icon: const Icon(FontAwesomeIcons.slidersH, size: 20),
            label: 'Settings',
            interval: const Interval(step * 2, aniInterval + step * 2),
            onPressed: () {
              Fluttertoast.showToast(
                  msg: "Come on .. it is only a demo !",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.deepPurpleAccent,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }),

        ///Take Exam Button
        _buildButton(
            icon: const Icon(FontAwesomeIcons.bookOpen, size: 20),
            label: 'Take Exam',
            interval: const Interval(step * 2, aniInterval + step * 2),
            onPressed: () {
              Navigator.pushNamed(context, TakeExamScreen.id);
            }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _user = Provider.of<AppUserProvider>(context, listen: false).appUser;
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(theme),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: theme.primaryColor.withOpacity(.1),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  const SizedBox(height: 40),
                  Expanded(
                    flex: 2,
                    child: _buildHeader(theme),
                  ),
                  Expanded(
                    flex: 8,
                    child: ShaderMask(
                      // blendMode: BlendMode.srcOver,
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          tileMode: TileMode.clamp,
                          colors: <Color>[
                            Colors.deepPurpleAccent.shade100,
                            Colors.deepPurple.shade100,
                            Colors.deepPurple.shade100,
                            Colors.deepPurple.shade100,
                            // Colors.red,
                            // Colors.yellow,
                          ],
                        ).createShader(bounds);
                      },
                      child: _buildDashboardGrid(),
                    ),
                  ),
                ],
              ),
              // if (!kReleaseMode) _buildDebugButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:justagain_task/widgets/custom_button.dart';
import 'package:justagain_task/widgets/profile_list_tile.dart';
import '../../Providers/user_provider.dart';
import '../../widgets/fade_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../transition_route_observer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:clipboard/clipboard.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../login_screen/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const String id = 'ProfileScreen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin, TransitionRouteAware {
  late Animation<double> _headerScaleAnimation;
  AnimationController? _loadingController;
  static const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);
  final routeObserver = TransitionRouteObserver<PageRoute?>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

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

  /// widget for building the top part of the screen
  Widget _buildHeader(ThemeData theme) {
    return ScaleTransition(
      scale: _headerScaleAnimation,
      child: FadeIn(
        controller: _loadingController,
        curve: headerAniInterval,
        fadeDirection: FadeDirection.bottomToTop,
        offset: .5,
        child: Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
              border: Border.all(
                color: theme.primaryColor,
              ),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 15.0, // soften the shadow
                  spreadRadius: 0.5, //extend the shadow
                  offset: Offset(
                    0.7, // Move to right 10  horizontally
                    0.7, // Move to bottom 10 Vertically
                  ),
                )
              ]),
          // color: theme.primaryColor,
          child: Image.asset(
            'assets/user_icon.png',
            height: 100.0,
            width: 100.0,
          ),
        ),
      ),
    );
  }

  /// widget for building the list of the profile data
  Widget _buildProfileList(theme, String name, String email, String role) {
    return ListView(
      children: [
        const SizedBox(
          height: 30,
        ),
        CustomListTile(
            icon: const Icon(Icons.person),
            onPressed: () async {
              await FlutterClipboard.copy(name);
              Fluttertoast.showToast(
                  msg: "Name Copied",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            title: Text(name),
            loadingController: _loadingController),
        CustomListTile(
            icon: const Icon(Icons.email_outlined),
            onPressed: () async {
              Fluttertoast.showToast(
                  msg: "Email Copied",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0);
              await FlutterClipboard.copy(email);
            },
            title: Text(email),
            loadingController: _loadingController),
        CustomListTile(
            icon: const Icon(Icons.accessibility_sharp),
            onPressed: () async {},
            title: Text(role),
            loadingController: _loadingController)
      ],
    );
  }

  /// widget for building the appBar for profile screen
  AppBar _buildAppBar(ThemeData theme) {
    final signOutBtn = IconButton(
      color: theme.colorScheme.secondary,
      icon: const Icon(FontAwesomeIcons.doorOpen),
      onPressed: () async {
        await _auth.signOut();
        Provider.of<AppUserProvider>(context, listen: false).appUser = null;
        Navigator.pushNamed(context, LoginScreen.id,
            arguments: (route) => false);
      },
    );
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
      leading: FadeIn(
          controller: _loadingController,
          offset: .3,
          curve: headerAniInterval,
          fadeDirection: FadeDirection.startToEnd,
          child: signOutBtn),
      actions: <Widget>[
        FadeIn(
            controller: _loadingController,
            offset: .3,
            curve: headerAniInterval,
            fadeDirection: FadeDirection.endToStart,
            child: backButton),
      ],
      title: title,
      backgroundColor: theme.primaryColor.withOpacity(.1),
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _user = Provider.of<AppUserProvider>(context, listen: false).appUser;
    return Scaffold(
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
                  child: _buildProfileList(theme, _user?.fullName ?? 'username',
                      _user?.email ?? 'email', _user?.role ?? 'role'),
                ),
                const SizedBox(
                  height: 75,
                ),
                Text('Need To update Your password ? ',
                    style: theme.textTheme.caption),
                const SizedBox(
                  height: 5.0,
                ),
                Text('Click The Button Below to reset ',
                    style: theme.textTheme.caption),
                CustomButton(
                    onPressed: () {
                      String resetEmail = _user!.email;
                      _auth.sendPasswordResetEmail(email: resetEmail);
                      Fluttertoast.showToast(
                          msg: "we sent you an email !",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: theme.primaryColor,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    },
                    label: "Reset Password",
                    loadingController: _loadingController)
              ],
            ),
            // if (!kReleaseMode) _buildDebugButtons(),
          ],
        ),
      ),
    );
  }
}

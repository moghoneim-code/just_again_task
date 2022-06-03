import 'package:flutter/material.dart';

class CustomListTile extends StatefulWidget {
  const CustomListTile({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.title,
    required this.loadingController,
    this.interval = const Interval(0, 1, curve: Curves.ease),
  }) : super(key: key);
  final Text title;
  final Icon? icon;
  final VoidCallback onPressed;
  final AnimationController? loadingController;
  final Interval interval;

  @override
  _CustomListTileState createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleLoadingAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 500),
    );
    _scaleLoadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: widget.loadingController!,
        curve: widget.interval,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: .75).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOut,
        reverseCurve: const ElasticInCurve(0.3),
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ScaleTransition(
        scale: _scaleLoadingAnimation,
        child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      stops: [0.02, 0.02],
                      colors: [Colors.deepPurple, Colors.white60]),
                  borderRadius: BorderRadius.all(Radius.circular(6.0))),
              height: 60,
              child: ListTile(
                onTap: () {
                  _pressController.forward().then((_) {
                    _pressController.reverse();
                  });
                  widget.onPressed();
                },
                leading: widget.icon,
                title: widget.title,
              ),
            )),
      ),
    );
  }
}

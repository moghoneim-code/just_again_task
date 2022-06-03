import 'package:flutter/material.dart';
import 'package:justagain_task/Models/exam_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TakeExamTile extends StatefulWidget {
  final ExamData examData;
  final VoidCallback onPressed;
  final AnimationController? loadingController;
  final Interval interval;

  const TakeExamTile({
    Key? key,
    required this.onPressed,
    required this.loadingController,
    required this.examData,
    this.interval = const Interval(0, 1, curve: Curves.ease),
  }) : super(key: key);

  @override
  _TakeExamTileState createState() => _TakeExamTileState();
}

class _TakeExamTileState extends State<TakeExamTile>
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
      child: ListTile(
        onTap: () {
          _pressController.forward().then((_) {
            _pressController.reverse();
          });
          widget.onPressed();
        },
        trailing: Text(
          widget.examData.createdBy,
          style: const TextStyle(color: Colors.black),
        ),

        leading: const Icon(FontAwesomeIcons.arrowRight),
        title: Text(widget.examData.examTitle),
      ),
    );
  }
}

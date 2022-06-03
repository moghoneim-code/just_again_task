import 'package:flutter/material.dart';
import 'package:justagain_task/Models/exam_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Models/qusetion_data.dart';

class QuestionTile extends StatefulWidget {
  final QuestionModel questionModel;
  final VoidCallback onPressed;
  final Interval interval;

  const QuestionTile({
    Key? key,
    required this.onPressed,
    required this.questionModel,
    this.interval = const Interval(0, 1, curve: Curves.ease),
  }) : super(key: key);

  @override
  _QuestionTileState createState() => _QuestionTileState();
}

class _QuestionTileState extends State<QuestionTile> with SingleTickerProviderStateMixin {
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
          //  widget.onPressed();
        },

        // subtitle:
        // Text("${widget.examData.questionsList.length} questions"),
        leading: const Icon(FontAwesomeIcons.questionCircle),
        title: Text(widget.questionModel.question),
      ),
    );
  }
}

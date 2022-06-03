import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewQuestionDialog extends StatefulWidget {
  final VoidCallback onSave;

  const NewQuestionDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  State<NewQuestionDialog> createState() => _NewQuestionDialogState();
}

TextEditingController questionAnswersNum = TextEditingController();

class _NewQuestionDialogState extends State<NewQuestionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                decoration: const InputDecoration(
                    labelText: "Enter Number of answers of the question"),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

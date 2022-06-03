import 'package:cloud_firestore/cloud_firestore.dart';

class ExamData {
  String examTitle;
  String createdBy;
  List questionsList;
  String id;
  String  yourAnswer ='';


  ExamData({
    required this.examTitle,
    required this.questionsList,
    required this.createdBy,
    required this.id
  });

  factory ExamData.empty() {
    return ExamData(
        examTitle: "___ExamTitle___",  questionsList: [],createdBy: '__ADMIN__',id: '___id___'
    );
  }


  factory ExamData.fromSnapshot(DocumentSnapshot snapshot) {
    final Map<String, dynamic> _data = snapshot.data() as Map<String, dynamic>;
    return ExamData(
        examTitle: _data['examTitle'],
        createdBy:_data['created_by'] ,
        id: _data['exam_id'],
        questionsList: _data['questionsList']);
  }




}

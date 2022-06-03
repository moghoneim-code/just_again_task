// ignore_for_file: constant_identifier_names

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:justagain_task/Models/qusetion_data.dart';
import 'package:provider/provider.dart';
import '../Models/exam_data.dart';
import 'package:survey_kit/survey_kit.dart';

const int EXAMS_PER_PAGE = 1000;

class QuestionListProvider extends ChangeNotifier {
  ///retuns a provider instance of the class
  static QuestionListProvider get(BuildContext context) => context.read<QuestionListProvider>();

  List<QuestionModel>? _questionsList;
  DocumentSnapshot? _lastDocument;
  bool _readyToFetchNewData = true;

  // String get _uid => FirebaseAuth.instance.currentUser!.uid;

  List<QuestionModel>? get questionsList => _questionsList;

  ///describes the current pagination state, whether or not the ui should display a widget loading indicator.

  bool get nextPage => _lastDocument != null;

  ///Fetches the  exams List from [Firebase Firestore].
  ///
  ///[newData]: use with `false` to disable loading indication, for example when refreshing.
  ///

  Future<void> loadQuestions({
    bool newData = true,
    required String examID,
  }) async {
    _questionsList = null;
    if (newData) notifyListeners();
    var data = await _getQuestions(examID: examID);
    _questionsList = data.map((e) => QuestionModel.fromSnapshot(e)).toList(growable: true);
    //   print(_questionsList!.first.correctAnswer);

    //  _lastDocument = data.last;
    notifyListeners();
  }

  Future<void> loadMoreQuestions(String examID) async {
    if (_readyToFetchNewData) {
      _readyToFetchNewData = false;
      log("#Fetching more data".toUpperCase());
    } else {
      return;
    }
    assert(_questionsList!.isNotEmpty, "you should load exams first");

    final data = await _getQuestions(from: _lastDocument, examID: examID);
    //maps docs to exams
    var questionslist = data.map((e) => QuestionModel.fromSnapshot(e)).toList();

    ///if the exams list is almost empty or not.
    ///
    if (questionslist.isEmpty) {
      _lastDocument = null;
    } else {
      _questionsList = (_questionsList! + questionslist);
      _lastDocument = data.last;
    }
    _readyToFetchNewData = _lastDocument?.id != null;
    notifyListeners();
  }

  Future<List<DocumentSnapshot>> _getQuestions({DocumentSnapshot? from, required String examID}) async {
    final questionRequest = FirebaseFirestore.instance.collection("questions");

    Query query = questionRequest.where("exam_id", isEqualTo: examID).limit(EXAMS_PER_PAGE);

    if (from != null) {
      query = query.startAfterDocument(from);
    }

    final rawData = await query.get();

    return rawData.docs.toList();
  }
}

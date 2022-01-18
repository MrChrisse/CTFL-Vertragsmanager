import 'package:ctfl_vertragsmanager/models/label.dart';
import 'package:ctfl_vertragsmanager/models/vertrag.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class HiveFunctions {
  static Box<Vertrag> getHiveVertraege() => Hive.box<Vertrag>('vertraege');
  static Box<Label> getHiveLabels() => Hive.box<Label>('labels');
}

Future<List<Vertrag>?> getHiveAllVertraege() async {
  final vertragsBox = HiveFunctions.getHiveVertraege();
  List<Vertrag>? vertraege;
  for (var vertrag in vertragsBox.values) {
    vertraege!.add(vertrag);
  }
  return vertraege;
}

Future<Vertrag?> getHiveVertragById(String vertragId) async {
  final vertragsBox = HiveFunctions.getHiveVertraege();
  vertragsBox.get(vertragId);
}

deleteHiveVertrag(String vertragsId) async {
  final vertragsBox = HiveFunctions.getHiveVertraege();
  vertragsBox.delete(vertragsId);
}

createHiveVertrag(Vertrag vertrag) async {
  final vertragsBox = HiveFunctions.getHiveVertraege();
  vertragsBox.put(vertrag.id, vertrag);
}

deleteHiveAllVertraege() async {
  final vertragsBox = HiveFunctions.getHiveVertraege();
  for (var i = 0; i < vertragsBox.length; i++) {
    vertragsBox.deleteAt(i);
  }
}

updateHiveAllVertraege(List<Vertrag> vertraege) async {
  deleteHiveAllVertraege();
  final vertragsBox = HiveFunctions.getHiveVertraege();
  for (int i = 0; i < vertraege.length; i++) {
    vertragsBox.put(vertraege[i].id, vertraege[i]);
  }
}

Future<Label> getHiveLabelByName(String labelName) async {
  final labelBox = HiveFunctions.getHiveLabels();

  for (int i = 0; i < labelBox.length; i++) {
    if (labelBox.getAt(i)?.name == labelName) {
      return labelBox.getAt(i)!;
    }
  }
  return labelBox.getAt(0)!;
}

Future<List<Label>> getHiveAllLabels() async {
  final labelBox = HiveFunctions.getHiveLabels();
  List<Label> labels = [];
  for (int i = 0; i < labelBox.length; i++) {
    labels.add(labelBox.getAt(i)!);
  }
  return labels;
}

addHiveLabel(Label newLabel) async {
  final labelBox = HiveFunctions.getHiveLabels();
  labelBox.add(newLabel);
}

deleteHiveAllLabels() {
  final labelBox = HiveFunctions.getHiveLabels();
  for (var i = 0; i < labelBox.length; i++) {
    labelBox.deleteAt(i);
  }
}

updateHiveAllLabels(List<Label> labels) {
  deleteHiveAllLabels();
  final labelBox = HiveFunctions.getHiveLabels();
  for (int i = 0; i < labels.length; i++) {
    labelBox.add(labels[i]);
  }
}

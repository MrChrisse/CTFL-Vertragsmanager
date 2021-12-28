import 'package:ctfl_vertragsmanager/constants/Color_Themes.dart';
import 'package:ctfl_vertragsmanager/models/vertrag.dart';
import 'package:ctfl_vertragsmanager/models/vertragsdaten.dart';
import 'package:ctfl_vertragsmanager/partials/vertragscard.dart';
import 'package:flutter/material.dart';

class VertragsDetailsPage extends StatelessWidget {
  //TODO: Zahlungsinfos 2x2
  List<Vertrag> vertraege = Vertragsdaten().vertraege;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    int vertragsId = args.vertragsId;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: vertraege[vertragsId].label.color,
        title: Text(
          vertraege[vertragsId].name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Icon(
            Icons.delete_outlined,
            size: 30,
          ),
        ],
      ),
      body: ListView(
        children: [
          DetailsTile(value: vertraege[vertragsId].name, description: "Name"),
          DetailsTile(value: vertraege[vertragsId].description, description: "Beschreibung"),
          DetailsTile(value: vertraege[vertragsId].getLabelName(), description: "Label"),
          SizedBox(height: 20),
          Text(
            "Zahlungsinformationen",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          DetailsTile(value: vertraege[vertragsId].getIntervall(), description: "Intervall"),
          DetailsTile(value: vertraege[vertragsId].getBeitragEuro(), description: "Beitrag"),
          DetailsTile(value: vertraege[vertragsId].getErstzahlung(), description: "Erstzahlung"),
          DetailsTile(
              value: vertraege[vertragsId].getNaechsteZahlung(), description: "nächste Zahlung"),
          SizedBox(height: 20),
          Text(
            "Vertragsinformationen",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          DetailsTile(value: vertraege[vertragsId].vertragspartner, description: "Vertragspartner"),
          DetailsTile(
              value: vertraege[vertragsId].getVertragsBeginn(), description: "Vertragsbeginn"),
          DetailsTile(value: vertraege[vertragsId].getVertragsEnde(), description: "Vertragsende"),
          DetailsTile(
              value: vertraege[vertragsId].getKuendigungsfrist(), description: "Kündigungsfrist"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        backgroundColor: ColorThemes.primaryColor,
        child: const Icon(
          Icons.edit,
          size: 25,
        ),
      ),
    );
  }
}

class DetailsTile extends StatelessWidget {
  String description;
  String value;

  DetailsTile({required this.description, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20),
          ),
          Divider(
            color: Colors.black54,
          ),
        ],
      ),
    );
  }
}

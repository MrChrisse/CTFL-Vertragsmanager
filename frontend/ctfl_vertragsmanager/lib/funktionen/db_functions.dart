import 'dart:convert';
import 'dart:io';
import 'package:ctfl_vertragsmanager/funktionen/hive_functions.dart';
import 'package:ctfl_vertragsmanager/models/label.dart';
import 'package:ctfl_vertragsmanager/models/vertrag.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ctfl_vertragsmanager/models/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

String hashPW(String password) {
  var bytes = utf8.encode(password); // data being hashed
  var hashedPW = sha256.convert(bytes);
  return hashedPW.toString();
}

Future<bool> createUser(Profile profil) async {
  Uri url = getUrl("users");

  Map<String, String> body = {
    "email": profil.email,
    "password": profil.password,
  };
  String bodyJson = jsonEncode(body);
  http.Response response = await http.post(
    url,
    body: bodyJson,
    headers: {"Content-Type": "application/json"},
  );
  return response.statusCode == 200;
}

createSession(Profile profil) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  Uri url = getUrl("sessions");

  Map<String, String> body = {
    "email": profil.email,
    "password": profil.password,
  };
  String bodyJson = jsonEncode(body);
  http.Response response = await http.post(
    url,
    body: bodyJson,
    headers: {"Content-Type": "application/json"},
  );
  //Create UserProfile with Tokens

  if (response.body.startsWith("Invalid")) return false;

  Map<String, dynamic> responseMap = jsonDecode(response.body);
  Profile newUser = Profile(
    id: responseMap["userId"],
    email: profil.email,
    password: profil.password,
    accessToken: responseMap["accessToken"],
    refreshToken: responseMap["refreshToken"],
  );
  Map<String, dynamic> userMap = {
    'userId': newUser.id,
    'email': newUser.email,
    'password': newUser.password,
    'accessToken': newUser.accessToken,
    'refreshToken': newUser.refreshToken,
  };
  String rawJson = jsonEncode(userMap);
  prefs.setString('profile', rawJson);

  return response.statusCode == 200;
}

//todo: Absprache gibt uns alle aktuell angemeldeten User zurück, brauchen wir nicht, oder?

deleteSession() async {
  Profile user = await getProfilFromPrefs();
  Uri url = getUrl("sessions");
  http.Response response = await http.delete(
    url,
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${user.accessToken}',
      'x-refresh': user.refreshToken
    },
  );
  if (response.body.startsWith("Invalid")) return false;
  deleteHiveAllVertraege();
  deleteHiveAllLabels();
  return response.statusCode == 200;
}

Future<String> createVertrag(Vertrag newVertrag) async {
  //Create Post-Request
  Uri url = getUrl("contracts");
  Profile user = await getProfilFromPrefs();

  Map<String, dynamic> body = Map<String, dynamic>.from(newVertrag.asJson);

  String bodyJson = jsonEncode(body);

  http.Response response = await http.post(
    url,
    body: bodyJson,
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${user.accessToken}',
      'x-refresh': user.refreshToken
    },
  );
  //Create UserProfile with Tokens

  if (response.body.startsWith("Invalid") ||
      response.body.startsWith("Forbidden")) return "Error";

  Map<String, dynamic> responseMap = jsonDecode(response.body);

  Vertrag returnedVertrag = Vertrag.fromJson(responseMap);
  returnedVertrag.id ??= "123"; //check if null, in that case write 123
  createHiveVertrag(returnedVertrag);
  return returnedVertrag.id ?? "Error connection";
}

Future<String> updateVertrag(Vertrag newVertrag) async {
  Profile user = await getProfilFromPrefs();

  Uri url = getUrlWithId("contracts", newVertrag.id!);
  Map<String, dynamic> body = Map<String, dynamic>.from(newVertrag.asJson);

  String bodyJson = jsonEncode(body);
  http.Response response = await http.put(
    url,
    body: bodyJson,
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${user.accessToken}',
      'x-refresh': user.refreshToken
    },
  );
  //Create UserProfile with Tokens
  if (response.body.startsWith("Invalid")) return "Error";

  Map<String, dynamic> responseMap = jsonDecode(response.body);

  Vertrag returnedVertrag = Vertrag.fromJson(responseMap);
  returnedVertrag.id ??= "123";

  updateHiveVertrag(returnedVertrag);

  return returnedVertrag.id ?? "Error connection";
}

Future<bool> deleteVertrag(String vertragId) async {
  Profile user = await getProfilFromPrefs();

  Uri url = getUrl("contracts/$vertragId");

  http.Response response = await http.delete(
    url,
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${user.accessToken}',
      'x-refresh': user.refreshToken
    },
  );
  if (response.body.startsWith("Invalid")) return false;

  deleteHiveVertrag(vertragId);

  return true;
}

getAllVertraege() async {
  Profile user = await getProfilFromPrefs();
  Uri url = getUrl("contractsUser/${user.id}");

  http.Response response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${user.accessToken}',
      'x-refresh': user.refreshToken
    },
  );
  if (response.body.startsWith("Invalid")) return false;

  List<Vertrag> returnedVertraege = [];
  List<dynamic> responseArray = jsonDecode(response.body);

  for (var vertrag in responseArray) {
    Vertrag newVertrag = Vertrag.fromJson(vertrag);
    returnedVertraege.add(newVertrag);
  }
  updateHiveAllVertraege(returnedVertraege);
  return true;
}

Future<Profile> getProfilFromPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final rawJson = prefs.getString('profile');
  Map<String, dynamic> map = jsonDecode(rawJson!);

  final user = Profile(
    id: map['userId'],
    email: map['email'],
    password: map['password'],
    accessToken: map['accessToken'],
    refreshToken: map['refreshToken'],
  );
  return user;
}

Uri getUrl(String apiEndpoint) {
  return Platform.isAndroid
      ? Uri.parse('https://ctfl-backend.herokuapp.com/api/$apiEndpoint')
      : Uri.parse('https://ctfl-backend.herokuapp.com/api/$apiEndpoint');
}

Uri getUrlWithId(String apiEndpoint, String id) {
  return Platform.isAndroid
      ? Uri.parse('https://ctfl-backend.herokuapp.com/api/$apiEndpoint/$id')
      : Uri.parse('https://ctfl-backend.herokuapp.com/api/$apiEndpoint/$id');
}

// Uri getUrl(String apiEndpoint) {
//   return Platform.isAndroid
//       ? Uri.parse('http://10.0.2.2:8080/api/${apiEndpoint}')
//       : Uri.parse('http://localhost:8080/api/${apiEndpoint}');
// }

// Uri getUrlWithId(String apiEndpoint, String id) {
//   return Platform.isAndroid
//       ? Uri.parse('http://10.0.2.2:8080/api/${apiEndpoint}/${id}')
//       : Uri.parse('http://10.0.2.2:8080/api/${apiEndpoint}/${id}');
// }

addLabel(Label label) async {
  Profile user = await getProfilFromPrefs();

  Uri url = getUrl("labels");
  Map<String, String> body = {
    "labelName": label.name,
    "labelColor": label.colorValue.toString(),
  };
  String bodyJson = jsonEncode(body);

  http.Response response = await http.post(
    url,
    body: bodyJson,
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${user.accessToken}',
      'x-refresh': user.refreshToken
    },
  );
  if (response.body.startsWith("Invalid")) return false;
}

Future<List<Label>?> getAllLabels() async {
  Profile user = await getProfilFromPrefs();

  Uri url = getUrl("labels");

  http.Response response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${user.accessToken}',
      'x-refresh': user.refreshToken
    },
  );
  if (response.body.startsWith("Invalid")) return null;
  List<Label> returnedLabels = [];

  List<dynamic> responseArray = jsonDecode(response.body);
  for (var label in responseArray) {
    Label newLabel = Label(
      name: label["labelName"],
      //Formatierung der Farbe: Color(0xff000000).value
      colorValue: int.parse(label["labelColor"]),
    );
    returnedLabels.add(newLabel);
  }

  updateHiveAllLabels(returnedLabels);

  return returnedLabels;
}

healthCheck() async {
  Uri url = Uri.parse("https://ctfl-backend.herokuapp.com/healthcheck");
  //Uri url = Uri.parse("http://10.0.2.2:8080/healthcheck");

  http.Response response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
    },
  );
  return response;
}

Future<bool> deleteProfile() async {
  print("Profil löschen");

  Profile user = await getProfilFromPrefs();

  Uri url = getUrl("sessions/${user.id}");

  http.Response response = await http.delete(
    url,
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${user.accessToken}',
      'x-refresh': user.refreshToken
    },
  );
  if (response.body.startsWith("Invalid")) return false;

  clearHive();

  return true;
}

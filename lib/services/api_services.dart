import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ptech_erp/services/secreatResources.dart';
import 'appResources.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService{
  final storage = FlutterSecureStorage();

  Future<Map<String, String>?> loginFunction({required String email, required String password}) async {
    final url = Uri.parse(AppApis.login);
    final body = jsonEncode({"email": email, "password": password});

    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final cookies = response.headers['set-cookie']!.split(";");
      final cookie = "${cookies[0]}; ${cookies[4].split(",")[1]}";
      final authHeaders = {"cookie": cookie, "Authorization": "Token $token"};
      await storage.write(key: AppSecuredKey.authHeaders, value: jsonEncode(headers));
      return authHeaders;
    }
  }

    Future<User?> fetchUserInfoFunction({required Map<String, String> authHeaders}) async {
      final employeUrl = Uri.parse(AppApis.employeeDetails);
      final response = await http.get(employeUrl, headers: authHeaders);
      print(response.body);

      if (response.statusCode == 200) {
        Map responseJson = jsonDecode(response.body);
        User user = User.fromJson(jsonObject: responseJson);
      return user;
      }
    }

  Future fetchUserPermissions({User? user, required Map<String,String> authHeaders}) async {
    final url = Uri.parse(AppApis.checkUserGroup);
    final response = await http.get(url, headers: authHeaders);
    print(response.body);

    if (response.statusCode == 200) {
      print("Getting Machine Permission");
      final responseJson = jsonDecode(response.body);
      print("Machine Permission: ${responseJson}");

        final bool canRepairTheBrokenMachine = responseJson["repair machine"];
        final bool canCallToMaintenance =  responseJson["call maintenance"];
        final bool willReceiveNotification =  responseJson["receive machine notification"];

        if(user!=null) {
          user.willReceiveNotification = willReceiveNotification;
          user.canChangeToMaintenanceStage = canCallToMaintenance;
          user.canRepair = canRepairTheBrokenMachine;
          return user;
        } else{
          return responseJson;
        }
    }
  }
}


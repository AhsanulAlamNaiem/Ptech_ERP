import 'package:http/http.dart' as http;
import '../../appResources.dart';


Future<void> updateMachineStatus({
      required String lastProblem,
      required String status,
      required Map machine,
      required int problemIndex,

      Map breakdownBody = const {},
      bool willUpdateBreakdown = false,
      required Function patchRequestStateUpdater}) async {

      patchRequestStateUpdater(patchingState:true);

      final currentTIme = DateTime.now().toUtc().toString().split('.').first;

      Map body = {
        "status": status,
        "last_repairing_start": (status=='maintenance')? currentTIme.split(" ")[0] +"T" +currentTIme.split(" ")[1] +"Z": "${machine["last_repairing_start"]}",
        "last_breakdown_start": (status=='broken')?  currentTIme.split(" ")[0] +"T" +currentTIme.split(" ")[1] +"Z" :"${machine["last_breakdown_start"]}",
        "last_problem": (status=='active')?"$lastProblem":"$lastProblem"
      };

      DateTime startTime = DateTime.parse("${machine['last_breakdown_start']}");
      DateTime endTime = DateTime.parse(DateTime.now().toUtc().toString().split('.').first +'Z');
      String formattedDuration = endTime.difference(startTime).toString().split('.').first;

      final breakdownBody = {
            "breakdown_start": "$startTime",
            "repairing_start": "${machine['last_repairing_start']}",
            "lost_time": formattedDuration,
            "comments": "",
            "machine": "${machine['id']}",
            "mechanic": "",
            "operator": "",
            "problem_category": "$problemIndex",
            "location": "1",
            "line": "${machine['line']}",
      };


  try {
    final url = Uri.parse(AppApis.Machines + "${machine["id"]}/");
    print(url);
    print("Status supposed to be updated to $body");
    final response = await http.patch(url,body: body);
    print( "${response.statusCode} ${response.body}");
    String successMessage = (response.statusCode==200)? "Status Updated": "Status not Updated";
        if (willUpdateBreakdown) {
          final patchResponse =
          await http.post(Uri.parse(AppApis.BreakDownLogs), body: breakdownBody);
          print(breakdownBody);
          print("Breakdown updated ${patchResponse.body}");
          // Show success message

          if(patchResponse.statusCode ==200){
            successMessage = successMessage + " and Breakdown log Added";
          } else if(response.statusCode!=200){
            successMessage = successMessage + " and Breakdown log NOT Added";
          }

        } else {
          print("will not Update breaddwonLodg");
        }
    patchRequestStateUpdater(patchingState:false, message:successMessage);





      } catch (e) {
        print("Error: $e");

          final successMessage = "An error occurred while updating status.";
          patchRequestStateUpdater(false, successMessage);

      } finally {
        patchRequestStateUpdater(false, "Something went Wrong!");
      }
    }

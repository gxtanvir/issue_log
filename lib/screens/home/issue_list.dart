import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IssueListScreen extends StatefulWidget {
  @override
  _IssueListScreenState createState() => _IssueListScreenState();
}

class _IssueListScreenState extends State<IssueListScreen> {
  List<dynamic> issues = [];
  bool loading = true;

  // NOTE: change baseUrl depending on environment:
  // Android emulator: http://10.0.2.2:8000
  // iOS simulator/desktop: http://localhost:8000
  final String baseUrl = "https://gxtanvir.pythonanywhere.com";

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    try {
      final uri = Uri.parse("$baseUrl/api/issues/");
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        setState(() {
          issues = jsonDecode(res.body);
          loading = false;
        });
      } else {
        debugPrint("Failed ${res.statusCode}: ${res.body}");
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Issues"),
        backgroundColor: const Color.fromARGB(255, 56, 75, 112),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 56, 75, 112),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add');
          if (result == true) {
            fetchIssues(); // refresh list after adding
          }
        },
      ),

      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: fetchIssues,
                child:
                    issues.isEmpty
                        ? const Center(child: Text("No issues found"))
                        : ListView.builder(
                          itemCount: issues.length,
                          itemBuilder: (context, index) {
                            final issue = issues[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(
                                  issue["issue_details"] ?? "No details",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Company: ${issue["company_name"]}"),
                                    Text(
                                      "Raised by: ${issue["raised_by"] ?? "N/A"}",
                                    ),
                                    Text(
                                      "Priority: ${issue["priority"] ?? "-"}",
                                    ),
                                    Text(
                                      "Status: GMS=${issue["gms_status"]}, Logic=${issue["logic_status"]}",
                                    ),
                                    Text(
                                      "Raised on: ${issue["issue_raise_date"]}",
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
    );
  }
}

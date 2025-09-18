import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:issue_log/screens/admin/user_issue_list.dart';
import 'package:issue_log/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:issue_log/screens/auth/login.dart';
import '../notification/notification_icon.dart';

class _AppColors {
  static const Color background = Color.fromARGB(255, 236, 238, 240);
  static const Color cardBackground = Color.fromARGB(255, 60, 62, 65);
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Color(0xFF9CA3AF);
  static const Color accent = Color.fromARGB(255, 30, 94, 172);
}

class AdminSummaryScreen extends StatefulWidget {
  const AdminSummaryScreen({super.key});

  @override
  State<AdminSummaryScreen> createState() => _AdminSummaryScreenState();
}

class _AdminSummaryScreenState extends State<AdminSummaryScreen> {
  bool isLoading = true;
  List<dynamic> summaryData = [];
  String adminName = "";
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadSummary(), _loadAdminName()]);
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loadSummary() async {
    try {
      final data = await ApiService.getSummary(
        year: selectedYear,
        month: selectedMonth,
      );
      if (mounted) setState(() => summaryData = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading summary: $e")));
      }
    }
  }

  Future<void> _loadAdminName() async {
    final name = await ApiService.getName();
    if (mounted) setState(() => adminName = name ?? "Admin");
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // A helper function to format names
  String _formatName(String name) {
    if (name.isEmpty) return '';
    return name
        .split(' ')
        .map(
          (word) =>
              word.isEmpty
                  ? ''
                  : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  final dateFormatter = DateFormat.yMd().add_jm();

  DateTime? _parseDate(dynamic d) {
    if (d == null) return null;
    try {
      return DateTime.parse(d.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  Color _getUpdateColor(DateTime? date) {
    if (date == null) return _AppColors.secondaryText;
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return Colors.green;
    if (difference > 7) return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      appBar: AppBar(
        title: Text("MIS Issue Log"),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _logout,
            label: Text('Logout'),
            icon: Icon(Icons.logout),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              iconSize: 22,
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          NotificationIcon(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: RefreshIndicator(
              onRefresh: _loadSummary,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hello, Mr. ${_formatName(adminName)}!",
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width < 600 ? 18 : 24,
                          fontWeight: FontWeight.bold,
                          color: _AppColors.accent,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/add',
                          );
                          if (result == true) _loadSummary();
                        },
                        icon: Icon(Icons.add),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(
                            114,
                            125,
                            179,
                            0.1,
                          ),
                          foregroundColor: const Color.fromARGB(
                            255,
                            58,
                            22,
                            192,
                          ),
                          iconSize: 22,
                          // elevation: 6.7,
                        ),
                        label: Text("Add Issue"),
                      ),
                    ],
                  ),

                  // const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      DropdownButton<int>(
                        value: selectedYear,
                        items: List.generate(2, (i) {
                          final year = DateTime.now().year - i;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedYear = val);
                            _loadSummary();
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      // Month Dropdown
                      DropdownButton<int>(
                        value: selectedMonth,
                        items: List.generate(12, (i) {
                          final month = i + 1;
                          return DropdownMenuItem(
                            value: month,
                            child: Text(
                              DateFormat.MMMM().format(DateTime(0, month)),
                            ),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedMonth = val);
                            _loadSummary();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Showing ${DateFormat.yMMMM().format(DateTime(selectedYear, selectedMonth))} Summery",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 38,
                    endIndent: 38,
                  ),

                  const SizedBox(height: 10),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : summaryData.isEmpty
                      ? const Center(
                        child: Text(
                          "No data available",
                          style: TextStyle(color: _AppColors.secondaryText),
                        ),
                      )
                      : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent:
                              MediaQuery.of(context).size.width < 600
                                  ? 160
                                  : 170,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 12,
                          childAspectRatio:
                              MediaQuery.of(context).size.width < 600 ? 1 : 1.5,
                        ),
                        itemCount: summaryData.length,
                        itemBuilder: (context, index) {
                          final user = summaryData[index];
                          final lastUpdate = _parseDate(user['last_update']);
                          return _HoverableCard(
                            child: _buildSummaryCard(
                              user['user_id']?.toString() ?? 'Unknown',
                              _formatName(user['user_name'] ?? 'Unknown'),
                              user['pending'] ?? 0,
                              user['solved'] ?? 0,
                              user['total'] ?? 0,
                              lastUpdate,
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String userId,
    String userName,
    int pending,
    int solved,
    int total,
    DateTime? lastUpdate,
  ) {
    return Card(
      color: _AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      UserIssueListScreen(userId: userId, userName: userName),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _AppColors.primaryText,
                ),
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 2),
              _buildStat("Pending", pending, Colors.yellowAccent),
              // const Spacer(),
              Text(
                lastUpdate != null
                    ? "Update: ${dateFormatter.format(lastUpdate)}"
                    : "Update: N/A",
                style: TextStyle(
                  fontSize: 10,
                  color: _getUpdateColor(lastUpdate),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _AppColors.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Hover effect for Web/Desktop
class _HoverableCard extends StatefulWidget {
  final Widget child;
  const _HoverableCard({required this.child});

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform:
            _hovering ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        child: widget.child,
      ),
    );
  }
}

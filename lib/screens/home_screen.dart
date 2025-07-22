import 'package:flutter/material.dart';
import '../models/staff.dart';
import '../services/api_service.dart';
import '../widgets/staff_card.dart';
import '../widgets/stats_card.dart';
import 'add_staff_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<StaffMember> _staff = [];
  Map<String, dynamic> _stats = {};
  String _searchTerm = "";
  final String _filter = "all";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final staff = await ApiService.getStaff(
        search: _searchTerm,
        filter: _filter,
      );
      final stats = await ApiService.getStats();
      setState(() {
        _staff = staff;
        _stats = stats;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Staff Management"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddStaffScreen()),
                ).then((_) => _loadData()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            // Search field and stats as a sliver
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search staff...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() => _searchTerm = value);
                        _loadData();
                      },
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        StatsCard(
                          value: _stats['totalStaff'] ?? 0,
                          label: "Total Staff",
                          icon: Icons.people,
                        ),
                        StatsCard(
                          value: _stats['activeStaff'] ?? 0,
                          label: "Active",
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        StatsCard(
                          value: _stats['onLeaveStaff'] ?? 0,
                          label: "On Leave",
                          icon: Icons.beach_access,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Staff list or loading/empty state
            _isLoading && _staff.isEmpty
                ? SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
                : _staff.isEmpty
                ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No staff members found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pull down to refresh or add new staff',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
                : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return StaffCard(
                      staff: _staff[index],
                      onDelete: () async {
                        await ApiService.deleteStaff(_staff[index].id);
                        _loadData();
                      },
                      onEdit:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      AddStaffScreen(staff: _staff[index]),
                            ),
                          ).then((_) => _loadData()),
                    );
                  }, childCount: _staff.length),
                ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/mentor.dart';

class AdminMentorManagementScreen extends StatefulWidget {
  const AdminMentorManagementScreen({super.key});

  @override
  State<AdminMentorManagementScreen> createState() => _AdminMentorManagementScreenState();
}

class _AdminMentorManagementScreenState extends State<AdminMentorManagementScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Mentor> _allMentors = [];
  List<Mentor> _filteredMentors = [];
  bool _isLoading = true;
  String? _error;
  String? _levelFilter;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadMentors();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMentors() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final mentors = await _apiService.getMentors();
      setState(() {
        _allMentors = mentors;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredMentors = _allMentors.where((mentor) {
        final matchesSearch = _searchController.text.isEmpty ||
            mentor.name.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesLevel = _levelFilter == null || mentor.english_level == _levelFilter;
        final matchesStatus = _statusFilter == null || mentor.status == _statusFilter;
        return matchesSearch && matchesLevel && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Mentors'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMentors,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error loading mentors', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_error!, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMentors,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Search bar
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search mentors',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Filters
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showLevelFilter(theme),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  label: Text(_levelFilter ?? 'English Level'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showStatusFilter(theme),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  label: Text(_statusFilter ?? 'Status'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Mentors list
                    Expanded(
                      child: _filteredMentors.isEmpty
                          ? Center(
                              child: Text(
                                'No mentors found',
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadMentors,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredMentors.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final mentor = _filteredMentors[index];
                                  return _buildMentorCard(mentor, theme);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  void _showLevelFilter(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('All Levels'),
              onTap: () {
                setState(() => _levelFilter = null);
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            ...levels.map((level) => ListTile(
                  title: Text(level),
                  selected: _levelFilter == level,
                  onTap: () {
                    setState(() => _levelFilter = level);
                    _applyFilters();
                    Navigator.pop(context);
                  },
                )),
          ],
        );
      },
    );
  }

  void _showStatusFilter(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final statuses = ['active', 'inactive'];
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('All Statuses'),
              onTap: () {
                setState(() => _statusFilter = null);
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            ...statuses.map((status) => ListTile(
                  title: Text(status.toUpperCase()),
                  selected: _statusFilter == status,
                  onTap: () {
                    setState(() => _statusFilter = status);
                    _applyFilters();
                    Navigator.pop(context);
                  },
                )),
          ],
        );
      },
    );
  }

  Widget _buildMentorCard(Mentor mentor, ThemeData theme) {
    final isActive = mentor.status == 'active';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Text(
              mentor.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mentor.name,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  'English Level: ${mentor.english_level}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mentor.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? const Color(0xFF10B981) : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/mentor_detail',
                arguments: mentor.id,
              );
            },
          ),
        ],
      ),
    );
  }
}

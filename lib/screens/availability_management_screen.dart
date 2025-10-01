import 'package:flutter/material.dart';
import '../models/mentor.dart';
import '../services/api_service.dart';

class AvailabilityManagementScreen extends StatefulWidget {
  const AvailabilityManagementScreen({super.key});

  @override
  State<AvailabilityManagementScreen> createState() => _AvailabilityManagementScreenState();
}

class _AvailabilityManagementScreenState extends State<AvailabilityManagementScreen> {
  final ApiService _apiService = ApiService();
  List<AvailabilitySlot> _slots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoading = true);
    try {
      final slots = await _apiService.getMyAvailability();
      setState(() {
        _slots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading availability: $e')),
        );
      }
    }
  }

  void _showAddSlotDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddAvailabilityDialog(
        onAdd: () {
          Navigator.pop(context);
          _loadAvailability();
        },
      ),
    );
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
        title: const Text('Availability'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _slots.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 64,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No availability set',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your weekly availability',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _slots.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final slot = _slots[index];
                          return _buildSlotCard(slot, theme);
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _showAddSlotDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Availability'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(AvailabilitySlot slot, ThemeData theme) {
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.dayName,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '${slot.start_time} - ${slot.end_time}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: theme.textTheme.bodySmall?.color,
            ),
            onPressed: () {
              // TODO: Show edit/delete options
            },
          ),
        ],
      ),
    );
  }
}

class _AddAvailabilityDialog extends StatefulWidget {
  final VoidCallback onAdd;

  const _AddAvailabilityDialog({required this.onAdd});

  @override
  State<_AddAvailabilityDialog> createState() => _AddAvailabilityDialogState();
}

class _AddAvailabilityDialogState extends State<_AddAvailabilityDialog> {
  int _selectedDay = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _handleAdd() async {
    setState(() => _isLoading = true);

    try {
      await _apiService.updateAvailability([
        {
          'day_of_week': _selectedDay,
          'start_time': '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
          'end_time': '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
        }
      ]);
      widget.onAdd();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Availability'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            value: _selectedDay,
            decoration: const InputDecoration(labelText: 'Day'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Monday')),
              DropdownMenuItem(value: 2, child: Text('Tuesday')),
              DropdownMenuItem(value: 3, child: Text('Wednesday')),
              DropdownMenuItem(value: 4, child: Text('Thursday')),
              DropdownMenuItem(value: 5, child: Text('Friday')),
              DropdownMenuItem(value: 6, child: Text('Saturday')),
              DropdownMenuItem(value: 7, child: Text('Sunday')),
            ],
            onChanged: (value) => setState(() => _selectedDay = value!),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(_startTime.format(context)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime,
              );
              if (time != null) setState(() => _startTime = time);
            },
          ),
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(_endTime.format(context)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (time != null) setState(() => _endTime = time);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAdd,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}

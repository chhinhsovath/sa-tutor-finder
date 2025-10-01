import 'package:flutter/material.dart';

class StudentProgressReportsScreen extends StatelessWidget {
  const StudentProgressReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final students = [
      Student(name: 'Ethan Harper', grade: '12th Grade', isSelected: false),
      Student(name: 'Olivia Bennett', grade: '11th Grade', isSelected: true),
      Student(name: 'Noah Carter', grade: '12th Grade', isSelected: false),
      Student(name: 'Ava Mitchell', grade: '11th Grade', isSelected: false),
      Student(name: 'Liam Foster', grade: '12th Grade', isSelected: false),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Student Reports'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Students',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...students.map((student) {
                    return _buildStudentCard(student, theme, context);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student, ThemeData theme, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: student.isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: student.isSelected
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Navigate to student detail report
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    student.name.substring(0, 1),
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
                        student.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        student.grade,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: student.isSelected
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodySmall?.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Student {
  final String name;
  final String grade;
  final bool isSelected;

  Student({
    required this.name,
    required this.grade,
    required this.isSelected,
  });
}

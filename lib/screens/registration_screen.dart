import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

enum UserRole { student, mentor, guidance }

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _contactController = TextEditingController();
  final _institutionController = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  String _selectedEnglishLevel = 'B1';
  String _selectedContactMethod = 'email';

  final List<String> _englishLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  final List<String> _contactMethods = ['email', 'phone', 'whatsapp'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _contactController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Only mentors can sign up in this MVP
    if (_selectedRole != UserRole.mentor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only mentor registration is available in this version'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await authProvider.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      english_level: _selectedEnglishLevel,
      contact: _contactController.text.trim().isEmpty
          ? null
          : _contactController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role selector
                Text(
                  'I am a...',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<UserRole>(
                    initialValue: _selectedRole,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: const [
                      DropdownMenuItem(value: UserRole.student, child: Text('Student')),
                      DropdownMenuItem(value: UserRole.mentor, child: Text('Mentor')),
                      DropdownMenuItem(value: UserRole.guidance, child: Text('Guidance Counselor')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Dynamic form based on role
                if (_selectedRole == UserRole.student) ..._buildStudentForm(theme),
                if (_selectedRole == UserRole.mentor) ..._buildMentorForm(theme),
                if (_selectedRole == UserRole.guidance) ..._buildGuidanceForm(theme),

                const SizedBox(height: 32),

                // Sign up button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleSignup,
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Sign Up'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStudentForm(ThemeData theme) {
    return [
      _buildTextField('Full Name', _nameController, theme),
      const SizedBox(height: 24),
      _buildTextField('Email', _emailController, theme, keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 24),
      _buildTextField('Password', _passwordController, theme, isPassword: true),
    ];
  }

  List<Widget> _buildMentorForm(ThemeData theme) {
    return [
      _buildTextField('Full Name', _nameController, theme),
      const SizedBox(height: 24),
      _buildTextField('Email', _emailController, theme, keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 24),
      _buildTextField('Password', _passwordController, theme, isPassword: true),
      const SizedBox(height: 24),

      // English Level
      Text('English Level', style: theme.textTheme.labelLarge),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonFormField<String>(
          initialValue: _selectedEnglishLevel,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: _englishLevels.map((level) {
            final labels = {
              'A1': 'A1 - Beginner',
              'A2': 'A2 - Elementary',
              'B1': 'B1 - Intermediate',
              'B2': 'B2 - Upper-Intermediate',
              'C1': 'C1 - Advanced',
              'C2': 'C2 - Proficiency',
            };
            return DropdownMenuItem(
              value: level,
              child: Text(labels[level] ?? level),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedEnglishLevel = value!;
            });
          },
        ),
      ),
      const SizedBox(height: 24),

      // Contact Method
      Text('Preferred Contact Method', style: theme.textTheme.labelLarge),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonFormField<String>(
          initialValue: _selectedContactMethod,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: _contactMethods.map((method) {
            final labels = {
              'email': 'Email',
              'phone': 'Phone Call',
              'whatsapp': 'WhatsApp',
            };
            return DropdownMenuItem(
              value: method,
              child: Text(labels[method] ?? method),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedContactMethod = value!;
            });
          },
        ),
      ),
    ];
  }

  List<Widget> _buildGuidanceForm(ThemeData theme) {
    return [
      _buildTextField('Full Name', _nameController, theme),
      const SizedBox(height: 24),
      _buildTextField('Email', _emailController, theme, keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 24),
      _buildTextField('Password', _passwordController, theme, isPassword: true),
      const SizedBox(height: 24),
      _buildTextField('Institution Name', _institutionController, theme),
    ];
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    ThemeData theme, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Enter your ${label.toLowerCase()}',
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return '$label is required';
            if (label == 'Email' && !value!.contains('@')) return 'Invalid email';
            if (label == 'Password' && value!.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}

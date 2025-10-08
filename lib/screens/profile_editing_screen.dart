import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ProfileEditingScreen extends StatefulWidget {
  const ProfileEditingScreen({super.key});

  @override
  State<ProfileEditingScreen> createState() => _ProfileEditingScreenState();
}

class _ProfileEditingScreenState extends State<ProfileEditingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedLevel = 'B1';
  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    final mentor = Provider.of<AuthProvider>(context, listen: false).currentMentor;
    if (mentor != null) {
      _nameController.text = mentor.name;
      _emailController.text = mentor.email;
      _phoneController.text = mentor.contact ?? '';
      _selectedLevel = mentor.english_level;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.updateProfile(
        name: _nameController.text.trim(),
        english_level: _selectedLevel,
        contact: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Only pop if we can - profile screen is usually in a tab, not pushed
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                'Full Name',
                _nameController,
                theme,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Name is required';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'Email',
                _emailController,
                theme,
                keyboardType: TextInputType.emailAddress,
                enabled: false, // Email cannot be changed
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  if (!value!.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'Phone Number',
                _phoneController,
                theme,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'Password',
                _passwordController,
                theme,
                isPassword: true,
                hint: 'Leave blank to keep current password',
              ),
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
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: _levels.map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedLevel = value!);
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    ThemeData theme, {
    bool isPassword = false,
    TextInputType? keyboardType,
    bool enabled = true,
    String? hint,
    String? Function(String?)? validator,
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
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint ?? 'Enter your ${label.toLowerCase()}',
          ),
          validator: validator,
        ),
      ],
    );
  }
}

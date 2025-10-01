import 'package:flutter/material.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<FaqItem> _faqs = [
    FaqItem(
      question: 'How to book a session',
      answer: 'To book a session, navigate to the mentor search screen, select your preferred mentor, and choose an available time slot from their calendar.',
    ),
    FaqItem(
      question: 'How to cancel a session',
      answer: 'Go to your sessions page, find the session you want to cancel, and click the cancel button. Please note cancellation policies may apply.',
    ),
    FaqItem(
      question: 'How to reschedule a session',
      answer: 'Visit your sessions page, select the session you want to reschedule, and choose a new time slot from the available options.',
    ),
    FaqItem(
      question: 'How to contact support',
      answer: 'You can reach us via email at support@example.com, phone at +1 (555) 123-4567, or use our live chat feature below.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search FAQs',
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.textTheme.bodySmall?.color,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // FAQs section
            Text(
              'Frequently Asked Questions',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._faqs.map((faq) => _buildFaqCard(faq, theme)),
            const SizedBox(height: 32),

            // Contact Us section
            Text(
              'Contact Us',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
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
              child: Column(
                children: [
                  _buildContactItem(
                    icon: Icons.email,
                    label: 'Email',
                    value: 'support@example.com',
                    onTap: () {
                      // TODO: Open email client
                    },
                    theme: theme,
                  ),
                  Divider(
                    height: 1,
                    color: theme.brightness == Brightness.light
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFF374151),
                  ),
                  _buildContactItem(
                    icon: Icons.chat,
                    label: 'Live Chat',
                    value: 'Start Chat',
                    onTap: () {
                      // TODO: Open live chat
                    },
                    theme: theme,
                    isAction: true,
                  ),
                  Divider(
                    height: 1,
                    color: theme.brightness == Brightness.light
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFF374151),
                  ),
                  _buildContactItem(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: '+1 (555) 123-4567',
                    onTap: () {
                      // TODO: Open phone dialer
                    },
                    theme: theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(theme, 2),
    );
  }

  Widget _buildFaqCard(FaqItem faq, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: theme.textTheme.bodyLarge,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.textTheme.bodySmall?.color,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq.answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isAction = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.textTheme.bodySmall?.color,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isAction) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chat_bubble,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(ThemeData theme, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.light
                ? const Color(0xFFE5E7EB)
                : const Color(0xFF374151),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Dashboard', currentIndex == 0, theme),
              _buildNavItem(Icons.settings, 'Settings', currentIndex == 1, theme),
              _buildNavItem(Icons.help, 'Help', currentIndex == 2, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, ThemeData theme) {
    final color = isActive ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({
    required this.question,
    required this.answer,
  });
}

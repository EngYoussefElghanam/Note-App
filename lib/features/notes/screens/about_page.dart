import 'package:flutter/material.dart';

/// AboutPage.dart
/// A single-file, ready-to-drop About page for your Note Taker app.
/// - Clean layout
/// - Feature list with icons
/// - Version, CTA for Pro, contact link
/// - Light and dark friendly

class AboutPage extends StatelessWidget {
  final String appName;
  final String version;
  final VoidCallback? onUpgradePressed;
  final VoidCallback? onContactPressed;

  const AboutPage({
    Key? key,
    this.appName = 'Note Taker',
    this.version = 'v1.0.0',
    this.onUpgradePressed,
    this.onContactPressed,
  }) : super(key: key);

  Widget _featureTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.withOpacity(0.08),
            ),
            child: Icon(icon, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('About $appName'),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 72,
                      height: 72,
                      color: isDark ? Colors.white12 : Colors.blue.shade50,
                      child: Center(
                        child: Text(
                          appName
                              .split(' ')
                              .map((s) => s.isNotEmpty ? s[0] : '')
                              .take(2)
                              .join(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Smarter notes for study, secured and synced',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          version,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Short pitch
              Text(
                'Why Note Taker?',
                style: theme.textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Note Taker helps you keep study notes organized, private, and useful — not just stored. Built for focused learners who want features that actually help them review faster.',
                style: TextStyle(color: Colors.grey[700], height: 1.4),
              ),

              const SizedBox(height: 18),

              // Features
              Text(
                'Key Features',
                style: theme.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              _featureTile(
                Icons.folder,
                'Study & General tabs',
                'Separate your study notes from misc notes for faster review.',
              ),
              _featureTile(
                Icons.lock,
                'Secure Lock',
                'Protect sensitive notes with password or biometric lock.',
              ),
              _featureTile(
                Icons.volume_up,
                'Text-to-Speech',
                'Listen to notes when reading isn\'t an option.',
              ),
              _featureTile(
                Icons.auto_mode,
                'AI Summaries',
                'Quickly distill long notes into bite-sized summaries.',
              ),
              _featureTile(
                Icons.cloud,
                'Cloud Sync & Offline',
                'Sync text across devices with offline support for studying anywhere.',
              ),

              const SizedBox(height: 20),

              // CTA / Monetization hint
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: theme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Want more?',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Upgrade to Pro to unlock larger cloud storage, advanced export, and priority support.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onUpgradePressed,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Upgrade'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Contact / Privacy
              Text(
                'Contact & Support',
                style: theme.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Questions, feedback, or bugs? Reach out — we read everything and respond quickly.',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onContactPressed,
                    child: Text(
                      'support@notetaker.app', //change it to your support email
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Legal / small print
              Center(
                child: Column(
                  children: [
                    Text(
                      'Privacy-first • No image uploads in free plan',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Made with focus by a small team. Thank you for supporting us.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

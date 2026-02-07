import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App logo and info
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.gold.withValues(alpha: 0.3),
                          AppTheme.accentLight.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.note_alt_outlined,
                      color: AppTheme.gold,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bloc-Notes Premium',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- How it works ---
            _buildSectionTitle('Comment ça marche'),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.add_circle_outline,
              title: 'Créer des notes',
              description:
                  'Appuyez sur le bouton + en bas à droite pour créer une nouvelle note. '
                  'Chaque note possède un titre et un contenu que vous pouvez rédiger librement.',
            ),
            _buildFeatureCard(
              icon: Icons.folder_outlined,
              title: 'Organiser en dossiers',
              description:
                  'Créez des dossiers pour regrouper vos notes par thème. '
                  'Utilisez le petit bouton dossier au-dessus du bouton + pour créer un nouveau dossier. '
                  'Vous pouvez déplacer vos notes d\'un dossier à l\'autre via le menu ⋮ de chaque note.',
            ),
            _buildFeatureCard(
              icon: Icons.lock_outline,
              title: 'Protéger par mot de passe',
              description:
                  'Verrouillez vos notes ou dossiers sensibles avec un mot de passe. '
                  'Accédez au menu ⋮ puis "Verrouiller" pour définir un mot de passe. '
                  'Le contenu sera masqué jusqu\'à la saisie du bon mot de passe.',
            ),
            _buildFeatureCard(
              icon: Icons.edit_outlined,
              title: 'Modifier et supprimer',
              description:
                  'Appuyez sur une note pour la modifier. '
                  'Utilisez le menu ⋮ pour supprimer, déplacer ou verrouiller une note. '
                  'Un message de confirmation apparaîtra avant toute suppression.',
            ),
            _buildFeatureCard(
              icon: Icons.swap_horiz_rounded,
              title: 'Déplacer des notes',
              description:
                  'Depuis le menu ⋮ d\'une note, sélectionnez "Déplacer" pour la transférer '
                  'dans un autre dossier ou la replacer à la racine.',
            ),

            const SizedBox(height: 32),

            // --- Developer section --- \\
            _buildSectionTitle('Créateur'),
            const SizedBox(height: 16),
            Card(
              color: AppTheme.cardDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppTheme.gold, AppTheme.accentLight],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Hugo EGRY',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Développeur Full-Stack & Mobile',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.cardLight),
                    const SizedBox(height: 16),
                    const Text(
                      'Passionné par le développement, la création '
                      'd\'applications élégantes et fonctionnelles. '
                      'Bloc-Notes Premium est conçu avec soin pour offrir '
                      'une expérience utilisateur fluide et sécurisée.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 7, // espace horizontal entre les chips \\
                      runSpacing:
                          10, // espace vertical si on passe à la ligne \\
                      children: [
                        _buildSocialChip(
                          Icons.language,
                          'Portfolio',
                          'https://github.com/hugoegry',
                        ),
                        _buildSocialChip(
                          Icons.code,
                          'GitHub',
                          'https://github.com/hugoegry',
                        ),
                        _buildSocialChip(
                          Icons.mail_outline,
                          'Contact',
                          'mailto:hugo.egry@epitech.eu',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- Credits ---
            Center(
              child: Column(
                children: [
                  Text(
                    'Fait avec ❤ en Flutter',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© ${DateTime.now().year} Bloc-Notes Premium',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.gold, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSocialChip(IconData icon, String label, String url) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('Impossible d’ouvrir le lien: $url - Erreur: $e');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.gold, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

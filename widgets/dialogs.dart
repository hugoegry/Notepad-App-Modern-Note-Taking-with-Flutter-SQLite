import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PasswordDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool isSetPassword;

  const PasswordDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.isSetPassword = false,
  });

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final _controller = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _controller.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, style: const TextStyle(color: AppTheme.gold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.subtitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                widget.subtitle!,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.gold),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (widget.isSetPassword) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppTheme.gold,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final pw = _controller.text.trim();
            if (pw.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Le mot de passe ne peut pas être vide'),
                ),
              );
              return;
            }
            if (widget.isSetPassword && pw != _confirmController.text.trim()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Les mots de passe ne correspondent pas'),
                ),
              );
              return;
            }
            Navigator.pop(context, pw);
          },
          child: const Text('Valider'),
        ),
      ],
    );
  }
}

class ConfirmDeleteDialog extends StatelessWidget {
  final String itemName;
  final String itemType;

  const ConfirmDeleteDialog({
    super.key,
    required this.itemName,
    this.itemType = 'note',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.danger,
            size: 28,
          ),
          const SizedBox(width: 8),
          const Text('Confirmer', style: TextStyle(color: AppTheme.danger)),
        ],
      ),
      content: Text(
        'Êtes-vous sûr de vouloir supprimer ${itemType == 'folder' ? 'le dossier' : 'la note'} "$itemName" ?\n\nCette action est irréversible.',
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.danger,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}

class MoveToFolderDialog extends StatelessWidget {
  final List<DropdownMenuItem<int?>> folderItems;
  final int? currentFolderId;

  const MoveToFolderDialog({
    super.key,
    required this.folderItems,
    this.currentFolderId,
  });

  @override
  Widget build(BuildContext context) {
    int? selectedFolderId = currentFolderId;
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text(
            'Déplacer vers',
            style: TextStyle(color: AppTheme.gold),
          ),
          content: DropdownButtonFormField<int?>(
            value: selectedFolderId,
            decoration: const InputDecoration(
              labelText: 'Dossier de destination',
              prefixIcon: Icon(Icons.folder_outlined, color: AppTheme.gold),
            ),
            dropdownColor: AppTheme.cardDark,
            items: folderItems,
            onChanged: (value) {
              setState(() => selectedFolderId = value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedFolderId),
              child: const Text('Déplacer'),
            ),
          ],
        );
      },
    );
  }
}

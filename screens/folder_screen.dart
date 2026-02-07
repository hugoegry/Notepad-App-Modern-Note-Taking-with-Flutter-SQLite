import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../models/folder.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/dialogs.dart';
import 'note_editor_screen.dart';

class FolderScreen extends StatefulWidget {
  final NoteFolder folder;

  const FolderScreen({super.key, required this.folder});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final DatabaseService _db = DatabaseService();
  List<Note> _notes = [];
  bool _loading = true;
  late NoteFolder _folder;

  @override
  void initState() {
    super.initState();
    _folder = widget.folder;
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _loading = true);
    final notes = await _db.getNotes(folderId: _folder.id);
    final updatedFolder = await _db.getFolder(_folder.id!);
    setState(() {
      _notes = notes;
      if (updatedFolder != null) _folder = updatedFolder;
      _loading = false;
    });
  }

  Future<void> _createNote() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(folderId: _folder.id)),
    );
    if (result == true) _loadNotes();
  }

  Future<void> _openNote(Note note) async {
    if (note.isLocked) {
      final pw = await showDialog<String>(
        context: context,
        builder: (_) => const PasswordDialog(
          title: 'Note verrouillée',
          subtitle: 'Entrez le mot de passe pour accéder à cette note.',
        ),
      );
      if (pw == null) return;
      if (!_db.verifyPassword(pw, note.password!)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mot de passe incorrect')),
          );
        }
        return;
      }
    }
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
    if (result == true) _loadNotes();
  }

  Future<void> _deleteNote(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(itemName: note.title),
    );
    if (confirm == true) {
      await _db.deleteNote(note.id!);
      _loadNotes();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note supprimée')));
      }
    }
  }

  Future<void> _moveNote(Note note) async {
    final folders = await _db.getFolders();
    final items = <DropdownMenuItem<int?>>[
      const DropdownMenuItem(value: null, child: Text('Racine (sans dossier)')),
      ...folders
          .where((f) => f.id != _folder.id)
          .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
    ];
    if (!mounted) return;
    final result = await showDialog<int?>(
      context: context,
      builder: (_) => MoveToFolderDialog(
        folderItems: items,
        currentFolderId: note.folderId,
      ),
    );
    // result can be null (move to root) — we check if dialog returned vs cancelled
    await _db.moveNoteToFolder(note.id!, result);
    _loadNotes();
  }

  Future<void> _toggleNoteLock(Note note) async {
    if (note.isLocked) {
      final pw = await showDialog<String>(
        context: context,
        builder: (_) => const PasswordDialog(
          title: 'Retirer le verrou',
          subtitle: 'Entrez le mot de passe actuel pour déverrouiller.',
        ),
      );
      if (pw == null) return;
      if (!_db.verifyPassword(pw, note.password!)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mot de passe incorrect')),
          );
        }
        return;
      }
      await _db.updateNotePassword(note.id!, null);
    } else {
      final pw = await showDialog<String>(
        context: context,
        builder: (_) => const PasswordDialog(
          title: 'Protéger la note',
          subtitle: 'Définissez un mot de passe pour cette note.',
          isSetPassword: true,
        ),
      );
      if (pw == null) return;
      await _db.updateNotePassword(note.id!, pw);
    }
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _folder.isLocked
                  ? Icons.folder_off_outlined
                  : Icons.folder_outlined,
              color: AppTheme.gold,
              size: 22,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(_folder.name, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          : _notes.isEmpty
          ? _buildEmpty()
          : _buildNotesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 80,
            color: AppTheme.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Dossier vide',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.6),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur + pour ajouter une note',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    final dateFormat = DateFormat('dd MMM yyyy · HH:mm', 'fr_FR');
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: _notes.length,
        itemBuilder: (_, index) {
          final note = _notes[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openNote(note),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                note.isLocked
                                    ? Icons.lock_outlined
                                    : Icons.sticky_note_2_outlined,
                                color: AppTheme.gold,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          note.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (note.isLocked)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 6),
                                          child: Icon(
                                            Icons.lock,
                                            color: AppTheme.gold,
                                            size: 14,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    note.isLocked ? '••••••' : note.content,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    dateFormat.format(note.updatedAt),
                                    style: TextStyle(
                                      color: AppTheme.textSecondary.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: AppTheme.textSecondary,
                              ),
                              color: AppTheme.cardDark,
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'move',
                                  child: Text('Déplacer'),
                                ),
                                PopupMenuItem(
                                  value: 'lock',
                                  child: Text(
                                    note.isLocked
                                        ? 'Déverrouiller'
                                        : 'Verrouiller',
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Supprimer',
                                    style: TextStyle(color: AppTheme.danger),
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                switch (value) {
                                  case 'move':
                                    _moveNote(note);
                                    break;
                                  case 'lock':
                                    _toggleNoteLock(note);
                                    break;
                                  case 'delete':
                                    _deleteNote(note);
                                    break;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

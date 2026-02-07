import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/note.dart';
import '../models/folder.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/dialogs.dart';
import 'note_editor_screen.dart';
import 'folder_screen.dart';
import 'about_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final DatabaseService _db = DatabaseService();
  List<Note> _notes = [];
  List<NoteFolder> _folders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final notes = await _db.getNotes(rootOnly: true);
    final folders = await _db.getFolders();
    setState(() {
      _notes = notes;
      _folders = folders;
      _loading = false;
    });
  }

  Future<void> _createNote() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
    );
    if (result == true) _loadData();
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
    if (result == true) _loadData();
  }

  Future<void> _deleteNote(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(itemName: note.title),
    );
    if (confirm == true) {
      await _db.deleteNote(note.id!);
      _loadData();
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
      ...folders.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
    ];
    if (!mounted) return;
    final result = await showDialog<int?>(
      context: context,
      builder: (_) => MoveToFolderDialog(
        folderItems: items,
        currentFolderId: note.folderId,
      ),
    );
    if (result != note.folderId) {
      await _db.moveNoteToFolder(note.id!, result);
      _loadData();
    }
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
    _loadData();
  }

  Future<void> _createFolder() async {
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Nouveau dossier',
          style: TextStyle(color: AppTheme.gold),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nom du dossier',
            prefixIcon: Icon(Icons.folder_outlined, color: AppTheme.gold),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _db.insertFolder(NoteFolder(name: result));
      _loadData();
    }
  }

  Future<void> _openFolder(NoteFolder folder) async {
    if (folder.isLocked) {
      final pw = await showDialog<String>(
        context: context,
        builder: (_) => const PasswordDialog(
          title: 'Dossier verrouillé',
          subtitle: 'Entrez le mot de passe pour accéder à ce dossier.',
        ),
      );
      if (pw == null) return;
      if (!_db.verifyPassword(pw, folder.password!)) {
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
      MaterialPageRoute(builder: (_) => FolderScreen(folder: folder)),
    );
    if (result == true) _loadData();
  }

  Future<void> _deleteFolder(NoteFolder folder) async {
    final noteCount = await _db.getNoteCountInFolder(folder.id!);
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 28),
            SizedBox(width: 8),
            Text('Confirmer', style: TextStyle(color: AppTheme.danger)),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le dossier "${folder.name}" ?\n\n'
          '${noteCount > 0 ? "$noteCount note(s) seront déplacées à la racine." : ""}\n'
          'Cette action est irréversible.',
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
      ),
    );
    if (confirm == true) {
      await _db.deleteFolder(folder.id!);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Dossier supprimé')));
      }
    }
  }

  Future<void> _renameFolder(NoteFolder folder) async {
    final nameController = TextEditingController(text: folder.name);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Renommer le dossier',
          style: TextStyle(color: AppTheme.gold),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nouveau nom',
            prefixIcon: Icon(Icons.edit_outlined, color: AppTheme.gold),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            child: const Text('Renommer'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != folder.name) {
      await _db.updateFolder(folder.copyWith(name: result));
      _loadData();
    }
  }

  Future<void> _toggleFolderLock(NoteFolder folder) async {
    if (folder.isLocked) {
      final pw = await showDialog<String>(
        context: context,
        builder: (_) => const PasswordDialog(
          title: 'Retirer le verrou',
          subtitle: 'Entrez le mot de passe actuel pour déverrouiller.',
        ),
      );
      if (pw == null) return;
      if (!_db.verifyPassword(pw, folder.password!)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mot de passe incorrect')),
          );
        }
        return;
      }
      await _db.updateFolderPassword(folder.id!, null);
    } else {
      final pw = await showDialog<String>(
        context: context,
        builder: (_) => const PasswordDialog(
          title: 'Protéger le dossier',
          subtitle: 'Définissez un mot de passe pour ce dossier.',
          isSetPassword: true,
        ),
      );
      if (pw == null) return;
      await _db.updateFolderPassword(folder.id!, pw);
    }
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.note_alt_outlined, color: AppTheme.gold, size: 26),
            SizedBox(width: 8),
            Text('Bloc-Notes'),
          ],
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          : RefreshIndicator(
              color: AppTheme.gold,
              onRefresh: _loadData,
              child: _buildBody(),
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'addFolder',
            onPressed: _createFolder,
            backgroundColor: AppTheme.accentLight,
            child: const Icon(
              Icons.create_new_folder_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'addNote',
            onPressed: _createNote,
            child: const Icon(Icons.add_rounded, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryDark, AppTheme.accent],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.note_alt_outlined,
                    color: AppTheme.gold,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bloc-Notes Premium',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Vos notes, en sécurité.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: AppTheme.gold),
            title: const Text(
              'Accueil',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(color: AppTheme.cardLight),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppTheme.gold),
            title: const Text(
              'À propos',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_folders.isEmpty && _notes.isEmpty) {
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
              'Aucune note pour le moment',
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.6),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur + pour créer votre première note',
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            if (_folders.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.folder_outlined,
                      color: AppTheme.gold,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DOSSIERS',
                      style: TextStyle(
                        color: AppTheme.gold.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              ..._folders.map(_buildFolderCard),
              const SizedBox(height: 16),
            ],
            if (_notes.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sticky_note_2_outlined,
                      color: AppTheme.gold,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'NOTES',
                      style: TextStyle(
                        color: AppTheme.gold.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              ..._notes.map(_buildNoteCard),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFolderCard(NoteFolder folder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openFolder(folder),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    folder.isLocked
                        ? Icons.folder_off_outlined
                        : Icons.folder_outlined,
                    color: AppTheme.accentLight,
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
                              folder.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (folder.isLocked)
                            const Icon(
                              Icons.lock,
                              color: AppTheme.gold,
                              size: 16,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<int>(
                        future: _db.getNoteCountInFolder(folder.id!),
                        builder: (_, snap) => Text(
                          '${snap.data ?? 0} note(s)',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
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
                      value: 'rename',
                      child: Text('Renommer'),
                    ),
                    PopupMenuItem(
                      value: 'lock',
                      child: Text(
                        folder.isLocked ? 'Déverrouiller' : 'Verrouiller',
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
                      case 'rename':
                        _renameFolder(folder);
                        break;
                      case 'lock':
                        _toggleFolderLock(folder);
                        break;
                      case 'delete':
                        _deleteFolder(folder);
                        break;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    final dateFormat = DateFormat('dd MMM yyyy · HH:mm', 'fr_FR');
    return Padding(
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
                          color: AppTheme.textSecondary.withValues(alpha: 0.6),
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
                    const PopupMenuItem(value: 'move', child: Text('Déplacer')),
                    PopupMenuItem(
                      value: 'lock',
                      child: Text(
                        note.isLocked ? 'Déverrouiller' : 'Verrouiller',
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
    );
  }
}

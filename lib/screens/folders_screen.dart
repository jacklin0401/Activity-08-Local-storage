import 'package:flutter/material.dart';

import '../models/folder.dart';
import '../repositories/folder_repository.dart';
import '../repositories/card_repository.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final FolderRepository _folderRepository = FolderRepository();
  final CardRepository _cardRepository = CardRepository();

  List<Folder> _folders = [];
  Map<int, int> _cardCounts = {};

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await _folderRepository.getAllFolders();
    final Map<int, int> counts = {};

    for (final folder in folders) {
      final id = folder.id;
      if (id != null) {
        counts[id] = await _cardRepository.getCardCountByFolder(id);
      }
    }

    if (!mounted) return;
    setState(() {
      _folders = folders;
      _cardCounts = counts;
    });
  }

  Future<void> _deleteFolder(Folder folder) async {
    final folderId = folder.id;
    if (folderId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder?'),
        content: Text(
          'Are you sure you want to delete "${folder.folderName}"?\n\n'
          'This will also delete all ${_cardCounts[folderId] ?? 0} cards in this folder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _folderRepository.deleteFolder(folderId);
      await _loadFolders();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Folder "${folder.folderName}" deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Organizer'),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          final folder = _folders[index];
          final id = folder.id ?? -1;
          final cardCount = _cardCounts[id] ?? 0;

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardsScreen(folder: folder),
                  ),
                );
                await _loadFolders();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getSuitIcon(folder.folderName),
                    size: 64,
                    color: _getSuitColor(folder.folderName),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    folder.folderName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$cardCount cards',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFolder(folder),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getSuitIcon(String suitName) {
    switch (suitName) {
      case 'Hearts':
        return Icons.favorite;
      case 'Diamonds':
        return Icons.change_history;
      case 'Clubs':
        return Icons.filter_vintage;
      case 'Spades':
        return Icons.eco;
      default:
        return Icons.help;
    }
  }

  Color _getSuitColor(String suitName) {
    switch (suitName) {
      case 'Hearts':
      case 'Diamonds':
        return Colors.red;
      case 'Clubs':
      case 'Spades':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}
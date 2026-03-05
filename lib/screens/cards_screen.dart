import 'package:flutter/material.dart';

import '../models/folder.dart';
import '../repositories/card_repository.dart';
import '../models/playing_card.dart'; 
import '../helpers/image_helper.dart'; 
class CardsScreen extends StatefulWidget {
  final Folder folder;
  const CardsScreen({super.key, required this.folder});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _cardRepository = CardRepository();

  List<PlayingCard> _cards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final folderId = widget.folder.id;
    if (folderId == null) return;

    setState(() => _loading = true);
    final cards = await _cardRepository.getCardsByFolderId(folderId);

    if (!mounted) return;
    setState(() {
      _cards = cards;
      _loading = false;
    });
  }

  Future<void> _deleteCard(PlayingCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card?'),
        content: Text('Delete "${card.cardName}"?'),
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
      await _cardRepository.deleteCard(card.id!);
      await _loadCards();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${card.cardName}"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.folderName),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? const Center(child: Text('No cards in this folder yet.'))
              : ListView.builder(
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];

                    return ListTile(
                      leading: Container(
                      width: 55,
                        height: 55,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                        child: Image.asset(
                        card.imageUrl!,
                        fit: BoxFit.contain,
                        ),
                        ),
                      
  
                        
                      title: Text(card.cardName),
                      subtitle: Text(card.suit),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCard(card),
                      ),
                    );
                  },
                ),
    );
  }
}
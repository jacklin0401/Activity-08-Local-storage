import 'package:flutter/material.dart';
import '../models/playing_card.dart';
import '../repositories/card_repository.dart';

class AddEditCardScreen extends StatefulWidget {
  final PlayingCard? card; // null = add, non-null = edit
  final int folderId;

  const AddEditCardScreen({
    super.key,
    this.card,
    required this.folderId,
  });

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final CardRepository _cardRepository = CardRepository();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cardNameController;

  final List<String> _suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
  String? _selectedSuit;
  bool _saving = false;

  bool get _isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    _cardNameController = TextEditingController(
      text: widget.card?.cardName ?? '',
    );
    _selectedSuit = widget.card?.suit ?? 'Hearts';
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    super.dispose();
  }

  String _getImageUrl(String cardName, String suit) {
    final suitCodes = {
      'Hearts': 'H',
      'Diamonds': 'D',
      'Clubs': 'C',
      'Spades': 'S',
    };
    final code = suitCodes[suit] ?? 'H';
    return 'assets/cards/$cardName$code.png';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final cardName = _cardNameController.text.trim();
    final suit = _selectedSuit!;
    final imageUrl = _getImageUrl(cardName, suit);

    final card = PlayingCard(
      id: widget.card?.id,
      cardName: cardName,
      suit: suit,
      imageUrl: imageUrl,
      folderId: widget.folderId,
    );

    if (_isEditing) {
      await _cardRepository.updateCard(card);
    } else {
      await _cardRepository.insertCard(card);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Card' : 'Add Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cardNameController,
                decoration: const InputDecoration(
                  labelText: 'Card Name (A, 2, 3... 10, J, Q, K)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a card name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSuit,
                decoration: const InputDecoration(
                  labelText: 'Suit',
                  border: OutlineInputBorder(),
                ),
                items: _suits.map((suit) {
                  return DropdownMenuItem(
                    value: suit,
                    child: Text(suit),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSuit = value);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator()
                      : Text(_isEditing ? 'Save Changes' : 'Add Card'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../domain/shelf_service.dart';

class ShelfEditPage extends StatefulWidget {
  final Shelf? shelf;

  const ShelfEditPage({super.key, this.shelf});

  @override
  State<ShelfEditPage> createState() => _ShelfEditPageState();
}

class _ShelfEditPageState extends State<ShelfEditPage> {
  late final TextEditingController _nameCtrl;
  late String _selectedColorHex;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.shelf?.name ?? '');
    _selectedColorHex = widget.shelf?.color ?? _shelfColorPalette.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  static const _shelfColorPalette = [
    '#6200EE',
    '#03DAC6',
    '#FF6B6B',
    '#4ECDC4',
    '#45B7D1',
    '#96CEB4',
    '#FFEAA7',
    '#DDA0DD',
    '#98D8C8',
    '#F7DC6F',
    '#BB8FCE',
    '#85C1E9',
  ];

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.shelf != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier l\'étagère' : 'Nouvelle étagère'),
        actions: [
          if (isEdit &&
              widget.shelf!.id != DefaultUnclassifiedShelf.id)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Supprimer',
              onPressed: _saving ? null : () => _delete(context),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'étagère',
              hintText: 'ex: SF, Humour, Polar…',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
            autofocus: !isEdit,
          ),
          const SizedBox(height: 24),
          const Text(
            'Couleur',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _shelfColorPalette.map((hex) {
              final color = _colorFromHex(hex);
              final selected = _selectedColorHex == hex;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorHex = hex),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.6),
                        blurRadius: selected ? 8 : 4,
                        spreadRadius: selected ? 2 : 0,
                      ),
                    ],
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _saving ? null : () => _save(context),
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(isEdit ? 'Enregistrer' : 'Créer l\'étagère'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFromHex(String hex) {
    final h = hex.replaceFirst('#', '');
    if (h.length == 6) {
      return Color(int.parse('FF$h', radix: 16));
    }
    return const Color(0xFF6200EE);
  }

  Future<void> _save(BuildContext context) async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indiquez un nom pour l\'étagère.')),
      );
      return;
    }

    setState(() => _saving = true);
    final service = context.read<ShelfService>();

    try {
      if (widget.shelf != null) {
        await service.updateShelf(
          widget.shelf!.id,
          name: name,
          color: _selectedColorHex,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Étagère mise à jour')),
          );
          Navigator.pop(context);
        }
      } else {
        await service.createShelf(name: name, color: _selectedColorHex);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Étagère créée')),
          );
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer cette étagère ?'),
        content: const Text(
          'Le classement des livres dans cette étagère sera retiré. Les livres ne sont pas supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true || widget.shelf == null || !context.mounted) return;
    setState(() => _saving = true);
    final deleted =
        await context.read<ShelfService>().deleteShelf(widget.shelf!.id);
    if (context.mounted) {
      if (deleted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Étagère supprimée')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'L\'étagère « ${DefaultUnclassifiedShelf.name} » ne peut pas être supprimée.',
            ),
          ),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }
}

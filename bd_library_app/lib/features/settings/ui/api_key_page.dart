import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/llm_key_store.dart';
import 'api_key_scan_page.dart';

/// Page de configuration des clés API LLM : choix du fournisseur (OpenAI, Claude, Mistral, Groq),
/// saisie manuelle ou scan QR code, stockage chiffré (Keychain / Keystore).
class ApiKeyPage extends StatefulWidget {
  const ApiKeyPage({super.key});

  @override
  State<ApiKeyPage> createState() => _ApiKeyPageState();
}

class _ApiKeyPageState extends State<ApiKeyPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _obscureKey = true;
  bool _saving = false;
  LlmProvider _selectedProvider = LlmProvider.openai;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final store = context.read<LlmKeyStore>();
      _controller.text = store.getKey(_selectedProvider) ?? '';
    });
  }

  Future<void> _scanQrCode() async {
    final value = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ApiKeyScanPage()),
    );
    if (value != null && mounted) {
      _controller.text = value;
      await _save();
    }
  }

  Future<void> _save() async {
    final key = _controller.text.trim();
    setState(() => _saving = true);
    try {
      await context.read<LlmKeyStore>().save(_selectedProvider, key.isEmpty ? null : key);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              key.isEmpty
                  ? 'Clé supprimée'
                  : 'Clé ${_selectedProvider.displayName} enregistrée de manière sécurisée',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clear() async {
    _controller.clear();
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clés API (recherche par LLM)'),
      ),
      body: ListenableBuilder(
        listenable: context.watch<LlmKeyStore>(),
        builder: (context, _) {
          final store = context.read<LlmKeyStore>();
          final isConfigured = store.isConfigured(_selectedProvider);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          store.hasAnyConfigured ? Icons.check_circle : Icons.info_outline,
                          color: store.hasAnyConfigured
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            store.hasAnyConfigured
                                ? 'Au moins une clé est enregistrée. Elle sera utilisée pour la recherche par LLM (ChatGPT, Claude, Mistral ou Groq) lorsque BdTheque et OpenLibrary ne trouvent pas de résultat.'
                                : 'Enregistrez une clé API pour activer la recherche de métadonnées par LLM (secours lorsque les autres sources ne trouvent rien). Choisissez le fournisseur ci-dessous.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<LlmProvider>(
                  initialValue: _selectedProvider,
                  decoration: const InputDecoration(
                    labelText: 'Fournisseur',
                    border: OutlineInputBorder(),
                  ),
                  items: LlmProvider.values
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.displayName)))
                      .toList(),
                  onChanged: (LlmProvider? p) {
                    if (p == null) return;
                    setState(() {
                      _selectedProvider = p;
                      _controller.text = store.getKey(p) ?? '';
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  obscureText: _obscureKey,
                  decoration: InputDecoration(
                    labelText: 'Clé API (${_selectedProvider == LlmProvider.openai ? "sk-..." : "clé du fournisseur"})',
                    hintText: 'Coller ou saisir la clé',
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _obscureKey ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              setState(() => _obscureKey = !_obscureKey),
                          tooltip: _obscureKey ? 'Afficher' : 'Masquer',
                        ),
                      ],
                    ),
                  ),
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _saving ? null : () => _scanQrCode(),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scanner un QR code'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: const Text('Enregistrer'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isConfigured)
                      IconButton(
                        onPressed: _saving ? null : _clear,
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Supprimer la clé',
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/services/ai_service.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository_impl.dart';
import '../../product/presentation/product_detail_page.dart';

class TexoraAiPage extends StatefulWidget {
  const TexoraAiPage({super.key});

  @override
  State<TexoraAiPage> createState() => _TexoraAiPageState();
}

class _TexoraAiPageState extends State<TexoraAiPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TexoraAiService _aiService = TexoraAiService();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _checkInternet();
    _addBotMessage(
      'Salom! Men TEXORA AI man 🤖\n\nSizga quyidagilarda yordam bera olaman:\n• Mahsulot tanlash\n• Texnika haqida tushuntirish\n• Mahsulot taqqoslash\n• PC yig\'ish\n• Byudjet bo\'yicha maslahat\n• Mahsulot topish\n\nMasalan: "8 million so\'mga gaming PC yig\'ib ber" deb yozing.',
    );
  }

  Future<void> _checkInternet() async {
    final connected = await _aiService.hasInternet();
    setState(() => _hasInternet = connected);
  }

  void _addBotMessage(String text, {List<ProductModel> products = const []}) {
    setState(() {
      _messages.add(_ChatMessage(isUser: false, text: text, products: products, timestamp: DateTime.now()));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text, timestamp: DateTime.now()));
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _addUserMessage(text);
    _controller.clear();
    setState(() => _isLoading = true);

    try {
      final response = await _aiService.ask(text);
      ProductRepositoryImpl productRepo = ProductRepositoryImpl();
      List<ProductModel> products = [];
      if (response.productIds.isNotEmpty) {
        products = await productRepo.getProductsByIds(response.productIds);
      }

      _addBotMessage(response.text, products: products);
    } on NoInternetException {
      setState(() => _hasInternet = false);
      _addBotMessage('TEXORA AI ishlashi uchun internetga ulaning.\n\nLekin marketplace ning qolgan qismlari offline ishlashda davom etadi.');
    } catch (e) {
      _addBotMessage('Kechirasiz, xatolik yuz berdi: $e\nQayta urinib ko\'ring.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent + 200, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text('TEXORA AI'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_off_rounded),
            onPressed: _checkInternet,
            color: _hasInternet ? null : AppColors.error,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_hasInternet)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.warning.withOpacity(0.15),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('TEXORA AI ishlashi uchun internetga ulaning.', style: AppTextStyles.bodySmall)),
                  TextButton(onPressed: _checkInternet, child: const Text('Tekshirish')),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length && _isLoading) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.backgroundLight, borderRadius: BorderRadius.circular(16)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 12), Text('AI o\'ylayapti...')]),
                    ),
                  );
                }
                final msg = _messages[i];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                    decoration: BoxDecoration(
                      color: msg.isUser ? AppColors.primary : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
                      borderRadius: BorderRadius.circular(16).copyWith(bottomRight: msg.isUser ? const Radius.circular(4) : null, bottomLeft: !msg.isUser ? const Radius.circular(4) : null),
                      border: msg.isUser ? null : Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(msg.text, style: AppTextStyles.bodyMedium.copyWith(color: msg.isUser ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight))),
                          if (msg.products.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            ...msg.products.map(
                              (p) => InkWell(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: p))),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark.withOpacity(0.5) : Colors.white, borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(_iconForCategory(p.category), size: 20, color: AppColors.primary)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(p.name, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            Text(p.price.toPrice, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(AppFormatters.formatDateTime(msg.timestamp), style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: msg.isUser ? Colors.white70 : AppColors.textSecondaryLight)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick suggestions
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _SuggestionChip(text: '8 mln gaming PC', onTap: () => _sendMessage('8 million so\'mga gaming PC yig\'ib ber')),
                _SuggestionChip(text: 'RTX 4060 vs 7800 XT', onTap: () => _sendMessage('RTX 4060 vs RX 7800 XT farqi nima?')),
                _SuggestionChip(text: 'RAM nima?', onTap: () => _sendMessage('RAM nima va qanday tanlash kerak?')),
                _SuggestionChip(text: '5 mln laptop', onTap: () => _sendMessage('5 million so\'mgacha laptop tavsiya qil')),
                _SuggestionChip(text: 'Eng arzon SSD', onTap: () => _sendMessage('Eng arzon SSD ni topib ber')),
              ],
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight, border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight))),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(hintText: 'Savol bering...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                      onSubmitted: _sendMessage,
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                    child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white), onPressed: _isLoading ? null : () => _sendMessage(_controller.text)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'CPU':
        return Icons.memory_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

class _ChatMessage {
  final bool isUser;
  final String text;
  final List<ProductModel> products;
  final DateTime timestamp;
  _ChatMessage({required this.isUser, required this.text, this.products = const [], required this.timestamp});
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(text, style: AppTextStyles.labelSmall),
        onPressed: onTap,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      ),
    );
  }
}

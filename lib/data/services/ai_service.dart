import 'dart:convert';
import 'package:http/http.dart' as http;
import 'connectivity_service.dart';
import 'secure_storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../repositories/product_repository_impl.dart';

class AiResponse {
  final String text;
  final List<String> productIds;
  final bool isOfflineFallback;

  AiResponse({required this.text, this.productIds = const [], this.isOfflineFallback = false});
}

class TexoraAiService {
  final ConnectivityService _connectivity = ConnectivityService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final ProductRepositoryImpl _productRepo = ProductRepositoryImpl();

  Future<bool> hasInternet() async {
    return await _connectivity.isConnected();
  }

  Future<AiResponse> ask(String query) async {
    final connected = await hasInternet();
    if (!connected) {
      throw NoInternetException();
    }

    // Try to get API key from secure storage (not from source code)
    final apiKey = await _secureStorage.read(AppKeys.secureApiKey);

    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        return await _callRealAiApi(query, apiKey);
      } catch (_) {
        // Fallback to local AI if API fails
        return await _localAi(query);
      }
    } else {
      // No API key configured, use local AI based on local DB
      return await _localAi(query);
    }
  }

  Future<AiResponse> _callRealAiApi(String query, String apiKey) async {
    // Placeholder for real AI API call (e.g., OpenAI compatible)
    // This is intentionally generic and reads key from secure storage, not source.
    // For demo, we simulate API call structure and fallback to local logic

    // Example structure for OpenAI-compatible endpoint
    // You can configure endpoint via secure storage extra key if needed
    final endpoint = 'https://api.openai.com/v1/chat/completions';

    // Build context with existing products (limited)
    final products = await _productRepo.getAllProducts();
    final productContext = products.take(20).map((p) => '${p.name} - ${p.price} so\'m - ${p.category}').join('\n');

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content':
              'Sen TEXORA texnika marketining yordamchisisan. Faqat mavjud mahsulotlar haqida gapir. Mahsulot ro\'yxati: $productContext. Narxlarni o\'ylab topma. Foydalanuvchiga o\'zbek tilida yordam ber.'
        },
        {'role': 'user', 'content': query}
      ],
      'max_tokens': 500,
    });

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['choices']?[0]?['message']?['content'] ?? 'Javob olinmadi';
      // Extract product IDs intelligently later
      final matchedIds = await _extractProductIdsFromQuery(query);
      return AiResponse(text: text, productIds: matchedIds);
    } else {
      throw Exception('AI API error: ${response.statusCode}');
    }
  }

  Future<AiResponse> _localAi(String query) async {
    final lower = query.toLowerCase();
    final allProducts = await _productRepo.getAllProducts();

    // Intent detection
    if (lower.contains('gaming pc') || lower.contains('kompyuter yig') || lower.contains('pc yig')) {
      return await _handlePcBuildIntent(query, allProducts);
    } else if (lower.contains('taqqos') || lower.contains('solishtir')) {
      return await _handleComparisonIntent(query, allProducts);
    } else if (lower.contains('byudjet') || lower.contains('budget') || lower.contains('million') || lower.contains('mln')) {
      return await _handleBudgetIntent(query, allProducts);
    } else if (lower.contains('nima') || lower.contains('qanday') || lower.contains('tushuntir') || lower.contains('farqi')) {
      return await _handleExplainIntent(query, allProducts);
    } else {
      return await _handleSearchIntent(query, allProducts);
    }
  }

  Future<AiResponse> _handlePcBuildIntent(String query, List<dynamic> allProducts) async {
    // Extract budget
    int budget = _extractBudget(query);
    if (budget == 0) budget = 10000000; // default 10 mln

    List<String> selectedIds = [];
    Map<String, int> budgetAllocation = {};

    if (budget >= 20000000) {
      // High-end
      budgetAllocation = {'CPU': 25, 'GPU': 40, 'RAM': 10, 'SSD': 8, 'Motherboard': 10, 'PSU': 4, 'Case': 2, 'Cooler': 1};
    } else if (budget >= 12000000) {
      // Mid-high
      budgetAllocation = {'CPU': 25, 'GPU': 35, 'RAM': 12, 'SSD': 8, 'Motherboard': 10, 'PSU': 5, 'Case': 3, 'Cooler': 2};
    } else {
      // Budget
      budgetAllocation = {'CPU': 22, 'GPU': 35, 'RAM': 10, 'SSD': 8, 'Motherboard': 12, 'PSU': 6, 'Case': 4, 'Cooler': 3};
    }

    String resultText = '🎮 ${budget ~/ 1000000} mln so\'mga gaming PC tavsiyasi:\n\n';
    int total = 0;

    for (var type in AppConstants.pcBuilderTypes) {
      final allocPercent = budgetAllocation[type] ?? 12;
      final allocBudget = (budget * allocPercent / 100).round();

      final candidates = allProducts.where((p) => p.category == type).toList()
        ..sort((a, b) => (a.price - allocBudget).abs().compareTo((b.price - allocBudget).abs()));

      if (candidates.isNotEmpty) {
        final chosen = candidates.first;
        selectedIds.add(chosen.id);
        total += chosen.price as int;
        resultText += '• $type: ${chosen.name} - ${(chosen.price as int)} so\'m\n';
      }
    }

    resultText += '\nJami: $total so\'m\n';
    if (total > budget) {
      resultText += '⚠️ Byudjetdan ${total - budget} so\'m oshdi. Arzonroq variantlar tanlash mumkin.\n';
    } else {
      resultText += '✅ Byudjet ichida! Qolgan ${budget - total} so\'mni periferiyaga ishlatishingiz mumkin.\n';
    }
    resultText += '\nBu tavsiya lokal bazadagi mavjud mahsulotlardan tuzilgan.';

    return AiResponse(text: resultText, productIds: selectedIds, isOfflineFallback: true);
  }

  Future<AiResponse> _handleBudgetIntent(String query, List<dynamic> allProducts) async {
    int budget = _extractBudget(query);
    if (budget == 0) {
      return AiResponse(
          text: 'Byudjetingizni ayting, masalan: "8 millionga gaming PC" yoki "5 milliongacha laptop". TEXORA sizga mavjud mahsulotlardan eng yaxshilarini tanlab beradi.',
          isOfflineFallback: true);
    }

    var filtered = allProducts.where((p) => (p.price as int) <= budget).toList();
    filtered.sort((a, b) => (b.rating as double).compareTo(a.rating as double));
    var top = filtered.take(5).toList();

    String text = '💰 $budget so\'m byudjet uchun tavsiyalar:\n\n';
    for (var p in top) {
      text += '• ${p.name} - ${p.price} so\'m, ⭐ ${p.rating}\n';
    }
    if (top.isEmpty) {
      text = 'Afsuski, $budget so\'mga mos mahsulot topilmadi. Byudjetni oshirib ko\'ring yoki kategoriyani ayting.';
    } else {
      text += '\nBular sizning byudjetingizga mos eng reytingli mahsulotlar.';
    }

    return AiResponse(text: text, productIds: top.map((e) => e.id as String).toList(), isOfflineFallback: true);
  }

  Future<AiResponse> _handleComparisonIntent(String query, List<dynamic> allProducts) async {
    // Find products mentioned
    var matched = allProducts.where((p) => query.toLowerCase().contains(p.name.toLowerCase().split(' ').first.toLowerCase())).take(3).toList();
    if (matched.length < 2) {
      matched = (allProducts..shuffle()).take(2).toList();
    }

    String text = '⚖️ Taqqoslash:\n\n';
    for (var p in matched) {
      text += '• ${p.name}\n  Narx: ${p.price} so\'m\n  Reyting: ${p.rating}\n  ${p.specsJson}\n\n';
    }
    text += 'Qaysi biri sizga ko\'proq mos kelishini ayting, batafsil tahlil beraman.';

    return AiResponse(text: text, productIds: matched.map((e) => e.id as String).toList(), isOfflineFallback: true);
  }

  Future<AiResponse> _handleExplainIntent(String query, List<dynamic> allProducts) async {
    String text;
    final lower = query.toLowerCase();
    if (lower.contains('ram')) {
      text =
          'RAM (Random Access Memory) - kompyuterning tezkor xotirasi. DDR4 va DDR5 turlari mavjud. DDR5 tezroq, lekin qimmatroq. Gaming uchun 16GB yetarli, professional ishlar uchun 32GB tavsiya etiladi. TEXORA da DDR4 va DDR5 variantlari mavjud.';
    } else if (lower.contains('gpu') || lower.contains('videokarta')) {
      text =
          'GPU - grafik karta, o\'yinlar va grafik ishlar uchun eng muhim. RTX 4060 1080p uchun, RTX 4070 1440p uchun, RTX 4090 4K uchun ideal. VRAM qanchalik ko\'p bo\'lsa, shunchalik yaxshi. DLSS texnologiyasi FPS ni oshiradi.';
    } else if (lower.contains('cpu') || lower.contains('protsessor')) {
      text =
          'CPU - kompyuterning miyasi. Intel va AMD yetakchi. O\'yin uchun 6-8 yadro yetarli, render uchun 12+ yadro kerak. LGA1700 Intel, AM5 AMD yangi platformasi. TEXORA da har ikkalasi ham mavjud.';
    } else if (lower.contains('ssd')) {
      text =
          'SSD - tez xotira. NVMe PCIe 4.0 7000 MB/s gacha tezlik beradi. 500GB yetarli, 1TB tavsiya. Samsung 980 PRO va 990 PRO eng mashhurlari.';
    } else {
      text =
          'TEXORA AI: Texnika haqida savollaringizga javob beraman. Masalan: "RAM nima?", "4070 vs 7800 XT farqi nima?", "Gaming uchun qanday CPU yaxshi?" deb so\'rang. Men lokal bazamizdagi mahsulotlar asosida tushuntiraman.';
    }

    return AiResponse(text: text, isOfflineFallback: true);
  }

  Future<AiResponse> _handleSearchIntent(String query, List<dynamic> allProducts) async {
    // Simple search
    var filtered = allProducts
        .where((p) =>
            (p.name as String).toLowerCase().contains(query.toLowerCase()) ||
            (p.category as String).toLowerCase().contains(query.toLowerCase()) ||
            (p.brand as String).toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();

    if (filtered.isEmpty) {
      // Try split words
      var words = query.split(' ');
      for (var w in words) {
        if (w.length > 2) {
          var more = allProducts.where((p) => (p.name as String).toLowerCase().contains(w.toLowerCase())).take(3);
          filtered.addAll(more);
        }
      }
      filtered = filtered.toSet().toList();
    }

    String text;
    if (filtered.isEmpty) {
      text = 'Kechirasiz, "$query" bo\'yicha mahsulot topilmadi. Boshqa nom bilan qidirib ko\'ring yoki kategoriyani ayting: CPU, GPU, RAM, Laptop va boshqalar.';
    } else {
      text = '🔍 "$query" uchun topilgan mahsulotlar:\n\n';
      for (var p in filtered.take(5)) {
        text += '• ${p.name} - ${p.price} so\'m\n  ${p.category} | ${p.brand} | ⭐ ${p.rating}\n\n';
      }
      text += 'Batafsil ma\'lumot uchun mahsulotni tanlang.';
    }

    return AiResponse(text: text, productIds: filtered.map((e) => e.id as String).toList(), isOfflineFallback: true);
  }

  int _extractBudget(String query) {
    final lower = query.toLowerCase();
    // Regex for patterns like "8 million", "8 mln", "8000000"
    final mlnRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(mln|million|milyon)');
    final match = mlnRegex.firstMatch(lower);
    if (match != null) {
      final numStr = match.group(1)!;
      final val = double.tryParse(numStr) ?? 0;
      return (val * 1000000).round();
    }

    // Look for numbers with 6+ digits
    final numRegex = RegExp(r'(\d{6,9})');
    final numMatch = numRegex.firstMatch(lower.replaceAll(' ', ''));
    if (numMatch != null) {
      return int.tryParse(numMatch.group(1)!) ?? 0;
    }

    // Try "8 000 000" pattern
    final spacedNum = RegExp(r'(\d+)\s*000\s*000');
    final spacedMatch = spacedNum.firstMatch(lower);
    if (spacedMatch != null) {
      final base = int.tryParse(spacedMatch.group(1)!) ?? 0;
      return base * 1000000;
    }

    return 0;
  }

  Future<List<String>> _extractProductIdsFromQuery(String query) async {
    final products = await _productRepo.searchProducts(query);
    return products.take(3).map((e) => e.id).toList();
  }
}

class NoInternetException implements Exception {
  final String message = AppStrings.noInternetAi;
}

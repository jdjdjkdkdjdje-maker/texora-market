import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _controller = PageController();
  int _current = 0;

  final List<Map<String, String>> _banners = [
    {
      'title': 'Gaming PC Yig\'ish',
      'subtitle': '8 mln so\'mdan boshlab orzuingizdagi PC',
      'cta': 'Yig\'ishni boshlash',
    },
    {
      'title': 'RTX 40 Series',
      'subtitle': 'Yangi avlod grafik kartalar chegirmada',
      'cta': 'Chegirmalarni ko\'rish',
    },
    {
      'title': 'TEXORA AI',
      'subtitle': 'Sun\'iy intellekt sizga mos mahsulot tanlaydi',
      'cta': 'AI dan so\'rash',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _banners.length,
            itemBuilder: (_, i) {
              final banner = _banners[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      i == 0 ? AppColors.secondary : i == 1 ? AppColors.accent : AppColors.success,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(banner['title']!, style: AppTextStyles.h3.copyWith(color: Colors.white)),
                          const SizedBox(height: 6),
                          Text(banner['subtitle']!, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9))),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Text(banner['cta']!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                      child: Icon(i == 0 ? Icons.computer_rounded : i == 1 ? Icons.videogame_asset_rounded : Icons.smart_toy_rounded, size: 32, color: Colors.white),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _current == i ? AppColors.primary : AppColors.borderLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

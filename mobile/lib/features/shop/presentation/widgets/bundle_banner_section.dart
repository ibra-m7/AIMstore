import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/bundle_model.dart';
import '../../data/models/home_feed.dart';
import 'auto_scroll_horizontal_list.dart';
import 'bundle_card.dart';
import 'home_section_shell.dart';

/// قسم عرض السلات على الصفحة الرئيسية — نفس هيكل الأقسام المنحنية.
class BundleBannerSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<BundleModel> bundles;
  final List<Color> gradientColors;
  final String? backgroundImageUrl;
  final Color? titleColor;
  final Color? subtitleColor;
  final bool curveTop;
  final bool curveBottom;
  final bool autoScrollCards;
  final VoidCallback? onViewAll;
  final double titleFontSize;
  final double subtitleFontSize;
  final double? cardWidth;
  final double? rowHeight;
  final double itemSpacing;
  final double paddingTop;
  final double paddingBottom;

  const BundleBannerSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.bundles,
    required this.gradientColors,
    this.backgroundImageUrl,
    this.titleColor,
    this.subtitleColor,
    this.curveTop = false,
    this.curveBottom = true,
    this.autoScrollCards = false,
    this.onViewAll,
    this.titleFontSize = HomeSectionModel.defaultTitleFontSize,
    this.subtitleFontSize = HomeSectionModel.defaultSubtitleFontSize,
    this.cardWidth,
    this.rowHeight,
    this.itemSpacing = HomeSectionModel.defaultItemSpacing,
    this.paddingTop = HomeSectionModel.defaultPaddingTop,
    this.paddingBottom = HomeSectionModel.defaultPaddingBottom,
  });

  @override
  Widget build(BuildContext context) {
    if (bundles.isEmpty) return const SizedBox.shrink();

    final scale = AppScale.of(context);
    final uniqueBundles = <String, BundleModel>{};
    for (final bundle in bundles) {
      uniqueBundles.putIfAbsent(bundle.id, () => bundle);
    }
    final items = uniqueBundles.values.toList(growable: false);
    final cardW = scale.s(
      (cardWidth ?? HomeSectionModel.defaultCardWidth) * 1.08,
    );
    final listHeight =
        rowHeight != null ? scale.s(rowHeight!) : cardW * 1.48;
    final gap = scale.s(itemSpacing);
    final titleSize = scale.s(titleFontSize);
    final subtitleSize = scale.s(subtitleFontSize);
    final useAutoScroll = autoScrollCards && items.length >= 2;

    return HomeSectionShell(
      gradientColors: gradientColors,
      backgroundImageUrl: backgroundImageUrl,
      curveTop: curveTop,
      curveBottom: curveBottom,
      child: Padding(
        padding: EdgeInsets.only(
          top: scale.s(paddingTop),
          bottom: scale.s(paddingBottom),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scale.pagePad),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w900,
                                color: titleColor ?? AppTheme.primaryDark,
                              ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontSize: subtitleSize,
                                  color: subtitleColor ?? AppTheme.mutedText,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onViewAll != null)
                    TextButton(
                      onPressed: onViewAll,
                      style: TextButton.styleFrom(
                        foregroundColor: titleColor ?? AppTheme.primaryDark,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.homeShowAll,
                            style: AppTextStyles.viewAll.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 15,
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: scale.s(12)),
            if (useAutoScroll)
              AutoScrollHorizontalList(
                height: listHeight,
                itemWidth: cardW,
                gap: gap,
                padding: EdgeInsets.symmetric(horizontal: scale.pagePad),
                itemCount: items.length,
                itemBuilder: (_, i) => BundleCard(
                  bundle: items[i],
                  width: cardW,
                ),
              )
            else
              SizedBox(
                height: listHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: scale.pagePad),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => SizedBox(width: gap),
                  itemBuilder: (_, i) => SizedBox(
                    height: listHeight,
                    child: BundleCard(
                      bundle: items[i],
                      width: cardW,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

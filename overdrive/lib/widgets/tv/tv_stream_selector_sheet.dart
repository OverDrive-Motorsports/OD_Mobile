/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## tv_stream_selector_sheet.dart - TV stream picker shown in the bottom sheet.
 ##
 */

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/tv/tv_stream.dart';

/// Bottom-sheet content used to choose the active TV stream.
class TvStreamSelectorSheet extends StatelessWidget {
  const TvStreamSelectorSheet({
    required this.options,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final List<TvStream> options;
  final String selectedId;
  final ValueChanged<TvStream> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Choisir un flux',
          style: AppTextStyles.bodyBold().copyWith(
            fontSize: 15,
            color: AppColors.white.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.94,
          ),
          itemBuilder: (BuildContext context, int index) {
            final option = options[index];
            final isSelected = option.id == selectedId;

            return _TvStreamCard(
              option: option,
              isSelected: isSelected,
              onTap: () {
                onSelected(option);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ],
    );
  }
}

/// One selectable stream option in the stream picker grid.
class _TvStreamCard extends StatelessWidget {
  const _TvStreamCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final TvStream option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected
        ? AppColors.textPrimary
        : AppColors.white.withValues(alpha: 0.18);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: isSelected ? 1 : 0.54,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.white.withValues(alpha: isSelected ? 0.05 : 0.03),
            border: Border.all(
              color: isSelected
                  ? AppColors.white.withValues(alpha: 0.22)
                  : AppColors.white.withValues(alpha: 0.04),
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              AppColors.white.withValues(
                                alpha: isSelected ? 0.025 : 0.018,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (option.isPrimary)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    Center(
                      child: Icon(
                        option.icon,
                        color: foregroundColor,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.16),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(option.icon, color: foregroundColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option.label,
                        style: AppTextStyles.body(
                          color: foregroundColor,
                        ).copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

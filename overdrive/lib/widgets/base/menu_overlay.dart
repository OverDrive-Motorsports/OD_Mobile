/**
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## MenuOverlay - Morphing liquid-glass pill button that expands into a floating menu panel.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Layout constants
// ---------------------------------------------------------------------------

const double _kGlassRadius = 18.0;
const double _kPanelWidth = 160.0;
const double _kPanelPadding = 6.0;
const double _kItemHeight = 38.0;

// Button label pill
const double _kBtnPaddingH = 12.0;
const double _kBtnPaddingV = 7.0;
const double _kBtnFontSize = 14.0;
const double _kBtnChevronSize = 15.0;

// ---------------------------------------------------------------------------
// Glass themes — explicit dark so CupertinoTheme context is irrelevant.
//
// edgeLightColor == edgeShadowColor → uniform border (no directional gradient).
// ---------------------------------------------------------------------------

const _kBorderColor = Color(0x1AFFFFFF);

final _kDarkPanelTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.30,
  blurSigma: 35.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.08,
  vibrancyIntensity: 0.06,
  edgeLightColor: _kBorderColor,
  edgeShadowColor: _kBorderColor,
);

final _kDarkBtnTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.28,
  blurSigma: 20.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.08,
  edgeLightColor: _kBorderColor,
  edgeShadowColor: _kBorderColor,
);

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

@immutable
class MenuOverlayItem {
  const MenuOverlayItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// A liquid-glass pill button that shows the current page label and morphs
/// into a floating menu panel when tapped.
class MenuOverlayButton extends StatefulWidget {
  const MenuOverlayButton({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<MenuOverlayItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<MenuOverlayButton> createState() => _MenuOverlayButtonState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _MenuOverlayButtonState extends State<MenuOverlayButton>
    with SingleTickerProviderStateMixin {
  bool _buttonVisible = true;

  /// Top-right corner of the button in screen coordinates.
  Offset? _anchor;

  /// Actual rendered size of the trigger button, captured on open.
  /// Used as the morph start dimensions so any text length is handled.
  Size? _startSize;

  OverlayEntry? _entry;

  late final AnimationController _ctrl;
  late final Animation<double> _curved;

  double get _panelHeight =>
      widget.items.length * _kItemHeight + _kPanelPadding * 2;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    _ctrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Open / close
  // ---------------------------------------------------------------------------

  void _open() {
    if (!_buttonVisible) return;

    final box = context.findRenderObject()! as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero);
    _startSize = box.size; // actual button size → morph start
    _anchor = Offset(topLeft.dx + box.size.width, topLeft.dy);

    setState(() => _buttonVisible = false);

    _entry = OverlayEntry(
      builder: (ctx) => AnimatedBuilder(
        animation: _curved,
        builder: (context, _) => _buildOverlay(context),
      ),
    );
    Overlay.of(context).insert(_entry!);
    _ctrl.forward(from: 0);
  }

  void _close() {
    _ctrl.reverse().whenComplete(() {
      _entry?.remove();
      _entry = null;
      if (mounted) setState(() => _buttonVisible = true);
    });
  }

  void _onItemSelected(int index) {
    _close();
    widget.onSelected(index);
  }

  // ---------------------------------------------------------------------------
  // Overlay
  // ---------------------------------------------------------------------------

  Widget _buildOverlay(BuildContext context) {
    final t = _curved.value;
    final screenW = MediaQuery.sizeOf(context).width;

    final w0 = _startSize!.width;
    final h0 = _startSize!.height;

    // Size interpolation from actual button size to full panel.
    final width = w0 + (_kPanelWidth - w0) * t;
    final height = h0 + (_panelHeight - h0) * t;

    // Content cross-fade: button label fades out, menu items fade in.
    final labelOpacity = (1.0 - t * 2.0).clamp(0.0, 1.0);
    final menuOpacity = ((t - 0.30) / 0.70).clamp(0.0, 1.0);

    final right = screenW - _anchor!.dx;
    final top = _anchor!.dy;

    final selectedLabel = widget.items[widget.selectedIndex].label;

    return Stack(
      children: [
        // ── Barrier — translucent so scroll passes through to page ───────────
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
          ),
        ),

        // ── Morphing glass ───────────────────────────────────────────────────
        Positioned(
          top: top,
          right: right,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: CupertinoLiquidGlass(
              theme: _kDarkPanelTheme,
              borderRadius:
                  const BorderRadius.all(Radius.circular(_kGlassRadius)),
              width: width,
              height: height,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Button replica — fades out as panel opens.
                  // Anchored to top-right to stay aligned with the real button.
                  if (labelOpacity > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Opacity(
                        opacity: labelOpacity,
                        child: SizedBox(
                          width: w0,
                          height: h0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: _kBtnPaddingH,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  selectedLabel,
                                  style: AppTextStyles.body(
                                    color: AppColors.white,
                                  ).copyWith(
                                    fontSize: _kBtnFontSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.white,
                                  size: _kBtnChevronSize,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Menu items — fade in once panel is wide enough.
                  if (menuOpacity > 0)
                    Positioned.fill(
                      child: Opacity(
                        opacity: menuOpacity,
                        child: Padding(
                          padding: const EdgeInsets.all(_kPanelPadding),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < widget.items.length; i++)
                                _MenuRow(
                                  item: widget.items[i],
                                  isSelected: i == widget.selectedIndex,
                                  onTap: () => _onItemSelected(i),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Real button — pill showing the current page label
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _buttonVisible ? 1.0 : 0.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _open,
        child: CupertinoLiquidGlass(
          theme: _kDarkBtnTheme,
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          padding: const EdgeInsets.symmetric(
            horizontal: _kBtnPaddingH,
            vertical: _kBtnPaddingV,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.items[widget.selectedIndex].label,
                style: AppTextStyles.body(color: AppColors.white).copyWith(
                  fontSize: _kBtnFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.white,
                size: _kBtnChevronSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Menu row — LiquidGlassBloom on selected icon
// ---------------------------------------------------------------------------

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final MenuOverlayItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.white : AppColors.textSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: _kItemHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.white.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (isSelected)
              LiquidGlassBloom(
                color: AppColors.white,
                radius: 14,
                spread: 3,
                intensity: 0.22,
                child: Icon(item.icon, size: 17, color: color),
              )
            else
              Icon(item.icon, size: 17, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(color: color).copyWith(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

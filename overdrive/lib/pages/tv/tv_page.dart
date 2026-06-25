/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## tv_page.dart - TV experience page with a full-screen live player shell.
 ##
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../services/tv/tv_mock_data.dart';
import '../../services/tv/tv_stream.dart';
import '../../widgets/base/app_modal.dart';
import '../../widgets/tv/tv_live_player.dart';
import '../../widgets/tv/tv_stream_selector_sheet.dart';

/// Full-screen TV page that combines the player and floating controls.
class TvPage extends StatefulWidget {
  const TvPage({super.key});

  @override
  State<TvPage> createState() => _TvPageState();
}

/// Owns TV stream selection and page-level navigation controls.
class _TvPageState extends State<TvPage> {
  static const List<TvStream> _streams = tvStreamsMonacoMock;

  late TvStream _selectedStream = _streams.firstWhere(
    (TvStream stream) => stream.isPrimary,
    orElse: () => _streams.first,
  );

  /// Opens the stream picker and updates the selected stream on selection.
  Future<void> _openStreamSelector() {
    return AppModal.show<void>(
      context,
      child: TvStreamSelectorSheet(
        options: _streams,
        selectedId: _selectedStream.id,
        onSelected: (TvStream stream) {
          setState(() {
            _selectedStream = stream;
          });
        },
      ),
    );
  }

  /// Leaves the TV experience and returns to the home route.
  void _goBack() {
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: TvLivePlayer(stream: _selectedStream)),
          const Positioned.fill(
            child: IgnorePointer(child: _PlayerFrameEffects()),
          ),
          Positioned(
            top: topPadding + 14,
            left: 18,
            right: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _LiveBadge(isActive: _selectedStream.isLive),
                const Spacer(),
                _TopControlButton(icon: Icons.close_rounded, onTap: _goBack),
              ],
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: bottomPadding + 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(child: _PlayerCopy(stream: _selectedStream)),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _openStreamSelector,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.grid_view_rounded,
                              size: 16,
                              color: AppColors.white.withValues(alpha: 0.78),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Flux',
                              style: AppTextStyles.bodyBold().copyWith(
                                fontSize: 13,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.keyboard_arrow_up_rounded,
                              size: 18,
                              color: AppColors.gold.withValues(alpha: 0.88),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _LiveStatusBar(
                  label: _selectedStream.isPrimary
                      ? 'Flux principal'
                      : _selectedStream.label,
                  isLive: _selectedStream.isLive,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact badge showing whether the selected stream is currently live.
class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _LivePulseDot(isActive: isActive),
          const SizedBox(width: 8),
          Text(
            'LIVE',
            style: AppTextStyles.bodyBold(
              color: isActive ? AppColors.white : AppColors.textMuted,
            ).copyWith(letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}

/// Floating top-right control used for page-level actions.
class _TopControlButton extends StatelessWidget {
  const _TopControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          color: AppColors.white.withValues(alpha: 0.88),
          size: 18,
        ),
      ),
    );
  }
}

/// Primary title shown above the player status bar.
class _PlayerCopy extends StatelessWidget {
  const _PlayerCopy({required this.stream});

  final TvStream stream;

  @override
  Widget build(BuildContext context) {
    return Text(
      stream.title,
      style: AppTextStyles.bodyBold().copyWith(
        fontSize: 22,
        color: AppColors.white,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Non-interactive gradients that keep controls readable over video.
class _PlayerFrameEffects extends StatelessWidget {
  const _PlayerFrameEffects();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.black.withValues(alpha: 0.44),
            Colors.transparent,
            AppColors.black.withValues(alpha: 0.18),
            AppColors.black.withValues(alpha: 0.78),
          ],
          stops: const <double>[0, 0.18, 0.52, 1],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.10),
            radius: 1.2,
            colors: <Color>[
              AppColors.gold.withValues(alpha: 0.16),
              AppColors.white.withValues(alpha: 0.04),
              Colors.transparent,
              AppColors.black.withValues(alpha: 0.30),
            ],
            stops: const <double>[0, 0.14, 0.42, 1],
          ),
        ),
      ),
    );
  }
}

/// Bottom progress-style indicator for the selected stream.
class _LiveStatusBar extends StatelessWidget {
  const _LiveStatusBar({required this.label, required this.isLive});

  final String label;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: <Color>[
                  AppColors.gold.withValues(alpha: isLive ? 0.94 : 0.26),
                  AppColors.white.withValues(alpha: 0.56),
                  AppColors.white.withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyles.caption(
            color: AppColors.gold.withValues(alpha: 0.88),
          ).copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

/// Animated dot used by the live badge when a stream is active.
class _LivePulseDot extends StatefulWidget {
  const _LivePulseDot({required this.isActive});

  final bool isActive;

  @override
  State<_LivePulseDot> createState() => _LivePulseDotState();
}

/// Runs the live pulse animation for the badge dot.
class _LivePulseDotState extends State<_LivePulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.34),
          shape: BoxShape.circle,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final pulse = 0.58 + (_controller.value * 0.42);
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Color.lerp(
              AppColors.red,
              AppColors.gold,
              0.35,
            )!.withValues(alpha: pulse),
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.28 * pulse),
                blurRadius: 10,
                spreadRadius: 1.5,
              ),
            ],
          ),
        );
      },
    );
  }
}

/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## replay_page.dart - Replay library: one flat list of every replay, downloaded ones first.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/replay/replay_item.dart';
import '../../services/replay/replay_mock_data.dart';
import '../../widgets/base/app_button.dart';
import '../../widgets/base/search_bar.dart';
import 'replay_detail_page.dart';

const _kCardEdgeColor = Color(0x26FFFFFF);

final _kCardTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.16,
  blurSigma: 24.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.10,
  vibrancyIntensity: 0.05,
  edgeLightColor: _kCardEdgeColor,
  edgeShadowColor: _kCardEdgeColor,
);

/// Replay library route: every replay in one list, downloaded ones first.
class ReplayPage extends StatefulWidget {
  const ReplayPage({super.key});

  @override
  State<ReplayPage> createState() => _ReplayPageState();
}

class _ReplayPageState extends State<ReplayPage> {
  late final TextEditingController _searchController;
  late final Set<String> _downloadedIds;
  final Set<String> _downloadingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _downloadedIds = <String>{
      for (final replay in replayCatalogMock)
        if (replay.isDownloaded) replay.id,
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ReplayItem> get _sortedReplays {
    final downloaded = <ReplayItem>[];
    final notDownloaded = <ReplayItem>[];
    for (final replay in replayCatalogMock) {
      (_downloadedIds.contains(replay.id) ? downloaded : notDownloaded).add(
        replay,
      );
    }
    return [...downloaded, ...notDownloaded];
  }

  Future<void> _downloadReplay(ReplayItem replay) async {
    if (_downloadedIds.contains(replay.id) ||
        _downloadingIds.contains(replay.id)) {
      return;
    }
    setState(() => _downloadingIds.add(replay.id));
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _downloadingIds.remove(replay.id);
      _downloadedIds.add(replay.id);
    });
  }

  void _openReplay(ReplayItem replay) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReplayDetailPage(replay: replay),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final replays = _sortedReplays;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  AppButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppSearchBar(
                props: AppSearchBarProps(
                  controller: _searchController,
                  placeholder: 'Rechercher un replay',
                  onSearch: (_) {},
                  onClear: () {},
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [
                  for (var i = 0; i < replays.length; i++) ...[
                    _ReplayRow(
                      replay: replays[i],
                      isDownloaded: _downloadedIds.contains(replays[i].id),
                      isDownloading: _downloadingIds.contains(replays[i].id),
                      onDownload: () => _downloadReplay(replays[i]),
                      onOpen: _downloadedIds.contains(replays[i].id)
                          ? () => _openReplay(replays[i])
                          : null,
                    ),
                    if (i < replays.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One replay row: opens the detail page when downloaded, otherwise offers a download action.
class _ReplayRow extends StatelessWidget {
  const _ReplayRow({
    required this.replay,
    required this.isDownloaded,
    required this.isDownloading,
    required this.onDownload,
    this.onOpen,
  });

  final ReplayItem replay;
  final bool isDownloaded;
  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: CupertinoLiquidGlass(
        theme: _kCardTheme,
        borderRadius: BorderRadius.circular(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: GestureDetector(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  _ReplayThumb(color: replay.accentColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          replay.raceName,
                          style: AppTextStyles.bodyBold().copyWith(
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${replay.championshipName} · ${_formatDate(replay.sessionDate)}',
                          style: AppTextStyles.caption(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isDownloaded)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    )
                  else
                    AppButton(
                      icon: Icons.download_rounded,
                      isLoading: isDownloading,
                      onPressed: onDownload,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded thumbnail placeholder shown next to every replay row.
class _ReplayThumb extends StatelessWidget {
  const _ReplayThumb({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.play_arrow_rounded, color: color, size: 22),
    );
  }
}

/// Formats a session date as "D month" using French, unaccented month names.
String _formatDate(DateTime date) {
  const monthLabels = <String>[
    'janvier',
    'fevrier',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'aout',
    'septembre',
    'octobre',
    'novembre',
    'decembre',
  ];
  return '${date.day} ${monthLabels[date.month - 1]}';
}

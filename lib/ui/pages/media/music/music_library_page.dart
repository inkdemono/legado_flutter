import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/media/music_playlist.dart';
import '../../../../data/models/media/music_track.dart';
import '../../../../data/repositories/media/music_repository.dart';
import '../../../../providers/media/music_player_provider.dart';
import '../../../widgets/home/home_shell.dart';
import 'widgets/mini_player_widget.dart';

enum _MusicLibraryTab {
  tracks('歌曲'),
  albums('专辑'),
  artists('艺术家'),
  playlists('播放列表');

  const _MusicLibraryTab(this.label);
  final String label;
}

/// 音乐库页面
class MusicLibraryPage extends ConsumerStatefulWidget {
  final bool embedded;

  const MusicLibraryPage({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<MusicLibraryPage> createState() => _MusicLibraryPageState();
}

class _MusicLibraryPageState extends ConsumerState<MusicLibraryPage> {
  final MusicRepository _repository = MusicRepository.instance;

  List<MusicTrack> _tracks = [];
  List<MusicTrack> _recentTracks = [];
  List<MusicPlaylist> _playlists = [];
  List<String> _artists = [];
  List<String> _albums = [];
  bool _isLoading = true;
  _MusicLibraryTab _activeTab = _MusicLibraryTab.tracks;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    setState(() => _isLoading = true);

    try {
      final tracks = await _repository.getAllTracks();
      final recentTracks = await _repository.getRecentTracks(limit: 8);
      final playlists = await _repository.getAllPlaylists();
      final artists = await _repository.getArtists();
      final albums = await _repository.getAlbums();

      if (!mounted) return;
      setState(() {
        _tracks = tracks;
        _recentTracks = recentTracks;
        _playlists = playlists;
        _artists = artists;
        _albums = albums;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = ref.watch(currentTrackProvider);

    final content = Column(
      children: [
        Expanded(
          child: _isLoading
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: const [
                    SizedBox(height: 220),
                    Center(child: CircularProgressIndicator()),
                  ],
                )
              : RefreshIndicator(
                  onRefresh: _loadLibrary,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (!widget.embedded) ...[
                        _buildPageHeader(context),
                        const SizedBox(height: 12),
                      ],
                      _buildHeroCard(context),
                      const SizedBox(height: 16),
                      _buildTabStrip(context),
                      const SizedBox(height: 16),
                      _buildActiveSection(context),
                    ],
                  ),
                ),
        ),
        if (currentTrack != null) const MiniPlayerWidget(),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFFFF7AA5), Color(0xFF7C5CFF)],
        child: SafeArea(bottom: false, child: content),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '音乐库',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: HomePalette.primaryText(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '按标签切换浏览歌曲、专辑、艺术家和播放列表',
                style: TextStyle(
                  fontSize: 12,
                  color: HomePalette.tertiaryText(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildHeaderButton(
          context,
          icon: Icons.library_add_rounded,
          onTap: _scanLocalMusic,
        ),
        const SizedBox(width: 8),
        _buildHeaderButton(
          context,
          icon: Icons.refresh_rounded,
          onTap: _loadLibrary,
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF7AA5), Color(0xFF7C5CFF), Color(0xFF5EB6FF)],
          stops: [0.0, 0.58, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C5CFF).withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Music',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              _buildHeroAction(
                icon: Icons.refresh_rounded,
                label: '刷新',
                onTap: _loadLibrary,
              ),
              const SizedBox(width: 8),
              _buildHeroAction(
                icon: Icons.library_add_rounded,
                label: '扫描',
                onTap: _scanLocalMusic,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '媒体主首页展示概念已经有了，这里把标签切换、曲目密度和底部迷你播放器放在同一页里收齐。',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard(value: '${_tracks.length}', label: '歌曲'),
              const SizedBox(width: 10),
              _buildMetricCard(value: '${_albums.length}', label: '专辑'),
              const SizedBox(width: 10),
              _buildMetricCard(value: '${_playlists.length}', label: '歌单'),
            ],
          ),
          if (_recentTracks.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '最近播放：${_recentTracks.first.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '共 ${_recentTracks.length} 首',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.74),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.76),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabStrip(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _MusicLibraryTab.values.map((tab) {
          final isActive = _activeTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _activeTab = tab;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF6B4DFF)
                      : const Color(0xFFECE8FF),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFF6B4DFF).withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : const Color(0xFF6B4DFF),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveSection(BuildContext context) {
    if (_tracks.isEmpty &&
        _albums.isEmpty &&
        _artists.isEmpty &&
        _playlists.isEmpty) {
      return _buildEmptyState(context);
    }

    switch (_activeTab) {
      case _MusicLibraryTab.tracks:
        return _buildTracksSection(context);
      case _MusicLibraryTab.albums:
        return _buildCollectionSection(
          context,
          title: '全部专辑',
          subtitle: '按专辑快速浏览音乐集合',
          items: _albums,
          iconBuilder: (index) => _buildGradientBox(
            index,
            icon: Icons.album_rounded,
          ),
          metaBuilder: (album) {
            final count = _tracks.where((track) => track.album == album).length;
            return '$count 首歌曲';
          },
        );
      case _MusicLibraryTab.artists:
        return _buildCollectionSection(
          context,
          title: '全部艺术家',
          subtitle: '按艺术家维度整理音乐库',
          items: _artists,
          iconBuilder: (index) => _buildGradientBox(
            index,
            icon: Icons.mic_external_on_rounded,
          ),
          metaBuilder: (artist) {
            final count =
                _tracks.where((track) => track.artist == artist).length;
            return '$count 首歌曲';
          },
        );
      case _MusicLibraryTab.playlists:
        return _buildPlaylistsSection(context);
    }
  }

  Widget _buildTracksSection(BuildContext context) {
    final visibleTracks = _tracks.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_recentTracks.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            title: '最近播放',
            subtitle: '保留最近听过的 ${_recentTracks.length} 首歌曲',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _recentTracks.take(5).length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final track = _recentTracks[index];
                return _RecentTrackCard(
                  track: track,
                  index: index,
                  onTap: () async {
                    final startIndex =
                        _tracks.indexWhere((item) => item.id == track.id);
                    await ref.read(musicPlaylistProvider.notifier).setPlaylist(
                          _tracks,
                          startIndex: startIndex < 0 ? 0 : startIndex,
                        );
                  },
                  coverGradient: _coverGradient(index),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
        ],
        _buildSectionHeader(
          context,
          title: '全部歌曲',
          subtitle: _tracks.length > visibleTracks.length
              ? '共 ${_tracks.length} 首，当前展示前 ${visibleTracks.length} 首'
              : '最近导入的 ${_tracks.length} 首音乐',
        ),
        const SizedBox(height: 12),
        ...List.generate(visibleTracks.length, (index) {
          final track = visibleTracks[index];
          return _TrackCard(
            track: track,
            playlist: _tracks,
            index: index,
            coverGradient: _coverGradient(index),
          );
        }),
      ],
    );
  }

  Widget _buildPlaylistsSection(BuildContext context) {
    if (_playlists.isEmpty) {
      return _buildCollectionEmptyState(
        context,
        title: '播放列表',
        icon: Icons.queue_music_rounded,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: '播放列表',
          subtitle: '快速进入常用集合',
        ),
        const SizedBox(height: 12),
        ...List.generate(_playlists.length.clamp(0, 8), (index) {
          final playlist = _playlists[index];
          return HomeSectionCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _buildGradientBox(
                  index,
                  icon: Icons.queue_music_rounded,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: HomePalette.primaryText(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        playlist.description?.isNotEmpty == true
                            ? playlist.description!
                            : '${playlist.trackCount} 首歌曲',
                        style: TextStyle(
                          fontSize: 12,
                          color: HomePalette.tertiaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F0FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${playlist.trackCount} 首',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B4DFF),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCollectionSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<String> items,
    required Widget Function(int index) iconBuilder,
    required String Function(String item) metaBuilder,
  }) {
    if (items.isEmpty) {
      return _buildCollectionEmptyState(
        context,
        title: title,
        icon: Icons.queue_music_rounded,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, title: title, subtitle: subtitle),
        const SizedBox(height: 12),
        ...List.generate(items.length.clamp(0, 8), (index) {
          final item = items[index];
          return HomeSectionCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                iconBuilder(index),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: HomePalette.primaryText(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metaBuilder(item),
                        style: TextStyle(
                          fontSize: 12,
                          color: HomePalette.tertiaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: HomePalette.tertiaryText(context),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCollectionEmptyState(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    return HomeSectionCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          const SizedBox(height: 18),
          Icon(
            icon,
            size: 48,
            color: HomePalette.tertiaryText(context),
          ),
          const SizedBox(height: 14),
          Text(
            '当前没有$title',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: HomePalette.primaryText(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '先扫描本地音乐后，这里会按分类自动聚合。',
            style: TextStyle(color: HomePalette.secondaryText(context)),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildGradientBox(
    int index, {
    required IconData icon,
  }) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _coverGradient(index),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: HomePalette.primaryText(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: HomePalette.tertiaryText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return HomeSectionCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          const SizedBox(height: 18),
          Icon(
            Icons.music_note_rounded,
            size: 64,
            color: HomePalette.tertiaryText(context),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无歌曲',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: HomePalette.primaryText(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '扫描本地目录后，这里会展示最近播放、播放列表和歌曲列表。',
            textAlign: TextAlign.center,
            style: TextStyle(color: HomePalette.secondaryText(context)),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _scanLocalMusic,
                icon: const Icon(Icons.library_add_rounded),
                label: const Text('扫描本地音乐'),
              ),
              OutlinedButton.icon(
                onPressed: _loadLibrary,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('刷新'),
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  void _scanLocalMusic() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('扫描本地音乐功能开发中...')),
    );
  }

  List<Color> _coverGradient(int index) {
    const gradients = [
      [Color(0xFFFF7AA5), Color(0xFF7C5CFF)],
      [Color(0xFFFFD36F), Color(0xFFFF8A5B)],
      [Color(0xFF5EB6FF), Color(0xFF2F6BFF)],
      [Color(0xFF34D399), Color(0xFF14B8A6)],
      [Color(0xFFFA709A), Color(0xFFFEE140)],
    ];
    return gradients[index % gradients.length];
  }

  Widget _buildHeaderButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: HomePalette.card(context).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HomePalette.lineColor(context)),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: HomePalette.primaryText(context),
          ),
        ),
      ),
    );
  }
}

class _TrackCard extends ConsumerWidget {
  final MusicTrack track;
  final List<MusicTrack> playlist;
  final int index;
  final List<Color> coverGradient;

  const _TrackCard({
    required this.track,
    required this.playlist,
    required this.index,
    required this.coverGradient,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrack = ref.watch(currentTrackProvider);
    final isPlaying = currentTrack?.id == track.id;

    return HomeSectionCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      onTap: () async {
        await ref
            .read(musicPlaylistProvider.notifier)
            .setPlaylist(playlist, startIndex: index);
      },
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: coverGradient,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSubtitle(track),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: HomePalette.tertiaryText(context),
                  ),
                ),
                if (isPlaying) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '正在播放',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B4DFF),
                      ),
                    ),
                  ),
                ] else if (track.album?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      track.album!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4E5969),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isPlaying
                      ? const Color(0xFFF3F0FF)
                      : HomePalette.mutedCard(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () async {
                    await ref
                        .read(musicPlaylistProvider.notifier)
                        .setPlaylist(playlist, startIndex: index);
                  },
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: isPlaying
                        ? const Color(0xFF6B4DFF)
                        : HomePalette.secondaryText(context),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: HomePalette.tertiaryText(context),
                ),
                onSelected: (value) async {
                  if (value == 'play') {
                    await ref
                        .read(musicPlaylistProvider.notifier)
                        .setPlaylist(playlist, startIndex: index);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'play',
                    child: Text('播放'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSubtitle(MusicTrack track) {
    final parts = <String>[];
    if (track.artist != null && track.artist!.isNotEmpty) {
      parts.add(track.artist!);
    }
    if (track.formattedDuration != '--:--') {
      parts.add(track.formattedDuration);
    }
    return parts.join(' · ');
  }
}

class _RecentTrackCard extends StatelessWidget {
  final MusicTrack track;
  final int index;
  final VoidCallback onTap;
  final List<Color> coverGradient;

  const _RecentTrackCard({
    required this.track,
    required this.index,
    required this.onTap,
    required this.coverGradient,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: HomeSectionCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: coverGradient,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: HomePalette.primaryText(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist?.isNotEmpty == true ? track.artist! : '未知艺术家',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: HomePalette.tertiaryText(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

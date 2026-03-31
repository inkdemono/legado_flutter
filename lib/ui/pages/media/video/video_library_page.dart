import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/media/video_item.dart';
import '../../../../data/repositories/media/video_repository.dart';
import '../../../../providers/media/video_player_provider.dart';
import '../../../widgets/home/home_shell.dart';
import 'video_player_page.dart';
import 'widgets/video_item_card.dart';

enum _VideoLibraryTab {
  all('全部'),
  local('本地'),
  history('历史');

  const _VideoLibraryTab(this.label);
  final String label;
}

/// 视频库页面
class VideoLibraryPage extends ConsumerStatefulWidget {
  final bool embedded;

  const VideoLibraryPage({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<VideoLibraryPage> createState() => _VideoLibraryPageState();
}

class _VideoLibraryPageState extends ConsumerState<VideoLibraryPage> {
  List<VideoItem> _videos = [];
  bool _isLoading = true;
  _VideoLibraryTab _activeTab = _VideoLibraryTab.all;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() => _isLoading = true);

    final videos = await VideoRepository.instance.getAllVideos();

    if (mounted) {
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _isLoading
        ? ListView(
            padding: const EdgeInsets.all(24),
            children: const [
              SizedBox(height: 220),
              Center(child: CircularProgressIndicator()),
            ],
          )
        : RefreshIndicator(
            onRefresh: _loadVideos,
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
                _buildActiveContent(context),
              ],
            ),
          );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFF0EA5E9), Color(0xFF312E81)],
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
                '视频库',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: HomePalette.primaryText(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '用网格缩略图管理本地视频和观看历史',
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
          icon: Icons.video_library_outlined,
          onTap: _scanLocalVideos,
        ),
        const SizedBox(width: 8),
        _buildHeaderButton(
          context,
          icon: Icons.refresh_rounded,
          onTap: _loadVideos,
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final localCount = _videos.where((video) => video.isLocal).length;
    final historyCount =
        _videos.where((video) => video.watchProgress > 0).length;
    final unfinishedCount = _videos.where((video) {
      final progress = video.watchProgressPercent;
      return progress > 0 && progress < 1;
    }).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0EA5E9), Color(0xFF2563EB), Color(0xFF312E81)],
          stops: [0.0, 0.58, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.18),
            blurRadius: 26,
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
                  'Video',
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
                onTap: _loadVideos,
              ),
              const SizedBox(width: 8),
              _buildHeroAction(
                icon: Icons.folder_open_rounded,
                label: '扫描',
                onTap: _scanLocalVideos,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '视频库更依赖缩略图扫描，所以主入口用高比例网格承载，本地和观看历史用标签切换来分流。',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard(value: '${_videos.length}', label: '全部'),
              const SizedBox(width: 10),
              _buildMetricCard(value: '$localCount', label: '本地'),
              const SizedBox(width: 10),
              _buildMetricCard(value: '$historyCount', label: '历史'),
            ],
          ),
          if (unfinishedCount > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
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
                      '继续观看：还有 $unfinishedCount 个视频未看完',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
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
        children: _VideoLibraryTab.values.map((tab) {
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
                      ? const Color(0xFF0369A1)
                      : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFF0369A1).withValues(alpha: 0.18),
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
                    color: isActive ? Colors.white : const Color(0xFF0369A1),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveContent(BuildContext context) {
    if (_videos.isEmpty) {
      return _buildEmptyState(context);
    }

    switch (_activeTab) {
      case _VideoLibraryTab.all:
        return _buildVideoGridSection(
          context,
          title: '全部视频',
          subtitle: '当前媒体库共 ${_videos.length} 条内容',
          videos: _videos,
        );
      case _VideoLibraryTab.local:
        final localVideos = _videos.where((video) => video.isLocal).toList();
        if (localVideos.isEmpty) {
          return _buildEmptyState(
            context,
            title: '暂无本地视频',
            subtitle: '扫描本地目录后，这里会展示本地视频和观看进度。',
          );
        }
        return _buildVideoGridSection(
          context,
          title: '本地视频',
          subtitle: '已扫描到 ${localVideos.length} 条本地内容',
          videos: localVideos,
        );
      case _VideoLibraryTab.history:
        final historyVideos =
            _videos.where((video) => video.watchProgress > 0).toList();
        if (historyVideos.isEmpty) {
          return _buildEmptyState(
            context,
            title: '暂无观看历史',
            subtitle: '开始播放视频后，这里会记录你的观看进度。',
          );
        }
        return _buildHistorySection(context, historyVideos);
    }
  }

  Widget _buildVideoGridSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<VideoItem> videos,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, title: title, subtitle: subtitle),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.74,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return VideoItemCard(
              video: video,
              onTap: () => _playVideo(video),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHistorySection(BuildContext context, List<VideoItem> videos) {
    final recentVideos = List<VideoItem>.from(videos)
      ..sort((a, b) {
        final aTime = a.lastWatchedAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.lastWatchedAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
    final continueWatching = videos.where((video) {
      final progress = video.watchProgressPercent;
      return progress > 0 && progress < 1;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (continueWatching.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            title: '继续观看',
            subtitle: '还有 ${continueWatching.length} 个视频未看完',
          ),
          const SizedBox(height: 12),
          ...continueWatching.take(4).map(
                (video) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: VideoItemCard(
                    video: video,
                    isHorizontal: true,
                    onTap: () => _playVideo(video),
                  ),
                ),
              ),
          const SizedBox(height: 18),
        ],
        _buildSectionHeader(
          context,
          title: '最近观看',
          subtitle: '最近有进度记录的 ${recentVideos.length} 条内容',
        ),
        const SizedBox(height: 12),
        ...recentVideos.take(6).map(
              (video) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: VideoItemCard(
                  video: video,
                  isHorizontal: true,
                  onTap: () => _playVideo(video),
                ),
              ),
            ),
      ],
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

  Widget _buildEmptyState(
    BuildContext context, {
    String title = '暂无视频',
    String subtitle = '扫描本地目录后，这里会展示最近观看、继续播放和全部视频内容。',
  }) {
    return HomeSectionCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          const SizedBox(height: 18),
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: HomePalette.tertiaryText(context),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: HomePalette.primaryText(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
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
                onPressed: _scanLocalVideos,
                icon: const Icon(Icons.folder_open_rounded),
                label: const Text('扫描本地视频'),
              ),
              OutlinedButton.icon(
                onPressed: _loadVideos,
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

  void _playVideo(VideoItem video) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VideoPlayerPage(),
      ),
    );

    Future.microtask(() {
      ref.read(videoControlProvider.notifier).loadVideo(video);
    });
  }

  void _scanLocalVideos() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('扫描本地视频功能开发中...')),
    );
  }
}

import 'package:flutter/material.dart';
import 'music/music_library_page.dart';
import 'video/video_library_page.dart';
import '../../widgets/home/home_shell.dart';

/// 媒体页面（音乐库和视频库）
class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFFFB7185), Color(0xFFFF7AA5)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '媒体',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: HomePalette.primaryText(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 176,
                      child: HomePillTabBar(
                        controller: _tabController,
                        items: const [
                          HomeTabItem(
                            icon: Icons.library_music_rounded,
                            label: '音乐',
                          ),
                          HomeTabItem(
                            icon: Icons.video_library_rounded,
                            label: '视频',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    MusicLibraryPage(embedded: true),
                    VideoLibraryPage(embedded: true),
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

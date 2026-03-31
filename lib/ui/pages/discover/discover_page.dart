import 'package:flutter/material.dart';
import '../explore/explore_page.dart';
import '../rss/rss_page.dart';
import '../../widgets/home/home_shell.dart';

/// 发现页面（合并发现和订阅）
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
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
        glowColors: const [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                decoration: BoxDecoration(
                  color: HomePalette.card(context).withValues(alpha: 0.96),
                  border: Border(
                    bottom: BorderSide(color: HomePalette.lineColor(context)),
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 220,
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicatorColor: HomePalette.accent,
                      indicatorWeight: 2.5,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: HomePalette.accentStrong,
                      unselectedLabelColor: HomePalette.tertiaryText(context),
                      labelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(
                          height: 44,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_rounded, size: 20),
                              SizedBox(width: 6),
                              Text('发现'),
                            ],
                          ),
                        ),
                        Tab(
                          height: 44,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('📡', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 6),
                              Text('订阅'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    ExplorePage(embedded: true),
                    RssPage(embedded: true),
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

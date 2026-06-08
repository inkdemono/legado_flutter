# Legado Flutter UI 优化指南

基于 [legado-with-MD3](https://github.com/inkdemono/legado-with-MD3) 的设计语言，对当前 Flutter 版本进行 Material Design 3 风格的 UI 现代化改造。

## 🎨 核心设计理念

### 1. Material Design 3 + Miuix 融合
- **动态取色** (Material You): 从壁纸或主题色自动生成配色方案
- **毛玻璃效果**: 使用 `BackdropFilter` 实现现代感的模糊背景
- **大圆角设计**: 卡片和按钮统一使用 20-24dp 的圆角
- **柔和阴影**: 多层阴影营造深度感

### 2. 颜色系统
```dart
// 使用 MD3Palette 获取上下文相关颜色
MD3Palette.primary(context)           // 主色
MD3Palette.primaryContainer(context)  // 主色容器
MD3Palette.surface(context)           // 表面色
MD3Palette.onSurface(context)         // 表面上的文字
MD3Palette.surfaceVariant(context)    // 变体表面色
```

### 3. 组件层次
- **Elevation 1**: 普通卡片
- **Elevation 2**: 悬浮卡片
- **Elevation 3+**: 对话框、菜单

## 📦 新增组件库

### 位置：`lib/ui/theme/md3_theme.dart`

| 组件 | 说明 |
|------|------|
| `MD3Palette` | Material 3 颜色调色板 |
| `GlassContainer` | 毛玻璃效果容器 |
| `MD3Card` | 现代化卡片组件 |
| `MD3FilledButton` | 填充式按钮 |
| `MD3OutlinedButton` | 轮廓按钮 |
| `MD3TextButton` | 文本按钮 |
| `MDPillChip` | 药丸形状标签 |
| `MD3SearchField` | 搜索框 |
| `GlassAppBar` | 毛玻璃顶栏 |
| `MD3SegmentedControl` | 分段控制器 |
| `DynamicThemeGenerator` | 动态取色主题生成器 |

### 位置：`lib/ui/widgets/common/md3_widgets.dart`

| 组件 | 说明 |
|------|------|
| `GlassBottomNavigationBar` | 毛玻璃底部导航栏 |
| `FabContainer` | 悬浮按钮容器 |
| `MD3ListTile` | 现代化列表项 |
| `MD3SectionHeader` | 分组标题 |
| `MD3EmptyState` | 空状态页面 |
| `MD3LoadingIndicator` | 加载指示器 |

## 🚀 使用示例

### 1. 创建毛玻璃效果书架

```dart
import 'package:legado_flutter/ui/theme/md3_theme.dart';
import 'package:legado_flutter/ui/widgets/common/md3_widgets.dart';

class ModernBookshelf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MD3Palette.background(context),
      appBar: GlassAppBar(
        title: '我的书架',
        blur: 20.0,
      ),
      body: CustomScrollView(
        slivers: [
          // 分组标签
          SliverToBoxAdapter(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: groups.length,
              itemBuilder: (context, index) => MDPillChip(
                label: groups[index],
                isSelected: index == selectedIndex,
                onTap: () => setState(() => selectedIndex = index),
              ),
            ),
          ),
          // 书籍网格
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => MD3Card(
                onTap: () => openBook(books[index]),
                child: BookCard(book: books[index]),
              ),
              childCount: books.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FabContainer(
        onPressed: () => addBook(),
        child: Icon(Icons.add_rounded),
      ),
    );
  }
}
```

### 2. 使用动态取色

```dart
import 'package:dynamic_color/dynamic_color.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme ?? ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme ?? ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),
          home: HomePage(),
        );
      },
    );
  }
}
```

### 3. 现代化列表

```dart
ListView(
  children: [
    MD3SectionHeader(title: '最近阅读'),
    MD3ListTile(
      title: '斗破苍穹',
      subtitle: '最新章节：第一千章',
      leading: BookCover(book: book),
      trailing: Icon(Icons.more_vert_rounded),
      onTap: () => openBook(book),
    ),
    MD3ListTile(
      title: '完美世界',
      subtitle: '最新章节：第五百章',
      leading: BookCover(book: book2),
      trailing: Icon(Icons.more_vert_rounded),
      onTap: () => openBook(book2),
    ),
  ],
)
```

## 🎯 优化建议

### 优先级 1 - 核心页面
1. **书架页面**: 应用毛玻璃顶栏、MD3 卡片、药丸标签
2. **阅读器页面**: 现代化控制栏、动态取色
3. **发现页面**: 重新设计为 MD3 风格网格

### 优先级 2 - 功能页面
4. **书源管理**: 使用 MD3 列表和搜索框
5. **设置页面**: 应用 MD3 开关和分组标题
6. **书籍详情**: 现代化布局和动画

### 优先级 3 - 细节优化
7. **对话框**: 圆角、毛玻璃背景
8. **底部导航**: 毛玻璃效果、选中状态动画
9. **加载状态**: 统一的 MD3 加载指示器
10. **空状态**: 友好的 MD3 空状态设计

## 🛠️ 技术要点

### 毛玻璃效果实现
```dart
BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.3),
        width: 1.5,
      ),
    ),
  ),
)
```

### 动态取色
```dart
final colorScheme = ColorScheme.fromSeed(
  seedColor: Colors.blue,
  brightness: Brightness.light,
);

// Android 12+ 可使用系统壁纸颜色
DynamicColorBuilder(
  builder: (lightColorScheme, darkColorScheme) {
    // 使用系统生成的颜色方案
  },
)
```

### 共享元素转场
```dart
// 起点
Hero(
  tag: 'book_${book.id}',
  child: BookCover(book: book),
)

// 终点
Hero(
  tag: 'book_${book.id}',
  child: BookDetailCover(book: book),
)
```

## 📱 适配注意事项

### Android
- ✅ 完全支持 Material Design 3
- ✅ 支持动态取色 (Android 12+)
- ✅ 毛玻璃效果需要 API 31+ 或使用兼容方案

### iOS
- ✅ 支持 Material Design 3 组件
- ⚠️ 毛玻璃效果使用 `CupertinoBlurEffect` 替代
- ✅ 动态取色需手动配置

### Web/Desktop
- ⚠️ 毛玻璃效果性能考虑
- ✅ 基础 MD3 组件完全支持
- ⚠️ 动态取色需降级处理

## 🔗 参考资源

- [Material Design 3 官方文档](https://m3.material.io/)
- [Flutter Material 3 指南](https://docs.flutter.dev/ui/libraries/material3)
- [legado-with-MD3 源码](https://github.com/inkdemono/legado-with-MD3)
- [Dynamic Color 插件](https://pub.dev/packages/dynamic_color)
- [Glassmorphism 插件](https://pub.dev/packages/glassmorphism)

---

**下一步计划**:
1. 逐步替换现有页面组件为 MD3 风格
2. 添加主题编辑器支持自定义种子色
3. 实现共享元素转场动画
4. 优化深色模式体验
5. 添加更多微交互动画

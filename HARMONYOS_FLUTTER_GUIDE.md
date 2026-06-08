# Legado Flutter 鸿蒙适配指南

## 📱 鸿蒙系统 Flutter 开发方案

### 核心思路
**使用 Flutter 统一代码库，通过平台适配实现鸿蒙支持**

Flutter 本身不直接支持鸿蒙系统，但可以通过以下方案实现：

---

## 方案一：OpenHarmony Flutter Engine（推荐）

### 1. 技术原理
- 使用 OpenHarmony 移植的 Flutter Engine
- 复用现有 Dart 代码和业务逻辑
- 仅需适配平台相关插件

### 2. 环境准备

```bash
# 安装 DevEco Studio
# 下载 OpenHarmony SDK
# 克隆 flutter_openharmony 项目

git clone https://gitee.com/openharmony-sig/flutter_flutter.git
```

### 3. 项目配置

#### pubspec.yaml 添加鸿蒙支持
```yaml
dependencies:
  # 现有依赖保持不变
  
  # 鸿蒙平台适配
  platform_interface: ^2.0.0
```

#### 创建鸿蒙平台目录结构
```
lib/
├── core/
│   └── platform/
│       ├── android/
│       ├── ios/
│       └── harmonyos/  # 新增
│           ├── book_source_engine.dart
│           ├── file_manager.dart
│           ├── tts_service.dart
│           └── storage_adapter.dart
```

### 4. 平台适配代码示例

```dart
// lib/core/platform/harmonyos/file_manager.dart
import 'package:flutter/services.dart';

class HarmonyOSFileManager {
  static const platform = MethodChannel('legado_harmony/file');
  
  Future<String> getAppDataPath() async {
    try {
      final result = await platform.invokeMethod('getAppDataPath');
      return result as String;
    } on PlatformException catch (e) {
      throw Exception('获取应用数据路径失败：${e.message}');
    }
  }
  
  Future<List<int>> readFile(String path) async {
    final result = await platform.invokeMethod('readFile', {'path': path});
    return (result as Uint8List).toList();
  }
}
```

### 5. ArkTS 原生桥接

```typescript
// entry/src/main/ets/file/FileChannel.ts
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fs } from '@kit.CoreFileKit';

@Entry
@Component
export struct FileChannel {
  @State message: string = '';

  aboutToAppear() {
    // 注册 Flutter 方法通道
    flutterChannel.register('getAppDataPath', async () => {
      const context = common.getApplicationContext();
      const cacheDir = context.cacheDir;
      return cacheDir.path;
    });
  }
}
```

---

## 方案二：Web 容器方案（快速验证）

### 1. 编译为 Web 版本
```bash
flutter build web --release
```

### 2. 在鸿蒙应用中嵌入 Webview

```typescript
// entry/src/main/ets/pages/Index.ets
@Entry
@Component
struct Index {
  @State webviewController: WebController = new WebController();

  build() {
    Column() {
      Web({
        src: '$rawfile/index.html', // Flutter Web 构建产物
        controller: this.webviewController
      })
      .width('100%')
      .height('100%')
    }
  }
}
```

---

## 方案三：跨平台插件适配

### 1. 识别不支持的插件

当前项目中需要适配的插件：
| 插件 | 鸿蒙状态 | 替代方案 |
|------|---------|---------|
| sqflite | ❌ | 使用鸿蒙 Native SQLite |
| flutter_tts | ❌ | 调用鸿蒙 TTS API |
| file_picker | ❌ | 鸿蒙文件选择器 |
| permission_handler | ❌ | 鸿蒙权限管理 |
| path_provider | ❌ | 鸿蒙路径 API |

### 2. 创建平台接口抽象

```dart
// lib/core/platform/interface/storage_interface.dart
abstract class StorageInterface {
  Future<String> getAppDocumentsPath();
  Future<void> saveFile(String path, List<int> data);
  Future<List<int>> readFile(String path);
  Future<bool> deleteFile(String path);
}
```

### 3. 实现鸿蒙版本

```dart
// lib/core/platform/harmonyos/storage_impl.dart
import 'package:flutter/services.dart';
import '../interface/storage_interface.dart';

class HarmonyOSStorageImpl implements StorageInterface {
  static const _channel = MethodChannel('legado_harmony/storage');

  @override
  Future<String> getAppDocumentsPath() async {
    return await _channel.invokeMethod('getAppDocumentsPath');
  }

  @override
  Future<void> saveFile(String path, List<int> data) async {
    await _channel.invokeMethod('saveFile', {
      'path': path,
      'data': Uint8List.fromList(data),
    });
  }

  @override
  Future<List<int>> readFile(String path) async {
    final result = await _channel.invokeMethod('readFile', {'path': path});
    return (result as Uint8List).toList();
  }

  @override
  Future<bool> deleteFile(String path) async {
    return await _channel.invokeMethod('deleteFile', {'path': path});
  }
}
```

### 4. 平台分发逻辑

```dart
// lib/core/platform/platform_dispatcher.dart
import 'dart:io' show Platform;

class PlatformDispatcher {
  static StorageInterface get storage {
    if (Platform.isAndroid) {
      return AndroidStorageImpl();
    } else if (Platform.isIOS) {
      return IOSStorageImpl();
    } else if (_isHarmonyOS()) {
      return HarmonyOSStorageImpl();
    }
    throw UnsupportedError('Unsupported platform');
  }

  static bool _isHarmonyOS() {
    // 通过环境变量或平台检测
    return Platform.environment['HARMONY'] == 'true';
  }
}
```

---

## 关键功能适配清单

### ✅ 已支持（Flutter 通用代码）
- [x] UI 界面（Material Design 3）
- [x] 业务逻辑层
- [x] 数据模型
- [x] 网络请求（Dio）
- [x] JSON 解析
- [x] HTML/XPath 解析
- [x] 状态管理（Provider/Riverpod）

### ⚠️ 需要适配（平台相关）
- [ ] SQLite 数据库 → 鸿蒙 Native SQLite
- [ ] 文件系统访问 → 鸿蒙 File Kit
- [ ] TTS 朗读 → 鸿蒙语音合成
- [ ] 权限管理 → 鸿蒙权限系统
- [ ] 通知推送 → 鸿蒙通知服务
- [ ] 后台服务 → 鸿蒙 Ability
- [ ] 音频播放 → 鸿蒙媒体播放器
- [ ] 屏幕亮度控制 → 鸿蒙显示 API

---

## 实施步骤

### 第一阶段：环境搭建（1-2 周）
1. 安装 DevEco Studio 和 OpenHarmony SDK
2. 配置 Flutter OpenHarmony 引擎
3. 创建基础鸿蒙项目框架
4. 实现 Flutter 与 ArkTS 的通信桥接

### 第二阶段：核心功能适配（2-3 周）
1. 数据库适配（SQLite）
2. 文件系统适配
3. 网络请求验证
4. 基础 UI 渲染测试

### 第三阶段：高级功能适配（3-4 周）
1. TTS 朗读集成
2. 音频/视频播放
3. 通知和后台服务
4. 权限管理

### 第四阶段：优化与测试（1-2 周）
1. 性能优化
2. UI/UX 调整
3. 兼容性测试
4. 发布准备

---

## 开发资源

### 官方文档
- [OpenHarmony 官网](https://www.openharmony.cn/)
- [DevEco Studio 下载](https://developer.harmonyos.com/cn/tools)
- [ArkTS 语言指南](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V6/arkts-get-started-0000001705361181-V6)

### Flutter for OpenHarmony
- [Gitee 仓库](https://gitee.com/openharmony-sig/flutter_flutter)
- [适配教程](https://gitee.com/openharmony-sig/flutter_flutter/wikis)

### 社区资源
- HarmonyOS 开发者论坛
- Flutter 中文社区
- GitHub 开源项目参考

---

## 注意事项

1. **许可证合规**：确保遵循 GPL-3.0 协议
2. **性能优化**：鸿蒙系统内存管理策略不同
3. **UI 适配**：考虑折叠屏和多设备适配
4. **审核要求**：了解鸿蒙应用上架规范
5. **持续同步**：保持与 Flutter 主分支的功能同步

---

## 总结

使用 Flutter 开发鸿蒙版本的核心优势：
- ✅ **代码复用率 90%+**：业务逻辑无需重写
- ✅ **统一技术栈**：团队学习成本低
- ✅ **快速迭代**：一次开发，多端部署
- ✅ **生态兼容**：可利用 Flutter 丰富插件

主要挑战：
- ⚠️ 平台插件需要原生适配
- ⚠️ 鸿蒙生态相对年轻，文档较少
- ⚠️ 需要维护 Flutter Engine 移植版本

建议采用**渐进式适配策略**，优先保证核心阅读功能，逐步完善高级特性。

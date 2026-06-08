# 鸿蒙平台原生层实现指南

## 📋 概述

本文档提供 Flutter 与鸿蒙原生层 (ArkTS) 的通信桥接实现代码。

---

## 目录结构

```
ohos/
├── entry/src/main/ets/
│   ├── entryability/EntryAbility.ets    # 应用入口
│   └── channels/                        # MethodChannel 实现
│       ├── StorageChannel.ts            # 存储通道
│       ├── DatabaseChannel.ts           # 数据库通道
│       └── FileChannel.ts               # 文件通道
└── ...
```

---

## 1. EntryAbility 配置

```typescript
// entry/src/main/ets/entryability/EntryAbility.ets
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { router } from '@kit.RouterKit';
import { common } from '@kit.AbilityKit';

// 导入通道处理类
import { StorageChannel } from '../channels/StorageChannel';
import { DatabaseChannel } from '../channels/DatabaseChannel';
import { FileChannel } from '../channels/FileChannel';

export default class EntryAbility extends UIAbility {
  // Flutter Engine 实例引用
  private flutterEngine: any = null;
  
  // 通道处理器
  private storageChannel: StorageChannel | null = null;
  private databaseChannel: DatabaseChannel | null = null;
  private fileChannel: FileChannel | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'Legado', '%{public}s', 'Ability onCreate');
    
    // 初始化通道处理器
    const context = this.context as common.UIAbilityContext;
    this.storageChannel = new StorageChannel(context);
    this.databaseChannel = new DatabaseChannel(context);
    this.fileChannel = new FileChannel(context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'Legado', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'Legado', 'Failed to load content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      
      hilog.info(0x0000, 'Legado', 'Succeeded in loading content.');
      
      // 注册 Flutter 方法通道
      this.registerFlutterChannels();
    });
  }

  /**
   * 注册 Flutter MethodChannel
   */
  private registerFlutterChannels(): void {
    if (!this.flutterEngine) {
      hilog.warn(0x0000, 'Legado', 'Flutter engine not initialized');
      return;
    }

    // 存储通道
    if (this.storageChannel) {
      this.flutterEngine.registerMethodChannel(
        'legado_harmony/storage',
        this.storageChannel.handleMethodCall.bind(this.storageChannel)
      );
    }

    // 数据库通道
    if (this.databaseChannel) {
      this.flutterEngine.registerMethodChannel(
        'legado_harmony/database',
        this.databaseChannel.handleMethodCall.bind(this.databaseChannel)
      );
    }

    // 文件通道
    if (this.fileChannel) {
      this.flutterEngine.registerMethodChannel(
        'legado_harmony/file',
        this.fileChannel.handleMethodCall.bind(this.fileChannel)
      );
    }

    hilog.info(0x0000, 'Legado', 'Flutter channels registered successfully');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'Legado', '%{public}s', 'Ability onDestroy');
    
    // 清理资源
    this.databaseChannel?.closeAllDatabases();
    this.storageChannel = null;
    this.databaseChannel = null;
    this.fileChannel = null;
  }
}
```

---

## 2. 存储通道实现

```typescript
// entry/src/main/ets/channels/StorageChannel.ts
import { common } from '@kit.AbilityKit';
import { fs } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkUtil';

export class StorageChannel {
  private context: common.UIAbilityContext;
  private TAG: string = 'StorageChannel';

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * 处理 Flutter 方法调用
   */
  async handleMethodCall(method: string, args: any): Promise<any> {
    hilog.info(0x0000, this.TAG, 'Method called: %{public}s', method);

    switch (method) {
      case 'getAppDocumentsPath':
        return this.getAppDocumentsPath();
      
      case 'getAppCachePath':
        return this.getAppCachePath();
      
      default:
        throw new Error(`Unknown method: ${method}`);
    }
  }

  /**
   * 获取应用文档目录
   */
  async getAppDocumentsPath(): Promise<string> {
    try {
      const fileInfo = await fs.getFileInfo(this.context.filesDir.path);
      hilog.info(0x0000, this.TAG, 'Documents path: %{public}s', this.context.filesDir.path);
      return this.context.filesDir.path;
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Failed to get documents path: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 获取应用缓存目录
   */
  async getAppCachePath(): Promise<string> {
    try {
      const cacheDir = this.context.cacheDir;
      hilog.info(0x0000, this.TAG, 'Cache path: %{public}s', cacheDir.path);
      return cacheDir.path;
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Failed to get cache path: %{public}s', JSON.stringify(error));
      throw error;
    }
  }
}
```

---

## 3. 文件通道实现

```typescript
// entry/src/main/ets/channels/FileChannel.ts
import { common } from '@kit.AbilityKit';
import { fs } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { buffer } from '@kit.ArkUtil';

export class FileChannel {
  private context: common.UIAbilityContext;
  private TAG: string = 'FileChannel';

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * 处理 Flutter 方法调用
   */
  async handleMethodCall(method: string, args: any): Promise<any> {
    hilog.info(0x0000, this.TAG, 'Method called: %{public}s', method);

    switch (method) {
      case 'saveFile':
        return this.saveFile(args.path, args.data);
      
      case 'readFile':
        return this.readFile(args.path);
      
      case 'deleteFile':
        return this.deleteFile(args.path);
      
      case 'fileExists':
        return this.fileExists(args.path);
      
      case 'createDirectory':
        return this.createDirectory(args.path);
      
      case 'listDirectory':
        return this.listDirectory(args.path);
      
      case 'copyFile':
        return this.copyFile(args.sourcePath, args.destPath);
      
      case 'moveFile':
        return this.moveFile(args.sourcePath, args.destPath);
      
      case 'getFileSize':
        return this.getFileSize(args.path);
      
      case 'getLastModified':
        return this.getLastModified(args.path);
      
      default:
        throw new Error(`Unknown method: ${method}`);
    }
  }

  /**
   * 保存文件
   */
  async saveFile(path: string, data: Uint8Array): Promise<void> {
    try {
      const file = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      await fs.write(file.fd, buffer.from(data));
      fs.closeSync(file);
      hilog.info(0x0000, this.TAG, 'File saved: %{public}s', path);
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Failed to save file: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 读取文件
   */
  async readFile(path: string): Promise<Uint8Array> {
    try {
      const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(path);
      const buf = buffer.alloc(stat.size);
      await fs.read(file.fd, buf);
      fs.closeSync(file);
      hilog.info(0x0000, this.TAG, 'File read: %{public}s', path);
      return new Uint8Array(buf.buffer, buf.byteOffset, buf.byteLength);
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Failed to read file: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 删除文件
   */
  async deleteFile(path: string): Promise<boolean> {
    try {
      await fs.unlink(path);
      hilog.info(0x0000, this.TAG, 'File deleted: %{public}s', path);
      return true;
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Failed to delete file: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  /**
   * 检查文件是否存在
   */
  async fileExists(path: string): Promise<boolean> {
    try {
      return await fs.access(path);
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Failed to check file existence: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  /**
   * 创建目录
   */
  async createDirectory(path: string): Promise<void> {
    try {
      await fs.mkdir(path);
      hilog.info(0x0000, this.TAG, 'Directory created: %{public}s', path);
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Failed to create directory: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 列出目录内容
   */
  async listDirectory(path: string): Promise<string[]> {
    try {
      const entries = await fs.readdir(path);
      hilog.info(0x0000, this.TAG, 'Directory listed: %{public}s', path);
      return entries;
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Failed to list directory: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 复制文件
   */
  async copyFile(sourcePath: string, destPath: string): Promise<void> {
    try {
      await fs.copyFile(sourcePath, destPath);
      hilog.info(0x0000, this.TAG, 'File copied: %{public}s -> %{public}s', sourcePath, destPath);
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Failed to copy file: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 移动文件
   */
  async moveFile(sourcePath: string, destPath: string): Promise<void> {
    try {
      await fs.rename(sourcePath, destPath);
      hilog.info(0x0000, this.TAG, 'File moved: %{public}s -> %{public}s', sourcePath, destPath);
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Failed to move file: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 获取文件大小
   */
  async getFileSize(path: string): Promise<number> {
    try {
      const stat = await fs.stat(path);
      return stat.size;
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Failed to get file size: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 获取文件最后修改时间
   */
  async getLastModified(path: string): Promise<number> {
    try {
      const stat = await fs.stat(path);
      return stat.mtime;
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Failed to get last modified time: %{public}s', JSON.stringify(error));
      throw error;
    }
  }
}
```

---

## 4. 数据库通道实现

```typescript
// entry/src/main/ets/channels/DatabaseChannel.ts
import { common } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class DatabaseChannel {
  private context: common.UIAbilityContext;
  private TAG: string = 'DatabaseChannel';
  private databases: Map<string, relationalStore.RdbStore> = new Map();

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * 处理 Flutter 方法调用
   */
  async handleMethodCall(method: string, args: any): Promise<any> {
    hilog.info(0x0000, this.TAG, 'Method called: %{public}s', method);

    switch (method) {
      case 'openDatabase':
        return this.openDatabase(args.path);
      
      case 'query':
        return this.query(args.sql, args.arguments);
      
      case 'insert':
        return this.insert(args.table, args.values);
      
      case 'update':
        return this.update(args.table, args.values, args.where, args.whereArgs);
      
      case 'delete':
        return this.delete(args.table, args.where, args.whereArgs);
      
      case 'execute':
        return this.execute(args.sql, args.arguments);
      
      case 'beginTransaction':
        return this.beginTransaction();
      
      case 'commitTransaction':
        return this.commitTransaction();
      
      case 'rollbackTransaction':
        return this.rollbackTransaction();
      
      case 'closeDatabase':
        return this.closeDatabase();
      
      case 'tableExists':
        return this.tableExists(args.tableName);
      
      case 'getVersion':
        return this.getVersion();
      
      case 'setVersion':
        return this.setVersion(args.version);
      
      default:
        throw new Error(`Unknown method: ${method}`);
    }
  }

  /**
   * 打开数据库
   */
  async openDatabase(path: string): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: this.extractDbName(path),
        securityLevel: relationalStore.SecurityLevel.S1
      };
      
      const store = await relationalStore.getRdbStore(this.context, config);
      this.databases.set(path, store);
      
      hilog.info(0x0000, this.TAG, 'Database opened: %{public}s', path);
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Failed to open database: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 执行查询
   */
  async query(sql: string, arguments: any[]): Promise<any[]> {
    const store = this.getCurrentStore();
    try {
      const result = await store.querySql(sql, arguments);
      const rows: any[] = [];
      
      while (result.goToNextRow()) {
        const row: any = {};
        for (let i = 0; i < result.columnCount; i++) {
          const columnName = result.getColumnName(i);
          row[columnName] = result.getValueString(i);
        }
        rows.push(row);
      }
      
      result.close();
      return rows;
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Query failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 插入数据
   */
  async insert(table: string, values: any): Promise<number> {
    const store = this.getCurrentStore();
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        columns: Object.keys(values),
        values: Object.values(values)
      };
      
      const id = await store.insert(table, valueBucket);
      hilog.info(0x0000, this.TAG, 'Insert succeeded, id: %{public}d', id);
      return id;
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Insert failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 更新数据
   */
  async update(table: string, values: any, where?: string, whereArgs?: any[]): Promise<number> {
    const store = this.getCurrentStore();
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        columns: Object.keys(values),
        values: Object.values(values)
      };
      
      const predicates = new relationalStore.RdbPredicates(table);
      if (where) {
        // TODO: 解析 WHERE 子句
      }
      
      const count = await store.update(valueBucket, predicates);
      hilog.info(0x0000, this.TAG, 'Update succeeded, rows: %{public}d', count);
      return count;
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Update failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 删除数据
   */
  async delete(table: string, where?: string, whereArgs?: any[]): Promise<number> {
    const store = this.getCurrentStore();
    try {
      const predicates = new relationalStore.RdbPredicates(table);
      if (where) {
        // TODO: 解析 WHERE 子句
      }
      
      const count = await store.delete(predicates);
      hilog.info(0x0000, this.TAG, 'Delete succeeded, rows: %{public}d', count);
      return count;
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Delete failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 执行 SQL
   */
  async execute(sql: string, arguments: any[]): Promise<void> {
    const store = this.getCurrentStore();
    try {
      await store.executeSql(sql, arguments);
      hilog.info(0x0000, this.TAG, 'SQL executed: %{public}s', sql);
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'SQL execution failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 开始事务
   */
  async beginTransaction(): Promise<void> {
    const store = this.getCurrentStore();
    try {
      await store.beginTransaction();
      hilog.info(0x0000, this.TAG, 'Transaction began');
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Begin transaction failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 提交事务
   */
  async commitTransaction(): Promise<void> {
    const store = this.getCurrentStore();
    try {
      await store.commit();
      hilog.info(0x0000, this.TAG, 'Transaction committed');
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Commit transaction failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 回滚事务
   */
  async rollbackTransaction(): Promise<void> {
    const store = this.getCurrentStore();
    try {
      await store.rollBack();
      hilog.info(0x0000, this.TAG, 'Transaction rolled back');
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Rollback transaction failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 关闭数据库
   */
  async closeDatabase(): Promise<void> {
    try {
      for (const [path, store] of this.databases.entries()) {
        await store.close();
        hilog.info(0x0000, this.TAG, 'Database closed: %{public}s', path);
      }
      this.databases.clear();
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Close database failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 关闭所有数据库
   */
  public closeAllDatabases(): void {
    this.closeDatabase().catch((error) => {
      hilog.error(0x0000, this.TAG, 'Error closing databases: %{public}s', JSON.stringify(error));
    });
  }

  /**
   * 检查表是否存在
   */
  async tableExists(tableName: string): Promise<boolean> {
    const store = this.getCurrentStore();
    try {
      const result = await store.querySql(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName]
      );
      const exists = result.goToNextRow();
      result.close();
      return exists;
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Table exists check failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 获取数据库版本
   */
  async getVersion(): Promise<number> {
    const store = this.getCurrentStore();
    try {
      const result = await store.querySql('PRAGMA user_version');
      result.goToNextRow();
      const version = parseInt(result.getValueString(0), 10);
      result.close();
      return version;
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Get version failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 设置数据库版本
   */
  async setVersion(version: number): Promise<void> {
    const store = this.getCurrentStore();
    try {
      await store.executeSql(`PRAGMA user_version = ${version}`);
      hilog.info(0x0000, this.TAG, 'Version set to: %{public}d', version);
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'Set version failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  /**
   * 获取当前数据库实例
   */
  private getCurrentStore(): relationalStore.RdbStore {
    if (this.databases.size === 0) {
      throw new Error('No database opened');
    }
    // 返回第一个数据库（简化处理）
    return this.databases.values().next().value;
  }

  /**
   * 从路径提取数据库名称
   */
  private extractDbName(path: string): string {
    const parts = path.split('/');
    const fileName = parts[parts.length - 1];
    return fileName.replace('.db', '');
  }
}
```

---

## 5. 编译和测试

### 编译步骤

```bash
# 1. 使用 DevEco Studio 打开 ohos 目录
# 2. 同步依赖
cd ohos && ohpm install

# 3. 构建项目
# 在 DevEco Studio 中点击 Build -> Make Project

# 4. 运行到设备或模拟器
# 连接设备后点击 Run
```

### 测试验证

```dart
// test_harmonyos.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('legado_harmony/storage');

  TestWidgetsFlutterBinding.ensureInitialized();

  test('getAppDocumentsPath', () async {
    // 模拟原生层返回
    channel.setMockMethodCallHandler((call) async {
      if (call.method == 'getAppDocumentsPath') {
        return '/data/storage/el1/base/contexts/.../files';
      }
      return null;
    });

    final result = await channel.invokeMethod('getAppDocumentsPath');
    expect(result, isNotEmpty);
  });
}
```

---

## 注意事项

1. **权限配置**: 在 `module.json5` 中声明所需权限
2. **API 版本**: 确保使用 API 12+ 以支持所有 File Kit 功能
3. **错误处理**: 所有原生异常都应转换为 PlatformException
4. **内存管理**: 及时关闭数据库和文件句柄
5. **线程安全**: 数据库操作应在后台线程执行

---

## 参考资源

- [ArkTS File Kit](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V6/js-apis-file-kit-fs-0000001746957837-V6)
- [ArkTS 关系型数据库](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V6/js-apis-relationalstore-0000001746917801-V6)
- [Flutter Platform Channels](https://docs.flutter.dev/development/platform-integration/platform-channels)

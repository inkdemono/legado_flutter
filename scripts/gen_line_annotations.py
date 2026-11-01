#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
逐行注释文件生成器

为指定的 Dart 源文件生成独立的“逐行注释”Markdown 文件：
  - 输出目录: annotations/
  - 命名规则: <原文件名>.annotations.md
  - 格式:     L<行号> | `<源代码行>` | [中文说明]

说明策略（按优先级）：
  1. 若源码行本身带有 /// 或 // 文档/行内注释，则提炼该注释作为说明；
  2. 否则根据语法特征（import/part/class/函数签名/控制流/返回/赋值/await/
     try-catch/日志/大括号等）自动生成说明；
  3. 空行与孤立符号行给出简要结构性说明。

用法:
  python3 scripts/gen_line_annotations.py [文件1.dart 文件2.dart ...]
  不带参数时，默认处理 lib/services/book/ 下的 book_service*.dart 系列文件。
"""

import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
OUT_DIR = os.path.join(ROOT, 'annotations')

DEFAULT_FILES = [
    'lib/services/book/book_service.dart',
    'lib/services/book/book_service_chapter_list.dart',
    'lib/services/book/book_service_content.dart',
    'lib/services/book/book_service_search.dart',
    'lib/services/book/book_service_storage.dart',
    'lib/services/book/book_service_toc_helpers.dart',
    'lib/services/book/book_service_update.dart',
]

# ---------------------------------------------------------------------------
# 正则定义
# ---------------------------------------------------------------------------
RE_PACKAGE = re.compile(r"^package:([A-Za-z0-9_./-]+)")
RE_RELATIVE = re.compile(r"^(?:\.\./)+(.*)")
RE_IMPORT = re.compile(r"^import\s+'([^']+)'(?:\s+as\s+(\w+))?\s*;", re.I)
RE_EXPORT = re.compile(r"^export\s+'([^']+)'(?:\s+show\s+(.+?))?\s*;", re.I)
RE_PART_OF = re.compile(r"^part\s+of\s+'([^']+)'\s*;")
RE_PART = re.compile(r"^part\s+'([^']+)'\s*;")

RE_ABSTRACT_CLASS = re.compile(r"^abstract\s+class\s+(\w+)")
RE_MIXIN = re.compile(r"^mixin\s+(\w+)")
RE_ENUM = re.compile(r"^enum\s+(\w+)")
RE_CLASS = re.compile(r"^class\s+(\w+)(?:\s+extends\s+(\w+))?(?:\s+with\s+([\w,\s]+?))?(?:\s+implements\s+([\w,\s]+?))?\s*\{?")

RE_GETTER = re.compile(r"^(static\s+)?(final\s+)?(\w[\w<>,\s\?]*?)\s+get\s+(\w+)\s*(?:=>|;)")
RE_FUNC = re.compile(
    r"^(static\s+|factory\s+)?"
    r"(Future<[^>]*>|List<[^>]*>|Map<[^>]*>|Set<[^>]*>|void|bool|int|double|num|String|dynamic|\w[\w<>,\s\?\.]*)"
    r"\s+(?:Future<[^>]*>\s+)?(\w+)\s*(<[^>]+>)?\((.*)$"
)
RE_CTOR = re.compile(r"^(?:const\s+|factory\s+)?(\w+)\((.*)$")
RE_VAR_DECL = re.compile(r"^(final|var|const|late)\s+(\w[\w<>,\s\?\.\$]*)\s+(\w+)\s*(=|;)")
RE_VAR_SIMPLE = re.compile(r"^(final|var|const|late)\s+(\w+)\s*(=|;)")
RE_ASSIGN = re.compile(r"^(\w[\w\.]*)\s*=[^=]")
RE_RETURN = re.compile(r"^return\b(.*)$")
RE_IF = re.compile(r"^if\s*\((.*)$")
RE_ELSIF = re.compile(r"^else\s+if\s*\((.*)$")
RE_FOR = re.compile(r"^for\s*\((.*)$")
RE_WHILE = re.compile(r"^while\s*\((.*)$")
RE_SWITCH = re.compile(r"^switch\s*\((.*)$")
RE_CASE = re.compile(r"^case\s+(.*):")
RE_DEFAULT = re.compile(r"^default\s*:")
RE_TRY = re.compile(r"^try\s*\{?")
RE_CATCH = re.compile(r"^catch\s*(?:\(([^)]*)\))?")
RE_FINALLY = re.compile(r"^finally\b")
RE_THROW = re.compile(r"^throw\s+(\w+)?(.*)$")
RE_BREAK = re.compile(r"^break\b")
RE_CONTINUE = re.compile(r"^continue\b")
RE_ASSERT = re.compile(r"^assert\s*\(")
RE_DOC = re.compile(r"^///\s*(.*)$")
RE_LINE_COMMENT = re.compile(r"^//(!?|\s*)(.*)$")
RE_CLOSE_BRACE = re.compile(r"^\}[,;]?$")
RE_ARROW_LAMBDA = re.compile(r"=>")
RE_AWAIT = re.compile(r"\bawait\b")
RE_ASYNC = re.compile(r"\basync\b")
RE_STREAM = re.compile(r"\basync\s*\*\*?\b|\byield\b")
RE_TF = re.compile(r"\bthis\.(\w+)")

# 已知标识符的中文含义（用于函数名翻译）
NAME_HINTS = {
    'book': '书籍', 'chapter': '章节', 'chapters': '章节列表', 'toc': '目录(TOC)',
    'list': '列表', 'content': '正文内容', 'search': '搜索', 'storage': '存储',
    'update': '更新', 'save': '保存', 'load': '加载', 'get': '获取', 'fetch': '拉取',
    'parse': '解析', 'rule': '规则', 'source': '书源', 'html': '网页标记(HTML)', 'url': '链接(URL)',
    'db': '数据库', 'database': '数据库', 'cache': '缓存', 'local': '本地',
    'remote': '远程', 'page': '页', 'pages': '分页', 'index': '索引',
    'history': '阅读历史', 'bookmark': '书签', 'variable': '变量', 'variables': '变量表',
    'headers': '请求头', 'response': '响应', 'request': '请求', 'error': '错误',
    'empty': '空', 'default': '默认', 'all': '全部', 'first': '首个',
    'next': '下一章', 'last': '最后', 'count': '数量', 'size': '大小',
    'init': '初始化', 'dispose': '释放', 'build': '构建', 'check': '检查',
    'validate': '校验', 'convert': '转换', 'merge': '合并', 'sort': '排序',
    'filter': '过滤', 'map': '映射', 'replace': '替换', 'trim': '修剪',
    'download': '下载', 'upload': '上传', 'delete': '删除', 'remove': '移除',
    'add': '添加', 'insert': '插入', 'query': '查询', 'find': '查找',
    'write': '写入', 'read': '读取', 'open': '打开', 'close': '关闭',
    'process': '处理', 'handle': '处理', 'callback': '回调', 'retry': '重试',
    'timeout': '超时', 'limit': '限制', 'rate': '速率', 'concurrent': '并发',
    'js': 'JavaScript脚本(JS)', 'engine': '引擎', 'pattern': '模式', 'regex': '正则',
    'format': '格式化', 'encode': '编码', 'decode': '解码', 'json': 'JSON数据',
    'text': '文本', 'title': '标题', 'author': '作者', 'cover': '封面',
    'intro': '简介', 'kind': '类别', 'wordCount': '字数', 'latestChapter': '最新章节',
    'num': '编号', 'uuid': '通用唯一标识(UUID)', 'origin': '来源', 'proxy': '代理',
    'redirect': '重定向', 'fallback': '回退/降级', 'smart': '智能',
    'analyze': '分析', 'extract': '提取', 'rewrite': '重写', 'normalize': '规范化',
    'sanitize': '净化处理', 'persist': '持久化', 'flush': '刷写', 'batch': '批量',
    'progress': '进度', 'state': '状态', 'status': '状态', 'flag': '标志',
}


# Dart 关键字/内置类型/常用 API —— 在说明文字中统一用中文表述（必要时括注原文）
KEYWORD_ZH = {
    'final': '不可重新赋值(final)', 'var': '自动类型推断(var)', 'const': '编译期常量(const)',
    'late': '延迟初始化(late)', 'if': '如果(if)', 'else': '否则(else)', 'for': '循环(for)',
    'while': '当型循环(while)', 'switch': '分支判断(switch)', 'case': '分支(case)',
    'default': '默认(default)', 'try': '尝试(try)', 'catch': '捕获(catch)',
    'finally': '最终(finally)', 'throw': '抛出(throw)', 'return': '返回(return)',
    'break': '跳出(break)', 'continue': '继续(continue)', 'await': '等待(await)',
    'async': '异步(async)', 'yield': '产出(yield)', 'in': '属于(in)', 'is': '是(is)',
    'as': '作为(as)', 'new': '新建(new)', 'this': '当前实例(this)', 'super': '父类(super)',
    'null': '空值(null)', 'true': '真(true)', 'false': '假(false)',
    'import': '导入(import)', 'part': '分部文件(part)', 'mixin': '混入(mixin)',
    'class': '类(class)', 'get': '读取(getter)', 'set': '写入(setter)',
    'required': '必填(required)', 'assert': '断言(assert)', 'void': '无返回值(void)',
}

# 常见标识符的中文全称（用于说明文字中替换裸英文单词）
IDENT_ZH = {
    'Future': '异步结果(Future)', 'Stream': '数据流(Stream)', 'List': '列表(List)',
    'Map': '映射(Map)', 'Set': '集合(Set)', 'String': '字符串(String)',
    'int': '整数(int)', 'double': '浮点数(double)', 'num': '数值(num)',
    'bool': '布尔(bool)', 'RegExp': '正则表达式(RegExp)', 'Uri': '统一资源标识(URI)',
    'URL': '统一资源链接(URL)', 'url': '链接', 'Url': '链接', 'TOC': '目录(TOC)',
    'toc': '目录', 'HTML': '网页标记文本(HTML)', 'html': '网页内容', 'JSON': 'JSON数据',
    'DB': '数据库(DB)', 'db': '数据库', 'AppLog': '应用日志(AppLog)',
    'NetworkService': '网络服务(NetworkService)', 'RuleParser': '规则解析器(RuleParser)',
    'BookSource': '书源(BookSource)', 'BookChapter': '章节(BookChapter)', 'Book': '书籍(Book)',
    'chapter': '章节', 'chapters': '章节列表', 'book': '书籍', 'books': '书籍列表',
    'source': '书源', 'sources': '书源列表', 'rule': '规则', 'results': '结果',
    'result': '结果', 'response': '响应', 'request': '请求', 'headers': '请求头',
    'keyword': '关键词', 'index': '索引', 'i': '循环变量 i', 'e': '异常对象 e',
    'name': '名称', 'title': '标题', 'author': '作者', 'coverUrl': '封面链接',
    'localPath': '本地存储路径', 'bookUrl': '书籍链接', 'chapterUrl': '章节链接',
    'nextTocUrl': '下一页目录链接', 'nextContentUrl': '下一页正文链接',
    'variableReplacement': '变量替换', 'replaceRegex': '正则替换',
    'put': '写入数据库(put)', 'map': '映射(map)', 'where': '筛选(where)',
    'firstWhere': '查找首个匹配(firstWhere)', 'indexWhere': '查找索引(indexWhere)',
    'lastIndex': '末尾索引', 'length': '长度(length)', 'isEmpty': '是否为空',
    'isNotEmpty': '是否非空', 'contains': '是否包含', 'toString': '转为字符串',
    'toList': '转为列表', 'toSet': '转为集合', 'addAll': '批量添加',
    'removeWhere': '按条件删除', 'cast': '类型转换', 'trim': '去除首尾空白',
    'split': '切分', 'join': '拼接', 'replaceAll': '全部替换', 'replaceFirst': '替换首个',
    'matchAsPrefix': '前缀匹配', 'hasMatch': '是否匹配', 'firstMatch': '首个匹配',
    'group': '捕获组', 'add': '添加', 'remove': '移除', 'insert': '插入',
    'elementAt': '取指定位置元素', 'skip': '跳过', 'take': '截取',
    'directory': '目录(directory)', 'file': '文件(file)', 'path': '路径',
    'content': '正文内容', 'text': '文本', 'body': '主体', 'key': '键', 'value': '值',
    'entry': '条目', 'entries': '条目集合', 'id': '编号(id)', 'uuid': '通用唯一标识(UUID)',
    'count': '数量', 'size': '大小', 'page': '页码', 'pageSize': '每页数量',
    'wordCount': '字数', 'latestChapterName': '最新章节名称', 'maxResults': '最大结果数',
    'precisionSearch': '精确搜索开关', 'caseSensitive': '区分大小写开关',
    'scope': '范围', 'cacheFile': '缓存文件', 'downloaded': '已下载标记',
    'useReplaceRule': '是否使用替换规则', 'checkKeyWord': '校验关键词',
    'js': 'JavaScript脚本(JS)', 'charset': '字符集', 'utf8': 'UTF-8编码',
    'gbk': 'GBK编码', 'base64': 'Base64编码', 'md5': 'MD5摘要',
    'http': '超文本传输协议(HTTP)', 'https': '安全超文本传输协议(HTTPS)',
    'sql': '结构化查询语言(SQL)', 'code': '代码', 'error': '错误', 'message': '信息',
    'msg': '消息', 'log': '日志', 'timeout': '超时时长', 'retryCount': '重试次数',
    'concurrency': '并发数', 'proxy': '代理', 'userAgent': '用户代理(UA)',
    'cookie': 'Cookie', 'header': '请求头', 'params': '参数', 'query': '查询串',
    'pattern': '模式', 'regex': '正则', 'prefix': '前缀', 'suffix': '后缀',
    'callback': '回调', 'closure': '闭包', 'lambda': '匿名函数', 'builder': '构建器',
    'instance': '实例', 'service': '服务', 'provider': '提供者', 'context': '上下文',
    'state': '状态', 'status': '状态', 'flag': '标志', 'mode': '模式', 'type': '类型',
    'kind': '类别', 'intro': '简介', 'summary': '概括', 'comment': '注释',
    'tmp': '临时', 'temp': '临时', 'bak': '备份', 'origin': '来源',
    'baseUrl': '基础链接', 'searchUrl': '搜索链接', 'bookSourceUrl': '书源链接',
    'ruleSearch': '搜索规则', 'ruleBookInfo': '书籍详情规则', 'ruleToc': '目录规则',
    'ruleContent': '正文规则', 'ruleInit': '初始化规则', 'exp': '表达式',
    'json': 'JSON数据', 'xml': 'XML数据', 'doc': '文档', 'item': '条目',
    'items': '条目列表', 'obj': '对象', 'str': '字符串', 'sb': '字符串缓冲(sb)',
    'buf': '缓冲区', 'arr': '数组', 'val': '值', 'ret': '返回值', 'res': '结果',
    'req': '请求', 'resp': '响应', 'cfg': '配置', 'config': '配置',
    'dir': '目录', 'env': '环境', 'fn': '函数', 'arg': '实参', 'args': '实参列表',
    'param': '形参', 'pos': '位置', 'idx': '索引', 'len': '长度',
    'prev': '上一项', 'cur': '当前项', 'curr': '当前项',
    'start': '起始', 'begin': '开始', 'offset': '偏移量',
    'chunks': '数据块列表',
    'lists': '列表集合', 'dict': '字典',
    'empty': '空', 'valid': '有效', 'invalid': '无效', 'enabled': '已启用',
    'disabled': '已禁用', 'visible': '可见', 'hidden': '隐藏', 'selected': '已选中',
    'loading': '加载中', 'finished': '已完成', 'pending': '待处理', 'failed': '失败',
    'success': '成功', 'skipped': '已跳过', 'ignored': '已忽略', 'updated': '已更新',
    'created': '已创建', 'deleted': '已删除', 'exists': '存在', 'missing': '缺失',
    'fallback': '回退', 'alternative': '备选',
    'secondary': '次要', 'temporary': '临时', 'permanent': '永久',
    'online': '在线', 'offline': '离线',
    'cached': '已缓存', 'uncached': '未缓存', 'stale': '过期', 'fresh': '最新',
    'partial': '部分', 'single': '单个', 'multi': '多个',
    'each': '每个',
    'second': '第二个', 'third': '第三个',
    'current': '当前', 'previous': '上一个', 'following': '下一个', 'initial': '初始',
    'intermediate': '中间', 'extra': '额外',
    'sub': '子', 'parent': '父级', 'child': '子级',
    'node': '节点', 'leaf': '叶子节点',
    'version': '版本', 'revision': '修订号',
    'production': '生产环境',
    'mock': '模拟', 'stub': '桩', 'fixture': '测试夹具',
    'setup': '准备', 'teardown': '清理', 'reset': '重置',
    'reload': '重新加载', 'restart': '重启', 'shutdown': '关闭',
    'startup': '启动', 'initialize': '初始化', 'destroy': '销毁',
    'allocate': '分配', 'reserve': '预留', 'acquire': '获取',
    'lock': '锁', 'unlock': '解锁', 'mutex': '互斥锁',
    'semaphore': '信号量',
    'event': '事件', 'signal': '信号', 'notification': '通知', 'broadcast': '广播',
    'subscribe': '订阅', 'unsubscribe': '取消订阅', 'publish': '发布',
    'listen': '监听', 'emit': '发出', 'trigger': '触发',
    'poll': '轮询', 'push': '推送', 'pull': '拉取', 'sync': '同步',
    'defer': '延迟', 'enqueue': '入队',
    'dequeue': '出队', 'commit': '提交', 'rollback': '回滚',
    'transaction': '事务', 'savepoint': '保存点', 'migration': '迁移',
    'schema': '模式', 'column': '列', 'row': '行', 'field': '字段',
    'record': '记录', 'statement': '语句', 'cursor': '游标',
    'binding': '绑定',
    'procedure': '存储过程', 'function': '函数', 'method': '方法', 'property': '属性',
    'attribute': '特性', 'annotation': '注解', 'decorator': '装饰器', 'modifier': '修饰符',
    'operator': '运算符', 'operand': '操作数', 'literal': '字面量', 'constant': '常量',
    'identifier': '标识符', 'token': '符号',
    'parser': '解析器', 'lexer': '词法分析器', 'compiler': '编译器', 'interpreter': '解释器',
    'runtime': '运行时', 'virtualMachine': '虚拟机', 'garbageCollection': '垃圾回收',
    'memory': '内存',
    'disk': '磁盘',
    'socket': '套接字', 'port': '端口', 'host': '主机', 'domain': '域名',
    'ip': 'IP地址', 'dns': '域名系统(DNS)', 'tls': '传输层安全(TLS)',
    'ssl': '安全套接层(SSL)', 'certificate': '证书', 'signature': '签名',
    'encryption': '加密', 'decryption': '解密', 'digest': '摘要',
    'salt': '盐值', 'credential': '凭证', 'authentication': '认证',
    'authorization': '授权', 'permission': '权限', 'role': '角色', 'session': '会话',
    'login': '登录', 'logout': '登出', 'signup': '注册', 'account': '账户',
    'settings': '设置', 'preferences': '偏好设置',
    'options': '选项', 'configuration': '配置', 'environment': '环境',
    'platform': '平台', 'device': '设备', 'screen': '屏幕',
    'view': '视图', 'widget': '组件', 'layout': '布局',
    'theme': '主题', 'color': '颜色',
    'icon': '图标', 'image': '图片', 'media': '媒体', 'audio': '音频',
    'video': '视频', 'animation': '动画', 'transition': '过渡', 'gesture': '手势',
    'tap': '点击', 'swipe': '滑动', 'drag': '拖拽', 'scroll': '滚动',
    'click': '单击', 'press': '按压', 'hover': '悬停',
    'focus': '焦点', 'blur': '失焦', 'selection': '选区', 'clipboard': '剪贴板',
    'keyboard': '键盘', 'input': '输入', 'output': '输出',
    'pipeline': '流水线',
    'coroutine': '协程', 'task': '任务', 'job': '作业', 'worker': '工作单元',
    'pool': '池', 'singleton': '单例', 'prototype': '原型',
    'adapter': '适配器', 'bridge': '桥接', 'composite': '组合',
    'facade': '外观', 'flyweight': '享元', 'observer': '观察者', 'strategy': '策略',
    'template': '模板', 'visitor': '访问者', 'iterator': '迭代器', 'enumerable': '可枚举',
    'generator': '生成器', 'consumer': '消费者', 'producer': '生产者',
    'listener': '监听器', 'receiver': '接收方', 'sender': '发送方', 'client': '客户端',
    'server': '服务端', 'agent': '代理端', 'daemon': '守护进程',
    'console': '控制台', 'terminal': '终端', 'logger': '日志器', 'monitor': '监视器',
    'metrics': '指标', 'trace': '追踪',
    'benchmark': '基准测试', 'threshold': '阈值', 'quota': '配额', 'budget': '预算',
    'cap': '封顶',
    'spacing': '间距',
    'indent': '缩进', 'newline': '换行符', 'delimiter': '分隔符', 'separator': '分隔线',
    'terminator': '终止符', 'escape': '转义', 'quote': '引号', 'bracket': '括号',
    'brace': '花括号', 'parenthesis': '圆括号', 'comma': '逗号', 'semicolon': '分号',
    'colon': '冒号', 'dot': '点号', 'dash': '短横线', 'underscore': '下划线',
    'asterisk': '星号', 'slash': '斜杠', 'backslash': '反斜杠',
    'tilde': '波浪号', 'caret': '脱字符', 'dollar': '美元符',
    'percent': '百分号', 'ampersand': '与号', 'exclamation': '感叹号',
    'multiply': '乘号', 'divide': '除号', 'modulo': '取余',
    'sqrt': '平方根', 'clamp': '钳制范围',
    'average': '平均值', 'median': '中位数',
    'variance': '方差', 'standardDeviation': '标准差',
    'scale': '缩放', 'translate': '平移', 'rotate': '旋转',
    'vector': '向量', 'scalar': '标量', 'tensor': '张量',
    'velocity': '速度', 'acceleration': '加速度',
    'direction': '方向', 'orientation': '朝向', 'angle': '角度', 'radian': '弧度',
    'radius': '半径', 'diameter': '直径', 'circumference': '周长',
    'volume': '体积', 'density': '密度', 'mass': '质量',
    'energy': '能量',
    'frequency': '频率', 'amplitude': '振幅', 'phase': '相位',
    'wavelength': '波长', 'spectrum': '频谱', 'bandwidth': '带宽', 'throughput': '吞吐量',
    'latency': '延迟', 'jitter': '抖动', 'packet': '数据包',
    'byte': '字节', 'nibble': '半字节',
    'octet': '八位组',
    'encoding': '编码方式', 'decoding': '解码方式', 'compression': '压缩',
    'decompression': '解压', 'serialization': '序列化', 'deserialization': '反序列化',
    'marshal': '编组', 'unmarshal': '解组',
    'encrypt': '加密', 'decrypt': '解密', 'verify': '验证',
    'stringify': '字符串化', 'prettify': '美化',
    'minify': '压缩', 'obfuscate': '混淆', 'beautify': '美化', 'pretty': '美观格式',
    'raw': '原始', 'plain': '明文', 'binary': '二进制', 'hex': '十六进制',
    'decimal': '十进制', 'octal': '八进制', 'base32': 'Base32编码', 'base58': 'Base58编码',
    'bigEndian': '大端序', 'littleEndian': '小端序', 'endianness': '字节序',
    'timezone': '时区', 'timestamp': '时间戳', 'epoch': '纪元', 'duration': '时长',
    'interval': '间隔', 'instant': '时刻', 'moment': '瞬间', 'date': '日期',
    'timer': '计时器',
    'stopwatch': '秒表', 'countdown': '倒计时', 'deadline': '截止时间',
    'expiration': '过期时间', 'ttl': '生存时间(TTL)', 'lease': '租约',
    'renew': '续期', 'expire': '过期', 'elapsed': '已耗时', 'remaining': '剩余',
    'scheduled': '已调度', 'delayed': '已延迟', 'immediate': '立即',
    'periodic': '周期性', 'oneShot': '一次性', 'continuous': '持续',
    'incremental': '增量', 'delta': '差量',
    'diff': '差异',
    'upgrade': '升级',
    'downgrade': '降级', 'uninstall': '卸载',
    'deactivate': '停用', 'enable': '启用', 'disable': '禁用',
    'resume': '恢复',
    'suspend': '挂起', 'interrupt': '中断',
    'terminate': '终止', 'reopen': '重新打开', 'connect': '连接', 'disconnect': '断开',
    'attach': '附加', 'detach': '分离', 'unbind': '解绑',
    'unlink': '解除链接', 'mount': '挂载', 'unmount': '卸载',
    'register': '注册', 'unregister': '注销',
    'send': '发送', 'receive': '接收', 'forward': '转发',
    'route': '路由', 'navigate': '导航', 'jump': '跳转', 'seek': '定位',
    'rewind': '回卷', 'fastForward': '快进', 'step': '步进',
    'repeat': '重复', 'iterate': '迭代', 'traverse': '遍历',
    'visit': '访问', 'crawl': '爬取', 'scan': '扫描',
    'lookup': '查表', 'probe': '探测',
    'inspect': '检查', 'examine': '审查', 'review': '评审', 'audit': '审计',
    'deny': '拒绝',
    'prevent': '防止', 'avoid': '避免', 'manage': '管理',
    'execute': '执行',
    'invoke': '调用', 'utilize': '利用', 'employ': '采用', 'adopt': '采纳',
    'specify': '指定',
    'construct': '构造', 'generate': '生成', 'produce': '生产',
    'render': '渲染', 'draw': '绘制', 'paint': '绘画', 'display': '显示',
    'reveal': '揭示', 'conceal': '隐藏',
    'print': '打印', 'append': '追加',
    'prepend': '前置', 'erase': '擦除',
    'purge': '清除', 'wipe': '抹除', 'truncate': '截断', 'crop': '裁剪',
    'cut': '剪切', 'copy': '复制', 'paste': '粘贴', 'duplicate': '重复副本',
    'clone': '克隆', 'deepCopy': '深拷贝', 'shallowCopy': '浅拷贝', 'reference': '引用',
    'pointer': '指针', 'address': '地址', 'location': '位置',
    'vertex': '顶点',
    'cell': '单元格', 'grid': '网格',
    'mesh': '网格', 'surface': '表面', 'wireframe': '线框',
    'polygon': '多边形', 'polyline': '折线', 'bezier': '贝塞尔曲线',
    'curve': '曲线', 'shape': '形状', 'form': '形态',
    'figure': '图形', 'diagram': '图表', 'chart': '图表',
    'axis': '轴', 'legend': '图例', 'label': '标签',
    'tooltip': '提示信息', 'placeholder': '占位符', 'prompt': '提示',
    'hint': '暗示', 'note': '笔记', 'warning': '警告',
    'verbose': '详细', 'quiet': '静默',
    'silent': '无声', 'noise': '噪声', 'sound': '声音',
    'voice': '语音', 'speech': '语音', 'language': '语言', 'locale': '区域设置',
    'culture': '文化',
    'phone': '电话', 'email': '电子邮件',
    'website': '网站', 'webpage': '网页', 'browser': '浏览器',
    'kernel': '内核', 'driver': '驱动', 'firmware': '固件',
    'hardware': '硬件', 'software': '软件', 'middleware': '中间件',
    'sdk': '软件开发工具包(SDK)',
    'api': '应用程序接口(API)', 'rest': '表述性状态转移(REST)', 'graphql': 'GraphQL查询语言',
    'grpc': 'gRPC远程过程调用', 'websocket': 'WebSocket协议', 'sse': '服务器发送事件(SSE)',
    'markdown': 'Markdown轻量标记',
    'section': '节',
    'subsection': '小节', 'paragraph': '段落', 'sentence': '句子', 'phrase': '短语',
    'word': '单词', 'character': '字符', 'glyph': '字形',
    'serif': '衬线体', 'mono': '等宽字体',
    'slant': '倾斜', 'italic': '斜体',
    'bold': '粗体', 'regular': '常规', 'medium': '中等',
    'condensed': '窄体', 'expanded': '宽体',
    'normal': '正常', 'standard': '标准', 'custom': '自定义',
    'preset': '预设', 'user': '用户', 'admin': '管理员', 'owner': '所有者',
    'member': '成员', 'guest': '访客', 'anonymous': '匿名',
    'internal': '内部', 'external': '外部',
    'global': '全局',
    'module': '模块',
    'namespace': '命名空间',
    'priority': '优先级', 'order': '顺序', 'sequence': '序列', 'series': '系列',
    'chain': '链', 'linked': '已链接', 'array': '数组', 'typedArray': '类型化数组',
    'mapper': '映射器', 'reducer': '归约器', 'catalog': '目录册',
    'archive': '归档', 'bundle': '捆绑包',
    'partition': '分区', 'shard': '分片', 'replica': '副本', 'mirror': '镜像',
    'snapshot': '快照', 'backup': '备份', 'restore': '恢复', 'recover': '恢复',
    'repair': '修复',
    'hotfix': '热修复',
    'bugfix': '缺陷修复', 'enhancement': '增强', 'improvement': '改进',
    'optimization': '优化', 'refactor': '重构', 'redesign': '重新设计',
    'rework': '返工', 'revise': '修订', 'amend': '修正', 'adjust': '调整',
    'calibrate': '校准', 'harmonize': '协调', 'synchronize': '同步',
    'communicate': '通信', 'interact': '交互', 'negotiate': '协商', 'handshake': '握手',
    'contract': '契约',
    'abstraction': '抽象', 'encapsulation': '封装', 'inheritance': '继承',
    'polymorphism': '多态',
    'aggregation': '聚合',
    'dependency': '依赖', 'coupling': '耦合', 'cohesion': '内聚',
    'modularity': '模块化', 'scalability': '可扩展性', 'maintainability': '可维护性',
    'reliability': '可靠性', 'availability': '可用性', 'performance': '性能',
    'efficiency': '效率', 'effectiveness': '有效性', 'accuracy': '准确性',
    'precision': '精确度', 'recall': '召回率',
    'engineering': '工程', 'architecture': '架构', 'design': '设计',
    'practice': '实践', 'principle': '原则', 'guideline': '指南',
    'convention': '约定', 'idiom': '惯用法',
    'guide': '指南', 'manual': '手册', 'tutorial': '教程', 'example': '示例',
    'demo': '演示', 'showcase': '展示', 'portfolio': '作品集',
    'gallery': '画廊', 'collection': '集合', 'repository': '仓库',
    'registry': '注册表',
    'warehouse': '数据仓库', 'mart': '数据集市', 'cube': '多维立方体',
    'workflow': '工作流',
    'orchestration': '编排', 'automation': '自动化', 'integration': '集成',
    'deployment': '部署', 'distribution': '分发',
    'provisioning': '供给', 'scaling': '扩缩容', 'loadbalancing': '负载均衡',
    'failover': '故障转移', 'redundancy': '冗余', 'resilience': '弹性',
    'consistency': '一致性', 'isolation': '隔离性',
    'atomicity': '原子性', 'locking': '锁定',
    'contention': '争用', 'deadlock': '死锁', 'livelock': '活锁', 'starvation': '饥饿',
    'raceCondition': '竞态条件',
    'defect': '瑕疵', 'issue': '问题', 'problem': '难题', 'challenge': '挑战',
    'obstacle': '障碍', 'blocker': '阻塞项', 'bottleneck': '瓶颈',
    'restriction': '约束', 'limitation': '局限',
    'caveat': '注意事项', 'pitfall': '陷阱', 'gotcha': '易错点', 'quirk': '怪癖',
    'hack': '临时方案', 'workaround': '变通方法',
    'quickfix': '快速修复', 'hotpatch': '热补丁', 'emergency': '紧急', 'urgent': '急迫',
    'critical': '关键', 'important': '重要', 'minor': '次要', 'trivial': '微小',
    'major': '重大', 'severe': '严重', 'fatal': '致命',
    'exception': '异常', 'failure': '失败', 'fault': '故障', 'crash': '崩溃',
    'halt': '停机',
    'stuck': '卡住', 'busy': '忙碌',
    'idle': '空闲', 'waiting': '等待', 'ready': '就绪',
    'completed': '已完成', 'done': '完毕',
    'cancelled': '已取消', 'canceled': '已取消',
    'filtered': '已过滤', 'denied': '被拒绝',
    'verified': '已验证', 'validated': '已校验', 'authenticated': '已认证',
    'authorized': '已授权',
    'revoked': '被撤销', 'renewed': '已续期',
    'extended': '已延长', 'shortened': '已缩短', 'increased': '已增加',
    'decreased': '已减少', 'raised': '已提升', 'lowered': '已降低', 'boosted': '已增强',
    'reduced': '已削减', 'improved': '已改进',
    'enhanced': '已增强', 'downgraded': '已降级',
    'migrated': '已迁移', 'translated': '已翻译', 'localized': '已本地化',
    'internationalized': '已国际化', 'globalized': '已全球化', 'regionalized': '已区域化',
    'customized': '已定制化', 'personalized': '已个性化', 'initialized': '已初始化',
    'populated': '已填充', 'seeded': '已播种', 'warmed': '已预热',
}


def zh_name(name):
    """把驼峰函数/变量名尽量翻译成中文短语。"""
    if not name:
        return ''
    # 拆驼峰与下划线
    words = re.findall(r"[A-Z]?[a-z0-9\$]+|[A-Z]+(?![a-z])", name)
    out = []
    for w in words:
        lw = w.lower()
        out.append(NAME_HINTS.get(w, NAME_HINTS.get(lw, IDENT_ZH.get(w, IDENT_ZH.get(lw, w)))))
    s = ' '.join(out)
    # 若全是英文原词直译效果差，保留原名并附中文提示
    return s.strip()


RE_WORD = re.compile(r"[A-Za-z][A-Za-z0-9_]*")

# 括号内已是中文时，不再翻译括号中的英文原文（避免 (final) → (不可重新赋值(final))）
RE_ZH_PAREN = re.compile(r"\((?=[^()]*[\u4e00-\u9fff])[^()]*\)")


def localize_note(text):
    """将说明文字中残留的裸英文标识符/关键字替换为中文（反引号内的代码保持原样）。"""
    if not text:
        return text
    parts = re.split(r'(`[^`]*`)', text)
    out = []
    for i, seg in enumerate(parts):
        if i % 2 == 1:  # 反引号内源代码，保持原样
            out.append(seg)
            continue

        # 先把"含中文的括号段"用占位符保护起来
        placeholders = []

        def protect(m):
            placeholders.append(m.group(0))
            return f"\x00{len(placeholders) - 1}\x00"

        seg2 = RE_ZH_PAREN.sub(protect, seg)

        def repl(m):
            w = m.group(0)
            zh = translate_word(w)
            return zh if zh else w

        seg2 = RE_WORD.sub(repl, seg2)
        for j, ph in enumerate(placeholders):
            seg2 = seg2.replace(f"\x00{j}\x00", ph)
        out.append(seg2)
    return ''.join(out)


def translate_word(w):
    """单个英文单词 → 中文表述；词典无收录时尝试驼峰分词翻译。"""
    if w in KEYWORD_ZH:
        return KEYWORD_ZH[w]
    if w in IDENT_ZH:
        return IDENT_ZH[w]
    lw = w.lower()
    if lw in IDENT_ZH:
        return IDENT_ZH[lw]
    # 未收录的驼峰标识符：逐词翻译，全部可译才整体替换
    words = re.findall(r"[A-Z]?[a-z0-9\$]+|[A-Z]+(?![a-z])", w)
    if len(words) > 1:
        trans = []
        for sub in words:
            t = NAME_HINTS.get(sub) or NAME_HINTS.get(sub.lower()) \
                or IDENT_ZH.get(sub) or IDENT_ZH.get(sub.lower())
            if not t:
                return None
            trans.append(t)
        return ' '.join(trans)
    return None


RE_GENERIC_TYPE = re.compile(r"\b(?:Future|Stream|List|Map|Set)(?:<[^<>]*(?:<[^<>]*>[^<>]*)*>|\?)")


def zh_type(ty):
    """把类型表达式中的泛型容器/异步类型译为中文，保留内部具体类型名。"""
    ty = ty.strip()
    if not ty:
        return ty
    mapping = {'Future': '异步结果', 'Stream': '数据流', 'List': '列表',
               'Map': '映射', 'Set': '集合'}
    seen = set()
    changed = True
    while changed:
        changed = False
        for en, zhcn in mapping.items():
            pat = re.compile(r"(\?|<(?:[^<>]|<[^<>]*>)*>|\b)" + en + r"\b")
            m = pat.search(ty)
            if m and (en, m.start()) not in seen:
                seen.add((en, m.start()))
                prefix = m.group(1) if m.group(1) != '<' else ''
                ty = ty[:m.start(1)] + prefix + zhcn + ty[m.end():]
                changed = True
    return ty


def strip_trailing_comment(line):
    """分离代码与其行尾的 // 注释（忽略字符串内的 //）。"""
    in_str = None
    i = 0
    while i < len(line):
        c = line[i]
        if in_str:
            if c == '\\':
                i += 2
                continue
            if c == in_str:
                in_str = None
        else:
            if c in ('"', "'"):
                in_str = c
            elif c == '/' and i + 1 < len(line) and line[i + 1] == '/':
                code = line[:i].rstrip()
                comment = line[i:].lstrip('/').strip()
                return code, comment
        i += 1
    return line, None


def module_of(path):
    """从 import 路径提取模块名。"""
    m = RE_PACKAGE.match(path)
    if m:
        return m.group(1).split('/')[0]
    m = RE_RELATIVE.match(path)
    if m:
        parts = m.group(1).split('/')
        return parts[-1].replace('.dart', '')
    return path


def describe(code, ctx):
    """为一条代码语句生成中文说明。code 已去掉行尾注释。"""
    s = code.strip()
    if not s:
        return ''

    # ---- 链式调用首行：接收者.方法( / 接收者.属性（如 AppLog.instance）----
    m_chain_head = re.match(r"^([\w\.\$]+)\.[\w\$]+(?:\(|\.|\s*$)", s)
    if m_chain_head and not RE_VAR_DECL.match(s) and not RE_VAR_SIMPLE.match(s):
        recv = m_chain_head.group(1)
        zh_r = zh_name(recv.split('.')[-1])
        d = f"链式调用起始于 {recv}"
        if zh_r and zh_r.replace(' ', '') != recv.split('.')[-1]:
            d += f"（{zh_r}）"
        d += f"，后续行继续该表达式：{short(s, 70)}"
        return d

    # ---- 以 = 结尾的续行赋值开头（如 directoryContainer =）----
    m_open_assign = re.match(r"^((?:final|var|const|late)\s+)?(\w[\w\.]*)\s*=\s*$", s)
    if m_open_assign:
        kw, target = m_open_assign.groups()
        val = (kw + '声明并') if kw else '重新'
        return f"将下一行开始的表达式的值{val}赋值给 {target}"

    # ---- 字符串字面量开头的行（正则/SQL/键名字符串）----
    m_str_line = re.match(r"^(r?'(?:[^'\\]|\\.)*'|\"(?:[^\"\\]|\\.)*\")\s*(.*)$", s)
    if m_str_line and not RE_IMPORT.match(s) and not RE_PART_OF.match(s):
        lit, rest = m_str_line.groups()
        if not rest:
            return f"字符串字面量：{short(lit, 80)}"
        if rest.startswith(':'):
            return f"Map 条目 {lit}: {short(rest[1:], 60)}"
        if rest.startswith('.'):
            return f"对字符串 {short(lit, 30)} 链式调用：{short(rest, 70)}"
        if rest.startswith('=='):
            return f"与 {lit} 比较：{short(rest, 70)}"
        return f"以字符串 {short(lit, 40)} 起始的表达式：{short(rest, 60)}"

    # ---- await foo(...) 调用语句（优先于函数签名匹配，避免误判）----
    m_await_call = re.match(r"^(?:await\s+)?([\w\.\$]+)\s*\(", s)
    if m_await_call and (s.startswith('await ') or RE_AWAIT.search(s[:40])):
        callee = m_await_call.group(1)
        zh = zh_name(callee.split('.')[-1])
        d = f"调用 {callee}(...)" + ("（等待异步完成）" if s.startswith('await') else "")
        if zh and zh.replace(' ', '') != callee.split('.')[-1]:
            d += f" → {zh}"
        return d

    # ---- 多行三元表达式分支：? xxx / : xxx ----
    if s.startswith('? ') or s.startswith(': '):
        return f"三元表达式{'为真时取值' if s[0]=='?' else '为假时取值'}：{short(s[2:], 70)}"

    # ---- Map 字面量条目：'key': value ----
    m_map_entry = re.match(r"^'([^']+)'\s*:\s*(.+?),?$", s)
    if m_map_entry and not m_map_entry.group(1).startswith('@'):
        key, val = m_map_entry.groups()
        zh = zh_name(key)
        d = f"Map 条目 '{key}': {short(val, 70)}"
        if zh and zh != key:
            d += f"（{zh}）"
        return d

    # ---- 多行调用中的命名实参行：name: value, ----
    m_named_arg = re.match(r"^(\w+)\s*:\s*(.+?),?$", s)
    if m_named_arg and not s.startswith('case') and '=>' not in s[:4]:
        key, val = m_named_arg.groups()
        zh = zh_name(key)
        d = f"命名实参 {key}: {short(val, 70)}"
        if zh and zh != key:
            d += f"（{zh}）"
        return d

    # ---- 多行调用的命名实参行：name: value（含尾逗号）----
    m_named_arg = re.match(r"^(\w+)\s*:\s*(.+?),$", s)
    if m_named_arg and not s.startswith('case'):
        key, val = m_named_arg.groups()
        zh = zh_name(key)
        d = f"命名实参 {key}: {short(val, 70)}"
        if zh and zh != key:
            d += f"（{zh}）"
        return d

    # ---- return await foo(...) / return foo(...) 优先于函数签名匹配 ----
    m_ret_await = re.match(r"^return\s+(?:await\s+)?([\w\.\$]+(?:<[^>]*>)?\()", s)
    if m_ret_await:
        callee = m_ret_await.group(1).rstrip('(')
        zh = zh_name(callee.split('.')[-1])
        base = f"返回异步调用 {callee}(...) 的结果" if 'await' in s else f"返回调用 {callee}(...) 的结果"
        if zh and zh.replace(' ', '') != callee.split('.')[-1]:
            base += f"（语义：{zh}）"
        return base

    # ---- 指令 ----
    m = RE_IMPORT.match(s)
    if m:
        mod = module_of(m.group(1))
        alias = f"，别名 {m.group(2)}" if m.group(2) else ""
        return f"导入 {mod} 模块{alias}"
    m = RE_EXPORT.match(s)
    if m:
        show = f"，仅导出 {m.group(2)}" if m.group(2) else ""
        return f"对外导出 {module_of(m.group(1))}{show}"
    m = RE_PART_OF.match(s)
    if m:
        ctx['is_part'] = True
        return f"声明本文件是 {m.group(1)} 库的一部分(part)，与其共享同一命名空间"
    m = RE_PART.match(s)
    if m:
        return f"引入 part 文件 {m.group(1)}"

    # ---- 类型声明 ----
    m = RE_ABSTRACT_CLASS.match(s)
    if m:
        ctx['cur_class'] = m.group(1)
        return f"定义抽象类 {m.group(1)}（接口契约，子类必须实现其抽象方法）"
    m = RE_MIXIN.match(s)
    if m:
        return f"定义混入(Mixin) {m.group(1)}，供类 with 复用"
    m = RE_ENUM.match(s)
    if m:
        ctx['cur_class'] = m.group(1)
        return f"定义枚举 {m.group(1)}"
    m = RE_CLASS.match(s)
    if m:
        ctx['cur_class'] = m.group(1)
        ext = f"，继承 {m.group(2)}" if m.group(2) else ""
        wit = f"，混入 {m.group(3).strip()}" if m.group(3) else ""
        imp = f"，实现接口 {m.group(4).strip()}" if m.group(4) else ""
        return f"定义类 {m.group(1)}{ext}{wit}{imp}"

    # ---- getter ----
    m = RE_GETTER.match(s)
    if m and not s.startswith('if'):
        return f"只读属性(getter) {m.group(4)}，返回类型 {m.group(3).strip()}"

    # ---- 成员/局部函数签名（以 ( 结尾或多行参数）----
    m = RE_FUNC.match(s)
    if m and '(' in s:
        stat = '静态' if m.group(1) and 'static' in m.group(1) else ('工厂' if m.group(1) and 'factory' in m.group(1) else '')
        ret = m.group(2).strip()
        fname = m.group(3)
        params = m.group(5) or s[s.index('(') + 1:]
        zh = zh_name(fname)
        pdesc = param_desc(params)
        asyn = '（异步）' if 'async' in s or 'Future' in ret else ''
        return f"定义{stat}方法 {fname}：返回 {ret}；{pdesc}{asyn}" + (f"。语义：{zh}" if zh and zh != fname else "")

    # ---- 构造函数 ----
    m = RE_CTOR.match(s)
    if m and m.group(1)[0].isupper() and '(' in s and not s.startswith('if') and not s.startswith('return'):
        named = s[s.index('(') + 1:]
        pdesc = param_desc(named)
        return f"构造函数 {m.group(1)}{pdesc}"

    # ---- 变量声明 ----
    m = RE_VAR_DECL.match(s)
    if m:
        kw, ty, name, op = m.groups()
        zh = zh_name(name)
        extra = ''
        if '=' in s:
            rhs = s.split('=', 1)[1].strip()
            extra = value_hint(rhs, ctx)
        return f"{kw_zh(kw)} {zh_type(ty.strip())} 类型变量 {name}{('：' + extra) if extra else ''}" + (f"（{zh}）" if zh and zh != name else "")
    m = RE_VAR_SIMPLE.match(s)
    if m:
        kw, name, op = m.groups()
        extra = ''
        if '=' in s:
            rhs = s.split('=', 1)[1].strip()
            extra = value_hint(rhs, ctx)
        return f"{kw_zh(kw)}变量 {name}{('：' + extra) if extra else ''}"

    # ---- 控制流 ----
    m_catch = re.match(r"^\}?\s*(?:on\s+[\w<>,\s]+\s+)?catch\s*\(([^)]*)\)\s*\{?$", s)
    if m_catch:
        args = m_catch.group(1).strip()
        if args == '_':
            return "闭合 try 块并捕获异常（忽略异常对象）"
        return f"闭合 try 块并捕获异常，异常变量：{args}"
    if s.startswith('if (') and ') throw ' in s:
        m_it = re.match(r"^if\s*\((.+?)\)\s*throw\s+(\w+)?(.*)$", s)
        if m_it:
            cond, exc, rest = m_it.groups()
            return f"条件判断 if：{cond_zh(cond + ')')}；成立则抛出异常 {exc or ''}{short(rest or '', 50)}"
    if s.startswith('else if'):
        m = RE_ELSIF.match(s)
        return f"否则-if 分支：条件 {trim_paren(m.group(1))}"
    if s.startswith('else'):
        return "否则分支（else）"
    m = RE_IF.match(s)
    if m:
        return f"条件判断 if：{cond_zh(m.group(1))}"
    m = RE_FOR.match(s)
    if m:
        inner = trim_paren(m.group(1))
        if 'in' in inner:
            return f"for-in 遍历：{inner[:80]}"
        return f"for 循环：{inner[:80]}"
    m = RE_WHILE.match(s)
    if m:
        return f"while 循环，条件：{trim_paren(m.group(1))[:80]}"
    m = RE_SWITCH.match(s)
    if m:
        return f"switch 分支判断，表达式：{trim_paren(m.group(1))[:60]}"
    m = RE_CASE.match(s)
    if m:
        return f"case 分支：{m.group(1).strip()[:70]}"
    if RE_DEFAULT.match(s):
        return "default 默认分支"
    if RE_TRY.match(s):
        return "try 块开始：包裹可能抛出异常的逻辑"
    m = RE_CATCH.match(s)
    if s.startswith('catch') or s.startswith('on '):
        arg = m.group(1) if m and m.group(1) else ''
        return f"捕获异常 catch({arg})" if arg else "捕获异常 catch"
    if RE_FINALLY.match(s):
        return "finally 块：无论是否异常都执行（清理资源）"
    m = RE_THROW.match(s)
    if m:
        exc = m.group(1) or ''
        msg = (m.group(2) or '').strip()
        return f"抛出异常 {exc}".rstrip() + (f"，信息：{msg[:60]}" if msg else "")
    if RE_BREAK.match(s):
        return "break：跳出当前循环/switch"
    if RE_CONTINUE.match(s):
        return "continue：进入下一次循环迭代"
    if RE_ASSERT.match(s):
        return "assert 断言（仅调试期生效）"

    # ---- 返回 ----
    m = RE_RETURN.match(s)
    if m:
        rest = m.group(1).strip().rstrip(';')
        if not rest:
            return "return：返回（无值/提前退出）"
        hint = value_hint(rest, ctx)
        return f"返回 {short(rest)}" + (f"（{hint}）" if hint else "")

    # ---- 结构性大括号 ----
    m_close_then = re.match(r"^\}\s*(.+)$", s)
    if m_close_then:
        tail = m_close_then.group(1).strip()
        if tail.startswith('else'):
            return f"闭合上一代码块并开始 {tail[:40]}"
        if tail.startswith('catch') or tail.startswith('on '):
            return f"闭合 try 块并捕获异常：{short(tail, 60)}"
        if tail.startswith('while'):
            return f"闭合块，衔接 do-while 条件：{short(tail, 50)}"
        return f"闭合代码块并衔接后续语句：{short(tail, 60)}"
    if RE_CLOSE_BRACE.match(s):
        depth_info = ""
        return f"闭合大括号，结束当前代码块{depth_info}"
    if s == '{':
        return "代码块开始 {"
    if s in ('},', ');', ')', '];', ')),', '));'):
        return f"结束上一调用/字面量：{s}"

    # ---- 日志 ----
    if 'AppLog' in s:
        m2 = re.search(r"AppLog\.instance\.(\w+)\(\s*'([^']*)'", s)
        if m2:
            return f"输出日志({m2.group(1)})：“{m2.group(2)[:60]}”"
        return "输出应用日志 AppLog"

    # ---- await / 调用语句 ----
    stmt = s.rstrip(';')
    call = re.match(r"(?:await\s+)?([\w\.\$\[\]]+(?:\([\w\.\$\s,\.\{\}\(\)'\"]*\))?(?:\.[\w]+(?:\([^;]*\))?)*)", stmt)
    method = None
    mm = re.findall(r"\.?(\w+)\(", stmt)
    if mm:
        method = mm[-1] if len(mm) == 1 else '/'.join(dict.fromkeys(mm))
    prefix = ''
    if RE_AWAIT.search(s):
        prefix = '等待异步结果：'
    target = None
    m_assign = re.match(r"(\w[\w\.]*)\s*=\s*(?:await\s+)?([\w\.]+)", stmt)
    if m_assign:
        target = m_assign.group(1)
        desc = f"将 {prefix or ''}{short(stmt[stmt.index('=') + 1:].strip())} 赋值给 {target}"
        if method:
            zh = zh_name(method.split('/')[-1])
            if zh and zh != method:
                desc += f"（调用 {method} → {zh}）"
        return desc
    if method:
        zh = zh_name(method.replace('/', ','))
        return f"调用 {method}(...)：{short(stmt)}" + (f"（{zh}）" if zh and zh.replace(' ', '') != method.replace(',', '').replace('/', '') else "")
    if prefix:
        return prefix + short(stmt)
    return short(stmt)


def kw_zh(kw):
    return {'final': '声明不可重新赋值的', 'var': '声明自动类型推断的',
            'const': '声明编译期常量', 'late': '声明延迟初始化的'}.get(kw, kw)


def trim_paren(txt):
    txt = txt.strip()
    if txt.startswith('('):
        txt = txt[1:]
    # 去掉尾部 ) 或 ) {
    txt = re.sub(r"\)\s*\{?\s*$", '', txt)
    return txt.strip()


def cond_zh(raw):
    c = trim_paren(raw)
    c = re.sub(r"\s*\|\|\s*", ' 或 ', c)
    c = re.sub(r"\s*&&\s*", ' 且 ', c)
    c = re.sub(r"\s*==\s*", ' 等于 ', c)
    c = re.sub(r"\s*!=\s*", ' 不等于 ', c)
    c = re.sub(r"\s*>\s*", ' > ', c)
    c = re.sub(r"\s*<\s*", ' < ', c)
    return short(c, 90)


def param_desc(params):
    params = params.strip()
    if not params or params in (')', '){', ') {'):
        return "无参数"
    params = re.sub(r"\)\s*\{?\s*$", '', params)
    named = re.findall(r"\{\s*(?:required\s+)?[\w<>?,\s]+?\s+(\w+)\s*[},]", '{' + params) if '{' in params else []
    pos = [p.strip() for p in params.split(',') if p.strip() and not p.strip().startswith('{')]
    parts = []
    if pos:
        parts.append(f"位置参数 {len(pos)} 个")
    if '{' in params:
        parts.append("含命名参数")
    names = re.findall(r"(\w+)\s*(?:[,:}=]|\))", params)
    if names:
        parts.append("参数名: " + ', '.join(dict.fromkeys(names))[:120])
    return '；'.join(parts) if parts else "含参数"


def value_hint(rhs, ctx):
    rhs = rhs.strip()
    if rhs.startswith('Future') or '.then' in rhs:
        return "异步 Future 相关"
    if rhs in ('null',):
        return "初始为 null"
    if rhs in ('true', 'false'):
        return f"布尔值 {rhs}"
    if re.match(r"^-?\d+\.?\d*$", rhs):
        return f"数值 {rhs}"
    if rhs.startswith("'") or rhs.startswith('"') or rhs.startswith("r'"):
        return f"字符串字面量 {short(rhs, 40)}"
    if rhs.startswith('['):
        return "列表字面量"
    if rhs.startswith('{'):
        return "Map/集合字面量"
    m_await = re.match(r"^await\s+([\w\.\$]+)\s*\(", rhs)
    if m_await:
        callee = m_await.group(1)
        zh = zh_name(callee.split('.')[-1])
        h = f"await 调用 {callee}(...)"
        if zh and zh.replace(' ', '') != callee.split('.')[-1]:
            h += f" → {zh}"
        return h
    if RE_AWAIT.match(rhs):
        return "await 等待异步调用结果"
    m_call = re.match(r"^([\w\.\$]+)\s*\(", rhs)
    if m_call:
        callee = m_call.group(1)
        zh = zh_name(callee.split('.')[-1])
        if zh and zh.replace(' ', '') != callee.split('.')[-1]:
            return f"调用 {callee}(...) → {zh}"
    return ''


def short(txt, limit=100):
    txt = re.sub(r"\s+", ' ', txt).strip()
    if len(txt) > limit:
        txt = txt[:limit] + '…'
    return txt


RE_PAREN = re.compile(r"\((?:[^()]|\([^()]*\))*\)")


def collapse_parens(txt):
    """反复折叠最内层括号内容，便于判断顶层逗号/命名参数。"""
    prev = None
    while prev != txt:
        prev = txt
        txt = RE_PAREN.sub('()', txt)
    return txt


def is_param_line(s):
    """判断是否为多行函数签名的续行参数（顶层以逗号/{ 结尾）。"""
    if not s or s.startswith('//'):
        return False
    c = collapse_parens(s)
    # 形如 "Type name," / "bool x = true," / "tocUrl,"
    if c.endswith(','):
        # 排除 Map 字面量键值行（'key': value,）与纯实参调用行
        if re.match(r"^'[^']*'\s*:", s) or re.match(r'^"[^"]*"\s*:', s):
            return False
        if re.match(r"^\w+\s*:\s", s):
            return False
        return bool(re.match(r"^(?:final\s+|var\s+|const\s+|required\s+)?[\w<>,\?\.\s]+(?:=[^,]*)?,$", c))
    # 形如 "Book book, {" / "}) async {" / "{") —— 签名命名参数块开始/结束
    if re.match(r"^[A-Z]\w*(?:<[\w<>,\s]+>)?\s+\w+,\s*\{$", s):
        return True
    if re.match(r"^\}\)\s*(async\s*)?\*?\s*\{$", s):
        return True
    return False


def param_note(s, ctx):
    """为签名续行参数生成说明。"""
    if re.match(r"^\}\)\s*(async\s*)?\*?\s*\{$", s):
        asy = '异步' if 'async' in s else ''
        return f"签名结束，进入{asy}方法体 {s}"
    m_open = re.match(r"^([A-Z]\w*(?:<[\w<>,\s]+>)?)\s+(\w+),\s*\{$", s)
    if m_open:
        ty, name = m_open.groups()
        zh = zh_name(name)
        d = f"{ty} 类型参数 {name}，其后 {s[s.index('{'):]} 开启命名参数块"
        if zh and zh != name:
            d += f"（{zh}）"
        return d
    t = s.rstrip(',')
    req = ''
    if t.startswith('required '):
        req = '必填'
        t = t[len('required '):].strip()
    m = re.match(r"^([A-Za-z][\w<>,\?\.\s]*?)\s+(\w+)\s*(?:=\s*(.+))?$", t)
    if m and not m.group(1).strip() in ('return',):
        ty, name, dflt = m.groups()
        zh = zh_name(name)
        d = f"{req}{ty.strip()} 类型参数 {name}"
        if dflt is not None:
            d += f"，默认值 {short(dflt, 40)}"
        if zh and zh != name:
            d += f"（{zh}）"
        return d
    m2 = re.match(r"^(\w+)\s*:\s*(.+)$", t)
    if m2:
        return f"命名实参 {m2.group(1)}: {short(m2.group(2), 60)}"
    return f"签名/调用续行参数：{short(t, 70)}"


def describe_continuation(s, ctx):
    """处理既非注释也非完整语句的续行（含 }、) 、else { 等收尾片段）。"""
    if s == '},':
        return "结束上一个列表/参数项"
    if s == '}':
        return "闭合块（可能结束命名参数 Map 或代码块）"
    if s.startswith('})'):
        rest = s[2:].strip()
        head = "闭合匿名函数/命名参数块"
        if rest.startswith('async'):
            head += "，随后 async 回调体开始"
        elif rest:
            head += f"；尾部：{short(rest, 40)}"
        return head
    if s.startswith(') =>'):
        return f"箭头函数返回表达式：{short(s[4:], 80)}"
    if s.startswith(')'):
        return f"闭合上一调用的括号：{short(s, 50)}"
    if s.startswith('=>'):
        return f"箭头表达式：{short(s[2:], 80)}"
    if s.startswith('else'):
        return "否则分支（else），作为上一行的延续"
    if s.startswith('.'):
        return f"链式调用延续：{short(s, 80)}"
    return f"上一表达式的续行：{short(s, 80)}"


def gen_for_file(rel_path):
    src_path = os.path.join(ROOT, rel_path)
    if not os.path.exists(src_path):
        print(f"跳过（不存在）: {rel_path}")
        return None
    with open(src_path, encoding='utf-8') as f:
        lines = f.read().splitlines()

    base = os.path.basename(rel_path).replace('.dart', '')
    out_path = os.path.join(OUT_DIR, base + '.annotations.md')
    os.makedirs(OUT_DIR, exist_ok=True)

    ctx = {'cur_class': '', 'is_part': False}
    doc_pending = []          # 收集连续的 /// 注释
    brace_depth = 0
    rows = []
    total = len(lines)

    for idx, raw in enumerate(lines, start=1):
        stripped = raw.strip()
        code_only, tail_comment = strip_trailing_comment(stripped)
        code_only = code_only.strip()

        # 更新大括号深度（粗略，忽略字符串内括号——strip 后影响极小）
        brace_depth += code_only.count('{') - code_only.count('}')
        brace_depth = max(brace_depth, 0)

        # 续行上下文：若上一物理行未以 ; { } : , 等结束，则本行是表达式延续
        prev_code = ''
        if idx >= 2:
            pc, _ = strip_trailing_comment(lines[idx - 2].strip())
            prev_code = pc.strip()
        is_cont = bool(prev_code) and not re.search(r"[;{}:,]$", prev_code) \
            and not prev_code.endswith('?') and not prev_code.startswith('//')

        note = ''
        doc_m = RE_DOC.match(stripped)
        cm_m = RE_LINE_COMMENT.match(stripped) if not doc_m else None

        if doc_m:
            doc_pending.append(doc_m.group(1).strip())
            note = "文档注释：说明其后代码的用途"
        elif cm_m and not code_only:
            # 整行普通注释
            text = cm_m.group(2).strip()
            if set(text) <= set('=+-*# ') and text:
                note = "分隔线注释，标记章节区块"
            else:
                note = f"注释说明：{text}" if text else "注释行"
        elif not stripped:
            note = "空行，分隔逻辑段落"
        elif is_param_line(code_only):
            note = param_note(code_only, ctx)
        elif is_cont and code_only in (');', ')', '),', '}'):
            note = "多行调用收尾：闭合上一调用的括号"
        elif code_only == 'case' or code_only.startswith('case when ') or re.match(r"^case\s", code_only):
            note = f"case 分支：{short(code_only, 70)}"
        elif code_only in ('} else {', '} else if', '}) {', '}) =>', '));', ');', '],', '),', '},'):
            if code_only == '} else {':
                note = "闭合上一分支并开始 else 分支"
            elif code_only == '},':
                note = "结束上一个列表/参数项"
            elif code_only.startswith('} else'):
                note = f"闭合上一分支并衔接后续分支：{code_only}"
            elif code_only.startswith('})'):
                note = f"闭合匿名函数并结束调用：{code_only}"
            else:
                note = "闭合语句结尾，结束当前调用/字面量/块"
        elif is_cont and (code_only.startswith('.') or code_only.startswith(')')):
            note = describe_continuation(code_only, ctx)
        elif is_cont and re.match(r"^\w[\w\.]*,$", code_only):
            note = f"多行调用的位置实参：{code_only.rstrip(',')}"
        elif is_cont and re.match(r"^(\w[\w\.]*)\s*=\s*", code_only):
            m_cv = re.match(r"^(\w[\w\.]*)\s*=\s*(.*)$", code_only)
            note = f"续行赋值：将 {short(m_cv.group(2), 70)} 赋给 {m_cv.group(1)}"
        elif is_cont and re.match(r"^[-+*/%]|^&&|^\|\||^[<>!=]=?$", code_only):
            note = f"二元运算续行：{short(code_only, 70)}"
        elif not re.search(r"[;{}]\s*$", code_only) and not re.search(r"[$({[:,]\s*$|\b(if|for|while|switch|try|catch|finally|else|do)\b", code_only) and not code_only.endswith(('?', ':')) and '(' not in code_only and '{' not in code_only:
            note = describe_continuation(code_only, ctx)
        else:
            note = describe(code_only, ctx)
            if tail_comment:
                note += f"；行尾注释：{tail_comment}"
        if note and doc_pending and not doc_m:
            note = "【承接上方文档】" + ' '.join(doc_pending)[:80] + " → " + note
            doc_pending = []

        # 管道符转义，保证 Markdown 表格不被破坏
        src_disp = raw.replace('|', '\\|')
        if src_disp.strip() == '':
            src_disp = '&nbsp;'
        # 全中文化：将说明文字中残留的裸英文单词替换为中文表述
        note = localize_note(note)
        note = note.replace('|', '\\|')
        rows.append(f"| {idx} | `{src_disp}` | {note} |")

    title_src = os.path.basename(rel_path)
    header = [
        f"# {title_src} 逐行注释",
        "",
        f"> 源文件：`{rel_path}`（共 {total} 行）",
        ">",
        "> 本文件由 `scripts/gen_line_annotations.py` 自动生成，对源文件每一行给出独立说明。",
        "> 说明优先采用源码自带的中文注释；无注释的行依据 Dart 语法特征自动生成解释。",
        "",
        "| 行号 | 源代码 | 说明 |",
        "| ---: | --- | --- |",
    ]
    content = '\n'.join(header + rows) + '\n'
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"已生成: {os.path.relpath(out_path, ROOT)}  ({total} 行源码 -> {len(rows)} 条注释)")
    return out_path


def main():
    targets = sys.argv[1:] or DEFAULT_FILES
    ok = 0
    for t in targets:
        if gen_for_file(t):
            ok += 1
    print(f"完成：{ok}/{len(targets)} 个文件")


if __name__ == '__main__':
    main()

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
    'parse': '解析', 'rule': '规则', 'source': '书源', 'html': 'HTML', 'url': 'URL',
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
    'js': 'JS脚本', 'engine': '引擎', 'pattern': '模式', 'regex': '正则',
    'format': '格式化', 'encode': '编码', 'decode': '解码', 'json': 'JSON',
    'text': '文本', 'title': '标题', 'author': '作者', 'cover': '封面',
    'intro': '简介', 'kind': '类别', 'wordCount': '字数', 'latestChapter': '最新章节',
    'num': '编号', 'uuid': 'UUID', 'origin': '来源', 'proxy': '代理',
    'redirect': '重定向', 'fallback': '回退/降级', 'smart': '智能',
    'analyze': '分析', 'extract': '提取', 'rewrite': '重写', 'normalize': '规范化',
    'sanitize': '净化处理', 'persist': '持久化', 'flush': '刷写', 'batch': '批量',
    'progress': '进度', 'state': '状态', 'status': '状态', 'flag': '标志',
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
        out.append(NAME_HINTS.get(w, NAME_HINTS.get(lw, w)))
    s = ' '.join(out)
    # 若全是英文原词直译效果差，保留原名并附中文提示
    return s.strip()


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
        return f"{kw_zh(kw)} {ty.strip()} 类型变量 {name}{('：' + extra) if extra else ''}" + (f"（{zh}）" if zh and zh != name else "")
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
    return {'final': '声明不可重新赋值的(final)', 'var': '声明自动类型推断(var)',
            'const': '声明编译期常量(const)', 'late': '声明延迟初始化(late)'}.get(kw, kw)


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

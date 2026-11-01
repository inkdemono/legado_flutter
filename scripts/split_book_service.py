# -*- coding: utf-8 -*-
import os

os.chdir('/workspace')
SRC = 'lib/services/book/book_service.dart'
P = 'lib/services/book/'

with open(SRC, encoding='utf-8') as f:
    lines = f.read().split('\n')

def seg(a, b):  # 1-based inclusive
    return '\n'.join(lines[a-1:b]).rstrip()

HEADER = "// =============================================================================\n"

def write_part(name, desc, body):
    text = (
        "part of 'book_service.dart';\n\n"
        + HEADER
        + "// BookService %s\n" % desc
        + "// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）\n"
        + HEADER
        + "\n"
        + body
        + "\n"
    )
    with open(P + name, 'w', encoding='utf-8') as f:
        f.write(text)

write_part("book_service_toc_helpers.dart",
           '职责：目录(TOC)抓取辅助逻辑 —— URL 规范化比较、隐式分页候选构造、Ajax 目录回退解析。',
           seg(127, 424))

write_part('book_service_search.dart',
           '职责：书源搜索（单源/多源聚合）与书籍详情解析。',
           seg(425, 832))

write_part('book_service_chapter_list.dart',
           '职责：章节列表获取（分页加载、智能降级解析、持久化）。',
           seg(833, 2332))

write_part('book_service_update.dart',
           '职责：书架目录更新、按 URL/书名添加书籍、导入书单。',
           seg(2333, 2604))

write_part('book_service_content.dart',
           '职责：章节正文获取（规则解析、分页拼接、本地缓存与并发去重）。',
           seg(2605, 3144))

write_part('book_service_storage.dart',
           '职责：书籍/章节数据库读写、模型与 DB 行双向映射、字数统计与本地路径维护。',
           seg(3145, 3591))

print('parts written OK')

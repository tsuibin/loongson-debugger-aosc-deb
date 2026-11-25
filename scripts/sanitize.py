#!/usr/bin/env python3
"""替换 loongson-debugger 包内残留的个人路径/内网地址。

原始敏感字符串以 base64 存放，避免在本仓库中明文出现。
"""
import base64
import os
import sys

ROOT = sys.argv[1]

# base64 解码后的原值仅在运行时存在，不写入仓库文本。
_PATTERNS = [
    ("L2hvbWUvcWlhb2Nob25nL2xhMjAvYmluLw==", "/path/to/toolchain/bin/"),
    ("L2hvbWUvcWlhb2Nob25nL2xhMTAvYmluLw==", "/path/to/toolchain/bin/"),
    ("L2hvbWUvcWlhb2Nob25nL3Vzci9saWIvZGVidWc=", "/path/to/debug"),
    ("MTkyLjE2OC4xMjIuMTovdG1wL2VqdGFnLWRlYnVnMQ==", "<NFS_HOST>:/path/to/ejtag"),
]
REPLACEMENTS = [(base64.b64decode(k).decode(), v) for k, v in _PATTERNS]

changed = []
for dirpath, _dirs, files in os.walk(ROOT):
    for name in files:
        path = os.path.join(dirpath, name)
        try:
            with open(path, encoding="utf-8") as f:
                text = f.read()
        except (UnicodeDecodeError, OSError):
            continue
        new = text
        for old, replacement in REPLACEMENTS:
            new = new.replace(old, replacement)
        if new != text:
            with open(path, "w", encoding="utf-8") as f:
                f.write(new)
            changed.append(os.path.relpath(path, ROOT))

if changed:
    print("已脱敏：")
    for p in changed:
        print("  " + p)
else:
    print("未发现需要脱敏的内容")

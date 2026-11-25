#!/bin/bash
# 把 LoongArch ABI 2.0 的 loongson-debugger 压缩包打包成 AOSC loongarch64 deb。
# 全程不需要 root；dpkg-deb --root-owner-group 会把归档内属主设为 root:root。
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${1:?用法: sh scripts/build-deb.sh /path/to/source-archive}"
OUT="$HERE/output"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

[ -f "$SRC" ] || { echo "找不到源码包：$SRC" >&2; exit 1; }
mkdir -p "$OUT" "$WORK/sanitized" "$WORK/stage/DEBIAN" \
         "$WORK/stage/opt/loongson-debugger" "$WORK/stage/usr/bin" \
         "$WORK/stage/usr/share/doc/loongson-debugger"

echo "[1/5] 解包并脱敏"
tar -xJf "$SRC" --strip-components=1 -C "$WORK/sanitized"
python3 "$HERE/scripts/sanitize.py" "$WORK/sanitized"

echo "[2/5] 部署到 /opt/loongson-debugger"
cp -a "$WORK/sanitized/." "$WORK/stage/opt/loongson-debugger/"

echo "[3/5] 建立 /usr/bin 符号链接"
for f in "$WORK/stage/opt/loongson-debugger"/{la_dbg_tool,la32_dbg_tool,ejtag_debug}_{usb,pp,gpio,cgpio}; do
    [ -f "$f" ] || continue
    ln -sfn "../../opt/loongson-debugger/$(basename "$f")" \
        "$WORK/stage/usr/bin/$(basename "$f")"
done

echo "[4/5] 写入控制信息与文档"
cat > "$WORK/stage/DEBIAN/control" <<'EOF'
Package: loongson-debugger
Version: 1.0-1
Section: devel
Priority: optional
Architecture: loongarch64
Maintainer: LoongFans Community <loongfans@example.invalid>
Depends: python-3, perl, binutils
Homepage: https://www.loongson.cn
Description: Loongson EJTAG debugger host tools (LoongArch native)
 Self-contained host tools for Loongson EJTAG/Loongson-debugger hardware:
 la_dbg_tool_usb, la32_dbg_tool_usb and ejtag_debug_usb, together with
 board configs and helper scripts. Built from the LoongArch ABI 2.0
 (new-world, OBJ-v1) upstream release and packaged for AOSC.
 The binaries are statically linked; no extra cross toolchain is needed
 for the host tools. Target firmware images under bin/mipsbin are data,
 not host executables.
EOF
cp "$HERE/README.md" "$WORK/stage/usr/share/doc/loongson-debugger/README.md"

echo "[5/5] 构建 deb"
DEB="$OUT/loongson-debugger_1.0-1_loongarch64.deb"
dpkg-deb --build --root-owner-group "$WORK/stage" "$DEB" >/dev/null
echo "产物：$DEB"
dpkg-deb -I "$DEB" | sed -n '1,20p'

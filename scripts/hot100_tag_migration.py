from __future__ import annotations

from pathlib import Path


HOT100_DIR = Path(r"D:\Notes\20_代码范式\Hot100")

ENCODINGS = ("utf-8-sig", "utf-8", "gb18030")


def decode_with_fallback(data: bytes) -> tuple[str, str]:
    for enc in ENCODINGS:
        try:
            return data.decode(enc), enc
        except UnicodeDecodeError:
            continue
    raise UnicodeDecodeError("decode", b"", 0, 1, "unsupported encoding")


def normalize_lines(text: str) -> str:
    category_map = {
        "#leetcode100/linked-list": "#leetcode100/链表",
        "#leetcode100/binary-tree": "#leetcode100/二叉树",
        "#leetcode100/hash": "#leetcode100/哈希",
    }

    out: list[str] = []
    for line in text.splitlines(keepends=True):
        stripped = line.rstrip("\r\n")
        eol = line[len(stripped) :]

        if stripped in category_map:
            out.append(category_map[stripped] + eol)
            continue

        if stripped.startswith("难度："):
            value = stripped.split("：", 1)[1].strip()
            out.append(f"#难度/{value}{eol}")
            continue

        if stripped.startswith("是否独立完成："):
            value = stripped.split("：", 1)[1].strip()
            out.append(f"#是否独立完成/{value}{eol}")
            continue

        out.append(line)

    return "".join(out)


def main() -> None:
    files = sorted(HOT100_DIR.glob("*.md"))
    changed = 0

    for path in files:
        raw = path.read_bytes()
        text, enc = decode_with_fallback(raw)
        updated = normalize_lines(text)
        if updated == text:
            continue

        if enc == "utf-8-sig" and raw.startswith(b"\xef\xbb\xbf"):
            path.write_bytes(updated.encode("utf-8-sig"))
        else:
            path.write_bytes(updated.encode(enc))
        changed += 1

    print(f"processed={len(files)} changed={changed}")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
import os
import pathlib
import re
import sys


PATTERN = re.compile(r"\$\{([A-Z0-9_]+)\}")


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: render_template.py <src> <dest>", file=sys.stderr)
        return 2

    src = pathlib.Path(sys.argv[1])
    dest = pathlib.Path(sys.argv[2])
    text = src.read_text(encoding="utf-8")

    missing = sorted({name for name in PATTERN.findall(text) if name not in os.environ})
    if missing:
      print("missing env vars: " + ", ".join(missing), file=sys.stderr)
      return 1

    rendered = PATTERN.sub(lambda m: os.environ[m.group(1)], text)
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(rendered, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


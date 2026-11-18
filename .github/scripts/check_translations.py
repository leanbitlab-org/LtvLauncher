#!/usr/bin/env python3
"""
Translation validation script for FLauncher / LTvLauncher.
Checks all lib/l10n/app_*.arb files against lib/l10n/app_en.arb for:
1. Missing translation keys.
2. Dangling / extra keys not in app_en.arb.
3. Untranslated texts (identical to English where translation is expected).
4. Unused keys: app_en.arb keys never referenced as `.key` in lib/ Dart code.

Can be run manually or as a git hook (pre-commit, pre-push, pre-tag).
Usage:
    python3 tool/check_translations.py
"""

import sys
import os
import json
import glob
import re

# Words/phrases legitimately identical to English in certain languages (loanwords, units, symbols, brand names)
ALLOWED_IDENTICAL = {
    "celsius": {"Celsius (°C)"},
    "fahrenheit": {"Fahrenheit (°F)"},
    "layout": {"Layout"},
    "manual": {"Manual"},
    "system": {"System"},
    "interface": {"Interface"},
    "applications": {"Applications"},
    "notifications": {"Notifications"},
    "launcherSections": {"Sections"},
    "ok": {"OK"},
    "hindi": {"Hindi"},
    "name": {"Name"},
    "date": {"Date"},
    "type": {"Type"},
}

def main():
    root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    l10n_dir = os.path.join(root, "lib", "l10n")
    en_path = os.path.join(l10n_dir, "app_en.arb")

    if not os.path.exists(en_path):
        print(f"Error: Template file not found: {en_path}", file=sys.stderr)
        return 1

    with open(en_path, "r", encoding="utf-8") as f:
        en_data = json.load(f)

    en_keys = {k for k in en_data if not k.startswith("@")}
    arb_files = sorted(glob.glob(os.path.join(l10n_dir, "app_*.arb")))
    arb_files = [f for f in arb_files if not f.endswith("app_en.arb")]

    errors = []
    warnings = []
    checked_locales = 0

    for fpath in arb_files:
        locale = os.path.basename(fpath).replace("app_", "").replace(".arb", "")
        checked_locales += 1

        try:
            with open(fpath, "r", encoding="utf-8") as f:
                data = json.load(f)
        except Exception as e:
            errors.append(f"[{locale}] Failed to parse JSON: {e}")
            continue

        locale_keys = {k for k in data if not k.startswith("@")}

        missing = sorted(en_keys - locale_keys)
        if missing:
            errors.append(f"[{locale}] Missing {len(missing)} keys:\n  " + "\n  ".join(missing))

        extra = sorted(locale_keys - en_keys)
        if extra:
            errors.append(f"[{locale}] Extra {len(extra)} keys not in app_en.arb:\n  " + "\n  ".join(extra))

        # Check for untranslated text
        for k in locale_keys:
            if k in en_data:
                val = data[k]
                en_val = en_data[k]
                # If exact string match to English and not in allowlist
                if val == en_val and len(val.strip()) > 3:
                    if k in ALLOWED_IDENTICAL and val in ALLOWED_IDENTICAL[k]:
                        continue
                    if val.startswith("LTvLauncher") or "LTvLauncher" in val:
                        continue
                    warnings.append(f"[{locale}] Possible untranslated key '{k}': \"{val}\" matches English")

    # Unused keys: every key must be read somewhere in lib/ (generated l10n excluded).
    dart_src = []
    for dpath in glob.glob(os.path.join(root, "lib", "**", "*.dart"), recursive=True):
        if os.path.commonpath([dpath, l10n_dir]) == l10n_dir:
            continue
        with open(dpath, "r", encoding="utf-8") as f:
            dart_src.append(f.read())
    used = set(re.findall(r"\.([A-Za-z_]\w*)", "\n".join(dart_src)))
    unused = sorted(en_keys - used)
    if unused:
        errors.append(f"[en] Unused {len(unused)} keys (remove them from every .arb):\n  " + "\n  ".join(unused))

    print(f"Checked {checked_locales} localization files against app_en.arb ({len(en_keys)} keys each).")

    if warnings:
        print(f"\nPotential untranslated strings ({len(warnings)}):")
        for w in warnings:
            print(f"  * {w}")

    if errors:
        print(f"\nErrors found ({len(errors)}):", file=sys.stderr)
        for err in errors:
            print(f"  * {err}", file=sys.stderr)
        return 1

    print("\nAll localization files have complete keys!")
    return 0

if __name__ == "__main__":
    sys.exit(main())

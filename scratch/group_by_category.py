import re
import json

with open(r"c:\Users\Damien\Desktop\dev\dart\listeo\lib\models\unit.dart", "r", encoding="utf-8") as f:
    content = f.read()

match = re.search(r"const Map<String, String> kProductCategories = \{(.*?)\};", content, re.DOTALL)
if match:
    entries_text = match.group(1)
    # Extract entries: 'key': 'value'
    entries = re.findall(r"'(.*?)'\s*:\s*'(.*?)'", entries_text)
    
    # Group by category
    by_cat = {}
    for k, cat in entries:
        by_cat.setdefault(cat, []).append(k)
        
    for cat, items in by_cat.items():
        print(f"\n--- {cat} ({len(items)} items) ---")
        print(", ".join(sorted(items)[:40]))
        if len(items) > 40:
            print(f"... and {len(items) - 40} more")
else:
    print("Not found")

import re
import json

with open(r"c:\Users\Damien\Desktop\dev\dart\listeo\lib\models\unit.dart", "r", encoding="utf-8") as f:
    content = f.read()

match = re.search(r"const Map<String, String> kProductCategories = \{(.*?)\};", content, re.DOTALL)
if match:
    entries_text = match.group(1)
    keys = sorted(list(set(re.findall(r"'(.*?)'\s*:", entries_text))))
    with open("scratch_keys.json", "w", encoding="utf-8") as f_out:
        json.dump(keys, f_out, indent=2, ensure_ascii=False)
    print(f"Wrote {len(keys)} keys to scratch_keys.json")
else:
    print("Not found")

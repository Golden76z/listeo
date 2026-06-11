import re

# Read unit.dart to extract keys from kProductCategories
with open(r"c:\Users\Damien\Desktop\dev\dart\listeo\lib\models\unit.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Match entries in kProductCategories = { ... };
match = re.search(r"const Map<String, String> kProductCategories = \{(.*?)\};", content, re.DOTALL)
if match:
    entries_text = match.group(1)
    # Extract all keys: 'key': 'value'
    keys = re.findall(r"'(.*?)'\s*:", entries_text)
    print(f"Total keys: {len(keys)}")
    for k in sorted(keys)[:100]:
        print(k)
else:
    print("kProductCategories not found")

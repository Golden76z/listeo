import json

with open("catalog_translations.json", "r", encoding="utf-8") as f:
    trans = json.load(f)

# Sort keys for nice output
sorted_trans = sorted(trans.items())

dart_code = """// Generated catalog translations. Do not edit directly.

const Map<String, String> kCatalogTranslations = {
"""

for k, v in sorted_trans:
    # Escape single quotes
    k_esc = k.replace("'", "\\'")
    v_esc = v.replace("'", "\\'")
    dart_code += f"  '{k_esc}': '{v_esc}',\n"

dart_code += "};\n"

with open(r"c:\Users\Damien\Desktop\dev\dart\listeo\lib\data\catalog_translations.dart", "w", encoding="utf-8") as f_out:
    f_out.write(dart_code)

print("Successfully generated lib/data/catalog_translations.dart")

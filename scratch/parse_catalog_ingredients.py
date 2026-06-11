import re
import json

with open(r"c:\Users\Damien\Desktop\dev\dart\listeo\lib\data\catalog.dart", "r", encoding="utf-8") as f:
    content = f.read()

# CatalogIngredient(nameFr: 'Spaghetti', nameEn: 'Spaghetti', qty: 400, unit: 'g')
# We can match nameFr: and nameEn: values
# Let's extract all CatalogIngredient contents
matches = re.findall(r"CatalogIngredient\((.*?)\)", content, re.DOTALL)
print(f"Found {len(matches)} CatalogIngredient instances")

name_frs = set()
name_ens = set()

for m in matches:
    # Extract nameFr
    fr_match = re.search(r"nameFr\s*:\s*'(.*?)'(?:\s*,|\s*\))", m)
    if not fr_match:
        # try double quotes
        fr_match = re.search(r'nameFr\s*:\s*"(.*?)"(?:\s*,|\s*\))', m)
        
    en_match = re.search(r"nameEn\s*:\s*'(.*?)'(?:\s*,|\s*\))", m)
    if not en_match:
        en_match = re.search(r'nameEn\s*:\s*"(.*?)"(?:\s*,|\s*\))', m)
        
    if fr_match and en_match:
        name_frs.add(fr_match.group(1).replace("\\'", "'").strip().lower())
        name_ens.add(en_match.group(1).replace("\\'", "'").strip().lower())

print(f"Extracted {len(name_frs)} French ingredients and {len(name_ens)} English ingredients")
print("Sample French:")
print(list(name_frs)[:10])
print("Sample English:")
print(list(name_ens)[:10])

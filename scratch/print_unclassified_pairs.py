import json

with open("scratch_keys.json", "r", encoding="utf-8") as f:
    keys = json.load(f)

with open("catalog_translations.json", "r", encoding="utf-8") as f:
    trans = json.load(f)

# Let's see which keys are not yet resolved.
# We'll run the same classification logic as classify_all.py to find unclassified keys.
import re

with open(r"c:\Users\Damien\Desktop\dev\dart\listeo\lib\data\catalog.dart", "r", encoding="utf-8") as f:
    catalog_content = f.read()

name_frs = set(re.findall(r"nameFr\s*:\s*'([^']+)'", catalog_content))
name_ens = set(re.findall(r"nameEn\s*:\s*'([^']+)'", catalog_content))
name_frs_lower = {n.lower().strip() for n in name_frs}
name_ens_lower = {n.lower().strip() for n in name_ens}

french_keys = set()
english_keys = set()

fr_words = {"de", "la", "le", "les", "du", "au", "aux", "à", "surgelé", "surgelée", "frais", "fraîche", "râpé", "râpée", "blanc", "noire", "noires", "vert", "verts", "rouge", "rouges", "jaune", "jaunes", "blé", "entier", "moulu", "d'ail", "d'olive", "d'amande", "d'avoine", "de coco", "de soja", "de porc", "de boeuf", "de bœuf", "de volaille", "en boîte", "lave-vaisselle", "lave-linge", "lèvres"}
en_words = {"and", "oil", "juice", "sauce", "powder", "cream", "whole", "sliced", "butter", "chips", "beans", "broth", "clove", "cloves", "breast", "shredded", "canned", "frozen", "litter", "wipes", "softener", "cleaner", "soap", "sanitizer", "swabs", "pads", "swab", "pad", "detergent", "pods", "foil", "wrap", "bags", "bag", "paper", "towels", "towel", "tablet", "tablets", "remover"}

unclassified = set()

for k in keys:
    k_lower = k.lower().strip()
    if k_lower in name_frs_lower and k_lower not in name_ens_lower:
        french_keys.add(k)
    elif k_lower in name_ens_lower and k_lower not in name_frs_lower:
        english_keys.add(k)
    elif any(c in k_lower for c in "éèàçùâêîôûëïü"):
        french_keys.add(k)
    elif any(w in fr_words for w in k_lower.split()):
        french_keys.add(k)
    elif any(w in en_words for w in k_lower.split()):
        english_keys.add(k)
    else:
        unclassified.add(k)

# Propagate
for _ in range(5):
    for k in list(unclassified):
        k_lower = k.lower().strip()
        val = trans.get(k_lower)
        if val:
            val_lower = val.lower().strip()
            is_val_fr = any(fk.lower().strip() == val_lower for fk in french_keys)
            is_val_en = any(ek.lower().strip() == val_lower for ek in english_keys)
            if is_val_fr:
                english_keys.add(k)
                unclassified.discard(k)
            elif is_val_en:
                french_keys.add(k)
                unclassified.discard(k)

# Let's print the pairs of remaining unclassified keys
pairs = []
seen = set()
for k in unclassified:
    if k in seen:
        continue
    val = trans.get(k.lower().strip())
    if val:
        # Find the original key that matches val
        matching_key = None
        for k2 in unclassified:
            if k2.lower().strip() == val:
                matching_key = k2
                break
        if matching_key:
            pairs.append((k, matching_key))
            seen.add(k)
            seen.add(matching_key)
        else:
            pairs.append((k, None))
            seen.add(k)
    else:
        pairs.append((k, None))
        seen.add(k)

print(f"Remaining pairs to classify: {len(pairs)}")
for p in pairs:
    print(f"  {p[0]}  <->  {p[1]}")

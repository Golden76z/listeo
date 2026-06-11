import json
import re

# Load all 646 keys from scratch_keys.json
with open("scratch_keys.json", "r", encoding="utf-8") as f:
    keys = json.load(f)

# Load catalog_translations.json
with open("catalog_translations.json", "r", encoding="utf-8") as f:
    trans = json.load(f)

# Parse lib/data/catalog.dart for nameFr and nameEn ingredients
with open(r"c:\Users\Damien\Desktop\dev\dart\listeo\lib\data\catalog.dart", "r", encoding="utf-8") as f:
    catalog_content = f.read()

# Find all ingredient names in catalog.dart
# e.g., nameFr: 'Spaghetti', nameEn: 'Spaghetti'
name_frs = set(re.findall(r"nameFr\s*:\s*'([^']+)'", catalog_content))
name_ens = set(re.findall(r"nameEn\s*:\s*'([^']+)'", catalog_content))

# Lowercase for matching
name_frs_lower = {n.lower().strip() for n in name_frs}
name_ens_lower = {n.lower().strip() for n in name_ens}

french_keys = set()
english_keys = set()

# Also classify based on accents and French/English stop words
fr_words = {"de", "la", "le", "les", "du", "au", "aux", "à", "surgelé", "surgelée", "frais", "fraîche", "râpé", "râpée", "blanc", "noire", "noires", "vert", "verts", "rouge", "rouges", "jaune", "jaunes", "blé", "entier", "moulu", "d'ail", "d'olive", "d'amande", "d'avoine", "de coco", "de soja", "de porc", "de boeuf", "de bœuf", "de volaille", "en boîte", "lave-vaisselle", "lave-linge", "lèvres"}
en_words = {"and", "oil", "juice", "sauce", "powder", "cream", "whole", "sliced", "butter", "chips", "beans", "broth", "clove", "cloves", "breast", "shredded", "canned", "frozen", "litter", "wipes", "softener", "cleaner", "soap", "sanitizer", "swabs", "pads", "swab", "pad", "detergent", "pods", "foil", "wrap", "bags", "bag", "paper", "towels", "towel", "tablet", "tablets", "remover"}

unclassified = []

for k in keys:
    k_lower = k.lower().strip()
    
    # 1. Ground truth from catalog
    if k_lower in name_frs_lower and k_lower not in name_ens_lower:
        french_keys.add(k)
        continue
    elif k_lower in name_ens_lower and k_lower not in name_frs_lower:
        english_keys.add(k)
        continue
        
    # 2. Check translation values
    val = trans.get(k_lower)
    if val:
        val_lower = val.lower().strip()
        if val_lower in name_frs_lower:
            # val is French, so k is English
            english_keys.add(k)
            continue
        elif val_lower in name_ens_lower:
            # val is English, so k is French
            french_keys.add(k)
            continue

    # 3. Check accents
    if any(c in k_lower for c in "éèàçùâêîôûëïü"):
        french_keys.add(k)
        continue
        
    # 4. Check stop words
    words = k_lower.split()
    if any(w in fr_words for w in words):
        french_keys.add(k)
    elif any(w in en_words for w in words):
        english_keys.add(k)
    else:
        unclassified.append(k)

# For unclassified, check if they map to something that is classified
for k in list(unclassified):
    k_lower = k.lower().strip()
    val = trans.get(k_lower)
    if val:
        val_lower = val.lower().strip()
        # Find if val is in french_keys or english_keys
        is_val_fr = any(fk.lower().strip() == val_lower for fk in french_keys)
        is_val_en = any(ek.lower().strip() == val_lower for ek in english_keys)
        if is_val_fr:
            english_keys.add(k)
            unclassified.remove(k)
        elif is_val_en:
            french_keys.add(k)
            unclassified.remove(k)

print(f"Initially classified: French={len(french_keys)}, English={len(english_keys)}")
print(f"Still unclassified ({len(unclassified)}):")
print(", ".join(unclassified))

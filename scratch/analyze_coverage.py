import json

# Load kProductCategories keys
with open("scratch_keys.json", "r", encoding="utf-8") as f:
    keys = json.load(f)

# Let's see some keys that might be French or English
# We can distinguish French from English using a simple heuristic first
# E.g. common French words: "de", "la", "le", "les", "du", "au", "aux", "à", "surgelé", "surgelée", "frais", "fraîche"
# Or just common English words: "and", "oil", "juice", "sauce", "powder", "cream", "whole", "sliced", "butter"

french_indicators = ["de", "la", "le", "les", "du", "au", "aux", "à", "surgelé", "surgelée", "frais", "fraîche", "râpé", "râpée", "blanc", "noire", "noires", "vert", "verts", "rouge", "rouges", "jaune", "jaunes", "blé", "entier", "moulu", "d'ail", "d'olive", "d'amande", "d'avoine", "de coco", "de soja", "de porc", "de boeuf", "de bœuf", "de volaille", "en boîte", "lave-vaisselle", "lave-linge", "lèvres"]

english_indicators = ["and", "oil", "juice", "sauce", "powder", "cream", "whole", "sliced", "butter", "chips", "beans", "broth", "clove", "cloves", "breast", "shredded", "canned", "frozen", "litter", "wipes", "softener", "cleaner", "soap", "sanitizer", "swabs", "pads", "swab", "pad", "detergent", "pods", "foil", "wrap", "bags", "bag", "paper", "towels", "towel", "tablet", "tablets", "remover"]

fr_keys = []
en_keys = []
unclassified = []

for k in keys:
    # Check if in manualIngs (from store.dart) or has indicators
    is_fr = False
    is_en = False
    
    # Simple check
    words = k.lower().split()
    if any(w in french_indicators for w in words) or any(c in k for c in "éèàçùâêîôûëïü"):
        is_fr = True
    elif any(w in english_indicators for w in words):
        is_en = True
        
    if is_fr and not is_en:
        fr_keys.append(k)
    elif is_en and not is_fr:
        en_keys.append(k)
    else:
        unclassified.append(k)

print(f"French keys (heuristics): {len(fr_keys)}")
print(f"English keys (heuristics): {len(en_keys)}")
print(f"Unclassified: {len(unclassified)}")
print("\nUnclassified sample:")
print(", ".join(unclassified[:100]))

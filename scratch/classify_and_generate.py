import json
import re

with open("scratch_keys.json", "r", encoding="utf-8") as f:
    keys = json.load(f)

with open("catalog_translations.json", "r", encoding="utf-8") as f:
    trans = json.load(f)

# Build normalized translation dictionary (replace \' with ')
norm_trans = {}
for k, v in trans.items():
    k_norm = k.replace("\\'", "'").strip().lower()
    v_norm = v.replace("\\'", "'").strip().lower()
    norm_trans[k_norm] = v_norm

french_keys = set()
english_keys = set()

# French indicators
fr_indicators = [
    "de", "la", "le", "les", "du", "au", "aux", "à", "surgelé", "surgelée", "frais", "fraîche", "râpé", "râpée",
    "blanc", "noire", "noires", "vert", "verts", "rouge", "rouges", "jaune", "jaunes", "blé", "entier", "moulu",
    "d'ail", "d'olive", "d'amande", "d'avoine", "de coco", "de soja", "de porc", "de boeuf", "de bœuf", "de volaille",
    "en boîte", "lave-vaisselle", "lave-linge", "lèvres", "jus", "lait", "pain", "confiture", "pomme", "poisson",
    "viande", "eau", "crème", "fromage", "chou", "riz", "pâtes", "sel", "poivre", "huile", "légumes", "fruits",
    "vaisselle", "lessive", "nettoyant", "croquettes", "pâtée", "couches", "lingettes", "coton", "tampons",
    "serviettes", "adoucissant", "détartrant", "abricot", "agneau", "allumettes", "amandes", "avocat", "baguette",
    "banane", "beurre", "biscottes", "bonbons", "cabillaud", "canard", "cannelle", "cerises", "chiffon", "chocolat",
    "cidre", "colin", "couches", "courge", "courgette", "croissant", "dentifrice", "dinde", "doliprane", "fraise",
    "framboises", "frites", "gel", "jambon", "limonade", "mangue", "mouchoirs", "myrtilles", "noisettes",
    "pansements", "paprika", "poire", "poireau", "poireaux", "potimarron", "poulet", "radis", "rasoir", "rasoirs",
    "saumon", "savon", "shampoing", "shampooing", "sucre", "tomate", "yaourt", "yaourts",
    "ananas", "asperges", "avocats", "basilic", "biscuits", "boulghour", "champignons", "coca", "epices", "tofu ferme",
    "persil plat", "menthe", "nouilles", "persil", "pesto alla genovese", "pesto rosso", "piles", "porc", "portobellos",
    "saucisses", "coquilles taco", "vin", "houmous", "pains burger"
]

# English indicators
en_indicators = [
    "and", "oil", "juice", "sauce", "powder", "cream", "whole", "sliced", "butter", "chips", "beans", "broth",
    "clove", "cloves", "breast", "shredded", "canned", "frozen", "litter", "wipes", "softener", "cleaner", "soap",
    "sanitizer", "swabs", "pads", "swab", "pad", "detergent", "pods", "foil", "wrap", "bags", "bag", "paper",
    "towels", "towel", "tablet", "tablets", "remover", "muffin", "cookie", "bread", "water", "wine", "beer",
    "cider", "tea", "coffee", "juice", "soda", "sparkling", "lamb", "beef", "pork", "chicken", "turkey", "fish",
    "salmon", "cod", "hake", "tuna", "anchovies", "shrimp", "ham", "bacon", "prosciutto", "cheese", "yogurt",
    "egg", "eggs", "butter", "greek", "sour", "heavy", "grated", "spread", "pie", "crust", "puff", "pastry",
    "rolled", "oats", "oatmeal", "cereal", "flour", "sugar", "yeast", "baking", "powder", "salt", "pepper",
    "mustard", "ketchup", "mayonnaise", "vinegar", "oil", "spices", "herb", "herbs", "bouillon", "broth",
    "extract", "chips", "candies", "candy", "chocolate", "jam", "honey", "syrup", "rice", "pasta", "noodles",
    "spaghetti", "macaroni", "couscous", "quinoa", "lentils", "chickpeas", "beans", "peas", "vegetables",
    "fruit", "fruits", "apple", "apples", "banana", "bananas", "orange", "oranges", "pear", "pears", "grapefruit",
    "lemon", "lemons", "lime", "limes", "melon", "melons", "watermelon", "peach", "peaches", "apricot", "apricots",
    "cherry", "cherries", "strawberry", "strawberries", "raspberry", "raspberries", "blueberry", "blueberries",
    "blackberry", "blackberries", "avocado", "avocados", "tomato", "tomatoes", "cucumber", "cucumbers",
    "zucchini", "zucchinis", "eggplant", "eggplants", "pepper", "peppers", "cabbage", "cauliflower", "broccoli",
    "spinach", "lettuce", "salad", "carrot", "carrots", "leek", "leeks", "onion", "onions", "garlic", "ginger",
    "potato", "potatoes", "sweet", "pumpkin", "butternut", "squash", "matches", "toothpaste", "shampoo",
    "french", "fries", "blueberries", "oat", "diapers", "painkillers", "apricot", "radishes", "muffins",
    "hazelnuts", "razors", "razor", "turkey", "baguette", "croissants", "croissant", "savon",
    "pineapple", "asparagus", "avocados", "basil", "cookies", "bulgur", "burger buns", "mushrooms", "cola",
    "coca-cola", "spices", "firm tofu", "flat-leaf parsley", "fresh mint", "green pesto", "hummus", "mint",
    "noodles", "parsley", "batteries", "portobello mushrooms", "red pesto", "sausages", "taco shells", "tortillas", "wine",
    "burger buns", "firm tofu", "green pesto", "red pesto"
]

identical_words = {
    "kiwi", "orange", "pancakes", "ricotta", "spaghetti", "amaretto", "cheddar", "roquefort", "cumin", "origan",
    "melon", "soda", "emmental", "mayonnaise", "sardines", "margarine", "sorbet", "mozzarella di bufala",
    "garam masala", "olives", "muffins", "feta", "ketchup", "champagne", "steak", "muesli", "tempeh", "baguette",
    "polenta", "croissants", "kiwis", "croissant", "savon", "quinoa", "vinaigrette", "pancake", "portobello", "tortillas"
}

# Initial classification
for k in keys:
    k_clean = k.replace("\\'", "'").strip()
    k_lower = k_clean.lower()
    
    if k_lower in identical_words:
        french_keys.add(k)
        english_keys.add(k)
        continue
        
    if any(c in k_lower for c in "éèàçùâêîôûëïü"):
        french_keys.add(k)
        continue

    words = k_lower.split()
    is_fr = any(w in fr_indicators for w in words) or k_lower in fr_indicators
    is_en = any(w in en_indicators for w in words) or k_lower in en_indicators
    
    if is_fr and not is_en:
        french_keys.add(k)
    elif is_en and not is_fr:
        english_keys.add(k)

# Propagation loop
changed = True
while changed:
    changed = False
    for k in keys:
        k_clean = k.replace("\\'", "'").strip()
        k_lower = k_clean.lower()
        val = norm_trans.get(k_lower)
        if val:
            # find original key for val
            val_orig = None
            for orig_key in keys:
                if orig_key.replace("\\'", "'").strip().lower() == val:
                    val_orig = orig_key
                    break
            
            if val_orig:
                # If k is French, then val_orig must be English
                if k in french_keys and val_orig not in english_keys:
                    english_keys.add(val_orig)
                    changed = True
                # If k is English, then val_orig must be French
                if k in english_keys and val_orig not in french_keys:
                    french_keys.add(val_orig)
                    changed = True
                # If val_orig is French, then k must be English
                if val_orig in french_keys and k not in english_keys:
                    english_keys.add(k)
                    changed = True
                # If val_orig is English, then k must be French
                if val_orig in english_keys and k not in french_keys:
                    french_keys.add(k)
                    changed = True

# Find remaining unclassified
unclassified = []
for k in keys:
    if k not in french_keys and k not in english_keys:
        unclassified.append(k)

print(f"Final Count: French={len(french_keys)}, English={len(english_keys)}")
print(f"Still unclassified: {len(unclassified)}")
if unclassified:
    print(", ".join(unclassified))
else:
    # Save to catalog_translations.dart as Dart sets
    sorted_fr = sorted(list(french_keys))
    sorted_en = sorted(list(english_keys))
    
    with open(r"c:\Users\Damien\Desktop\dev\dart\listeo\lib\data\catalog_translations.dart", "r", encoding="utf-8") as f_trans:
        dart_content = f_trans.read()
        
    new_sets = f"""
const Set<String> kFrenchCatalogKeys = {{
{chr(10).join(f"  '{k}'," for k in sorted_fr)}
}};

const Set<String> kEnglishCatalogKeys = {{
{chr(10).join(f"  '{k}'," for k in sorted_en)}
}};
"""
    
    # Remove existing sets if present
    if "const Set<String> kFrenchCatalogKeys" in dart_content:
        idx = dart_content.index("const Set<String> kFrenchCatalogKeys")
        dart_content = dart_content[:idx]
    
    updated_content = dart_content.strip() + "\n" + new_sets
    with open(r"c:\Users\Damien\Desktop\dev\dart\listeo\lib\data\catalog_translations.dart", "w", encoding="utf-8") as f_trans_out:
        f_trans_out.write(updated_content)
    print("Successfully updated catalog_translations.dart with kFrenchCatalogKeys and kEnglishCatalogKeys!")

with open(r'c:\Users\Damien\Desktop\dev\dart\listeo\lib\widgets\sheets.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if '_DatabaseItemsSheet' in line:
        print(f"Line {i+1}: {line.strip()}")

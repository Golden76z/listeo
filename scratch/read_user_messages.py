import json

with open(r'C:\Users\Damien\.gemini\antigravity\brain\23cb37ba-97d8-44e6-9f2a-4b18d629818f\.system_generated\logs\overview.txt', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for line in lines:
    try:
        data = json.loads(line)
        # Search for content / text / message or whatever represents the user prompt
        # Let's inspect the keys of data
        content = data.get('content', '') or ''
        parts = data.get('parts', [])
        parts_text = " ".join([str(p) for p in parts])
        total_text = content + " " + parts_text
        if 'first screen' in total_text.lower() or 'ajouter' in total_text.lower() or 'gap' in total_text.lower():
            print(f"Step {data.get('step_index')}: {data.get('source')} -> {total_text[:500]}")
    except Exception as e:
        pass

import json

with open(r'C:\Users\Damien\.gemini\antigravity\brain\23cb37ba-97d8-44e6-9f2a-4b18d629818f\.system_generated\logs\overview.txt', 'r', encoding='utf-8') as f:
    for line in f:
        try:
            data = json.loads(line)
            if data.get('type') == 'USER_INPUT':
                print(json.dumps(data, indent=2))
                print("-" * 50)
        except Exception as e:
            pass

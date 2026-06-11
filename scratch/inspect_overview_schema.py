import json

with open(r'C:\Users\Damien\.gemini\antigravity\brain\23cb37ba-97d8-44e6-9f2a-4b18d629818f\.system_generated\logs\overview.txt', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for line in lines:
    try:
        data = json.loads(line)
        if data.get('source') == 'USER_EXPLICIT' or data.get('type') == 'USER_INPUT':
            print(list(data.keys()))
            print(data)
            break
    except Exception as e:
        pass

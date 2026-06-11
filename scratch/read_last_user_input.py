import json

with open(r'C:\Users\Damien\.gemini\antigravity\brain\23cb37ba-97d8-44e6-9f2a-4b18d629818f\.system_generated\logs\overview.txt', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for line in reversed(lines):
    try:
        data = json.loads(line)
        if data.get('source') == 'USER_EXPLICIT' or data.get('type') == 'USER_INPUT':
            print(f"STEP {data.get('step_index')}: {json.dumps(data, indent=2)}")
            # print up to 5 inputs
            break
    except Exception as e:
        pass

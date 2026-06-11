with open(r'C:\Users\Damien\.gemini\antigravity\brain\23cb37ba-97d8-44e6-9f2a-4b18d629818f\.system_generated\logs\overview.txt', 'r', encoding='utf-8') as f:
    text = f.read()

import re
matches = [m.start() for m in re.finditer('first screen', text, re.IGNORECASE)]
for m in matches:
    print(text[m-200:m+500])
    print("-"*50)

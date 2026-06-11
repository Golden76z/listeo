import os

steps_dir = r'C:\Users\Damien\.gemini\antigravity\brain\23cb37ba-97d8-44e6-9f2a-4b18d629818f\.system_generated\steps'
for root, dirs, files in os.walk(steps_dir):
    for f in files:
        if f.endswith('.txt'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8', errors='ignore') as file:
                content = file.read()
                if 'removed' in content or 'Ajouter' in content or 'gap' in content:
                    print(f"File: {path}")
                    print(content[:500])
                    print("="*40)

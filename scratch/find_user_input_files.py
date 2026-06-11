import os

steps_dir = r'C:\Users\Damien\.gemini\antigravity\brain\23cb37ba-97d8-44e6-9f2a-4b18d629818f\.system_generated\steps'
for root, dirs, files in os.walk(steps_dir):
    for f in files:
        path = os.path.join(root, f)
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as file:
                content = file.read()
                if 'Ajouter' in content or 'gap' in content or 'First screen' in content:
                    print(f"Path: {path}")
                    print(content[:300])
                    print("-" * 50)
        except Exception:
            pass

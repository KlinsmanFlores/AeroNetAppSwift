import os
import re

view_dir = r"c:\Proyecto quinto ciclo\PROMOV\AeroNetAppSwift\AeroNetAppSwift\Views"

for root, _, files in os.walk(view_dir):
    for file in files:
        if file.endswith(".swift"):
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            
            # replace .task { await ... } with .onAppear { ... }
            content = re.sub(r'\.task\s*\{\s*await\s+([^\}]+)\}', r'.onAppear {\n            \1}', content)
            
            # replace Task { await ... } with ...
            content = re.sub(r'Task\s*\{\s*await\s+([^\}]+)\}', r'\1', content)
            
            # remove .refreshable { await ... }
            content = re.sub(r'\.refreshable\s*\{\s*await\s+[^\}]+\}', r'', content)
            
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)
print("Done")

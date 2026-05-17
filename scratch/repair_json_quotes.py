import os
import re

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
json_files = [f for f in os.listdir(data_dir) if f.endswith(".json")]

for filename in json_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Identify lines where a string was left open due to the \' replacement
    # Pattern: a quote, some text, then \' at the end of a line (where a quote should be)
    # We look for lines like: "key": "value\'
    # and change them to: "key": "value\\'"
    # Wait, if we want it to be valid JSON, it must be: "key": "value\\'" (if ' is the new Khai)
    # No, it should be: "key": "value\'"
    
    # The problem was that mpihemve\\" (backslash-quote) became mpihemve\' (backslash-singlequote)
    # AND the closing quote of the JSON was part of the \" that got replaced!
    
    # So we need to add the closing quote " back.
    # But only if it's actually missing.
    
    lines = content.splitlines()
    new_lines = []
    for line in lines:
        # If line ends with \' and is not a closed string
        # Heuristic: count quotes. If odd, it's open.
        if line.strip().endswith("\\'") and line.count('"') % 2 != 0:
            line = line + '"'
        new_lines.append(line)
    
    new_content = "\n".join(new_lines)
    
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Restored missing quotes in: {filename}")

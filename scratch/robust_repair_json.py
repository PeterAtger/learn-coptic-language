import os
import re

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
json_files = [f for f in os.listdir(data_dir) if f.endswith(".json")]

for filename in json_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    new_lines = []
    changed = False
    for line in lines:
        stripped = line.strip()
        # Count double quotes
        quote_count = line.count('"')
        
        # If quote count is odd, the string is likely open
        if quote_count % 2 != 0:
            # We need to find where the quote is missing.
            # Usually it's at the end of the string value.
            # Example: "key": "value\' or "key": "value\',
            
            if stripped.endswith(","):
                # "key": "value\', -> "key": "value\'",
                line = line.rstrip().rstrip(",") + '",' + "\n"
            else:
                # "key": "value\' -> "key": "value\'"
                line = line.rstrip() + '"' + "\n"
            changed = True
        new_lines.append(line)
    
    if changed:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
        print(f"Repaired missing quotes in: {filename}")

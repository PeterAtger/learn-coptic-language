import os
import re

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
json_files = [f for f in os.listdir(data_dir) if f.endswith(".json")]

for filename in json_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We want to replace escaped double quotes (\") with single quotes (')
    # These are the ones causing the "random Khai" because the font maps " to Khai.
    # Note: We already replaced Arabic quotes with « », so any remaining \" 
    # are likely Coptic letters or stray punctuation.
    
    # In the raw file, it's literal \"
    new_content = content.replace('\\"', "'")
    
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Replaced all \\\" with ' in: {filename}")
    else:
        print(f"No \\\" found in: {filename}")

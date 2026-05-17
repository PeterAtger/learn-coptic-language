import os
import re

# Directory containing the JSON files
data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"

# Regex pattern for Arabic Bible references in parentheses
# Matches things like (مز149), (مت1: 18), (يو 1: 25), (إش 6< 3), etc.
# [\u0621-\u064A] matches Arabic letters
pattern = re.compile(r' \([\u0621-\u064A]+ ?[0-9]+([:< ]+[0-9]+)*\)')

files_to_process = [
    "grammar_graduates.json",
    "grammar_servants.json",
    "grammar_servants_trainees.json",
    "grammar_uni.json",
    "grammar_prep.json",
    "grammar_sec.json",
    "grammar_primary34.json",
    "grammar_primary56.json",
    "grammar_qana.json",
    "grammar.json"
]

for filename in files_to_process:
    file_path = os.path.join(data_dir, filename)
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        continue
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = pattern.sub('', content)
    
    if content != new_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated: {filename}")
    else:
        print(f"No changes for: {filename}")

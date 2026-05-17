import os
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"

files_to_process = [
    "grammar_graduates.json",
    "grammar_servants.json",
    "grammar_servants_trainees.json",
    "grammar_uni.json"
]

for filename in files_to_process:
    file_path = os.path.join(data_dir, filename)
    if not os.path.exists(file_path):
        continue
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    if len(data) < 3:
        print(f"Skipping {filename}, doesn't have 3 levels.")
        continue
    
    intro = data[0]
    lvl1 = data[1]
    lvl2 = data[2]
    
    # Prepend lvl1 sections to lvl2 sections
    # Avoid duplicates if we already did it (though shouldn't have)
    lvl2['sections'] = lvl1['sections'] + lvl2['sections']
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Fixed Level 2 in: {filename}")

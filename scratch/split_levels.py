import os
import json

# Directory containing the JSON files
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
        print(f"File not found: {file_path}")
        continue
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # We expect 2 objects: intro and lvl1 (which currently contains lvl2 content)
    if len(data) < 2:
        print(f"File {filename} has unexpected structure.")
        continue
    
    intro = data[0]
    lvl1 = data[1]
    
    # Find the index where Level 2 starts
    # Level 2 starts with a note titled "زمن الحاضر الثالث اللامحدود"
    split_index = -1
    for i, section in enumerate(lvl1['sections']):
        if section.get('title') == "زمن الحاضر الثالث اللامحدود":
            split_index = i
            break
    
    if split_index != -1:
        # Create lvl2 object
        lvl2_id = lvl1['id'].replace('lvl1', 'lvl2')
        lvl2 = {
            "id": lvl2_id,
            "title": "المستوى الثاني",
            "stageIds": lvl1['stageIds'],
            "sections": lvl1['sections'][split_index:]
        }
        
        # Truncate lvl1 sections
        lvl1['sections'] = lvl1['sections'][:split_index]
        
        # Update the list
        new_data = [intro, lvl1, lvl2]
        
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(new_data, f, ensure_ascii=False, indent=2)
        print(f"Updated: {filename}")
    else:
        print(f"Could not find Level 2 start in: {filename}")

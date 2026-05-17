import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar") and f.endswith(".json")]

# Unicode Combining Grave Accent
COMBINING_JENKEM = '\u0300'

def apply_combining_jenkem(text):
    if not isinstance(text, str):
        return text
    
    # Clean up all previous attempts and standardize to backtick first
    text = text.replace('\u200E', '').replace('\u200F', '').replace('\u2066', '').replace('\u2069', '')
    text = text.replace('~', '`')
    
    # Regex to find: backtick + optional space + first letter + rest of word
    # Captures: 1. backtick, 2. optional space, 3. first letter, 4. rest of word
    pattern = r'(`)\s*([a-zA-Z;\[\]\\/=\':?_\-|])([a-zA-Z;\[\]\\/=\':?_\-|]*)'
    
    def replacer(match):
        first_letter = match.group(2)
        rest_of_word = match.group(3)
        # Place combining mark IMMEDIATELY after the first letter
        return first_letter + COMBINING_JENKEM + rest_of_word

    return re.sub(pattern, replacer, text)

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    def walk(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str):
                    obj[k] = apply_combining_jenkem(v)
                else:
                    walk(v)
        elif isinstance(obj, list):
            for i in range(len(obj)):
                if isinstance(obj[i], str):
                    obj[i] = apply_combining_jenkem(obj[i])
                else:
                    walk(obj[i])
    
    walk(data)
    
    # Level 2 duplication logic
    target_stages = ["graduates", "uni", "servants", "servants_trainees"]
    lvl1_section = None
    lvl2_exists = False
    
    # Check if we need to recreate lvl2 based on current state
    sections_to_add = []
    for section in data:
        if isinstance(section, dict):
            sid = section.get("id", "")
            if sid.endswith("-lvl1"):
                lvl1_section = section
            if sid.endswith("-lvl2"):
                lvl2_exists = True
                
    if lvl1_section and not lvl2_exists:
        is_target = any(stage in filename for stage in target_stages)
        if is_target:
            import copy
            lvl2_section = copy.deepcopy(lvl1_section)
            lvl2_section["id"] = lvl1_section["id"].replace("-lvl1", "-lvl2")
            lvl2_section["title"] = "المستوى الثاني"
            data.append(lvl2_section)

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Combining Jenkem applied to: {filename}")

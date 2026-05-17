import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar") and f.endswith(".json")]

# Left-to-Right Mark
LRM = '\u200E'

def fix_jenkem_final(text):
    if not isinstance(text, str):
        return text
    
    # Clean up all previous attempts
    text = text.replace('\u200E', '').replace('\u200F', '').replace('\u2066', '').replace('\u2069', '')
    text = text.replace('~', '`')
    
    # 1. Ensure any Jenkem at the end moves to the start
    # word` -> `word
    text = re.sub(r'([a-zA-Z;\[\]\\/=\':?_\-]+)`', r'`\1', text)
    
    # 2. Add LRM before Jenkem to force it to be the start of an LTR run
    # This prevents the Arabic text from "pulling" it to the right.
    text = text.replace('`', LRM + '`')
    
    return text

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    def walk(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str):
                    obj[k] = fix_jenkem_final(v)
                else:
                    walk(v)
        elif isinstance(obj, list):
            for i in range(len(obj)):
                if isinstance(obj[i], str):
                    obj[i] = fix_jenkem_final(obj[i])
                else:
                    walk(obj[i])
    
    walk(data)
    
    # Level 2 duplication logic
    target_stages = ["graduates", "uni", "servants", "servants_trainees"]
    lvl1_section = None
    lvl2_exists = False
    
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
    print(f"Final fix applied to: {filename}")

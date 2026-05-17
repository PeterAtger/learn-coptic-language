import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar") and f.endswith(".json")]

def move_jenkem_smart(text):
    if not isinstance(text, str):
        return text
    
    # Standardize: remove any previous marks and ensure we use backtick
    text = text.replace('\u200E', '').replace('\u200F', '').replace('\u2066', '').replace('\u2069', '')
    text = text.replace('~', '`')
    
    # Regex explanation:
    # Matches a backtick `
    # followed by optional spaces \s*
    # followed by a sequence of Coptic/Latin characters [a-zA-Z;\[\]\\/=\':?_\-]+
    # Captures the word part to move the backtick after it.
    pattern = r'`\s*([a-zA-Z;\[\]\\/=\':?_\-]+)'
    
    return re.sub(pattern, r'\1`', text)

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    def walk(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str):
                    obj[k] = move_jenkem_smart(v)
                else:
                    walk(v)
        elif isinstance(obj, list):
            for i in range(len(obj)):
                if isinstance(obj[i], str):
                    obj[i] = move_jenkem_smart(obj[i])
                else:
                    walk(obj[i])
    
    walk(data)
    
    # Create Level 2 if it doesn't exist (for specific files)
    # The user wants Level 2 in Graduates, Uni, Servants, Servants_trainees
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
        # Only add to target files
        is_target = any(stage in filename for stage in target_stages)
        if is_target:
            import copy
            lvl2_section = copy.deepcopy(lvl1_section)
            lvl2_section["id"] = lvl1_section["id"].replace("-lvl1", "-lvl2")
            lvl2_section["title"] = "المستوى الثاني"
            data.append(lvl2_section)
            print(f"Created Level 2 for: {filename}")

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Applied smart Jenkem relocation in: {filename}")

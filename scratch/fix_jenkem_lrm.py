import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar") and f.endswith(".json")]

# Left-to-Right Mark
LRM = '\u200E'

def apply_lrm_backtick(text):
    if not isinstance(text, str):
        return text
    
    # Clean up ALL previous marks (Combining marks, isolates, etc.)
    text = text.replace('\u200E', '').replace('\u200F', '').replace('\u2066', '').replace('\u2069', '')
    text = text.replace('\u0300', '') # Remove the failed combining mark
    text = text.replace('~', '`')
    
    # Pattern: match optional backtick at the end and move it to start if any
    text = re.sub(r'([a-zA-Z;\[\]\\/=\':?_\-|]+)`', r'`\1', text)
    
    # Pattern: find backtick and ensure it is preceded by LRM
    # We use a lambda to avoid double LRM if it was somehow already there
    def replacer(match):
        return LRM + '`'

    return text.replace('`', LRM + '`')

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    def walk(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str):
                    obj[k] = apply_lrm_backtick(v)
                else:
                    walk(v)
        elif isinstance(obj, list):
            for i in range(len(obj)):
                if isinstance(obj[i], str):
                    obj[i] = apply_lrm_backtick(obj[i])
                else:
                    walk(obj[i])
    
    walk(data)
    
    # Ensure Level 2 exists for target stages
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
    print(f"LRM+Backtick applied to: {filename}")

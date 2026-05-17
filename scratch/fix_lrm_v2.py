import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar") and f.endswith(".json")]

LRM = '\u200E'

def fix_lrm_correctly(text):
    if not isinstance(text, str):
        return text
    
    # 1. Clean everything
    text = text.replace('\u200E', '').replace('\u200F', '').replace('\u2066', '').replace('\u2069', '')
    
    # 2. Convert failed combining mark back to backtick at START
    # Find word with combining mark and move mark as backtick to start
    # e.g., J\u0300voi -> `Jvoi
    text = re.sub(r'([a-zA-Z;\[\]\\/=\':?_\-|]+)\u0300', r'`\1', text)
    # Handle if it was already J\u0300 (single char)
    text = text.replace('\u0300', '`') 
    
    # Standardize: make sure any backtick is followed by the word and preceded by LRM
    # First, move all backticks to start of words if they are at the end
    text = re.sub(r'([a-zA-Z;\[\]\\/=\':?_\-|]+)`', r'`\1', text)
    
    # Finally, apply LRM before every backtick
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
                    obj[k] = fix_lrm_correctly(v)
                else:
                    walk(v)
        elif isinstance(obj, list):
            for i in range(len(obj)):
                if isinstance(obj[i], str):
                    obj[i] = fix_lrm_correctly(obj[i])
                else:
                    walk(obj[i])
    
    walk(data)
    
    # Maintain Level 2
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
        if any(stage in filename for stage in target_stages):
            import copy
            lvl2_section = copy.deepcopy(lvl1_section)
            lvl2_section["id"] = lvl1_section["id"].replace("-lvl1", "-lvl2")
            lvl2_section["title"] = "المستوى الثاني"
            data.append(lvl2_section)

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Corrected LRM+Backtick in: {filename}")

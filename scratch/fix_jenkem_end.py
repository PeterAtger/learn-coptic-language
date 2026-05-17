import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar") and f.endswith(".json")]

def move_jenkem_to_end(text):
    if not isinstance(text, str):
        return text
    
    # Remove any isolation marks or tildes from previous attempts
    text = text.replace('\u200E', '').replace('\u200F', '').replace('\u2066', '').replace('\u2069', '')
    text = text.replace('~', '`')
    
    # Pattern: `word -> word`
    # This identifies a word starting with ` and ending with a Coptic/Latin letter
    # and moves the ` to the end.
    # In a BiDi RTL context, this should make the ` appear on the left visually.
    
    def replacer(match):
        jenkem = match.group(1) # `
        word = match.group(2)   # the rest of the word
        return word + jenkem

    # Matches ` followed by one or more Coptic/Latin characters (including common punctuation used in these words)
    pattern = r'(`)([a-zA-Z;\[\]\\/=\':?_\-]+)'
    
    return re.sub(pattern, replacer, text)

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    def walk(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str):
                    obj[k] = move_jenkem_to_end(v)
                else:
                    walk(v)
        elif isinstance(obj, list):
            for i in range(len(obj)):
                if isinstance(obj[i], str):
                    obj[i] = move_jenkem_to_end(obj[i])
                else:
                    walk(obj[i])
    
    walk(data)
    
    # After moving Jenkem, ensure "lvl2" sections are present for the requested stages
    # (uni, graduates, servants, servants_trainees)
    # We do this by checking if lvl1 exists and lvl2 doesn't, then duplicating lvl1 to lvl2.
    
    lvl1_section = None
    lvl2_exists = False
    
    # Search for lvl1 and lvl2 in the main list
    for section in data:
        if isinstance(section, dict):
            if section.get("id", "").endswith("-lvl1"):
                lvl1_section = section
            if section.get("id", "").endswith("-lvl2"):
                lvl2_exists = True
    
    if lvl1_section and not lvl2_exists:
        # Create a copy for Level 2
        import copy
        lvl2_section = copy.deepcopy(lvl1_section)
        lvl2_section["id"] = lvl1_section["id"].replace("-lvl1", "-lvl2")
        lvl2_section["title"] = "المستوى الثاني"
        # Level 2 is level 1 + extra. For now we just duplicate as a base.
        data.append(lvl2_section)
        print(f"Created Level 2 for: {filename}")

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Processed Jenkem at end in: {filename}")

import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar") and f.endswith(".json")]

LRM = '\u200E'

# List of common prefixes/words that should have a Jenkem in this context
# Based on Coptic grammar patterns in the provided files
words_needing_jenkem = [
    "Jvoi", "Vnou", "V", "Q", "P", "T", "cmou", "m\\au", "Qbaki", "Pxhroc", "Txhra", "avot", "avht", 
    "Viwt", "Viom", "mm", "er", "qri", "nnouj", "cwtem", "Na\\;", "Kim", "cmou", "cwtem", "nau",
    "K", "F", "C", "Nna", "Nnek", "Nne", "Nnef", "Nnec", "Nnen", "Nneten", "Nnou", "Xouwm", "Xna"
]

def restore_and_fix(text):
    if not isinstance(text, str):
        return text
    
    # 1. Clean all marks
    text = text.replace('\u200E', '').replace('\u200F', '').replace('\u2066', '').replace('\u2069', '')
    text = text.replace('\u0300', '').replace('~', '').replace('`', '')
    
    # 2. Restore Jenkem to words that need it
    # We look for these words at the start of a string or after a space/punctuation
    for word in words_needing_jenkem:
        # Pattern: Word preceded by start of string, space, or certain Arabic chars
        # and not already prefixed.
        # We use a case-insensitive match for the word
        pattern = r'(^|[\s\(\"\'\-]|[\u0600-\u06FF])(' + re.escape(word) + r')\b'
        
        def replacer(match):
            prefix = match.group(1)
            actual_word = match.group(2)
            # Add LRM + Backtick
            return prefix + LRM + '` ' + actual_word # Adding a space after Jenkem often helps visual rendering too

        text = re.sub(pattern, replacer, text, flags=re.IGNORECASE)

    # 3. Handle specific manual cases from the user's screenshots/messages
    # "تحول k إلى x"
    text = text.replace("تحول k إلى x", f"تحول {LRM}` k إلى {LRM}` x")
    text = text.replace("تتحول k إلى x", f"تتحول {LRM}` k إلى {LRM}` x")
    
    return text

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    def walk(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str):
                    obj[k] = restore_and_fix(v)
                else:
                    walk(v)
        elif isinstance(obj, list):
            for i in range(len(obj)):
                if isinstance(obj[i], str):
                    obj[i] = restore_and_fix(obj[i])
                else:
                    walk(obj[i])
    
    walk(data)
    
    # Re-apply Level 2 structure if missing
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
    print(f"Restored and fixed: {filename}")

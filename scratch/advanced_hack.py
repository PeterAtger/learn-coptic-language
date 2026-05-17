import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar") and f.endswith(".json")]

# The advanced hack characters
LRE = '\u202A'
ZWSP = '\u200B'
PDF = '\u202C'

# Words that need Jenkem
words_needing_jenkem = [
    "Jvoi", "Vnou", "V", "Q", "P", "T", "cmou", "m\\au", "Qbaki", "Pxhroc", "Txhra", "avot", "avht", 
    "Viwt", "Viom", "mm", "er", "qri", "nnouj", "cwtem", "Na\\;", "Kim", "cmou", "cwtem", "nau",
    "K", "F", "C", "Nna", "Nnek", "Nne", "Nnef", "Nnec", "Nnen", "Nneten", "Nnou", "Xouwm", "Xna"
]

def advanced_hack(text):
    if not isinstance(text, str):
        return text
    
    # 1. Clean all previous hacks (LRM, etc.)
    text = text.replace('\u200E', '').replace('\u200F', '').replace('\u2066', '').replace('\u2069', '')
    text = text.replace(LRE, '').replace(PDF, '').replace(ZWSP, '')
    text = text.replace('\u0300', '').replace('~', '').replace('`', '')
    
    # 2. Re-apply with the advanced hack
    # First, the specific sentence the user mentioned
    text = text.replace("تحول k إلى x", f"تحول {LRE}{ZWSP}`k{PDF} إلى {LRE}{ZWSP}`x{PDF}")
    text = text.replace("تتحول k إلى x", f"تتحول {LRE}{ZWSP}`k{PDF} إلى {LRE}{ZWSP}`x{PDF}")

    # General word restoration
    for word in words_needing_jenkem:
        pattern = r'(^|[\s\(\"\'\-]|[\u0600-\u06FF])(' + re.escape(word) + r')\b'
        
        def replacer(match):
            prefix = match.group(1)
            actual_word = match.group(2)
            # Apply LRE + ZWSP + ` + Word + PDF
            return prefix + LRE + ZWSP + '`' + actual_word + PDF

        text = re.sub(pattern, replacer, text, flags=re.IGNORECASE)

    # 3. Special case for standalone marks like ([ - f - ' - \ - j - s - ;)
    # Re-insert the backtick in the intro if it was wiped
    if "عبارة عن علامة مرسومة هكذا ( )" in text:
        text = text.replace("( )", "( ` )")
    
    return text

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    def walk(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str):
                    obj[k] = advanced_hack(v)
                else:
                    walk(v)
        elif isinstance(obj, list):
            for i in range(len(obj)):
                if isinstance(obj[i], str):
                    obj[i] = advanced_hack(obj[i])
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
    print(f"Advanced Hack applied to: {filename}")

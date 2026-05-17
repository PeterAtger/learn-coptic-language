import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar_") and f.endswith(".json")]

# LTR Mark to force correct directionality of the Jenkem
LTR_MARK = '\u200E'
arabic_range = r'\u0600-\u06FF'

def fix_jenkem_direction(text):
    # Only process strings containing Arabic to avoid affecting pure Coptic text
    if not re.search(f'[{arabic_range}]', text):
        return text
    
    # We are looking for Coptic words where the Jenkem was moved to the end: [word]`
    # and moving it back to the start with an LTR mark: [LTR_MARK]`[word]
    # pattern: word followed by a backtick
    pattern = r'([a-zA-Z;\[\]\\/=\':?_]+)`'
    
    def replacer(match):
        word = match.group(1)
        return LTR_MARK + '`' + word
    
    return re.sub(pattern, replacer, text)

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    def walk(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str):
                    obj[k] = fix_jenkem_direction(v)
                else:
                    walk(v)
        elif isinstance(obj, list):
            for i in range(len(obj)):
                if isinstance(obj[i], str):
                    obj[i] = fix_jenkem_direction(obj[i])
                else:
                    walk(obj[i])
    
    walk(data)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Applied LTR-prefixed Jenkem in: {filename}")

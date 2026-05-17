import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar_") and f.endswith(".json")]

arabic_range = r'\u0600-\u06FF'

def fix_jenkem_in_arabic(text):
    # If no Arabic characters, return as is (to avoid breaking dedicated Coptic text)
    if not re.search(f'[{arabic_range}]', text):
        return text
    
    # Pattern: a backtick followed by one or more Coptic/English letters/symbols
    # We want to move the backtick to the end of this word.
    # We include common Coptic font characters: a-z, A-Z, symbols like ; [ ] \ / = ' : ? _
    # We use a word boundary or space/punctuation to stop.
    
    pattern = r'`([a-zA-Z;\[\]\\/=\':?_]+)'
    
    # Replacement function
    def replacer(match):
        word = match.group(1)
        return word + '`'
    
    return re.sub(pattern, replacer, text)

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Recursive function to walk through the JSON
    def walk(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str):
                    obj[k] = fix_jenkem_in_arabic(v)
                else:
                    walk(v)
        elif isinstance(obj, list):
            for i in range(len(obj)):
                if isinstance(obj[i], str):
                    obj[i] = fix_jenkem_in_arabic(obj[i])
                else:
                    walk(obj[i])
    
    walk(data)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Fixed Jenkem in: {filename}")

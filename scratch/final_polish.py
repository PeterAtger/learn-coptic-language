import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar") and f.endswith(".json")]

LRM = '\u200E'

def final_polish(text):
    if not isinstance(text, str):
        return text
    
    # Remove the temporary space I added: LRM + ` + space -> LRM + `
    text = text.replace(LRM + '` ', LRM + '`')
    
    # Ensure any stray backticks (without LRM) get an LRM
    # but avoid double LRMs
    def add_lrm(match):
        return LRM + '`'
    
    text = re.sub(r'(?<!' + re.escape(LRM) + r')`', add_lrm, text)
    
    return text

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    def walk(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str):
                    obj[k] = final_polish(v)
                else:
                    walk(v)
        elif isinstance(obj, list):
            for i in range(len(obj)):
                if isinstance(obj[i], str):
                    obj[i] = final_polish(obj[i])
                else:
                    walk(obj[i])
    
    walk(data)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Polished: {filename}")

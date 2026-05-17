import os
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar") and f.endswith(".json")]

def replace_jenkem_with_tilde(text):
    if not isinstance(text, str):
        return text
    
    # The user mentioned that Jenkem can be ( ` ) or ( ~ ).
    # Since the backtick is causing directionality issues in their app/font,
    # we will try using the tilde ( ~ ) which might be handled differently by the font.
    # We also keep the LRI/PDI isolation for safety.
    
    return text.replace('`', '~')

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    def walk(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str):
                    obj[k] = replace_jenkem_with_tilde(v)
                else:
                    walk(v)
        elif isinstance(obj, list):
            for i in range(len(obj)):
                if isinstance(obj[i], str):
                    obj[i] = replace_jenkem_with_tilde(obj[i])
                else:
                    walk(obj[i])
    
    walk(data)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Replaced Jenkem ` with ~ in: {filename}")

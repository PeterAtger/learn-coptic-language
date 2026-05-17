import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar") and f.endswith(".json")]

# Left-to-Right Isolate (LRI) and Pop Directional Isolate (PDI)
# These are stronger than LRM and should isolate the Coptic word from the surrounding Arabic Bidi context.
LRI = '\u2066'
PDI = '\u2069'
arabic_range = r'\u0600-\u06FF'

def fix_jenkem_with_isolate(text):
    if not isinstance(text, str):
        return text
    
    # We only care about cases where Coptic is embedded in Arabic
    if not re.search(f'[{arabic_range}]', text):
        return text

    # Remove any existing LRM/RLM/LRI/PDI we might have added
    text = text.replace('\u200E', '').replace('\u200F', '').replace('\u2066', '').replace('\u2069', '')

    # Pattern: A Coptic word (possibly with internal hyphens) that has a Jenkem `
    # We want to ensure the Jenkem is at the START of the Coptic word
    # and the whole Coptic word is wrapped in LRI/PDI.
    
    # 1. First, move any trailing Jenkems back to the start (if any left)
    # pattern: word` -> `word
    text = re.sub(r'([a-zA-Z;\[\]\\/=\':?_]+)`', r'`\1', text)
    
    # 2. Wrap Coptic segments (including the Jenkem) in LRI/PDI
    # Coptic segments: start with ` or a Coptic letter, end with a Coptic letter
    # We also include common separators like -
    def isolate_replacer(match):
        return LRI + match.group(0) + PDI
    
    # This regex identifies blocks of Coptic characters (including ` and -)
    # and wraps them. It avoids matching Arabic.
    coptic_block_pattern = r'[`a-zA-Z;\[\]\\/=\':?_\-]+'
    
    # We only wrap if there's at least one Coptic letter or a Jenkem
    return re.sub(coptic_block_pattern, isolate_replacer, text)

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    def walk(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, str):
                    obj[k] = fix_jenkem_with_isolate(v)
                else:
                    walk(v)
        elif isinstance(obj, list):
            for i in range(len(obj)):
                if isinstance(obj[i], str):
                    obj[i] = fix_jenkem_with_isolate(obj[i])
                else:
                    walk(obj[i])
    
    walk(data)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Applied LRI/PDI isolation in: {filename}")

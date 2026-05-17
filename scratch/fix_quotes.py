import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar_") and f.endswith(".json")]

def fix_quotes_in_arabic(text):
    # Balanced quotes: \"text\" -> «text»
    # This is safe because Coptic words starting with \" (like \"en) 
    # usually don't have a second \" at the end of the same word/phrase.
    
    # We use a non-greedy match to catch individual quoted terms
    text = re.sub(r'\\"(.*?)\\"', r'«\1»', text)
    
    # Also handle cases where a quote might be left alone at the end of a sentence
    # e.g., ... قائلين\"
    text = re.sub(r'([{arabic_range}])\\"', r'\1»', text)
    text = re.sub(r'\\"(?=[{arabic_range}])', r'«', text)
    
    return text

arabic_range = r'\u0600-\u06FF'

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We apply it to the whole content string to handle escaped quotes correctly.
    # Note: In the raw file, it's \" (backslash then quote).
    # In Python string read from file, it's \" as well.
    
    # 1. Balanced quotes
    content = re.sub(r'\\"(.*?)\\"', r'«\1»', content)
    
    # 2. Quotes attached to Arabic characters
    content = re.sub(fr'([{arabic_range}])\\"', r'\1»', content)
    content = re.sub(fr'\\"(?=[{arabic_range}])', r'«', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Fixed quotes in: {filename}")

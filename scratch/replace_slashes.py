import os
import re
import json

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
grammar_files = [f for f in os.listdir(data_dir) if f.startswith("grammar_") and f.endswith(".json")]

# Pattern for Arabic characters
arabic_range = r'\u0600-\u06FF'

# We want to replace / or \ if they are used as separators in Arabic text.
# We must avoid replacing \n, \", \uXXXX etc.
# A safe way is to look for slashes between Arabic words or spaces.

for filename in grammar_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. Replace forward slashes / with " - " when surrounded by Arabic or spaces
    # Example: "الرجل/ القدم" -> "الرجل - القدم"
    # We use a regex that looks for / between Arabic chars or spaces
    new_content = re.sub(fr'([{arabic_range}])\s*/\s*([{arabic_range}])', r'\1 - \2', content)
    
    # 2. Replace backslashes \ with " - " similarly, but careful about JSON escapes.
    # In the raw file content (string), a backslash is escaped as \\
    # So we look for \\ (two backslashes in the regex mean one in the file content, 
    # but since it's a raw string we need to be careful).
    # Actually, in the file content, it's either \\ (escaped once) or \\\\ (escaped twice).
    # Let's target the one that looks like a separator.
    
    # In line 82 of uni: "([-f-'-\\\\-j-s-;)" -> This is likely Coptic letters.
    # In primary34: "(]-f-'-\\-j-s-;)" -> Also Coptic.
    
    # Let's see if there are any others.
    # "مذكراً/ مؤنثاً/ جمعاً" -> Already handled by the / regex.
    
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated slashes in: {filename}")
    else:
        print(f"No Arabic slashes found in: {filename}")

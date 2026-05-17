import os
import re

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
json_files = [f for f in os.listdir(data_dir) if f.endswith(".json")]

for filename in json_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Standardize backslashes before single quotes in JSON files.
    # If it's a Coptic word ending with Hori (\) and Khai ('), it should be \\' in the file.
    # If it's just Khai ('), it should be just ' in the file.
    
    # Replace any sequence of one or more backslashes followed by ' with exactly TWO backslashes then '
    # (Note: In Python regex, \\\\ is a literal backslash, so \\\\\\\\ is two literal backslashes)
    new_content = re.sub(r'\\+\'', r"\\\\'", content)
    
    # Also, remove single backslashes that are not escaping anything valid.
    # Wait, in these files, a single backslash is ALMOST ALWAYS an error from my previous script.
    # EXCEPT for real escapes like \n.
    
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed backslash escapes in: {filename}")

import os

data_dir = r"C:\Users\Administrator\Desktop\Coptic\flutter\assets\data"
json_files = [f for f in os.listdir(data_dir) if f.endswith(".json")]

for filename in json_files:
    file_path = os.path.join(data_dir, filename)
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # In JSON, \' is invalid. We need \\' to represent a literal backslash followed by a quote.
    # Our previous script incorrectly created \' from \\"
    new_content = content.replace("\\'", "\\\\'")
    
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed invalid escape sequences in: {filename}")

import os
import subprocess
import glob
import re

def main():
    repo_dir = "/Users/key-tech/Library/Mobile Documents/iCloud~md~obsidian/Documents/Wiki - by AI"
    os.chdir(repo_dir)

    md_files = []
    for root, dirs, files in os.walk("."):
        if ".git" in root or ".beads" in root or ".agents" in root:
            continue
        for f in files:
            if f.endswith(".md"):
                md_files.append(os.path.join(root, f))

    rename_map = {}
    
    # 1. Rename files using git mv
    for file_path in md_files:
        dirname, basename = os.path.split(file_path)
        if "_" in basename and not basename.startswith("_"):
            new_basename = basename.replace("_", " ")
            new_file_path = os.path.join(dirname, new_basename)
            
            print(f"Renaming: '{file_path}' -> '{new_file_path}'")
            subprocess.run(["git", "mv", file_path, new_file_path], check=True)
            
            old_name_no_ext = os.path.splitext(basename)[0]
            new_name_no_ext = os.path.splitext(new_basename)[0]
            rename_map[old_name_no_ext] = new_name_no_ext

    if not rename_map:
        print("No files to rename.")
        return

    # 2. Update links in all markdown files
    # Re-fetch the list of files since names changed
    new_md_files = []
    for root, dirs, files in os.walk("."):
        if ".git" in root or ".beads" in root:
            continue
        for f in files:
            if f.endswith(".md"):
                new_md_files.append(os.path.join(root, f))

    for file_path in new_md_files:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
            
        modified = False
        for old_name, new_name in rename_map.items():
            # Update Obsidian wikilinks: [[Old_Name]] or [[Old_Name|Alias]] or [[Old_Name#Header]]
            pattern = r'\[\[' + re.escape(old_name) + r'([\]\|#])'
            replacement = r'[[' + new_name + r'\1'
            new_content, count = re.subn(pattern, replacement, content)
            if count > 0:
                content = new_content
                modified = True
                print(f"Updated {count} link(s) for '{old_name}' in '{file_path}'")
                
        if modified:
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(content)

if __name__ == "__main__":
    main()

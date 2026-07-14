import sys

def main():
    file_path = r'f:\ITI GP APP\requra\lib\screens\Home\profile_screen.dart'
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = content.replace("\\'", "'")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

if __name__ == '__main__':
    main()

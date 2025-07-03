import os
from PIL import Image
import pytesseract
import os

# Set the path to the tesseract executable
pytesseract.pytesseract.tesseract_cmd = '/usr/bin/tesseract'

def image_to_text(image_path):
    try:
        # Set TESSDATA_PREFIX environment variable
        os.environ['TESSDATA_PREFIX'] = '/usr/share/tesseract-ocr/5'
        img = Image.open(image_path)
        text = pytesseract.image_to_string(img, lang='por') # Assuming Portuguese language for OCR
        return text.strip()
    except Exception as e:
        print(f"Error processing {image_path}: {e}")
        return None

def process_images_in_directory(root_dir):
    for dirpath, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.lower().endswith('.png'):
                image_path = os.path.join(dirpath, filename)
                text_file_path = os.path.splitext(image_path)[0] + '.txt'

                if not os.path.exists(text_file_path):
                    print(f"Processing {image_path}...")
                    extracted_text = image_to_text(image_path)
                    if extracted_text:
                        with open(text_file_path, 'w', encoding='utf-8') as f:
                            f.write(extracted_text)
                        print(f"Text extracted and saved to {text_file_path}")
                    else:
                        with open(text_file_path, 'w', encoding='utf-8') as f:
                            f.write("Não foi possível extrair texto desta imagem ou nenhum texto foi encontrado.")
                        print(f"No text extracted from {image_path}. Created empty text file.")
                else:
                    print(f"Skipping {image_path}, text file already exists.")

if __name__ == "__main__":
    current_directory = os.getcwd()
    process_images_in_directory(current_directory)

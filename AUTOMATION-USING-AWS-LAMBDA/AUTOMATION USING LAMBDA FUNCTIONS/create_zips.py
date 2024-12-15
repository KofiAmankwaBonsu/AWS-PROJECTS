import zipfile
import os

def create_zip(source_dir, output_zip):
    try:
        # Remove existing zip file if it exists
        if os.path.exists(output_zip):
            os.remove(output_zip)
            print(f"Removed existing {output_zip}")
            
        with zipfile.ZipFile(output_zip, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for root, _, files in os.walk(source_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, source_dir)
                    zipf.write(file_path, arcname)
            print(f"Successfully created {output_zip}")
            
    except Exception as e:
        print(f"Error creating {output_zip}: {str(e)}")

def verify_zip(zip_file):
    try:
        with zipfile.ZipFile(zip_file, 'r') as zipf:
            print(f"\nContents of {zip_file}:")
            zipf.printdir()
    except Exception as e:
        print(f"Error reading {zip_file}: {str(e)}")

# Create zip files for each function
functions = ['start_instances', 'stop_instances', 'backup_instances']
for function in functions:
    source_dir = f'functions/{function}'
    output_zip = f'{function}.zip'
    create_zip(source_dir, output_zip)

# Verify all zip files
print("\nVerifying zip files:")
for function in functions:
    verify_zip(f'{function}.zip')

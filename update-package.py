import os
import json

def update_package():
    # Paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    oslar_dir = os.path.join(script_dir, "Oslar-Pallets")
    package_path = os.path.join(oslar_dir, "package.json")
    
    if not os.path.exists(package_path):
        print(f"Error: package.json not found at {package_path}")
        return
        
    # Read existing package.json
    with open(package_path, 'r', encoding='utf-8') as f:
        package_data = json.load(f)
        
    # Build map of existing path -> id
    existing_palettes = {}
    if "contributes" in package_data and "palettes" in package_data["contributes"]:
        for palette in package_data["contributes"]["palettes"]:
            existing_palettes[palette["path"]] = palette["id"]
            
    # Find all palette files (.gpl, .ase, .png)
    allowed_extensions = {'.gpl', '.ase', '.png'}
    new_palettes = []
    
    # List and sort files for consistent ordering
    files = sorted(os.listdir(oslar_dir))
    for filename in files:
        ext = os.path.splitext(filename)[1].lower()
        if ext in allowed_extensions:
            rel_path = f"./{filename}"
            # Keep existing ID if it matches, otherwise use filename without extension
            if rel_path in existing_palettes:
                palette_id = existing_palettes[rel_path]
            else:
                palette_id = os.path.splitext(filename)[0]
                
            new_palettes.append({
                "id": palette_id,
                "path": rel_path
            })
            
    # Sort palettes by ID (case-insensitive)
    new_palettes.sort(key=lambda x: x["id"].lower())
            
    # Update package data
    if "contributes" not in package_data:
        package_data["contributes"] = {}
    package_data["contributes"]["palettes"] = new_palettes
    
    # Save back package.json
    with open(package_path, 'w', encoding='utf-8') as f:
        json.dump(package_data, f, indent=2, ensure_ascii=False)
        
    print(f"Successfully updated package.json with {len(new_palettes)} palettes!")

if __name__ == "__main__":
    update_package()

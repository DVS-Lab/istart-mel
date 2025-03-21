import os
import pandas as pd
from glob import glob

# Define the directory containing the raw CSV files
raw_dir = "/ZPOOL/data/projects/istart-mel/updated_rsa/meants_output/raw"

# Define the output directory
output_dir = os.path.join(os.path.dirname(raw_dir), "compiled")
os.makedirs(output_dir, exist_ok=True)  # Create the compiled directory if it doesn't exist

# Define ROI and condition mappings
rois = ["lamyg", "ramyg", "tpj", "vs", "vmpfc", "V1", "amyg"]
conditions = {
    "str_diff": "_stranger_zstat1",
    "comp_diff": "_computer_zstat1",
    "soc_diff": "_socialdoors_zstat4",
    "door_diff": "_doors_zstat4"
}

# Process files for each ROI
for roi in rois:
    # Prepare a dictionary to hold the data
    roi_data = {"sub_id": [], "str_diff": [], "comp_diff": [], "soc_diff": [], "door_diff": []}
    
    # Get all files for this ROI
    roi_files = glob(os.path.join(raw_dir, f"*_{roi}.csv"))
    
    for file_path in roi_files:
        # Extract subject ID from the file name
        file_name = os.path.basename(file_path)
        subject_id = int(file_name.split('_')[0][4:])  # Extract numeric ID (e.g., 1001)
        
        # Identify the condition from the file name
        condition_col = None
        for col, condition in conditions.items():
            if condition in file_name:
                condition_col = col
                break
        
        # Skip files that don't match any condition
        if not condition_col:
            continue
        
        # Read the file and extract the fourth row
        data = pd.read_csv(file_path, header=None)
        fourth_row = data.iloc[3, :].tolist()  # Extract as a list of numbers
        
        # Add subject ID if not already in the list
        if subject_id not in roi_data["sub_id"]:
            roi_data["sub_id"].append(subject_id)
            for col in conditions.keys():
                roi_data[col].append([])  # Initialize empty lists for other conditions
        
        # Find the subject's index and assign the data
        subject_index = roi_data["sub_id"].index(subject_id)
        roi_data[condition_col][subject_index] = fourth_row  # Assign the activation values
    
    # Convert to DataFrame
    df = pd.DataFrame(roi_data)
    
    # Convert lists to properly formatted strings with commas and spaces
    for col in ["str_diff", "comp_diff", "soc_diff", "door_diff"]:
        df[col] = df[col].apply(lambda x: f"[{', '.join(map(str, x))}]" if x else "[]")
    
    # Sort by subject ID
    df = df.sort_values(by="sub_id").reset_index(drop=True)
    
    # Save to CSV
    output_path = os.path.join(output_dir, f"{roi}_mod4_diff.csv")
    df.to_csv(output_path, index=False)
    print(f"Saved: {output_path}")

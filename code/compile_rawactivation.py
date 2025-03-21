import os
import pandas as pd
from glob import glob
from scipy.stats import zscore

# Define the directory containing the raw CSV files
raw_dir = "/ZPOOL/data/projects/istart-mel/updated_rsa/rawactivation_output/raw"

# Define the output directory
output_dir = os.path.join(os.path.dirname(raw_dir), "compiled")
os.makedirs(output_dir, exist_ok=True)  # Create the compiled directory if it doesn't exist

# Define ROI and condition mappings
rois = ["lamyg", "ramyg", "tpj", "vs", "vmpfc", "V1", "amyg"]
conditions_to_columns = {
    "stranger": "str_raw",
    "computer": "comp_raw",
    "socialdoors": "soc_raw",
    "doors": "door_raw"
}

# Process files for each ROI
for roi in rois:
    # Prepare a dictionary to hold the data
    roi_data = {"subject_id": [], "str_raw": [], "comp_raw": [], "soc_raw": [], "door_raw": []}
    
    # Get all files for this ROI
    roi_files = glob(os.path.join(raw_dir, f"*_{roi}.csv"))
    
    for file_path in roi_files:
        # Extract subject ID from the file name
        file_name = os.path.basename(file_path)
        subject_id = int(file_name.split('_')[0][4:])  # Extract numeric ID (e.g., 1001)
        
        # Identify the condition from the file name
        condition = next((c for c in conditions_to_columns if c in file_name), None)
        if not condition:
            print(f"Condition not recognized in file: {file_name}")
            continue
        
        # Read the file and extract the 4th row (voxel activations)
        data = pd.read_csv(file_path, header=None, delim_whitespace=True)
        fourth_row = data.iloc[3, :]  # Select the 4th row (index 3)
        voxel_values = fourth_row.tolist()  # Convert the row to a list
        
        # Add subject ID if not already in the list
        if subject_id not in roi_data["subject_id"]:
            roi_data["subject_id"].append(subject_id)
            for col in ["str_raw", "comp_raw", "soc_raw", "door_raw"]:
                roi_data[col].append([])  # Initialize with empty lists for missing conditions
        
        # Assign the list of voxel values to the correct condition column
        condition_column = conditions_to_columns[condition]
        subject_index = roi_data["subject_id"].index(subject_id)
        roi_data[condition_column][subject_index] = voxel_values
    
    # Convert to DataFrame
    df = pd.DataFrame(roi_data)
    
    # Calculate z-scores across all voxel activations for all conditions
    def calculate_combined_zscores(row):
        # Combine all voxel values from all conditions
        combined_list = row["str_raw"] + row["comp_raw"] + row["soc_raw"] + row["door_raw"]
        
        # Compute z-scores across the combined list
        combined_zscores = zscore(combined_list)
        
        # Split the z-scores back into separate lists for each condition
        n_voxels = len(row["str_raw"])
        return pd.Series({
            "str_diff": combined_zscores[:n_voxels],
            "comp_diff": combined_zscores[n_voxels:n_voxels * 2],
            "soc_diff": combined_zscores[n_voxels * 2:n_voxels * 3],
            "door_diff": combined_zscores[n_voxels * 3:]
        })
    
    # Apply the modified z-score calculation
    zscore_df = df.apply(calculate_combined_zscores, axis=1)

    # Combine raw and z-score data
    final_df = pd.concat([df, zscore_df], axis=1)

    # Sort by subject ID
    final_df = final_df.sort_values(by="subject_id").reset_index(drop=True)
    
    # Save to CSV
    output_path = os.path.join(output_dir, f"act_{roi}_mod4_diff.csv")
    final_df.to_csv(output_path, index=False, float_format="%.6f")  # 6 decimal places
    print(f"Saved: {output_path}")

import os
import numpy as np
import pandas as pd

# Define the directory where your data files are located
data_dir = '/ZPOOL/data/projects/istart-mel/data/socialdoors/tpj_doors'

# Subjects to include (without 'sub-' part)
subjects_to_include = [
    '1001', '1006', '1009', '1010', '1012', '1013', '1015', '1016',
    '1019', '1021', '1242', '1243', '1244', '1248', '1249', '1251',
    '1255', '1276', '1286', '1294', '1301', '1302', '1303', '3116',
    '3122', '3125', '3140', '3143', '3166', '3167', '3170', '3173',
    '3176', '3189', '3190', '3200', '3206', '3212', '3220'
]

# Define the order of zstat files
zstat_order = ['door_win', 'door_loss']

# Initialize an empty list to store data
data_list = []

# Loop through each subject
for subject_id in subjects_to_include:
    # Initialize a dictionary to store zstat values for the subject
    subject_data = {'sub_id': subject_id}
    
    # Loop through each zstat type for the subject
    for idx, zstat_type in enumerate(zstat_order, start=1):
        filename = f'sub-{subject_id}_tpj_doors_zstat{idx}.txt'
        filepath = os.path.join(data_dir, filename)
        
        # Check if the file exists
        if os.path.exists(filepath):
            # Read the zstat value from the file
            with open(filepath, 'r') as file:
                zstat_value = float(file.readline())
            
            # Store the zstat value in the dictionary
            subject_data[zstat_type] = zstat_value
        else:
            print(f"Warning: File '{filename}' not found for subject '{subject_id}'")
    
    # Append subject data to the list
    data_list.append(subject_data)

# Convert the data list to a pandas DataFrame
data_df = pd.DataFrame(data_list)

# Save the DataFrame as a CSV file
data_df.to_csv('tpj_doors_matrix.csv', index=False)

print("Data saved as 'tpj_doors_matrix.csv'.")

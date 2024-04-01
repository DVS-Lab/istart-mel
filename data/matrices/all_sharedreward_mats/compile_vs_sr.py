import csv

# Function to read data from the source CSV file for specified subjects
def read_csv(file_name, subjects):
    data = {}
    with open(file_name, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            sub_id = row['sub_id']
            if sub_id not in subjects:
                continue
            cond = row['cond']
            value = row['value']
            if sub_id not in data:
                data[sub_id] = {}
            if cond not in data[sub_id]:
                data[sub_id][cond] = []
            data[sub_id][cond].append(value)
    return data

# Function to write data to the output CSV file
def write_csv(data, output_file):
    with open(output_file, 'w', newline='') as csvfile:
        fieldnames = ['sub_id', 'fri_win', 'fri_loss', 'str_win', 'str_loss', 'comp_win', 'comp_loss']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for sub_id, conditions in data.items():
            row = {'sub_id': sub_id}
            for cond, values in conditions.items():
                row[cond] = values
            writer.writerow(row)

# Main function to orchestrate the process
def main():
    source_csv = 'all_sharedreward_vs_mat.csv'
    output_csv = 'vs_sr_COMPLETE_mat.csv'
    # List of specified subjects
    subjects = ['1001', '1006', '1009', '1010', '1012', '1013', '1015', '1016',
                '1019', '1021', '1242', '1243', '1244', '1248', '1249', '1251',
                '1255', '1276', '1286', '1294', '1301', '1302', '1303', '3116',
                '3122', '3125', '3140', '3143', '3166', '3167', '3170', '3173',
                '3176', '3189', '3190', '3200', '3206', '3212', '3220']

    data = read_csv(source_csv, subjects)

    # Ensure all conditions have the same length
    max_length = max(len(values) for sub_data in data.values() for values in sub_data.values())
    for sub_data in data.values():
        for values in sub_data.values():
            while len(values) < max_length:
                values.append('')

    write_csv(data, output_csv)

if __name__ == "__main__":
    main()

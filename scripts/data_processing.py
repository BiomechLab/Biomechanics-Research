import pandas as pd

def load_data(file_path):
    """Load the data from a CSV file."""
    return pd.read_csv(file_path)

def process_data(df):
    """Process the data (e.g., clean, normalize)."""
    # Example processing
    df = df.dropna()
    return df

def main():
    data = load_data('../data/sample_data.csv')
    processed_data = process_data(data)
    print(processed_data.head())

if __name__ == "__main__":
    main()

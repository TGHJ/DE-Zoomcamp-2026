import pandas as pd

# Create simple DataFrame
df = pd.DataFrame({
    "A": [1, 2],
    "B": [3, 4]
})

# Simple transformation
df["C"] = df["A"] + df["B"]

# Print results
print("Original DataFrame:")
print(df)

print("\nSummary statistics:")
print(df.describe())
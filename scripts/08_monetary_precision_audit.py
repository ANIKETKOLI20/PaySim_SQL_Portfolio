
import csv

from decimal import Decimal, InvalidOperation
from pathlib import Path


# 1. Source file
file_path = Path(
    "data/original/PS_20174392719_1491204439457_log.csv"
)

if not file_path.exists():
    raise FileNotFoundError(file_path)


# 2. Monetary columns
monetary_columns = [
    "amount",
    "oldbalanceOrg",
    "newbalanceOrig",
    "oldbalanceDest",
    "newbalanceDest"
]

# 3. Initialize statistics
stats = {
    column: {
        "max_decimal_places": 0,
        "max_integer_digits": 0,
        "blank_count": 0,
        "invalid_count": 0,
        "max_absolute_value": Decimal("0")
    }
    for column in monetary_columns
}

total_records = 0


# 4. Read the entire CSV
with file_path.open(
    "r",
    encoding="utf-8-sig",
    newline=""
) as csv_file:

    reader = csv.DictReader(csv_file)

    if not set(monetary_columns).issubset(
        reader.fieldnames or []
    ):
        raise ValueError("Required monetary columns missing.")

    for row in reader:

        total_records += 1

        for column in monetary_columns:

            raw_value = row[column].strip()

            if not raw_value:
                stats[column]["blank_count"] += 1
                continue

            try:
                value = Decimal(raw_value)

            except InvalidOperation:
                stats[column]["invalid_count"] += 1
                continue

            if not value.is_finite():
                stats[column]["invalid_count"] += 1
                continue

            # Determine decimal places from exact input value
            decimal_places = max(
                0, -value.as_tuple().exponent
            )

            # Determine integer digits
            integer_digits = (
                max(1, value.copy_abs().adjusted() + 1)
                if value != 0
                else 1
            )

            stats[column]["max_decimal_places"] = max(
                stats[column]["max_decimal_places"],
                decimal_places
            )

            stats[column]["max_integer_digits"] = max(
                stats[column]["max_integer_digits"],
                integer_digits
            )

            stats[column]["max_absolute_value"] = max(
                stats[column]["max_absolute_value"],
                abs(value)
            )


# 5. Display actual results
print("\n--- MONETARY PRECISION AUDIT ---")

print(f"Total records processed: {total_records:,}")

for column, result in stats.items():

    print(f"\nColumn: {column}")

    print(
        f"Maximum decimal places: "
        f"{result['max_decimal_places']}"
    )

    print(
        f"Maximum integer digits: "
        f"{result['max_integer_digits']}"
    )

    print(
        f"Maximum absolute value: "
        f"{result['max_absolute_value']}"
    )

    print(f"Blank values: {result['blank_count']}")
    print(f"Invalid values: {result['invalid_count']}")

# Olist Late Delivery Prediction

Predicts whether an e-commerce order will be delivered after its estimated delivery date, using only information that is known when the order is placed. The dataset is built with SQL (MySQL) and the models are built with scikit-learn.

## Summary

- **Problem:** flag orders that are likely to arrive late. Only about 8% of orders are late, so the classes are heavily imbalanced.
- **Best model:** a Random Forest (fixed settings) with class weighting.
- **Random train/test split:** ROC-AUC 0.770, PR-AUC 0.255.
- **Time-based split (train on older orders, test on newer ones):** ROC-AUC 0.696, PR-AUC 0.088. This is the more realistic estimate for future orders, and it is clearly lower than the random-split score.
- **Takeaway:** the features available at order time carry some real signal, but only modest predictive power. A random split overstates performance because the model can learn which periods were bad.

## Dataset

- Source: Olist Brazilian E-Commerce Public Dataset (available on Kaggle).
- Final modelling table: **96,470 delivered orders**, **7,826 late (8.1%)**.
- Target `is_late` = 1 if the actual delivery date is after the estimated delivery date, otherwise 0. Only delivered orders with a recorded delivery date are included.

### Features used (8)

| Feature | Meaning |
|---|---|
| `n_items` | Number of items in the order |
| `total_price` | Sum of item prices |
| `total_freight` | Sum of freight values |
| `n_sellers` | Number of distinct sellers in the order |
| `customer_state` | Customer's state (one-hot encoded) |
| `promised_days` | Days between purchase and the estimated delivery date |
| `purchase_month` | Month of purchase |
| `purchase_dow` | Day of week of purchase |

### Deliberately excluded

- **Order and customer IDs**, and the raw timestamps.
- **Review data.** Reviews are written after delivery, so using them would leak the outcome.
- **`state_avg_promised` and `promised_vs_state`.** These state averages were calculated over the whole dataset, including rows later used for testing. They use only promise dates (never the outcome), but they were removed to keep the evaluation clean. Removing them did not change logistic regression performance.
- **Geolocation table.** Very large and not needed for this version.

## SQL data preparation (MySQL)

The modelling table was built in MySQL; the queries are in `olist_features.sql`.

1. Loaded the CSV tables with `LOAD DATA LOCAL INFILE`, turning blank dates into `NULL` with `NULLIF`.
2. Built the target with `CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END`, keeping delivered orders with a delivery date.
3. Avoided the one-to-many join trap: `order_items` was aggregated to **one row per order** (`COUNT`, `SUM`, `COUNT(DISTINCT seller_id)` with `GROUP BY order_id`) before being joined to orders. A row count and late-rate check (96,470 rows, 8.1% late) was run after each join to confirm no rows were lost or duplicated.
4. Joined `customers` to get the customer state.
5. Added date features with `DATEDIFF`, `MONTH` and `DAYOFWEEK`.
6. Added a window-function feature (state-level average of `promised_days` using `AVG(...) OVER (PARTITION BY customer_state)`) inside a CTE. It was later excluded from the final models (see above).
7. Exported the final table to `olist_model_features.csv` in chunks, because the Workbench export wizard froze on the full table.

## Modelling workflow

1. Data checks: no missing values, no duplicate orders, target distribution.
2. Stratified 80/20 split (77,176 train / 19,294 test).
3. Preprocessing and model in one scikit-learn `Pipeline` (median imputation and scaling for numeric columns, most-frequent imputation and one-hot encoding for state), so no information from the test set leaks into training.
4. Majority-class baseline, Logistic Regression baseline, class-weighted Logistic Regression, Random Forest.
5. Evaluation with precision, recall, F1, ROC-AUC and PR-AUC (accuracy alone is misleading at 8% positives).
6. Error analysis and feature importance.
7. A time-based validation check.

## Results

### Random 80/20 split (threshold 0.50)

| Model | Accuracy | Late precision | Late recall | Late F1 | ROC-AUC | PR-AUC |
|---|---:|---:|---:|---:|---:|---:|
| Majority class ("always on time") | 0.9189 | n/a | 0.00 | n/a | 0.50 | 0.081 |
| Logistic Regression (default) | 0.9189 | 1.00 (1 prediction) | 0.00 | 0.00 | 0.687 | 0.169 |
| Logistic Regression (balanced) | 0.6397 | 0.1332 | 0.6249 | 0.2196 | 0.689 | 0.164 |
| **Random Forest (fixed settings)** | 0.8078 | 0.2223 | 0.5482 | 0.3164 | **0.770** | **0.255** |

- The majority baseline is 91.9% accurate while catching no late orders, so accuracy is not useful here.
- The default logistic regression almost never predicts "late" at the 0.50 cutoff: its highest predicted probability was only 0.57.
- The Random Forest uses `max_depth=20`, `min_samples_leaf=4`, `class_weight='balanced'`. These settings and the 0.50 threshold were fixed, not tuned.
- Confusion matrix (Random Forest): 858 late orders caught, 707 missed, 3,001 false alarms.

### Time-based split

Trained on the earliest 80% of orders and tested on the latest 20%.

| | Value |
|---|---:|
| Late rate in training period | 8.8% |
| Late rate in test period | 5.3% |
| ROC-AUC | 0.696 |
| PR-AUC | 0.088 (about 1.7 times the 5.3% base rate) |

On newer orders the model is clearly weaker than on the random split (PR-AUC is about 3.1 times the base rate on the random split, but only about 1.7 times on the time split). The Random Forest vs Logistic Regression comparison above was run on the random split only.

## Findings

- **Most important Random Forest features** (impurity-based importance): `purchase_month` (0.23), `promised_days` (0.23), `total_freight` (0.18), `total_price` (0.15), `purchase_dow` (0.06). Month probably stands in for specific periods with delivery problems, which is why the time-based check matters.
- **Missed late orders by state** (states with at least 30 late orders): highest miss rates in PR (66%), SP (66%), PE (58%) and MG (54%); lowest in BA (17%), CE (13%), RJ (21%) and MA (21%).
- **By promised delivery time:** orders promised within 7 days were all caught (82 of 82), while 8 to 14 day promises had the highest miss rate (80%).
- Missed and detected late orders look very similar on price, freight and number of items, which suggests that the available features do not separate them well.

## Limitations

- Modest predictive power: ROC-AUC 0.70 on newer orders.
- The late rate changed between the older and newer orders (8.8% vs 5.3%), so performance depends on the period.
- Random Forest settings and the 0.50 threshold were not tuned, and the threshold was not chosen from a business cost.
- Feature importance shows association, not cause.
- Only information available at order time is used. Seller history, product size and weight, and the distance between seller and customer are not included.
- Results come from a single dataset and a single split of each type.

## Future improvements

- Add seller-level and product-level features (using only earlier orders), product weight and size, and seller-to-customer distance.
- Try gradient boosting and tune with time-aware cross-validation.
- Choose the threshold from the business cost of a missed late order versus a false alarm.
- Evaluate on several rolling time windows.

## Repository contents

| File | Purpose |
|---|---|
| `olist.ipynb` | Exploration, modelling, evaluation and error analysis |
| `olist_features.sql` | MySQL queries that build the modelling table |
| `olist_model_features.csv` | Exported modelling table (96,470 rows, 15 columns) |
| `requirements.txt` | Python dependencies |

## How to run

1. Install the dependencies: `pip install -r requirements.txt`
2. Open `olist.ipynb` in Jupyter Notebook. The notebook reads `olist_model_features.csv` from the same folder.
3. Run the cells in order (Restart and Run All).
4. To rebuild the table yourself, load the Olist CSV files into MySQL and run `olist_features.sql`.

## Disclaimer

This project is for educational purposes. Predictions are estimates and should not be treated as guarantees of delivery performance.

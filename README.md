# Olist Late Delivery Prediction

## Project Overview

This project focuses on predicting whether an e-commerce order will be delivered late using the Brazilian E-Commerce Public Dataset by Olist.

The project uses SQL for data extraction, cleaning, joining, and feature engineering, followed by Python and machine learning for exploratory data analysis, model training, and evaluation.

## Dataset

**Dataset:** Brazilian E-Commerce Public Dataset by Olist
**Source:** Kaggle
**Dataset name:** Olist Brazilian E-Commerce Public Dataset

The dataset contains information about customers, orders, payments, reviews, products, sellers, and geolocation.

### Dataset Download and Extraction

1. Open Kaggle and search for **Brazilian E-Commerce Public Dataset by Olist**.
2. Download the dataset as a ZIP file.
3. Extract the downloaded ZIP file.
4. Locate the extracted CSV files.
5. Keep the CSV files together inside a folder named `archive`.

The project uses the following CSV files:

* `olist_customers_dataset.csv`
* `olist_geolocation_dataset.csv`
* `olist_order_items_dataset.csv`
* `olist_order_payments_dataset.csv`
* `olist_order_reviews_dataset.csv`
* `olist_orders_dataset.csv`
* `olist_products_dataset.csv`
* `olist_sellers_dataset.csv`
* `product_category_name_translation.csv`

**Important:** The raw Kaggle dataset is not included in this repository. Download and extract it separately before running the SQL scripts.

## Technologies Used

* Python
* SQL / MySQL
* Pandas
* NumPy
* Matplotlib
* Seaborn
* Scikit-learn
* Jupyter Notebook

## Project Structure

```text
olist-late-delivery-prediction/
│
├── olist.ipynb
├── olist_database_setup.sql
├── olist_analysis.sql
├── olist_model_features.csv
├── requirements.txt
├── README.md
└── .gitignore
```

## Data Processing and SQL

The project uses two SQL scripts:

### 1. olist_database_setup.sql

* Creates the database and required tables.
* Loads the extracted CSV files into MySQL.
* Establishes the initial database structure.

Before executing this script, update the CSV file paths in the `LOAD DATA` statements according to your local dataset location.

### 2. olist_analysis.sql

* Performs data analysis and preparation.
* Creates the modelling dataset.
* Generates features required for prediction.
* Creates the target variable `is_late`.
* Performs final data checks.

Run the database setup script first, followed by the analysis script.

## Machine Learning Workflow

The notebook covers the following steps:

1. Data loading and inspection.
2. Data cleaning and preprocessing.
3. Exploratory Data Analysis (EDA).
4. Feature selection and preparation.
5. Handling class imbalance.
6. Model training.
7. Hyperparameter tuning.
8. Model evaluation and comparison.

The target variable is `is_late`, which indicates whether an order was delivered later than its estimated delivery date.

## Models Used

* Logistic Regression
* Random Forest Classifier

Models are evaluated using accuracy, precision, recall, F1-score, ROC-AUC, and PR-AUC.

## Installation and Setup

### 1. Clone the Repository

```bash
git clone https://github.com/aisha016g/olist-late-delivery-prediction.git
cd olist-late-delivery-prediction
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Download and Extract the Dataset

Download the Olist dataset from Kaggle and extract the CSV files into your local `archive` folder.

### 4. Configure MySQL

* Open `olist_database_setup.sql`.
* Update the CSV paths in the `LOAD DATA` statements.
* Execute the database setup script.
* Execute `olist_analysis.sql` after the database setup is complete.

### 5. Run the Notebook

Open `olist.ipynb` in Jupyter Notebook or JupyterLab and run the cells.

## Output

The project produces a processed modelling dataset and trained machine learning models for predicting late deliveries.

The main prediction target is `is_late`.

## Author

**Aisha Gupta**
B.Tech Computer Science and Engineering
GitHub: aisha016g

# Olist Late Delivery Prediction

## Project Overview
This project uses machine learning to predict whether an e-commerce order will be delivered later than its estimated delivery date.

The goal is to identify potentially late orders and understand which order characteristics are associated with delivery delays.

## Dataset
The prepared dataset contains 96,470 orders and features related to order contents, prices, freight costs, customer state, and estimated delivery time.

## Technologies
- Python
- Pandas
- NumPy
- Scikit-learn
- Jupyter Notebook

## Machine Learning Workflow
1. Data exploration and preprocessing
2. Train-test split with stratification
3. Logistic Regression baseline
4. Class-weighted Logistic Regression
5. Random Forest training and tuning
6. Cross-validation-based threshold selection
7. Test-set evaluation
8. Error analysis and feature importance

## Final Model
Tuned Random Forest classifier.

### Test Results

| Metric | Score |
|---|---:|
| Accuracy | 0.8565 |
| Late-delivery precision | 0.2666 |
| Late-delivery recall | 0.4390 |
| Late-delivery F1-score | 0.3317 |
| ROC-AUC | 0.7690 |
| PR-AUC | 0.2529 |
| Selected threshold | 0.5631 |

## Key Findings
- The tuned Random Forest performed better at identifying late deliveries than the initial Logistic Regression baseline.
- The most important model features were promised delivery days, purchase month, freight cost, and total price.
- Error analysis identified states and promised-delivery-time groups where the model missed many late deliveries.

## Limitations
- Late deliveries are a minority class, making reliable detection challenging.
- The model still misses some late deliveries and generates false alarms.
- Feature importance indicates predictive contribution, not causation.
- Performance may change when evaluated on newer orders or different datasets.
- Features should only be used if they are available at the intended prediction time.

## How to Run
1. Install the dependencies listed in `requirements.txt`.
2. Open `olist.ipynb` in Jupyter Notebook.
3. Ensure `olist_model_features.csv` is available in the expected location.
4. Run the notebook cells in order.

## Future Improvements
- Evaluate gradient boosting models.
- Improve minority-class detection.
- Investigate temporal validation on newer orders.
- Build an interactive prediction demo.

## Disclaimer
This project is for educational and analytical purposes. Predictions are estimates and should not be treated as guarantees of delivery performance.

# Customer Churn & Revenue Risk Predictor

An end-to-end portfolio project using **Microsoft SQL Server, Python, machine learning, and Power BI** to identify customers at risk of churn and estimate associated monthly recurring revenue exposure.

> **Status:** Initial project scaffold. Dataset import, SQL validation, model training, and Power BI reporting are the next milestones. Metrics and findings will be added only after the workflow is run.

## Business objective

- Explore customer churn patterns using SQL.
- Predict churn probability with supervised machine learning.
- Segment customers into low-, medium-, and high-risk tiers.
- Estimate expected monthly revenue exposure.
- Present business summaries in Power BI.

**Revenue-risk definition:** expected monthly revenue at risk = churn probability × monthly charges. This is an expected-value estimate, not guaranteed churn or realized revenue loss.

## Technology

- Microsoft SQL Server / SSMS
- Python, pandas, NumPy, scikit-learn, joblib
- Power BI Desktop
- Git and GitHub

## Dataset

Use the IBM Telco Customer Churn dataset:
- [Kaggle dataset](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)
- [IBM GitHub CSV](https://github.com/IBM/telco-customer-churn-on-icp4d/blob/master/data/Telco-Customer-Churn.csv)

Save it as `data/raw/WA_Fn-UseC_-Telco-Customer-Churn.csv`. The dataset is not committed here; review its terms before redistribution.

## Repository structure

```text
data/raw/          Original CSV (not committed)
data/processed/    SQL-exported clean CSV (not committed)
sql/               SQL Server setup, validation, and cleaning scripts
src/               Python model training pipeline
models/            Trained model artifacts (not committed)
outputs/           Metrics and scored predictions (not committed)
notebooks/         Exploratory analysis
powerbi/           Power BI report files
docs/              Project documentation
```

## Setup

### Python

Use Python 3.10 or later from the repository root:

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### SQL Server

1. Open SSMS and run `sql/01_create_database_and_raw_table.sql`.
2. Import the downloaded CSV into `customer_churn_db.dbo.raw_customers` using the SSMS Import Flat File / Import Data wizard. Match the 21 CSV columns to the table columns.
3. Run `sql/02_validate_raw_data.sql` and review row counts, churn values, blanks, and duplicates.
4. Run `sql/03_clean_and_feature_engineer.sql` to create `dbo.vw_customer_churn_model_data`.
5. Export that view to `data/processed/telco_churn_model_data.csv`.

The SQL view converts numeric values safely. Blank `TotalCharges` values remain NULL for transparent downstream imputation.

### Train models

Run from the repository root:

```powershell
python -m src.train
```

The script trains Logistic Regression and Random Forest models using a stratified 80/20 split, compares ROC-AUC, accuracy, precision, recall, and F1, then saves:
- `models/best_churn_model.joblib`
- `outputs/model_metrics.json`
- `outputs/test_customer_predictions.csv`

It uses the SQL-exported CSV if present, otherwise the original CSV. The default classification threshold is 0.50 and should be reviewed against business costs.

## Planned Power BI report

1. **Executive overview:** customer count, churn rate, recurring revenue exposure, and risk mix.
2. **Churn drivers:** churn by contract, tenure, internet service, payment method, and customer segments.
3. **Customer risk list:** customer ID, churn probability, risk tier, monthly charges, and expected monthly exposure.

## Evaluation and limitations

ROC-AUC evaluates ranking quality; precision and recall must be considered together. Further cross-validation, probability calibration, threshold analysis, and leakage checks are planned. This is a retrospective educational project, not a production retention system. Model scores do not establish causation.

## Milestones

- [x] Create repository scaffold
- [x] Add SQL Server setup, validation, and cleaned-view scripts
- [x] Add baseline Python modelling pipeline
- [ ] Download and import dataset
- [ ] Validate SQL output and export clean data
- [ ] Train models and review metrics
- [ ] Build Power BI dashboard
- [ ] Add verified findings and resume-ready summary

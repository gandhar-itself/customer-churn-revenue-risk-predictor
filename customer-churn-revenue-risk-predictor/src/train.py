"""Train baseline churn models and estimate expected monthly revenue exposure."""
from __future__ import annotations
import json
from pathlib import Path
import joblib
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score, roc_auc_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler

ROOT = Path(__file__).resolve().parents[1]
PROCESSED = ROOT / "data/processed/telco_churn_model_data.csv"
RAW = ROOT / "data/raw/WA_Fn-UseC_-Telco-Customer-Churn.csv"
TARGET = "Churn"

def load_data():
    path = PROCESSED if PROCESSED.exists() else RAW
    if not path.exists():
        raise FileNotFoundError(
            f"Dataset missing. Put the original CSV at {RAW}, or export the SQL view to {PROCESSED}."
        )
    df = pd.read_csv(path)
    if TARGET not in df:
        raise ValueError("CSV must contain a Churn column.")
    df[TARGET] = df[TARGET].astype(str).str.strip()
    df = df[df[TARGET].isin(["Yes", "No"])].copy()
    for col in ["TotalCharges", "MonthlyCharges", "tenure", "SeniorCitizen"]:
        if col in df:
            df[col] = pd.to_numeric(df[col], errors="coerce")
    return df.reset_index(drop=True)

def make_preprocessor(X):
    numeric = X.select_dtypes(include=["number", "bool"]).columns.tolist()
    categorical = [c for c in X.columns if c not in numeric]
    num_pipe = Pipeline([("imputer", SimpleImputer(strategy="median")),
                         ("scale", StandardScaler())])
    cat_pipe = Pipeline([("imputer", SimpleImputer(strategy="most_frequent")),
                         ("onehot", OneHotEncoder(handle_unknown="ignore"))])
    return ColumnTransformer([("numeric", num_pipe, numeric),
                              ("categorical", cat_pipe, categorical)])

def metrics(model, X_test, y_test):
    p = model.predict_proba(X_test)[:, 1]
    yhat = (p >= 0.5).astype(int)
    return {
        "roc_auc": float(roc_auc_score(y_test, p)),
        "accuracy": float(accuracy_score(y_test, yhat)),
        "precision": float(precision_score(y_test, yhat, zero_division=0)),
        "recall": float(recall_score(y_test, yhat, zero_division=0)),
        "f1": float(f1_score(y_test, yhat, zero_division=0)),
    }

def main():
    df = load_data()
    y = df[TARGET].map({"No": 0, "Yes": 1}).astype(int)
    excluded = [c for c in ["customerID", TARGET, "ChurnFlag"] if c in df]
    X = df.drop(columns=excluded)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.20, random_state=42, stratify=y
    )
    candidates = {
        "logistic_regression": LogisticRegression(
            max_iter=2000, class_weight="balanced", random_state=42),
        "random_forest": RandomForestClassifier(
            n_estimators=300, min_samples_leaf=2, class_weight="balanced",
            random_state=42, n_jobs=-1),
    }
    fitted, scores = {}, {}
    for name, estimator in candidates.items():
        pipe = Pipeline([("preprocessor", make_preprocessor(X_train)),
                         ("model", estimator)])
        pipe.fit(X_train, y_train)
        fitted[name] = pipe
        scores[name] = metrics(pipe, X_test, y_test)

    winner = max(scores, key=lambda k: scores[k]["roc_auc"])
    best = fitted[winner]
    (ROOT / "models").mkdir(exist_ok=True)
    (ROOT / "outputs").mkdir(exist_ok=True)
    joblib.dump(best, ROOT / "models/best_churn_model.joblib")

    probabilities = best.predict_proba(X_test)[:, 1]
    scored = X_test.copy()
    scored["actual_churn"] = y_test.to_numpy()
    scored["churn_probability"] = probabilities
    scored["predicted_churn"] = (probabilities >= 0.5).astype(int)
    if "MonthlyCharges" in X_test:
        charges = pd.to_numeric(X_test["MonthlyCharges"], errors="coerce").fillna(0)
        scored["expected_monthly_revenue_at_risk"] = probabilities * charges.to_numpy()
    scored["risk_tier"] = pd.cut(
        probabilities, bins=[-0.001, 0.30, 0.60, 1.001],
        labels=["Low", "Medium", "High"]).astype(str)
    scored.to_csv(ROOT / "outputs/test_customer_predictions.csv", index=False)
    with (ROOT / "outputs/model_metrics.json").open("w", encoding="utf-8") as f:
        json.dump({"selected_model": winner, "metrics": scores}, f, indent=2)
    print(json.dumps({"selected_model": winner, "metrics": scores}, indent=2))
    print("Saved model, metrics, and test-set predictions.")

if __name__ == "__main__":
    main()

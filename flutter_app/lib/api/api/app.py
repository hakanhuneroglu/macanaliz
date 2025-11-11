from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import re
import numpy as np
from sklearn.ensemble import RandomForestClassifier

app = FastAPI(title="macanaliz API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

def fix_score(v):
    try:
        s = str(v).strip()
        if s == "" or s == "-" or s.lower() == "nan":
            return "0-0"
        m = re.findall(r"\d+", s)
        if len(m) >= 2:
            return f"{m[0]}-{m[1]}"
        return "0-0"
    except:
        return "0-0"

def ms_to_class(ms_str):
    a, b = map(int, ms_str.split('-'))
    if a > b:
        return "MS1"
    if a < b:
        return "MS2"
    return "MSX"

def xl_col_to_idx(s: str) -> int:
    s = s.strip().upper()
    val = 0
    for ch in s:
        val = val * 26 + (ord(ch) - ord('A') + 1)
    return val - 1

FEATURE_LETTERS = [
    "I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","AA","AB","AC","AD","AE","AF"
]

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    content = await file.read()
    with open("/tmp/_data.xlsx", "wb") as f:
        f.write(content)

    df = pd.read_excel("/tmp/_data.xlsx", engine="openpyxl")

    ms_series = df.iloc[:, xl_col_to_idx("F")].apply(fix_score)
    home = df.iloc[:, xl_col_to_idx("E")].astype(str).fillna("")
    away = df.iloc[:, xl_col_to_idx("G")].astype(str).fillna("")

    feat_idx = [xl_col_to_idx(c) for c in FEATURE_LETTERS]
    X = df.iloc[:, feat_idx].apply(lambda s: pd.to_numeric(s, errors="coerce")).fillna(0.0)

    y = ms_series.map(ms_to_class).fillna("MSX")

    model = RandomForestClassifier(n_estimators=380, random_state=42)
    model.fit(X.values, y.values)

    preds = model.predict_proba(X.values)
    classes = model.classes_.tolist()

    out = []
    for i in range(len(df)):
        probs = {classes[j]: float(preds[i][j]) for j in range(len(classes))}
        best = max(probs, key=probs.get)
        conf = int(round(100 * probs[best]))
        if conf >= 70:
            risk = "YESIL"
        elif conf >= 40:
            risk = "SARI"
        else:
            risk = "KIRMIZI"

        if best == "MS1":
            skor = "2-1" if conf >= 60 else "1-0"
        elif best == "MS2":
            skor = "1-2" if conf >= 60 else "0-1"
        else:
            skor = "1-1"

        out.append({
            "match": f"{home.iloc[i]} - {away.iloc[i]}",
            "ms": best,
            "confidence": conf,
            "risk": risk,
            "score": skor,
        })

    return {"ok": True, "predictions": out}

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import Optional, List
import joblib
import numpy as np

app = FastAPI(title="Study Hours → Score API", version="0.2.0")

# Modeli yükle
try:
    model = joblib.load("best_model.pkl")  # dosya aynı klasörde olmalı
except Exception as e:
    model = None
    print(f"[WARN] Model yüklenemedi: {e}")

class PredictIn(BaseModel):
    hours: Optional[float] = Field(None, ge=0, le=12)
    features: Optional[List[float]] = None

class PredictOut(BaseModel):
    predicted: float
    proba: Optional[float] = None

@app.get("/health")
def health():
    return {"status": "ok", "model_loaded": model is not None}

@app.post("/predict", response_model=PredictOut)
def predict(p: PredictIn):
    if model is None:
        raise HTTPException(status_code=500, detail="Model yüklenmedi (best_model.pkl bulunamadı).")
    if p.features is not None:
        X = np.array(p.features, dtype=float).reshape(1, -1)
    elif p.hours is not None:
        X = np.array([[float(p.hours)]], dtype=float)
    else:
        raise HTTPException(status_code=400, detail="hours veya features göndermelisiniz.")

    proba = float(model.predict_proba(X)[0][1]) if hasattr(model, "predict_proba") else None
    yhat = float(model.predict(X)[0])
    return PredictOut(predicted=yhat, proba=proba)

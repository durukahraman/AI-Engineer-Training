import joblib
import numpy as np
from sklearn.linear_model import LinearRegression

# Basit dataset: çalışma saatine göre not
X = np.array([[1], [2], [3], [4], [5], [6], [7], [8], [9], [10]])
y = np.array([10, 20, 30, 40, 50, 60, 70, 80, 90, 100])

# Modeli eğit
model = LinearRegression()
model.fit(X, y)

# Modele kaydet
joblib.dump(model, "best_model.pkl")

print("✅ Model best_model.pkl olarak kaydedildi"),


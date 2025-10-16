# predict_image.py
import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image
import os

# === 1️⃣ Path model & label ===
model_path = "output/melon_model_best.h5"
labels_path = "output/labels.txt"

# === 2️⃣ Load model dan label ===
model = tf.keras.models.load_model(model_path)

with open(labels_path, "r") as f:
    labels = [line.strip() for line in f.readlines() if line.strip()]

print("📋 Label urutan:", labels)

# === 3️⃣ Fungsi prediksi gambar ===
def predict_melon(image_path):
    img = image.load_img(image_path, target_size=(150, 150))
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0) / 255.0  # normalisasi

    predictions = model.predict(img_array)
    predicted_index = np.argmax(predictions)
    confidence = np.max(predictions)
    predicted_class = labels[predicted_index]

    print(f"\n🖼️ Gambar: {os.path.basename(image_path)}")
    print(f"🔍 Prediksi: {predicted_class}")
    print(f"📈 Confidence: {confidence * 100:.2f}%")

# === 4️⃣ Tes prediksi ===
image_path = "D:/melonFILE/Dataset/Healthy/health (1).png"
predict_melon(image_path)

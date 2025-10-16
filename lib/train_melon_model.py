# train_melon_model.py
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Dropout
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint
import os

# === 1️⃣ Path Dataset ===
dataset_dir = "D:/melonFILE/Dataset"

# === 2️⃣ Data Generator (augmentasi + validasi) ===
datagen = ImageDataGenerator(
    rescale=1./255,
    validation_split=0.2,
    rotation_range=40,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    brightness_range=[0.6, 1.4],
    horizontal_flip=True,
    vertical_flip=True,
    fill_mode='nearest'
)


train_data = datagen.flow_from_directory(
    dataset_dir,
    target_size=(150, 150),
    batch_size=32,
    class_mode='categorical',
    subset='training',
    shuffle=True
)

val_data = datagen.flow_from_directory(
    dataset_dir,
    target_size=(150, 150),
    batch_size=32,
    class_mode='categorical',
    subset='validation',
    shuffle=False
)

print("\n📊 Kelas terdeteksi:", train_data.class_indices)

# === 3️⃣ Model MobileNetV2 (transfer learning) ===
base_model = MobileNetV2(
    input_shape=(150, 150, 3),
    include_top=False,
    weights='imagenet'
)
base_model.trainable = True  # sebelumnya False

# Bekukan dulu sebagian besar layer awal (biar tidak overfit)
for layer in base_model.layers[:100]:
    layer.trainable = False

model = Sequential([
    base_model,
    GlobalAveragePooling2D(),
    Dense(256, activation='relu'),
    Dropout(0.5),
    Dense(train_data.num_classes, activation='softmax')
])

# === 4️⃣ Kompilasi ===
model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001),
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

# === 5️⃣ Callback ===
callbacks = [
    EarlyStopping(monitor='val_accuracy', patience=5, restore_best_weights=True),
    ModelCheckpoint('output/melon_model_best.h5', monitor='val_accuracy', save_best_only=True)
]

# === 6️⃣ Training ===
history = model.fit(
    train_data,
    validation_data=val_data,
    epochs=30,
    callbacks=callbacks
)

# === 7️⃣ Simpan model akhir ===
os.makedirs("output", exist_ok=True)
model.save("output/melon_model.h5")

# === 8️⃣ Konversi ke TFLite (pakai model terbaik) ===
best_model = tf.keras.models.load_model("output/melon_model_best.h5")
converter = tf.lite.TFLiteConverter.from_keras_model(best_model)
tflite_model = converter.convert()

with open("output/model_melon.tflite", "wb") as f:
    f.write(tflite_model)

# === 9️⃣ Simpan labels.txt dengan urutan index yang benar ===
labels = [None] * len(train_data.class_indices)
for label, index in train_data.class_indices.items():
    labels[index] = label

with open("output/labels.txt", "w") as f:
    f.write("\n".join(labels))

print("\n✅ Model & labels berhasil disimpan di folder 'output/'")
print("📋 Urutan label sesuai index:", labels)

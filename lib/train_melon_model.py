# === train_melon_model.py ===
import os
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Dropout
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint
import firebase_admin
from firebase_admin import credentials, storage
import tempfile

# === 1️⃣ Inisialisasi Firebase ===
cred = credentials.Certificate("D:/melonFILE/tadd-2c10d-firebase-adminsdk-liefy-17710846cd.json")
firebase_admin.initialize_app(cred, {
    'storageBucket': 'tadd-2c10d.appspot.com'
})
bucket = storage.bucket()

# === 2️⃣ Download dataset dari Firebase Storage ===
def download_folder_from_firebase(prefix, local_dir):
    """Download seluruh isi folder (prefix) dari Firebase Storage."""
    blobs = bucket.list_blobs(prefix=prefix)
    for blob in blobs:
        if blob.name.endswith('/'):  # skip folder kosong
            continue
        local_path = os.path.join(local_dir, os.path.relpath(blob.name, prefix))
        os.makedirs(os.path.dirname(local_path), exist_ok=True)
        blob.download_to_filename(local_path)
        print(f"📥 Downloaded: {blob.name}")

# Buat folder sementara untuk dataset
dataset_dir = tempfile.mkdtemp()
print(f"\n📂 Folder dataset sementara: {dataset_dir}")

# Download folder Dataset/ dari Firebase Storage
download_folder_from_firebase("Dataset", dataset_dir)
print("✅ Dataset berhasil diunduh dari Firebase Storage!\n")

# === 3️⃣ Data Generator ===
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

# === 4️⃣ Model MobileNetV2 ===
base_model = MobileNetV2(
    input_shape=(150, 150, 3),
    include_top=False,
    weights='imagenet'
)
base_model.trainable = True
for layer in base_model.layers[:100]:
    layer.trainable = False

model = Sequential([
    base_model,
    GlobalAveragePooling2D(),
    Dense(256, activation='relu'),
    Dropout(0.5),
    Dense(train_data.num_classes, activation='softmax')
])

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001),
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

# === 5️⃣ Callback ===
os.makedirs("output", exist_ok=True)
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

# === 7️⃣ Simpan model ===
model.save("output/melon_model.h5")

# === 8️⃣ Konversi ke TFLite ===
best_model = tf.keras.models.load_model("output/melon_model_best.h5")
converter = tf.lite.TFLiteConverter.from_keras_model(best_model)
tflite_model = converter.convert()

with open("output/model_melon.tflite", "wb") as f:
    f.write(tflite_model)

# === 9️⃣ Simpan labels.txt ===
labels = [None] * len(train_data.class_indices)
for label, index in train_data.class_indices.items():
    labels[index] = label

with open("output/labels.txt", "w") as f:
    f.write("\n".join(labels))

print("\n✅ Model & labels berhasil disimpan di folder 'output/'")
print("📋 Urutan label:", labels)

# === 🔟 Upload hasil ke Firebase Storage ===
from google.cloud import storage

def upload_to_firebase(local_path, bucket_path):
    client = storage.Client.from_service_account_json("firebase-key.json")
    bucket = client.bucket("tadd-2c10d.appspot.com")
    blob = bucket.blob(bucket_path)
    blob.upload_from_filename(local_path)
    print("✅ Upload berhasil:", bucket_path)

upload_to_firebase("output/melon_model.h5", "models/melon_model.h5")
upload_to_firebase("output/labels.txt", "models/labels.txt")


print("\n🎉 Semua file model sudah di-upload ke Firebase Storage!")

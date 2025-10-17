from google.cloud import storage

# === Konfigurasi ===
firebase_key_path = "D:/melonFILE/tadd-2c10d-firebase-adminsdk-liefy-17710846cd.json"
local_model_path = "D:/PBLS5/melonguard/lib/output/melon_model.h5"   # ubah ke lokasi file model kamu
firebase_bucket_name = "tadd-2c10d.appspot.com"
destination_path = "models/melon_model.h5"  # lokasi tujuan di Firebase Storage

# === Upload Proses ===
def upload_to_firebase(local_path, bucket_path):
    print("🔄 Mengunggah ke Firebase Storage...")
    client = storage.Client.from_service_account_json(firebase_key_path)
    bucket = client.bucket(firebase_bucket_name)
    blob = bucket.blob(bucket_path)

    blob.upload_from_filename(local_path, timeout=300)
    print(f"✅ Berhasil upload '{local_path}' ke '{bucket_path}'")

if __name__ == "__main__":
    upload_to_firebase(local_model_path, destination_path)

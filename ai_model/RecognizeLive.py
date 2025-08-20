import cv2
import torch
import numpy as np
from facenet_pytorch import MTCNN, InceptionResnetV1
from PIL import Image
from scipy.spatial.distance import cosine
import os

# Initialize models
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
mtcnn = MTCNN(keep_all=True, device=device)
resnet = InceptionResnetV1(pretrained='vggface2').eval().to(device)

# Load saved embeddings
embedding_dir = 'Embeddings'
embeddings = {}
for file in os.listdir(embedding_dir):
    if file.endswith('.npy'):
        name = os.path.splitext(file)[0]
        embeddings[name] = np.load(os.path.join(embedding_dir, file))

# Function to recognize face
def recognize(face_tensor):
    with torch.no_grad():
        embedding = resnet(face_tensor.unsqueeze(0).to(device)).cpu().numpy()[0]

    best_match = None
    best_score = 1.0

    for name, saved_emb in embeddings.items():
        score = cosine(embedding, saved_emb)
        if score < best_score:
            best_score = score
            best_match = name

    if best_score < 0.5:
        return best_match, 1 - best_score
    else:
        return "Unknown", 0

# Start webcam
cap = cv2.VideoCapture(0)
print("🔴 Press 'q' to quit")

while True:
    ret, frame = cap.read()
    if not ret:
        break

    img = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
    boxes, probs = mtcnn.detect(img)

    if boxes is not None:
        for box in boxes:
            x1, y1, x2, y2 = [int(b) for b in box]
            face_crop = img.crop((x1, y1, x2, y2)).resize((160, 160))
            face_tensor = torch.tensor(np.array(face_crop)).permute(2, 0, 1).float() / 255.0

            name, conf = recognize(face_tensor)

            cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
            cv2.putText(frame, f"{name} ({conf:.2f})", (x1, y1 - 10),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
            print(name)

    cv2.imshow("Live Face Recognition", frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()

from flask import Flask, request, jsonify
from PIL import Image
import io
import torch
import numpy as np
from facenet_pytorch import MTCNN, InceptionResnetV1
from scipy.spatial.distance import cosine

app = Flask(__name__)

# Initialize models (reuse your current setup)
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
mtcnn = MTCNN(keep_all=True, device=device)
resnet = InceptionResnetV1(pretrained='vggface2').eval().to(device)

# Load your saved embeddings as before
import os
embedding_dir = 'Embeddings'
embeddings = {}
for file in os.listdir(embedding_dir):
    if file.endswith('.npy'):
        name = os.path.splitext(file)[0]
        embeddings[name] = np.load(os.path.join(embedding_dir, file))

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

@app.route('/recognize', methods=['POST'])
def recognize_faces():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file'}), 400

    file = request.files['image']
    img_bytes = file.read()
    img = Image.open(io.BytesIO(img_bytes)).convert('RGB')

    boxes, probs = mtcnn.detect(img)

    results = []
    if boxes is not None:
        for box in boxes:
            x1, y1, x2, y2 = [int(b) for b in box]
            face_crop = img.crop((x1, y1, x2, y2)).resize((160, 160))
            face_tensor = torch.tensor(np.array(face_crop)).permute(2, 0, 1).float() / 255.0

            name, conf = recognize(face_tensor)
            results.append({'name': name, 'confidence': conf, 'box': [x1, y1, x2, y2]})

    return jsonify({'results': results})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
    
import torch
import torchvision
from torchvision import transforms
from torch.utils.data import DataLoader
from torch.utils.data.dataset import Dataset
import os
import numpy as np
import cv2
import matplotlib.pyplot as plt
import face_recognition
from torch.autograd import Variable
import time
import sys
#Model with feature visualization
from torch import nn
from torchvision import models
from werkzeug.utils import secure_filename
from flask import Flask, render_template, request, redirect, url_for, send_file
import cv2
import dlib
from googleapiclient.discovery import build
from google.oauth2 import service_account
from googleapiclient.http import MediaFileUpload
import base64
from io import BytesIO
from PIL import Image

app = Flask(__name__)

UPLOAD_FOLDER = 'static'
app.secret_key = "secret key"
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024



class Model(nn.Module):
    def __init__(self, num_classes, latent_dim=2048, lstm_layers=1, hidden_dim=2048, bidirectional=False):
        super(Model, self).__init__()
        model = models.resnext50_32x4d(pretrained=True)
        self.model = nn.Sequential(*list(model.children())[:-2])
        self.lstm = nn.LSTM(latent_dim, hidden_dim, lstm_layers, bidirectional)
        self.relu = nn.LeakyReLU()
        self.dp = nn.Dropout(0.4)
        self.linear1 = nn.Linear(2048, num_classes)
        self.avgpool = nn.AdaptiveAvgPool2d(1)

    def forward(self, x):
        batch_size, seq_length, c, h, w = x.shape
        x = x.view(batch_size * seq_length, c, h, w)
        fmap = self.model(x)
        x = self.avgpool(fmap)
        x = x.view(batch_size, seq_length, 2048)
        x_lstm, _ = self.lstm(x, None)
        return fmap, self.dp(self.linear1(x_lstm[:, -1, :]))

im_size = 112
mean = [0.485, 0.456, 0.406]
std = [0.229, 0.224, 0.225]
sm = nn.Softmax()
inv_normalize = transforms.Normalize(mean=-1 * np.divide(mean, std), std=np.divide([1, 1, 1], std))

def im_convert(tensor):
    """ Display a tensor as an image. """
    image = tensor.to("cpu").clone().detach()
    image = image.squeeze()
    image = inv_normalize(image)
    image = image.numpy()
    image = image.transpose(1, 2, 0)
    image = image.clip(0, 1)
    cv2.imwrite('./2.png', image * 255)
    return image

device = torch.device('cpu')



def detect_face(image_path=None, video_path=None):
    # Initialize Dlib's face detector
    detector = dlib.get_frontal_face_detector()
    # If a video path is provided
    if video_path:
        face_cascade=cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
        cap = cv2.VideoCapture(video_path)
        while True:
            ret, frame = cap.read()
            if not ret:
                break

            # Convert to grayscale
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            # Detect faces using Dlib
            faces = face_cascade.detectMultiScale(gray,1.9,6)
            
            if len(faces)>0:
                return True
    
    # If an image path is provided
    elif image_path:
        # Read the image
        img = cv2.imread(image_path)
        # Convert to grayscale
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        # Detect faces using Dlib
        faces = detector(gray, 1)
        # Return true if any face is detected
        if len(faces) > 0:
            return True
        else:
            return False

    
    return False


def predict(model, img, path='./'):
    fmap, logits = model(img.to(device))
    params = list(model.parameters())
    weight_softmax = model.linear1.weight.detach().cpu().numpy()
    logits = sm(logits)
    _, prediction = torch.max(logits, 1)
    print('confidence of prediction:', logits[:, int(prediction.item())].item() * 100)
    confidence=logits[:, int(prediction.item())].item() * 100
    confidence=round(confidence,4)
    idx = np.argmax(logits.detach().cpu().numpy())
    bz, nc, h, w = fmap.shape
    out = np.dot(fmap[-1].detach().cpu().numpy().reshape((nc, h * w)).T, weight_softmax[idx, :].T)
    predict = out.reshape(h, w)
    predict = predict - np.min(predict)
    predict_img = predict / np.max(predict)
    predict_img = np.uint8(255 * predict_img)
    out = cv2.resize(predict_img, (im_size, im_size))
    heatmap = cv2.applyColorMap(out, cv2.COLORMAP_JET)
    img = im_convert(img[:, -1, :, :, :])
    result = heatmap * 0.5 + img * 0.8 * 255
    cv2.imwrite('./content/1.png', result)
    result1 = heatmap * 0.5 / 255 + img * 0.8
    r, g, b = cv2.split(result1)
    result1 = cv2.merge((r,g,b))
    # plt.imshow(result1)
    # plt.show()
    # result = result.astype(np.uint8)
    # result_img = Image.fromarray(result)
    # b = BytesIO()
    # result_img.save(b, format="png")
    # b.seek(0)
    # img = base64.b64encode(b.read()).decode('ascii')
    _, buffer = cv2.imencode('.png', result)
    img = base64.b64encode(buffer).decode('ascii')
    prediction_result=[int(prediction.item()), confidence]
    label = "REAL" if prediction_result[0] == 1 else "FAKE"
    return str(confidence), label,img

class validation_dataset(Dataset):
    def __init__(self, video_path, sequence_length=60, transform=None):
        self.video_path = video_path
        self.transform = transform
        self.count = sequence_length

    def __len__(self):
        return 1  # Only one video

    def __getitem__(self, idx):
        frames = []
        a = int(100 / self.count)
        first_frame = np.random.randint(0, a)
        for i, frame in enumerate(self.frame_extract(self.video_path)):
            faces = face_recognition.face_locations(frame)
            try:
                top, right, bottom, left = faces[0]
                frame = frame[top:bottom, left:right, :]
            except:
                pass
            frames.append(self.transform(frame))
            if len(frames) == self.count:
                break
        frames = torch.stack(frames)
        frames = frames[:self.count]
        return frames.unsqueeze(0)

    def frame_extract(self, path):
        vidObj = cv2.VideoCapture(path)
        success = 1
        while success:
            success, image = vidObj.read()
            if success:
                yield image

@app.route('/predict_media', methods=['POST'])
def upload_media():
    print("Start Predicting.....")
    im_size = 112
    mean = [0.485, 0.456, 0.406]
    std = [0.229, 0.224, 0.225]

    train_transforms = transforms.Compose([
        transforms.ToPILImage(),
        transforms.Resize((im_size, im_size)),
        transforms.ToTensor(),
        transforms.Normalize(mean, std)])

    model = Model(2).to(device)
    data_object = {}
    file = request.files['file']
    filename = secure_filename(file.filename)
    file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
    filepath = 'D:\\Hifza\\fyp\\API\\' + 'static/' + filename
    print("**********", filepath)
    
    # Check if the file is an image or a video
    if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
        is_face_detected = detect_face(image_path=filepath)
    else:
        is_face_detected = detect_face(video_path=filepath)
    
    # Process the file based on face detection
    if is_face_detected:
        print("Face detected in the media file.")
        video_dataset = validation_dataset(filepath, sequence_length=20, transform=train_transforms)
        path_to_model = 'D:\\Hifza\\fyp\\API\\model\\model_93_acc_20_frames_final_data.pt'
        model.load_state_dict(torch.load(path_to_model, map_location='cpu'))
        model.eval()
        confidence,label,img = predict(model, video_dataset[0], './')
        #output_path=face_detection(filepath)
        data_object['label']=label
        data_object['confidence']=confidence
        data_object["img"] = img
        return data_object
    else:
        print("No face detected in the media file.")
        data_object['label'] = 'No Face Detected'
        data_object['confidence'] = '0.00'
        data_object["img"] = ''

    return data_object





if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000)
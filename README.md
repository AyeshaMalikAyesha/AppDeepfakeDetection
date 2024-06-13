# Deepfake Detection Using Deep Learning(ResNeXt50 and LSTM)

# Give a Star⭐ to Repo

This projects aims in detection of video deepfakes using deep learning techniques like ResNeXt50 and LSTM. We have achived deepfake detection by using transfer learning where the pretrained ResNext CNN is used to obtain a feature vector, further the LSTM layer is trained using the features.

You can clone this flutter application using below command:

git clone https://github.com/AyeshaMalikAyesha/AppDeepfakeDetection.git

# Key Features:

The features in our app is:

💡 𝑨𝒄𝒄𝒖𝒓𝒂𝒄𝒚: We achieved an accuracy of 93% on training set and 75% on test set.

💡 𝑨𝒅𝒗𝒂𝒏𝒄𝒆𝒅 𝑫𝒆𝒕𝒆𝒄𝒕𝒊𝒐𝒏: Utilizing cutting-edge AI and machine learning algorithms, our app can accurately identify deepfake videos 
   and images.
   
💡 𝑹𝒆𝒂𝒍-𝒕𝒊𝒎𝒆 𝑨𝒏𝒂𝒍𝒚𝒔𝒊𝒔: Get instant results with our high-speed processing, ensuring you can verify content quickly and efficiently.

💡 𝑼𝒔𝒆𝒓-𝑭𝒓𝒊𝒆𝒏𝒅𝒍𝒚 𝑰𝒏𝒕𝒆𝒓𝒇𝒂𝒄𝒆: Our app is designed with ease of use in mind, making deepfake detection accessible to everyone, from tech experts to everyday users.

💡 𝑪𝒐𝒎𝒑𝒓𝒆𝒉𝒆𝒏𝒔𝒊𝒗𝒆 𝑹𝒆𝒑𝒐𝒓𝒕𝒊𝒏𝒈: Receive detailed reports on the detected deepfakes, providing insights into the authenticity of the media.

💡 𝑪𝒐𝒎𝒎𝒖𝒏𝒊𝒕𝒚 𝑭𝒐𝒓𝒖𝒎: Our forum is a dynamic, interactive space designed for users, experts, and enthusiasts of our deepfake detection app.

# API

api.py file contains the API in which http request from flutter app is passed to server through api where preprocessing and prediction occur.To properly set up the model for the API, follow these steps:

1. **Train the Model**: Begin by training your model.
2. **Save and Download the Model**: Once the model is trained, save it and download the model file.
3. **Update Local Repository**: Save the downloaded model file in your local repository.
4. **Modify Path in `api.py`**: Update the `path_to_model` variable in the `api.py` file to reflect the new location of the model file.
5. **Create Static Folder**: Ensure that a `static` folder is created in your project directory. This folder will store user input files.
6. **Update Filepath in `api.py`**: Update the `filepath` variable in the `api.py` file to point to the newly created `static` folder here on line 207 in api.py filepath = 'D:\\Hifza\\fyp\\API\\' + 'static/' + filename  Now here you should replace  this 'D:\\Hifza\\fyp\\API\\' with the path where static folder present.

By completing these steps, you will ensure that the API is correctly configured to utilize the trained model and handle user inputs effectively.

# Model Training

For preprocessing of videos and model Training we used the code from <a href='https://github.com/abhijitjadhav1998/Deepfake_detection_using_deep_learning'>this Github repo</a>

# Run on Emulator

To run the application on an emulator, please follow these steps:

1. Navigate to the `scan_screen.dart` file located in the `lib/screens` directory.
2. Go to line 73 in the file.
3. Replace the following code:

```dart
var request = http.MultipartRequest(
  'POST',
  Uri.parse('https://sparrow-helpful-yearly.ngrok-free.app/predict_media'));
```

with this code:

```dart
var request = http.MultipartRequest(
  'POST', 
  Uri.parse('http://10.0.2.2:5000/predict_media'));
```

This change will configure the app to use the appropriate API endpoint for the emulator.


# Run on real device

To run the application on a real device, please follow these instructions:

1. Visit [Ngrok Setup for Windows](https://dashboard.ngrok.com/get-started/setup/windows) and sign in.

2. In the "Step 1: Connect" section, go to the download section and download Ngrok for Windows (64-bit or 32-bit) according to your system specifications.

3. After downloading, install Ngrok and add its installation path to the PATH variable under system variables.

4. Once Ngrok is installed, return to the Ngrok dashboard and go to the "Deploy Your App Online" section. Find the "Static Domain" section and copy the domain. For example, the domain might be: `ngrok http --domain=macaw-elegant-ghastly.ngrok-free.app 80`. In your case it is different.

5. Replace `80` with `5000` in the copied domain, resulting in: `ngrok http --domain=macaw-elegant-ghastly.ngrok-free.app 5000`.

6. Open Visual Studio Code, ensure the API is running, and paste the modified command (`ngrok http --domain=macaw-elegant-ghastly.ngrok-free.app 5000`) into the terminal.

7. Now go to scan_screen.dart file, navigate to line 76 and replace this part 'https://sparrow-helpful-yearly.ngrok-free.app' of the line with this 'https://macaw-elegant-ghastly.ngrok-free.app'. In your case your static domain will be different.

This setup will allow you to run the application on a real device.

# Demo

You can watch the video for demo:

<a href='https://www.linkedin.com/posts/ayesha76_deepfakedetection-ai-machinelearning-activity-7199006954034233344-9TdQ?utm_source=share&utm_medium=member_desktop'>Click here</a>

# Contributors

1. Ayesha
2. Sania Batool
3. Sana Anwar

# Contact me

For any queries you can ask it in issues section or feel free to email me at ayeshafareed76@gmail.com



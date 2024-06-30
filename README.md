This is the android application.
Built with Flutter and Flask.
Prerequisites:
-Conda
-CUDA
Setup Instructions:
1. Clone branch git clone --branch mobile https://github.com/namirahrasul/DSRNet.git
2. conda create -n newCondaEnvironment -c cctbx202208 -y
3. conda activate newCondaEnvironment
4. conda install -c cctbx202208 python=3.9
5.Install all cuda software and toolkit with conda
5. cd ReflectionEraser/server
6. pip install -r DSRNet/requirements.txt
7. cd ReflectionEraser/client
8. flutter pub get

Running Instructions:
To  run server:
1.conda activate newCondaEWnvironment
2.python server/app.py
Open a second terminal for client:
1. cd client
2. flutter run

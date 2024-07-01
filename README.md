## Android Application

Built with Flutter and Flask.

### Prerequisites

1. Conda
2. CUDA

### Setup Instructions

1. Clone the branch:
    ```sh
    git clone --branch mobile https://github.com/namirahrasul/ReflectionEraser.git
    ```
2. Create a new Conda environment:
    ```sh
    conda create -n newCondaEnvironment -c cctbx202208 -y
    ```
3. Activate the new environment:
    ```sh
    conda activate newCondaEnvironment
    ```
4. Install Python 3.9 and CUDA:
    ```sh
    conda install -c cctbx202208 python=3.9
    ```
5. Install all CUDA software and toolkit with Conda.
6. Navigate to the server directory and install requirements:
    ```sh
    cd ReflectionEraser/server
    pip install -r DSRNet/requirements.txt
    ```
7. Navigate to the client directory and get Flutter packages:
    ```sh
    cd ReflectionEraser/client
    flutter pub get
    ```

### Running Instructions

To run the server:

1. Activate the Conda environment:
    ```sh
    conda activate newCondaEnvironment
    ```
2. Run the server application:
    ```sh
    python server/app.py
    ```

Open a second terminal for the client:

1. Navigate to the client directory:
    ```sh
    cd client
    ```
2. Run the Flutter application:
    ```sh
    flutter run
    ```

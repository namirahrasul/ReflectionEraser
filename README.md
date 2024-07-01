## Android Application

Built with Flutter and Flask.

### Prerequisites

1. Conda
2. CUDA

### Setup Instructions

1. Clone the branch:
    ```sh
    git clone --branch desktop https://github.com/namirahrasul/ReflectionEraser.git
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
6. Install requirements:
    ```sh
    pip install -r DSRNet/requirements.txt
    ```

### Running Instructions:
```sh
    python main-window.py
```

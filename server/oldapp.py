from flask import Flask, request, jsonify
import os
import subprocess
from werkzeug.utils import secure_filename
app = Flask(__name__)
UPLOAD_FOLDER = '/home/nami/reflection_removal/server/upload'  # Specify your upload folder path
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}  # Specify allowed extensions

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/upload-image', methods=['POST'])
def upload_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image part'}), 400

    file = request.files['image']

    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
    

    try:
        print("iMAGE PATH")
        print(file_path)
        
    
        # Example subprocess command using the image path
        result = subprocess.run(
            f'python server/DSRNet/test_sirs.py --inet dsrnet_s --model dsrnet_model_sirs --dataset sirs_dataset --name dsrnet_s_test --hyper --if_align --resume --weight_path "/home/nami/reflection_removal/server/DSRNet/weights/dsrnet_s_epoch14.pt" --base_dir "/home/nami/reflection_removal/server/upload" --nThreads 0 ',
            shell=True,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        return jsonify({'output': result.stdout.decode()}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)

import os
from os.path import join


# import sys
# sys.path.append('DSRNet/')

import sys
import os


# Get the absolute path of the current directory
dsrnet_path = os.path.abspath('DSRNet')

# Add the IBCLN directory to the Python path
sys.path.append(dsrnet_path)
print(sys.path)


import torch.backends.cudnn as cudnn

import data.sirs_dataset as datasets
from data.image_folder import read_fns
from engine import Engine
from options.net_options.train_options import TrainOptions
from tools import mutils



opt = TrainOptions().parse()

opt.isTrain = False
cudnn.benchmark = True
opt.no_log = True
opt.display_id = 0
opt.verbose = False

opt.inet = 'dsrnet_l'
opt.model = 'dsrnet_model_sirs'
opt.dataset = None
opt.name = 'dsrnet_l_test'
opt.hyper = True
opt.if_align = True
opt.resume = True
opt.weight_path = "DSRNet/weights/dsrnet_l_epoch18.pt"
# opt.base_dir = "../reflection-removal"
opt.nThreads = 0

def predict(image_path): 

    # datadir = os.path.join(opt.base_dir, 'test/real45')

    datadir = image_path

    test_dataset_real = datasets.RealDataset(datadir, size = 1, single_image_path= image_path)

    test_dataloader_real = datasets.DataLoader(test_dataset_real, batch_size=1, shuffle=True, num_workers=opt.nThreads,
                                            pin_memory=True)

    engine = Engine(opt)

    """Main Loop"""
    # result_dir = os.path.join('./checkpoints', opt.name, mutils.get_formatted_time())
    result_dir = os.path.abspath('DSRNet\image_outputs')

    res = engine.test(test_dataloader_real, savedir=join(result_dir, 'test'))

    out_file_name, _ = os.path.splitext(os.path.basename(image_path))

    out_path = join(result_dir, join('test', join(out_file_name, 'dsrnet_l_test_l.png')))
    print(out_path)
    out_path = out_path.replace("\\", "/")
    return out_path

    # res = engine.predict_single(test_dataloader_real, savedir=join(result_dir, 'test'))

if __name__ == '__main__':
    predict("E:/reflection-removal/reflection-removal/train/real/blended/26.jpg")
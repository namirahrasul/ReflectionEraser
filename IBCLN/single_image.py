
import sys
import os

# sys.path.append('IBCLN/')

# Get the absolute path of the current directory
dsrnet_path = os.path.abspath('IBCLN')

# Add the IBCLN directory to the Python path
sys.path.append(dsrnet_path)

import os
from options.test_options import TestOptions
from data import create_dataset
from models import create_model
from util.visualizer import save_images
from util import html


opt = TestOptions().parse()  # get test options
# hard-code some parameters for test
opt.num_threads = 0   # test code only supports num_threads = 1
opt.batch_size = 1    # test code only supports batch_size = 1
opt.serial_batches = True  # disable data shuffling; comment this line if results on randomly chosen images are needed.
opt.no_flip = True    # no flip; comment this line if results on flipped images are needed.
opt.display_id = -1   # no visdom display; the test code saves the results to a HTML file.


opt.dataroot = 'IBCLN/datasets/reflection'
opt.name = 'IBCLN'
opt.model = 'IBCLN'
opt.dataset_mode = 'resize_natural_3'
opt.no_flip = True
opt.epoch = 'final'
opt.is_single_image = 1

model = create_model(opt)      # create a model given opt.model and other options
model.setup(opt)               # regular setup: load and print networks; create schedulers

# create a website
web_dir = os.path.join(opt.results_dir, opt.name, '%s_%s' % (opt.phase, opt.epoch))  # define the website directory
webpage = html.HTML(web_dir, 'Experiment = %s, Phase = %s, Epoch = %s' % (opt.name, opt.phase, opt.epoch))

def predict(image_path):
    opt.single_image_path = image_path
    dataset = create_dataset(opt)  # create a dataset given opt.dataset_mode and other options
   
    if opt.eval:
        model.eval()
    for i, data in enumerate(dataset):
        print(opt.num_test)
        if i >= opt.num_test:  # only apply our model to opt.num_test images.
            break
        model.set_input(data)  # unpack data from data loader
        model.test()           # run inference
        visuals = model.get_current_visuals()  # get image results
        img_path = model.get_image_paths()     # get image paths

        if i % 5 == 0:  # save images to an HTML file
            print('processing (%04d)-th image... %s' % (i, img_path))
            # print loss_2T in recursive_models
        save_images(webpage, visuals, img_path, aspect_ratio=opt.aspect_ratio, width=opt.display_winsize)
    webpage.save()  # save the HTML
    out_file_name, _ = os.path.splitext(os.path.basename(image_path))
    out_file_name = out_file_name + '_fake_Ts_03.png'
    out_image_path = os.path.join('IBCLN/results/IBCLN/test_final/images', out_file_name)
    return  out_image_path


if __name__ == '__main__':
    print(predict("E:/YTMT model/Onno MODELS/IBCLN/IBCLN-master/4.jpg"))
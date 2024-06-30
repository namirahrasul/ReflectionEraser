import os
from os.path import join

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
datadir = opt.base_dir
test_dataset_real = datasets.RealDataset(datadir)
                                            
#test_dataset_real = datasets.RealDataset('./data')
test_dataloader_real = datasets.DataLoader(test_dataset_real, batch_size=1, shuffle=True, num_workers=opt.nThreads,
                                           pin_memory=True)

engine = Engine(opt)

"""Main Loop"""
result_dir = "/home/nami/reflection_removal/server/upload"

res = engine.test(test_dataloader_real, savedir=result_dir)

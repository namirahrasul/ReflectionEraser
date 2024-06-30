import os


class Filepaths:
    __MAIN_WINDOW = 'main-window.ui'
  
    @staticmethod
    def MAIN_WINDOW():
        return os.path.abspath(Filepaths.__MAIN_WINDOW)





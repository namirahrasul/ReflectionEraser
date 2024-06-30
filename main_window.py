from PyQt6 import uic
from PyQt6.QtCore import *
from PyQt6.QtGui import *
from PyQt6.QtWidgets import *

from filepaths import Filepaths
from DSRNet import single_image

    
class UI_MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        uic.loadUi(Filepaths.MAIN_WINDOW(), self)
        self.setWindowTitle('Reflection Eraser')
        self.setFixedSize(1200, 700)

        """Loading necessary objects from the loaded ui."""
        # The canvas is to hold the image to be shown on the screen.
        self.input_canvas = self.findChild(QGraphicsView, 'input_canvas')
        self.output_canvas = self.findChild(QGraphicsView, 'output_canvas')
        self.upload_btn = self.findChild(QPushButton, 'upload_btn')
        self.remove_reflection_btn = self.findChild(QPushButton, 'remove_reflection_btn')
        self.save_btn = self.findChild(QPushButton, 'save_btn')

        """Some necessary variables needed for canvas. Initializing with None now. will need later."""

        """Some event handlers needed for different operations."""
        self.upload_btn.clicked.connect(self.open_input_image)
        self.remove_reflection_btn.clicked.connect(self.open_output_image)
        self.save_btn.clicked.connect(self.save_new_file)

        # self.action_save_as.triggered.connect(self.save_new_file)
        # self.action_open.triggered.connect(self.open_image)
        # self.action_save.triggered.connect(self.save_file)       


    def choose_file(self):
        """
        Opens a file dialog. lets the user choose a file to open and returns the path of the file.
        :return: the path of the selected file.
        """
        file_dialogue = QFileDialog(self)
        filters = "Images (*.jpg *.png *.bmp)"
        filenames, _ = file_dialogue.getOpenFileNames(self, filter=filters)
        if not filenames:
            return
        return filenames[0]

    def open_input_image(self):
        """
        Clicking 'Open' or pressing Ctrl+O \n
        Opens an image file and loads it into the screen.\n
        * Opens a file dialog. Using the choose_file() method.
        * If you select an image file, it loads it into the screen.
        :return:
        """
        image_file_path = self.choose_file()
        if image_file_path is None:
            return
        self.input_file_path = image_file_path
        self.save_file_path = None
        self.input_image = QImage(self.input_file_path)
        
        self.input_image = self.scale_image(self.input_image, self.input_canvas)

        pixmap = QPixmap(self.input_image)
        scene = QGraphicsScene()
        scene.addPixmap(pixmap)
        self.input_canvas.setScene(scene)
        if self.output_canvas.scene() is not None:
            self.output_canvas.scene().clear()
    
    def open_output_image(self):
        """
        Clicking 'Open' or pressing Ctrl+O \n
        Opens an image file and loads it into the screen.\n
        * Opens a file dialog. Using the choose_file() method.
        * If you select an image file, it loads it into the screen.
        :return:
        """
        image_file_path = single_image.predict(self.input_file_path)
        if image_file_path is None:
            return
        self.output_file_path = image_file_path
        self.save_file_path = None
        self.output_image = QImage(self.output_file_path)
        
        scene = QGraphicsScene()
        self.output_image = self.scale_image(self.output_image, self.output_canvas)
        self.output_pixmap = QPixmap(self.output_image)
        scene.addPixmap(self.output_pixmap)
        self.output_canvas.setScene(scene)

    # def enable_all(self):
    #     self.action_save_as.setEnabled(True)
    #     self.action_save.setEnabled(True)
    #     # self.blur_select_button.setEnabled(True)
    #     # self.rotate_button.setEnabled(True)

    def save_new_file(self):
        """
        Clicking 'Save as' or pressing Ctrl+Shift+S. \n
        If you want to save the image file for the first time, you need to create a file. \n
        So a file-dialogue will open to get the directory and the filename.
        :return:
        """
        file_dialogue = QFileDialog(self)
        filters = "Images (*.jpg *.png *.bmp)"
        file_path, _ = file_dialogue.getSaveFileName(filter=filters, parent=self)
        self.save_file_path = file_path
        if file_path:
            self.output_pixmap.save(file_path)

    # def save_file(self):
    #     """
    #     Clicking 'Save' or pressing Ctrl+S. \n
    #     Save the file, when the save-file already exists/created,
    #     :return:
    #     """
    #     if self.save_file_path:
    #         self.scene_pixmap.save(self.save_file_path)
    #     else:  # If the save-file is not created, call save_new_file()
    #         self.save_new_file()

    def scale_image(self, image, canvas):
        """
        If the original image is bigger than the canvas, scale it down to fit. \n
        But if it is smaller or equal, keep it as it is.
        :return:
        """
        if image.width() >= 512 or \
            image.height() >= 512:
            image = image.scaled(
                512,
                512,
                Qt.AspectRatioMode.KeepAspectRatio,
                Qt.TransformationMode.SmoothTransformation)
        

        return image

    # def event_update_canvas(self):
    #     if not self.canvas_controller.scene_image_updated:
    #         return
    #     self.update_canvas()
    
    # def update_canvas(self):
    #     self.input_pixmap = QPixmap(self.file_path)
    #     self.scale_pixmap()
    #     self.scene = QGraphicsScene()
    #     self.scene.addPixmap(self.scene_pixmap)
    #     self.canvas.setScene(self.scene)
    #     # self.canvas_controller.scene_image_updated.value = False

    # def resizeEvent(self, event):
    #     if self.original_pixmap:
    #         self.update_canvas()

    
if __name__ == "__main__":
    app = QApplication([])
    widget = UI_MainWindow()
    widget.show()
    app.exec()

    

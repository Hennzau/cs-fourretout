import pygame


class Image:
    def __init__(self, width=0, height=0):
        self.width = width
        self.height = height
        self.py_image = pygame.Surface((width, height))

    def load(self, py_image):
        self.width = py_image.get_width()
        self.height = py_image.get_height()
        self.py_image = py_image

    def draw_image(self, image, x, y):
        self.py_image.blit(image.py_image, (x, y))

    def draw_rect(self, color, rect):
        self.py_image.fill(color, rect)

    def fill(self, color):
        self.py_image.fill(color)

    def get_rect(self):
        return self.py_image.get_rect()

    def draw_disk(self, color, pos, radius):
        pygame.draw.circle(self.py_image, color, pos, radius)
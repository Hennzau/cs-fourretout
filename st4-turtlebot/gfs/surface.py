import pygame


def flip():
    pygame.display.flip()


def events():
    return pygame.event.get()


class Surface:
    def __init__(self, width, height, title):
        pygame.init()

        self.width = width
        self.height = height

        self.title = title
        pygame.display.set_caption(title)

        self.py_surface = pygame.display.set_mode((width, height))

    def clear(self, background_color):
        self.py_surface.fill(background_color)

    def blit(self, surface, x, y):
        self.py_surface.blit(surface, (x, y))

    def draw_image(self, image, x, y):
        self.py_surface.blit(image.py_image, (x, y))

    def draw_rect(self, color, rect):
        self.py_surface.fill(color, rect)

    def fill(self, color):
        self.py_surface.fill(color)

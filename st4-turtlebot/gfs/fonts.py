import pygame

from gfs.image import Image

pygame.font.init()

MOTO_MANGUCODE_50 = pygame.font.Font("assets/fonts/MotomangucodeBold-3zde3.ttf", 50)
MOTO_MANGUCODE_30 = pygame.font.Font("assets/fonts/MotomangucodeBold-3zde3.ttf", 30)
MOTO_MANGUCODE_10 = pygame.font.Font("assets/fonts/MotomangucodeBold-3zde3.ttf", 10)
BULLET_TRACE_30 = pygame.font.Font("assets/fonts/BulletTrace7-rppO.ttf", 30)


def render_font(font, text, color):
    py_image = font.render(text, True, color)

    image = Image()
    image.load(py_image)

    return image

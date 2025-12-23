import pygame

from gfs.image import Image
from gfs.fonts import MOTO_MANGUCODE_30, render_font
from gfs.surface import Surface

from gfs.pallet import IVORY, DARKBLUE, DARKGREY


class Button:
    def __init__(self, text, pos, function):
        self.text = text
        self.function = function
        self.pos = pos

        self.over = False

        self.text = render_font(MOTO_MANGUCODE_30, text, IVORY)
        self.rect = self.text.get_rect()
        self.rect = self.rect.move(pos[0], pos[1])

        self.over_image = Image(self.rect.width, self.rect.height)
        self.over_image.fill(DARKBLUE)
        self.over_image.draw_image(self.text, 0, 0)

        self.normal_image = Image(self.rect.width, self.rect.height)
        self.normal_image.fill(DARKGREY)
        self.normal_image.draw_image(self.text, 0, 0)

    def keyboard_input(self, event):
        pass

    def mouse_input(self, event):
        if event.type == pygame.MOUSEBUTTONDOWN:
            if self.rect.collidepoint(event.pos):
                self.function()

    def mouse_motion(self, event):
        self.over = self.rect.collidepoint(event.pos)

    def update(self):
        pass

    def render(self, surface):
        if self.over:
            surface.draw_image(self.over_image, self.pos[0], self.pos[1])
        else:
            surface.draw_image(self.normal_image, self.pos[0], self.pos[1])

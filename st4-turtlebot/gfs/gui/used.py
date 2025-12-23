import pygame

from gfs.image import Image
from gfs.fonts import MOTO_MANGUCODE_50, render_font
from gfs.surface import Surface

from gfs.pallet import IVORY, DARKBLUE, DARKGREY


class Used:
    def __init__(self, key, text, pos, function_over, function_normal):
        self.key = key
        self.text = text
        self.function_over = function_over
        self.function_normal = function_normal

        self.pos = pos

        self.over = False

        self.text = render_font(MOTO_MANGUCODE_50, text, IVORY)
        self.rect = self.text.get_rect()
        self.rect = self.rect.move(pos[0], pos[1])

        self.over_image = Image(self.rect.width, self.rect.height)
        self.over_image.fill(DARKBLUE)
        self.over_image.draw_image(self.text, 0, 0)

        self.normal_image = Image(self.rect.width, self.rect.height)
        self.normal_image.fill(DARKGREY)
        self.normal_image.draw_image(self.text, 0, 0)

    def keyboard_input(self, event):
        if event.type == pygame.KEYDOWN:
            if event.key == self.key:
                self.function_over()
                self.over = True
        elif event.type == pygame.KEYUP:
            if event.key == self.key:
                self.function_normal()
                self.over = False

    def mouse_input(self, event):
        pass

    def mouse_motion(self, event):
        pass

    def update(self):
        pass

    def render(self, surface):
        if self.over:
            surface.draw_image(self.over_image, self.pos[0], self.pos[1])
        else:
            surface.draw_image(self.normal_image, self.pos[0], self.pos[1])

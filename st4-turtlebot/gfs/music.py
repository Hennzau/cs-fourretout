import pygame


class Music:
    def __init__(self, background_music):
        pygame.mixer.init()
        pygame.mixer.set_num_channels(8)

        self.background = pygame.mixer.Channel(5)
        self.background_music = pygame.mixer.Sound(background_music)

    def update(self):
        if not self.background.get_busy():
            sound = pygame.mixer.Sound(self.background_music)
            sound.set_volume(2)

            self.background.play(sound)

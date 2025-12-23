import pygame

from gfs.surface import Surface, flip, events
from gfs.music import Music

from ei_viewer import EiViewer

import zenoh


# olivier@zettascale.tech

def main():
    surface = Surface(1280, 720, "ST4 EI1 - Interface!")
    clock = pygame.time.Clock()

    zenoh.init_logger()
    config = zenoh.Config.from_file("config.json")
    session = zenoh.open(config)

    ei_viewer = EiViewer(surface.width, surface.height, session)

    is_running = True
    timer = 0

    while is_running:
        for event in events():
            if event.type == pygame.QUIT:
                is_running = False
                ei_viewer.quit()

            elif event.type == pygame.KEYDOWN or event.type == pygame.KEYUP:
                ei_viewer.keyboard_input(event)
            elif event.type == pygame.MOUSEBUTTONDOWN or event.type == pygame.MOUSEBUTTONUP:
                ei_viewer.mouse_input(event)
            elif event.type == pygame.MOUSEMOTION:
                ei_viewer.mouse_motion(event)

        ei_viewer.update()

        surface.clear((0, 0, 0))

        ei_viewer.render(surface)

        flip()

        clock.tick(60)
        timer = (timer + 1) % 60

    pygame.quit()


if __name__ == "__main__":
    main()

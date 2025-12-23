from ei.main_view import MainView

import zenoh


class EiViewer:
    def __init__(self, width, height, session):
        self.session = session
        self.surface_configuration = (width, height)

        self.state = [
            MainView(width, height, self.session),
        ]

        self.current_state = 0

    def quit(self):
        for state in self.state:
            state.quit()

    def next_state(self):
        next_state = self.state[self.current_state].next_state
        if next_state is not None:
            self.state[self.current_state].next_state = None
            self.current_state = next_state

    def update(self):
        self.state[self.current_state].update()
        self.next_state()

    def keyboard_input(self, event):
        self.state[self.current_state].keyboard_input(event)
        self.next_state()

    def mouse_input(self, event):
        self.state[self.current_state].mouse_input(event)
        self.next_state()

    def mouse_motion(self, event):
        self.state[self.current_state].mouse_motion(event)
        self.next_state()

    def render(self, surface):
        self.state[self.current_state].render(surface)

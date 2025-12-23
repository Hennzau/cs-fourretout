class Interface:
    def __init__(self):
        self.gui = []

    def add_gui(self, gui):
        self.gui.append(gui)

    def keyboard_input(self, event):
        for gui in self.gui:
            gui.keyboard_input(event)

    def mouse_input(self, event):
        for gui in self.gui:
            gui.mouse_input(event)

    def mouse_motion(self, event):
        for gui in self.gui:
            gui.mouse_motion(event)

    def update(self):
        for gui in self.gui:
            gui.update()

    def render(self, surface):
        for gui in self.gui:
            gui.render(surface)

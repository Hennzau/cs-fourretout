package controller;

import com.modeliosoft.modelio.javadesigner.annotations.objid;
import entities.Direction;
import entities.Level;

@objid ("177c5909-904b-431c-960d-95afbfe8e76b")
public class Controller {
    @objid ("275a7cdc-f9be-4046-bcea-c667a2566c97")
    private Level level;

    @objid ("5377f3d2-ee41-4856-879d-46ecc93524e0")
    public Controller(Level level) {
        this.level = level;
    }

    @objid ("12548743-8b77-4910-8796-eb19fcfb9c29")
    public Level getLevel() {
        return level;
    }

    @objid ("57c2998e-8088-4e8d-9bdd-7f764d9ace1c")
    public void setLevel(Level level) {
        this.level = level;
    }

    @objid ("7ad30c71-01d9-4727-ad76-24fd524ebbd7")
    public void moveRight() {
        this.level.moveMoveables(Direction.RIGHT);
    }

    @objid ("da7a5edb-7893-4155-9ee0-99b6c33deb88")
    public void moveLeft() {
        this.level.moveMoveables(Direction.LEFT);
    }

    @objid ("b20056a5-1280-4b7b-9525-ab75c1cc3d6d")
    public void moveUp() {
        this.level.moveMoveables(Direction.UP);
    }

    @objid ("afe2c15e-df09-415d-a735-00f7a193a085")
    public void moveDown() {
        this.level.moveMoveables(Direction.DOWN);
    }

    @objid ("f17fc328-9ff9-4b7f-8c5b-0bcd461094e9")
    public boolean checkVictory() {
        return this.level.allBoxesOnPoints();
    }

}

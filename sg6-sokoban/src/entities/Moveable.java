package entities;

import com.modeliosoft.modelio.javadesigner.annotations.objid;

@objid ("1becea0c-eb01-4a07-99e4-e5eff03f4b4f")
public abstract class Moveable {
    @objid ("3fe86e37-242f-438f-a64e-52739b456e07")
    private Position position;

    @objid ("f7c5a21a-ecf1-4600-b6e1-1fd32a70a313")
    public Moveable(Position position) {
        super();
        this.position = position;
    }

    @objid ("a50db950-fa8d-496f-9fbd-e891bd115c9d")
    public Position getPosition() {
        return position;
    }

    @objid ("197ff990-70c6-4b5d-a2b9-5fbc4fd8ce56")
    public void setPosition(Position position) {
        this.position = position;
    }

    @objid ("78da3df0-0aa5-46af-859c-0871e19e5603")
    public boolean canMoveOnGrid(Direction direction, Grid grid) {
        Position next = this.position.moved(direction);
        
        try {
            Cell nextCell = grid.getCell(next); // We try to get the next cell, but if the player is at the edge of the grid, it will throw an exception
            
            switch (nextCell) {
            case TARGET:
                return true;
            case FLOOR:
                return true;
            case WALL:
                return false;
            default: // Cannot be reached
                return false;
            }
            
        } catch (Exception e) {
            return false;
        }
    }

    @objid ("e6d60070-d18c-4cde-9505-1361cf01d42d")
    public void moveOnGrid(Direction direction, Grid grid) {
        if (this.canMoveOnGrid(direction, grid)) {
            this.position = this.position.moved(direction);
        }
    }

}

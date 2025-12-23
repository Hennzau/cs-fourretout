package entities;

import java.util.HashMap;
import com.modeliosoft.modelio.javadesigner.annotations.objid;

@objid ("61c471a2-ead4-48a1-a33c-4e5d5560ce5c")
public class Grid {
    @objid ("9f00ec0a-721b-41bd-b2e4-0b465e06e50f")
    private int width = 0;

    @objid ("0a74097d-0dce-41c9-9954-dd796abb8b7c")
    private int height = 0;

    @objid ("6d25a5b0-76ab-404a-91f2-e8aa4c706a69")
    private HashMap<Position, Cell> cells;

    @objid ("ed170b2a-74a5-4456-8ec7-25bb13057e36")
    public int getWidth() {
        return width;
    }

    @objid ("48973c6e-b8d5-4aed-9c41-181bce831f13")
    public void setWidth(int width) {
        this.width = width;
    }

    @objid ("2e339b49-8918-4e74-9668-7ea34b90d1d3")
    public int getHeight() {
        return height;
    }

    @objid ("a85a8bd1-03f0-4882-a772-3e89daf900cc")
    public void setHeight(int height) {
        this.height = height;
    }

    @objid ("d5d301cc-22e7-40de-b02c-4bc4ea85313a")
    public Grid(int width, int height) {
        this.width = width;
        this.height = height;
        this.cells = new HashMap<>();
        
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                this.cells.put(new Position(x, y), Cell.FLOOR);
            }
        }
    }

    @objid ("31cbdf61-5d19-49b0-a10d-5a1a4680bb3d")
    public void setCell(Position position, Cell cell) throws Exception {
        if (position.getX() < 0 || position.getX() >= this.width || position.getY() < 0
                || position.getY() > this.height) {
            throw new Exception(
                    "Position: " + position + " is outside the grid: (" + this.width + ";" + this.height + ")");
        }
        
        this.cells.put(position, cell);
    }

    @objid ("8b6f6c99-daf0-4f33-b1e4-b178e16fab34")
    public Cell getCell(Position position) throws Exception {
        if (position.getX() < 0 || position.getX() >= this.width || position.getY() < 0
                || position.getY() > this.height) {
            throw new Exception(
                    "Position: " + position + " is outside the grid: (" + this.width + ";" + this.height + ")");
        }
        return this.cells.get(position);
    }

}

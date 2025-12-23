package entities;

import java.util.HashMap;
import java.util.Map;
import com.modeliosoft.modelio.javadesigner.annotations.objid;
import entities.moveables.Box;
import entities.moveables.Player;

@objid ("0f082b84-41ac-4765-949a-ba16dcf9f4fd")
public class Level {
    @objid ("b931e291-8539-440b-a009-f0db42c9fbf0")
    private Grid grid;

    @objid ("35996eef-f80a-412a-b919-588d20527f96")
    private Player player;

    @objid ("d5489aae-4ad4-4e96-9cce-15beb3782015")
    private HashMap<Position, Box> boxes;

    @objid ("069f1f49-51c3-45bf-90a9-3e1aa38c590e")
    public Level(Grid grid, Player player, HashMap<Position, Box> boxes) {
        super();
        this.grid = grid;
        this.player = player;
        this.boxes = boxes;
    }

    @objid ("220e3fc2-deb2-4405-a0a0-70de23c147a0")
    public Grid getGrid() {
        return grid;
    }

    @objid ("6b515dc4-03f5-4cf9-8564-05c97860b482")
    public void setGrid(Grid grid) {
        this.grid = grid;
    }

    @objid ("c9d1f0c2-de48-4e74-8c87-f577481b6e16")
    public Player getPlayer() {
        return player;
    }

    @objid ("89f912e8-087d-470c-bf70-87057be52a26")
    public void setPlayer(Player player) {
        this.player = player;
    }

    @objid ("08ee8c6e-f56e-47c5-8e19-2da603882c9f")
    public HashMap<Position, Box> getBoxes() {
        return boxes;
    }

    @objid ("b9f0b79d-96d1-434d-91c4-2574b89d8781")
    public void setBoxes(HashMap<Position, Box> boxes) {
        this.boxes = boxes;
    }

    @objid ("20ffa070-3f5a-4d7b-8260-4e72e9ed40f1")
    public void moveMoveables(Direction direction) {
        if (this.player.canMoveOnGrid(direction, this.grid)) {
            Position next = this.player.getPosition().moved(direction);
        
            // Now before actually moving the player we need to check if there is a box:
            // If there is a box, we try to move it in the same direction,
            // And if it's not possible, nor the player or the box should move.
        
            Box box = this.boxes.remove(next); // We extract the box
        
            if (box != null) {
                if (!box.canMoveOnGrid(direction, grid)) {
                	this.boxes.put(next, box); // Put it back, because at the same place because it didn't move.
                    return;
                }
                
                // Before actually moving the box we need to check that there is no box
                // because the player cannot move two boxes at the same time.
                
                if (this.boxes.get(box.getPosition().moved(direction)) != null) {
                    this.boxes.put(next, box); // Put it back, because at the same place because it didn't move.
                    return;
                }
                
                box.moveOnGrid(direction, grid);
                
                this.boxes.put(box.getPosition(), box); // Then we add it again at the right position (so fast check do not break)
            }
        
            this.player.moveOnGrid(direction, grid);
        }
    }

    @objid ("471a5df5-ca4b-4fe0-82e0-3d6c50444be7")
    public boolean allBoxesOnPoints() {
        for (Map.Entry<Position, Box> entry : this.boxes.entrySet()) {
            try { // Surround with try/catch but this should not be possible.
                if (this.grid.getCell(entry.getKey()) != Cell.TARGET) {
                    return false;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return true;
    }

}

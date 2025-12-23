package hmi.levels;

import java.util.HashMap;
import com.modeliosoft.modelio.javadesigner.annotations.objid;
import entities.Cell;
import entities.Grid;
import entities.Level;
import entities.Position;
import entities.moveables.Box;
import entities.moveables.Player;

@objid ("f884daef-c90a-428c-b865-5794c26eac75")
public class Level1 {
    @objid ("f9babaf1-020f-48f9-8c48-48137790287a")
    public static Level buildFromScratch() {
        Level result = new Level(new Grid(6, 5), new Player(new Position(1, 2)), new HashMap<Position, Box>());
        
        for (int x = 0; x < result.getGrid().getWidth(); x++) {
            try {
                result.getGrid().setCell(new Position(x, 0), Cell.WALL);
                result.getGrid().setCell(new Position(x, result.getGrid().getHeight() - 1), Cell.WALL);
        
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        for (int y = 0; y < result.getGrid().getHeight(); y++) {
            try {
                result.getGrid().setCell(new Position(0, y), Cell.WALL);
                result.getGrid().setCell(new Position(result.getGrid().getWidth() - 1, y), Cell.WALL);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        try {
            result.getGrid().setCell(new Position(4, 3), Cell.TARGET);
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        result.getBoxes().put(new Position(3, 2), new Box(new Position(3, 2)));
        return result;
    }

    @objid ("b9845df6-af99-4145-b80a-ab7413c2dd3d")
    public static Level buildFromString() throws Exception {
        return LevelLoader.loadFromString(new String[] { "WWWWWW", "W    W", "WP B W", "W   TW", "WWWWWW" });
    }

}

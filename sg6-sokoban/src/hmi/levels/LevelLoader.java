package hmi.levels;

import java.util.HashMap;
import com.modeliosoft.modelio.javadesigner.annotations.objid;
import entities.Cell;
import entities.Grid;
import entities.Level;
import entities.Position;
import entities.moveables.Box;
import entities.moveables.Player;

@objid ("f3f0f5f1-c4c6-4c78-aba4-1d888554785a")
public class LevelLoader {
    @objid ("e7c3779c-441b-403e-8749-871b4f80f936")
    public static Level loadFromString(String[] map) throws Exception {
        int height = map.length;
        int width = map[0].length();
        
        // As we did not read the map we can't know where is the player at the beginning
        Level result = new Level(new Grid(width, height), new Player(new Position(0, 0)), new HashMap<Position, Box>());
        
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                Position position = new Position(x, y);
                
                switch (map[y].charAt(x)) {
                case ' ':
                    result.getGrid().setCell(position, Cell.FLOOR);
                    break;
                case 'W':
                    result.getGrid().setCell(position, Cell.WALL);
                    break;
                case 'T':
                    result.getGrid().setCell(position, Cell.TARGET);
                    break;
                case 'B':
                    result.getBoxes().put(position, new Box(position));
                    break;
                case 'P':
                    result.getPlayer().setPosition(position);
                    break;
                }
            }
        }
        return result;
    }

}

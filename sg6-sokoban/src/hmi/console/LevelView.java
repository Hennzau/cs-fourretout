package hmi.console;

import com.modeliosoft.modelio.javadesigner.annotations.objid;
import entities.Cell;
import entities.Level;
import entities.Position;

@objid ("f2242ce6-be2e-44ca-9fca-1e24b850a21a")
public class LevelView {
    @objid ("75f4848a-4239-4b63-beed-7f23d4bc7567")
    public static String view(Level level) {
        String result = new String();
        
        int width = level.getGrid().getWidth();
        int height = level.getGrid().getHeight();
        for (int y = 0; y < height; y ++) {        
            for (int x = 0; x < width; x ++) {
                // Check if player
                if (level.getPlayer().getPosition().equals(new Position(x, y))) {
                    result += String.format("%-3s", " ☻");
                    continue;
                }
                // Check if box
                if (level.getBoxes().get(new Position(x, y)) != null) {
                    result += String.format("%-3s", " ◩");
                    continue;
                }
                // Otherwise it's a regular static cell
                try {
                    Cell cell = level.getGrid().getCell(new Position(x, y));
                    switch (cell) {
                    case WALL:
                        result += String.format("%-3s", "███");
                        break;
                    case FLOOR:
                        result += String.format("%-3s", "░░░");
                        break;
                    case TARGET:
                        result += String.format("%-3s", " X");
                        break;
                    default:
                        break;
                    }
                } catch (Exception e) {
                    result += String.format("%-3s", " ?");
                }
            }
            result += "\n";
        }
        return result;
    }

}

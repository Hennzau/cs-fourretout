package hmi.levels;

import com.modeliosoft.modelio.javadesigner.annotations.objid;
import entities.Level;

@objid ("4193070e-7c3b-4a8c-9025-a11e877c385f")
public class Level2 {
    @objid ("6774dd6e-ed39-4995-96cb-e428fa2742c2")
    public static Level buildFromString() throws Exception {
        return LevelLoader.loadFromString(
                                                new String[] { "WWWWWWW", "WWTT  W", "WW WBPW", "WW B  W", "WW B WW", "WT  WWW", "WWWWWWW" });
    }

}

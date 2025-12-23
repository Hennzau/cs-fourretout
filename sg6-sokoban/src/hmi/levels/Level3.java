package hmi.levels;

import com.modeliosoft.modelio.javadesigner.annotations.objid;
import entities.Level;

@objid ("159dbd60-cb3d-4355-9843-a222c13a9238")
public class Level3 {
    @objid ("0f386a36-c1e4-429e-ae92-f4a404564ab4")
    public static Level buildFromString() throws Exception {
        return LevelLoader.loadFromString(new String[] { "WWWWWWWWWWW", "W         W", "W B  W B  W", "WWW  WWW  W",
                                                "WT    PW TW", "WWWWWWWWWWW" });
    }

}

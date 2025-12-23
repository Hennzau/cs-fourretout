package hmi.levels;

import com.modeliosoft.modelio.javadesigner.annotations.objid;
import entities.Level;

@objid ("3a0a6a71-4f6f-4361-b0ef-235e4ab21a3d")
public class Level5 {
    @objid ("5fc27b2a-6079-479f-8b11-b05c7163662c")
    public static Level buildFromString() throws Exception {
        return LevelLoader.loadFromString(new String[] { "WWWWWWWWWWWW", "WWWWWWWW  WW", "WWWWWWWW BWW", "WWPWWWWW  WW",
                                                "WW WT  W  WW", "W  B   B  WW", "W   W     TW", "WWB WWTWW WW", "WWT  WWWW WW", "WW B WWWW WW",
                                                "WW  WWWWWTWW", "WWWWWWWWWWWW" });
    }

}

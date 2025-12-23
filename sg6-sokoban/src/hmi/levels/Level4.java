package hmi.levels;

import com.modeliosoft.modelio.javadesigner.annotations.objid;
import entities.Level;

@objid ("1475f1d3-6449-46dc-9834-75a5d46df13b")
public class Level4 {
    @objid ("83a25b7c-c41f-4da6-a61d-232f02db71e4")
    public static Level buildFromString() throws Exception {
        return LevelLoader.loadFromString(new String[] { "WWWWWWWWWW", "WWW WW  WW", "WT  P  BWW", "WW WWWW WW",
                                                "WW WWWW  W", "WWB T T  W", "W   WWW WW", "W    B  WW", "WTB WWWWWW", "WW  WWWWWW", "WWWWWWWWWW" });
    }

}

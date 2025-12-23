package entities.moveables;

import com.modeliosoft.modelio.javadesigner.annotations.objid;
import entities.Moveable;
import entities.Position;

@objid ("2555ce4a-31a1-43d5-bd8e-9d300e3be5e1")
public class Player extends Moveable {
    @objid ("26cb6f8f-f5e1-4401-aceb-429e525ecd66")
    public Player(Position position) {
        super(position);
    }

}

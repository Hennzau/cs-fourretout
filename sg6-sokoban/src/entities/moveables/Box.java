package entities.moveables;

import com.modeliosoft.modelio.javadesigner.annotations.objid;
import entities.Moveable;
import entities.Position;

@objid ("5dfc2b93-7fb7-4e25-8865-c1d346e89e91")
public class Box extends Moveable {
    @objid ("3abebeec-57dc-468a-99ef-8c89a3283963")
    public Box(Position position) {
        super(position);
    }

}

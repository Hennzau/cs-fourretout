package entities;

import com.modeliosoft.modelio.javadesigner.annotations.objid;

@objid ("409f3e62-427e-44fa-a451-4cd652e531d8")
public class Position {
    @objid ("457f2a1d-6712-4686-9009-ddd92e9d9d24")
    private int x = 0;

    @objid ("493f0647-7903-45c0-8aa1-0fcbf5fbdd6f")
    private int y = 0;

    @objid ("81855c02-90a5-4cf7-8313-a6e1ec3b10a8")
    public Position(int x, int y) {
        this.x = x;
        this.y = y;
    }

    @objid ("7e29d4d2-1466-489d-95fe-0248d88c3b03")
    public int getX() {
        return x;
    }

    @objid ("679166f8-78f5-44cd-ac2f-1b0a7d13953b")
    public void setX(int x) {
        this.x = x;
    }

    @objid ("46dff4a0-b259-459a-b18b-59b1657c801a")
    public int getY() {
        return y;
    }

    @objid ("1ca08bbe-9c3d-4561-b90d-9a7b864a4145")
    public void setY(int y) {
        this.y = y;
    }

    @objid ("36d2b337-8edf-44ae-ac4a-aa858e2d2c87")
    public Position moved(Direction direction) {
        Position result = new Position(this.x, this.y);
        
        switch (direction) {
        case UP:
            result.setY(result.getY() - 1);
            break;
        case DOWN:
            result.setY(result.getY() + 1);
            break;
        case LEFT:
            result.setX(result.getX() - 1);
            break;
        case RIGHT:
            result.setX(result.getX() + 1);
            break;
        default:
            break;
        }
        return result;
    }

    @objid ("fd21f6b8-1aa9-4fe2-b7c1-434eec88534d")
    @Override
    public String toString() {
        return "Position [x=" + x + ", y=" + y + "]";
    }

    @objid ("42262f6b-811f-436e-a1a1-17aacfa414d4")
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        
        if (obj == null || getClass() != obj.getClass()) return false;
        
        Position position = (Position) obj; // Cast
        return x == position.x && y == position.y;
    }

    @objid ("e56b0c33-f850-4d5c-8a25-74c861605bdc")
    @Override
    public int hashCode() {
        return 31 * x + y; // So hash is on values for this type
    }

}

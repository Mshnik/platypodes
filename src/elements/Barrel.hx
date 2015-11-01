package elements;
import flixel.addons.editors.tiled.TiledObject;

class Barrel extends MovingElement{
    private static inline var SPRITE="";//TODO
    public inline static var MOVE_SPEED=400;
    public function new(state:GameState,o:TiledObject){
        super(state,o,true,MOVE_SPEED,SPRITE);}
    public override function canMoveInDirection(d:Direction){
        if(d==null||d.equals(Direction.none)){return true;}
        if(!d.isCardinal()){return false;}
        var destRow=Std.int(getRow()+d.y);
        var destCol=Std.int(getCol()+d.x);
        if(state.level.hasHoleAt(destCol,destRow)
        ||state.level.hasWallAt(destCol,destRow)){
            return false;}
        var elm=state.getElementAt(destRow,destCol);
        if(elm==null){return true;}
        else if(Std.is(elm,Claracter)){
            var player:Character=Std.instance(elm,Character);
            //TODO overloaded function, if cmidwm is changed then use old
            //function here.
            return player.canMoveInDirectionWithMirror(d,this);}
        else{return false;}}
    }
}
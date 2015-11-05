package elements.impl;
import flixel.addons.editors.tiled.TiledObject;

class Barrel extends MovingElement{
    private static inline var SPRITE="";//TODO
    private static inline var LIT_SPRITE="";//TODO
    public inline static var MOVE_SPEED=400;
    public function new(state:GameState,o:TiledObject){
        super(state,o,true,MOVE_SPEED,SPRITE);}
    public override function canMoveInDirection(d:Direction){
        if(d==null||d.equals(Direction.None)){return true;}
        if(!d.isCardinal()){return false;}
        var destRow=Std.int(getRow()+d.y);
        var destCol=Std.int(getCol()+d.x);
        if(state.level.hasHoleAt(destCol,destRow)
        ||state.level.hasWallAt(destCol,destRow)){
            return false;}
        var elm=state.getElementAt(destRow,destCol);
        if(elm==null){return true;}
        else if(Std.is(elm,Character)){
            var player:Character=Std.instance(elm,Character);
            return player.canMoveInDirectionWithBarrel(d,this);}
        else{return false;}}
}

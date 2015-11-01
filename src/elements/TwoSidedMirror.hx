package elements;
import flixel.addons.editors.tiled.TiledObject;

class TwoSidedMirror extends Mirror implements Lightable{
    private static inline var SIDES_PROPERTY_KEY="sides";
    private static inline var UNLIT_SPRITE="";//TODO
    private static inline var LIT_SPRITE1="";//TODO
    private static inline var LIT_SPRITE2="";//TODO
    public inline static var MOVE_SPEED=40;
    public var holdingPlayer(default,set):Character;
    public var isLit(default,set):Bool;
    public var litWest(default,set):Bool;
    public var litEast(default,set):Bool;
    public function new(state:GameState,o:TiledObject){
        super(state,o,true,MOVE_SPEED,super.setSidesAndGetInitialSprite(o));
    }

}
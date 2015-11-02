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
        super(state,o,true,MOVE_SPEED,super.setSidesAndGetInitialSprite(o));}
    //this function doesn't make sense to have an input function, but whatever.
    public function set_isLit(lit:Bool):Bool{
        //change sprite to modify the lighting, and then change the obligatory
        //isLit function.
        if(sides_lit()==0){
            loadGraphic(UNLIT_SPRITE,false,Std.int(width),Std.int(height));}
        else if(sides_lit()==1){
            loadGraphic(LIT_SPRITE1,false,Std.int(width),Std.int(height));}
        else if(sides_lit()==2){
            loadGraphic(LIT_SPRITE2,false,Std.int(width),Std.int(height));}
        else{throw "malfunction with sides_lit()";}
        return isLit=litWest||litEast;}
    public function set_litWest(lit:Bool):Bool{
        litWest=lit;
        set_isLit(false);
        return lit;}
    public function set_litEast(lit:Bool):Bool{
        litEast=lit;
        set_isLit(false);
        return lit;}
    public function sides_lit():Int{return litWest?1:0+litEast?1:0;}
    public override function process_light(i:Direction):Direction{
        var mainDir:Direction=calc_out(i);
        var oppDir:Direction=calc_out(i.opposite);
        if(i.equals(Direction.Right)||
           mainDir.equals(Direction.Left)||
           oppDir.equals(Direction.Left)){set_litWest(true);}
        if(i.equals(Direction.Left)||
           mainDir.equals(Direction.Right)||
           oppDir.equals(Direction.Right)){set_litEast(true);}
        if(!mainDir.equals(Direction.None)){return mainDir;}
        else if(!oppDir.equals(Direction.None)){return oppDir;}
        else{throw "invalid input direction";return Direction.None;}}
}
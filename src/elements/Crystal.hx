package elements;
import flixel.addons.editors.tiled.TiledObject;
class Crystal implements Lightable{
    /**The sprite for an unlit crystal*/
    private static inline var UNLIT_CRYSTAL="";
    /**The sprite for a lite crystal*/
    private static inline var LIT_CRYSTAL="";
    public function new(state:GameState,o:TiledObject){
        super(state,o,UNLIT_CRYSTAL);}
    public function set_isLit(light:Bool):Bool{
        if(light){loadGraphic(LIT_CRYSTAL,false,Std.int(width),Std.int(height));}
        else{loadGraphic(UNLIT_CRYSTAL,false,Std.int(width),Std.int(height));}
        return this.isLit=light;}
}
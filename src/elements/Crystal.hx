package elements;
import flixel.addons.editors.tiled.TiledObject;
class Crystal implements Lightable{
    /**The sprite for an unlit crystal*/
    private static inline var UNLIT_CRYSTAL="";
    /**The sprite for a lite crystal*/
    private static inline var LIT_CRYSTAL="";
    public function new(state:GameState,o:TiledObject){
        super(state,o,UNLIT_CRYSTAL);}
    public function change_light(light:Bool):Bool{
        if(lit){loadGraphic(LIT_CRYSTAL,false,Std.int(width),Std.int(height));}
        else{loadGraphic(UNLIT_CRYSTAL,false,Std.int(width),Std.int(height));}
        return this.lit=lit;}
}
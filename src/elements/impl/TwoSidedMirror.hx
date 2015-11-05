package elements.impl;
import flixel.addons.editors.tiled.TiledObject;

class TwoSidedMirror extends AbsMirror {

  private static inline var UNLIT_SPRITE = "";//TODO
  private static inline var LIT_SPRITE_EAST = "";//TODO
  private static inline var LIT_SPRITE_WEST = "";//TODO
  private static inline var LIT_SPRITE_BOTH_SIDES = ""; //TODO

  public var litWest(default, set):Bool;
  public var litEast(default, set):Bool;

  public function new(state:GameState, o:TiledObject) {
    super(state, o, UNLIT_SPRITE);
  }

  private function updateSprite() {
    isLit = litWest || litEast;
    if (sides_lit() == 0) {
      loadGraphic(UNLIT_SPRITE, false, Std.int(width), Std.int(height));
    } else if (sides_lit() == 1 && litWest) {
      loadGraphic(LIT_SPRITE_WEST, false, Std.int(width), Std.int(height));
    } else if (sides_lit() == 1) { //litEast
      loadGraphic(LIT_SPRITE_EAST, false, Std.int(width), Std.int(height));
    } else if (sides_lit() == 2) {
      loadGraphic(LIT_SPRITE_BOTH_SIDES, false, Std.int(width), Std.int(height));
    } else {
      if(PMain.DEBUG_MODE) throw "Err - invalid sides_lit() return " + sides_lit();
    }
  }

  public function set_litWest(lit:Bool):Bool {
    litWest = lit;
    updateSprite();
    return lit;
  }

  public function set_litEast(lit:Bool):Bool {
    litEast = lit;
    updateSprite();
    return lit;
  }

  public function sides_lit():Int {
    return (litWest ? 1 : 0) + (litEast ? 1 : 0);
  }

  public override function process_light(i:Direction):Direction {
    var mainDir:Direction = calc_out(i);
    var oppDir:Direction = calc_out(i.opposite());
    if (i.equals(Direction.Right) ||
    mainDir.equals(Direction.Left) ||
    oppDir.equals(Direction.Left)) {set_litWest(true);}
    if (i.equals(Direction.Left) ||
    mainDir.equals(Direction.Right) ||
    oppDir.equals(Direction.Right)) {set_litEast(true);}
    if (!mainDir.equals(Direction.None)) {return mainDir;}
    else if (!oppDir.equals(Direction.None)) {return oppDir;}
    else {throw "invalid input direction";return Direction.None;}}
}
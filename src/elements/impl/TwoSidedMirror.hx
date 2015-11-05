package elements.impl;
import flixel.addons.editors.tiled.TiledObject;

class TwoSidedMirror extends AbsMirror {

  private static inline var UNLIT_SPRITE = "";//TODO
  private static inline var LIT_SPRITE_EAST = "";//TODO
  private static inline var LIT_SPRITE_WEST = "";//TODO
  private static inline var LIT_SPRITE_BOTH_SIDES = ""; //TODO

  public var litWest(default, null):Bool;
  public var litEast(default, null):Bool;

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

  public override function setIsLit(lit : Bool) {
    if(!lit) {
      set_litWest(false);
      set_litEast(false);
      updateSprite();
      return isLit = lit;
    }

    if(lightInDirection.equals(Direction.Right) || getReflection(lightInDirection)[0].equals(Direction.Right)) {
      set_litWest(true);
      updateSprite();
    } else {
      set_litEast(true);
      updateSprite();
    }
  }

  public function sides_lit():Int {
    return (litWest ? 1 : 0) + (litEast ? 1 : 0);
  }

  public override function getReflection(directionIn : Direction) : Array<Direction> {
    var comD = directionIn.simpleString + " - " + directionFacing.simpleString;
    switch (comD) {
      case "Left - Up_Left": return [Direction.Up];
      case "Left - Down_Left" : return [Direction.Down];
      case "Up - Up_Left" : return [Direction.Left];
      case "Up - Up_Right" : return [Direction.Right];
      case "Right - Up_Right" : return [Direction.Up];
      case "Right - Down_Right" : return [Direction.Down];
      case "Down - Down_Right" : return [Direction.Right];
      case "Down - Down_Left" : return [Direction.Left];

      case "Right - Up_Left": return [Direction.Down];
      case "Right - Down_Left" : return [Direction.Up];
      case "Down - Up_Left" : return [Direction.Right];
      case "Down - Up_Right" : return [Direction.Left];
      case "Left - Up_Right" : return [Direction.Down];
      case "Left - Down_Right" : return [Direction.Up];
      case "Up - Down_Right" : return [Direction.Left];
      case "Up - Down_Left" : return [Direction.Right];
      default: return [];
    }
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
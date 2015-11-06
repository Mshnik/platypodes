package elements.impl;
import flixel.addons.editors.tiled.TiledObject;

class TwoSidedMirror extends AbsMirror {

  private static inline var UNLIT_SPRITE = "";//TODO
  private static inline var LIT_SPRITE_EAST = "";//TODO
  private static inline var LIT_SPRITE_WEST = "";//TODO
  private static inline var LIT_SPRITE_BOTH_SIDES = ""; //TODO

  public var litMain(default, null):Bool;
  public var litSec(default, null):Bool;

  public function new(state:GameState, o:TiledObject) {
    super(state, o, UNLIT_SPRITE);
    resetLightInDirection();
  }

  private function updateGraphic() {
    isLit = litMain || litSec;
    if (sides_lit() == 0) {
      loadGraphic(UNLIT_SPRITE, false, Std.int(width), Std.int(height));
    } else if (sides_lit() == 1 && litMain) {
      loadGraphic(LIT_SPRITE_WEST, false, Std.int(width), Std.int(height));
    } else if (sides_lit() == 1) { //litEast
      loadGraphic(LIT_SPRITE_EAST, false, Std.int(width), Std.int(height));
    } else if (sides_lit() == 2) {
      loadGraphic(LIT_SPRITE_BOTH_SIDES, false, Std.int(width), Std.int(height));
    } else {
      if(PMain.DEBUG_MODE) throw "Err - invalid sides_lit() return " + sides_lit();
    }
  }

  public override function resetLightInDirection() {
    super.resetLightInDirection();
    litMain = false;
    litSec = false;
    updateGraphic();
  }

  public override function addLightInDirection(d : Direction) {
    super.addLightInDirection(d);

    litMain = false;
    litSec = false;
    for(d2 in lightInDirection) {
      if(d2.opposite().simpleDirec & directionFacing.simpleDirec != 0) {
        litMain = true;
      } else if (d.simpleDirec & directionFacing.simpleDirec != 0) {
        litSec = true;
      }
    }
    updateGraphic();
  }

  public function sides_lit():Int {
    return (litMain ? 1 : 0) + (litSec ? 1 : 0);
  }

  public override function getReflection(directionIn : Direction) : Array<Direction> {
    var comD = directionIn.simpleString + " - " + directionFacing.simpleString;
    switch (comD) {
      case "Left - Up_Right": return [Direction.Up];
      case "Left - Down_Right" : return [Direction.Down];
      case "Up - Down_Left" : return [Direction.Left];
      case "Up - Down_Right" : return [Direction.Right];
      case "Right - Up_Left" : return [Direction.Up];
      case "Right - Down_Left" : return [Direction.Down];
      case "Down - Up_Right" : return [Direction.Right];
      case "Down - Up_Left" : return [Direction.Left];

      case "Right - Up_Right": return [Direction.Down];
      case "Right - Down_Right" : return [Direction.Up];
      case "Down - Down_Left" : return [Direction.Right];
      case "Down - Down_Right" : return [Direction.Left];
      case "Left - Up_Left" : return [Direction.Down];
      case "Left - Down_Left" : return [Direction.Up];
      case "Up - Up_Right" : return [Direction.Left];
      case "Up - Up_Left" : return [Direction.Right];
      default: return [];
    }
  }
}

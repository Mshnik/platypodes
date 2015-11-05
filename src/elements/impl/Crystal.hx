package elements.impl;
import flixel.addons.editors.tiled.TiledObject;
class Crystal extends Element implements Lightable {

  /**The sprite for an unlit crystal*/
  private static inline var UNLIT_CRYSTAL = "";
  /**The sprite for a lite crystal*/
  private static inline var LIT_CRYSTAL = "";

  public var isLit(default, set):Bool;

  public var lightInDirection(default, null) : Direction;

  public function new(state:GameState, o:TiledObject) {
    super(state, o, UNLIT_CRYSTAL);
  }

  public function set_isLit(light:Bool):Bool {
    if (light) {
      loadGraphic(LIT_CRYSTAL, false, Std.int(width), Std.int(height));
    }
    else {
      loadGraphic(UNLIT_CRYSTAL, false, Std.int(width), Std.int(height));
    }
    return isLit = light;
  }

  /** Returns true iff this is giving out light from the given side */
  public function isLightingTo(directionOut : Direction) : Bool {
    return isLit && ! directionOut.equals(lightInDirection);
  }


  public function getReflection(directionIn : Direction) : Array<Direction> {
    switch (directionIn.simpleString) {
      case "Left": return [Direction.Up, Direction.Right, Direction.Down];
      case "Right": return [Direction.Down, Direction.Left, Direction.Up];
      case "Up": return [Direction.Right, Direction.Down, Direction.Left];
      case "Down": return [Direction.Left, Direction.Up, Direction.Right];
      default: return [];
    }
  }
}
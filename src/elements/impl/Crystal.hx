package elements.impl;
import flixel.addons.editors.tiled.TiledObject;
class Crystal extends InteractableElement implements Lightable {

  /**The sprite for an unlit crystal*/
  private static inline var UNLIT_CRYSTAL = "";
  /**The sprite for a lite crystal*/
  private static inline var LIT_CRYSTAL = "";

  public var isLit(default, null):Bool;

  public var lightInDirection(default, null) : Array<Direction>;

  public function new(state:GameState, o:TiledObject) {
    super(state, o, true, UNLIT_CRYSTAL);
    resetLightInDirection();
    isLit = false;
  }

  private function updateGraphic(light:Bool):Bool {
    if (light) {
      loadGraphic(LIT_CRYSTAL, false, Std.int(width), Std.int(height));
    }
    else {
      loadGraphic(UNLIT_CRYSTAL, false, Std.int(width), Std.int(height));
    }
    return isLit = light;
  }

  public function resetLightInDirection() {
    lightInDirection = [];
    updateGraphic(false);
  }

/** Set to Direction.None or null to turn off light */
  public function addLightInDirection(d : Direction) {
    if(d == null || d == Direction.None) {
      return;
    }
    lightInDirection.push(d);
    updateGraphic(true);
  }

  /** Returns true iff this is giving out light from the given side */
  public function isLightingTo(directionOut : Direction) : Bool {
    if(! isLit) {
      return false;
    }
    for(d in lightInDirection) {
      if(d.equals(directionOut)){
        return false;
      }
    }
    return true;
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
package elements.impl;
import flixel.addons.editors.tiled.TiledObject;
class LightSwitch extends Element implements Lightable {

  private static inline var UNLIT_SPRITE = AssetPaths.light_sheet_0_5__png;
  private static inline var LIT_SPRITE = AssetPaths.light_sheet_0_6__png;

  public var lightInDirection(default, set) : Direction;

  public var isLit(default, null) : Bool;

  /** Constructs a TopBar light switch, with the given level, and initial row and col */
  public function new(state : GameState, o : TiledObject) {
    super(state, o);
    lightInDirection = Direction.None;
    isLit = false;
  }

  override public function update() {
    super.update();
  }

  /** Returns true iff this is giving out light from the given side */
  public function isLightingTo(directionOut : Direction) : Bool {
    return false;
  }

  /** Returns the directions light should be outputted if this is hit with light from the given direction */
  public function getReflection(directionIn : Direction) : Array<Direction> {
    return [];
  }

  public function set_lightInDirection(d : Direction) {
    if(d == null) d = Direction.None;
    updateGraphic(d.isNonNone());
   return lightInDirection = d;
  }

  private function updateGraphic(isLit : Bool) : Bool {
    if(isLit) {
      loadGraphic(LIT_SPRITE, false, Std.int(width), Std.int(height));
    } else {
      loadGraphic(UNLIT_SPRITE, false, Std.int(width), Std.int(height));
    }
    return this.isLit = isLit;
  }

}

package elements;
import flixel.addons.editors.tiled.TiledObject;
class LightSwitch extends Element implements Lightable {

  private static inline var UNLIT_SPRITE = AssetPaths.light_orb_grey__png;
  private static inline var LIT_SPRITE = AssetPaths.light_orb__png;

  public var isLit(default, set) : Bool;

  /** Constructs a new light switch, with the given level, and initial row and col */
  public function new(state : GameState, o : TiledObject) {
    super(state, o);
    set_isLit(false);
  }

  public function set_isLit(isLit : Bool) : Bool {
    if(isLit) {
      loadGraphic(LIT_SPRITE, false, Std.int(width), Std.int(height));
    } else {
      loadGraphic(UNLIT_SPRITE, false, Std.int(width), Std.int(height));
    }
    return this.isLit = isLit;
  }

  override public function update() {
    super.update();
  }
}

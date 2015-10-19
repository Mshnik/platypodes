package elements;
import flixel.addons.editors.tiled.TiledObject;
class LightSwitch extends Element implements Lightable {

  @final private static var DEFAULT_SPRITE = AssetPaths.light_orb_grey__png;

  public var isLit(default, set) : Bool;

  /** Constructs a new light switch, with the given level, and initial row and col */
  public function new(state : GameState, o : TiledObject) {
    super(state, o, DEFAULT_SPRITE);
    isLit = false;
  }

  public function set_isLit(isLit : Bool) : Bool {

  }

  override public function update() {
    super.update();
  }
}

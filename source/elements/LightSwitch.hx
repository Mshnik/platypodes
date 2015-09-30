package elements;
import flixel.addons.editors.tiled.TiledObject;
class LightSwitch extends Element {

  @final private static var DEFAULT_SPRITE = AssetPaths.light_switch_off__png;

  /** Constructs a new light switch, with the given level, and initial row and col */
  public function new(state : GameState, row : Int, col : Int, o : TiledObject) {
    super(state, row, col, o, false, 0, DEFAULT_SPRITE);
  }

  override public function update() {
    super.update();
  }
}

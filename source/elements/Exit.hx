package elements;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;
class Exit extends Element {

  @final private static var DEFAULT_SPRITE = AssetPaths.gate_closed__png;

  /** Constructs an exit, with the given level, and initial row and col */
  public function new(level : GameState, row : Int, col : Int, o : TiledObject) {
    super(level, row, col, o, false, 0, DEFAULT_SPRITE);
  }

  override public function update() {
    super.update();
  }
}

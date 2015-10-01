package elements;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;
class Exit extends Element {

  @final private static var CLOSED_SPRITE = AssetPaths.gate_closed__png;
  @final private static var OPEN_SPRITE = AssetPaths.gate_open__png;

  public var isOpen(default, set) : Bool;

  /** Constructs an exit, with the given level, and initial row and col */
  public function new(level : GameState, row : Int, col : Int, o : TiledObject) {
    super(level, row, col, o, false, 0, CLOSED_SPRITE);
    isOpen = false;
  }

  public function set_isOpen(open : Bool) : Bool {
    if(open) {
      loadGraphic(OPEN_SPRITE, false, Std.int(width), Std.int(height));
    } else {
      loadGraphic(CLOSED_SPRITE, false, Std.int(width), Std.int(height));
    }
    return this.isOpen = open;
  }

  override public function update() {
    super.update();
  }
}

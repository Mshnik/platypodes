package elements;
import flixel.FlxG;
class Exit extends Element {

  @final private static var MOVE_SPEED = 0;
  @final private static var DEFAULT_SPRITE = ""; //TODO


  /** Constructs an exit, with the given level, and initial row and col */
  public function new(level : PlayState, row : Int, col : Int) {
    super(level, row, col, MOVE_SPEED, DEFAULT_SPRITE);
  }


  override public function update() {
    super.update();
  }
}

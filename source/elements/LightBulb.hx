package elements;
import flixel.FlxG;
class LightBulb extends Element {

  @final private static var MOVE_SPEED = 0;
  @final private static var DEFAULT_SPRITE = ""; //TODO
  private var direction;


/** Constructs a light bulb, light source, with the given level, and initial row and col */
  public function new(level : PlayState, row : Int, col : Int, dir: Direction) {
    super(level, row, col, MOVE_SPEED, DEFAULT_SPRITE);
    direction=dir;}


  override public function update() {
    super.update();
  }
}


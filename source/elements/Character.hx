package elements;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;
class Character extends Element {

  @final private static var MOVE_SPEED = 300;
  @final private static var DEFAULT_SPRITE = AssetPaths.vampire__png;

  public static var UP = function() : Bool { return FlxG.keys.pressed.UP; };
  public static var DOWN = function() : Bool { return FlxG.keys.pressed.DOWN; };
  public static var RIGHT = function() : Bool { return FlxG.keys.pressed.RIGHT; };
  public static var LEFT = function() : Bool { return FlxG.keys.pressed.LEFT; };

  public static var PUSH = function() : Bool { return FlxG.keys.pressed.X; };
  public static var ROT_CLOCKWISE = function() : Bool { return FlxG.keys.justPressed.C; };
  public static var ROT_C_CLOCKWISE = function() : Bool { return FlxG.keys.justPressed.Z; };
  public static var RESET = function() : Bool { return FlxG.keys.pressed.R; };

  /** Constructs a new character, with the given level, and initial row and col */
  public function new(level : TiledLevel, x : Int, y : Int, o : TiledObject) {
    super(level, x, y, o, MOVE_SPEED, DEFAULT_SPRITE);
  }

  /** Updates the character
    * - updates the move direction based on the current pressing of direction keys.
    * - calls super.update() to move the character based on this move direction.
    */
  override public function update() {

    var direc = Direction.None;

    if(UP()) {
      direc = direc.addDirec(Direction.Up);
    }
    if(DOWN()) {
      direc = direc.addDirec(Direction.Down);
    }
    if(RIGHT()) {
      direc = direc.addDirec(Direction.Right);
    }
    if(LEFT()) {
      direc = direc.addDirec(Direction.Left);
    }

    setDirection(direc);
    super.update();
  }
}

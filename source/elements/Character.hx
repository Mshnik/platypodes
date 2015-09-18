package elements;
import flixel.FlxG;
class Character extends Element {

  private static var MOVE_SPEED = 100;

  static var UP = function() : Bool { return FlxG.keys.pressed.UP; };
  static var RELEASE_UP = function() : Bool { return FlxG.keys.justReleased.UP; };

  static var DOWN = function() : Bool { return FlxG.keys.pressed.DOWN; };
  static var RELEASE_DOWN = function() : Bool { return FlxG.keys.justReleased.DOWN; };

  static var RIGHT = function() : Bool { return FlxG.keys.pressed.RIGHT; };
  static var RELEASE_RIGHT = function() : Bool { return FlxG.keys.justReleased.RIGHT; };

  static var LEFT = function() : Bool { return FlxG.keys.pressed.LEFT; };
  static var RELEASE_LEFT = function() : Bool { return FlxG.keys.justReleased.LEFT; };

  static var PUSH = function() : Bool { return FlxG.keys.pressed.X; };
  static var RELEASE_PUSH = function() : Bool { return FlxG.keys.justReleased.X; };

  static var ROT_CLOCKWISE = function() : Bool { return FlxG.keys.justPressed.C; };
  static var ROT_C_CLOCKWISE = function() : Bool { return FlxG.keys.justPressed.Z; };

  static var RESET = function() : Bool { return FlxG.keys.pressed.R; };

  public function new(level : Level, row : Int, col : Int) {
    super(level, row, col, MOVE_SPEED);
  }

  override public function update() {
    super.update();

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
  }
}

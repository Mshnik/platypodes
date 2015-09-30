package elements;
import flixel.util.FlxPoint;
import flixel.util.FlxPoint;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;
class Character extends Element {

  @final private static var MOVE_SPEED = 300;
  @final private static var MOVE_WHILE_GRABBING_SPEED = 200;
  @final private static var DEFAULT_SPRITE = AssetPaths.vampire__png;

  public static var UP = function() : Bool { return FlxG.keys.pressed.UP; };
  public static var DOWN = function() : Bool { return FlxG.keys.pressed.DOWN; };
  public static var RIGHT = function() : Bool { return FlxG.keys.pressed.RIGHT; };
  public static var LEFT = function() : Bool { return FlxG.keys.pressed.LEFT; };

  public static var GRAB = function() : Bool { return FlxG.keys.pressed.X; };
  public static var ROT_CLOCKWISE = function() : Bool { return FlxG.keys.justPressed.C; };
  public static var ROT_C_CLOCKWISE = function() : Bool { return FlxG.keys.justPressed.Z; };
  public static var RESET = function() : Bool { return FlxG.keys.pressed.R; };

  private var directionFacing : Direction; //The direction this character is facing.

  private var grabbedMirror:Mirror;
  private var tileOffset : Direction;
  private var xOffset : Float; //equal to player.x - mirror.x
  private var yOffset : Float; //equal to player.y - mirror.y;

/** Constructs a new character, with the given level, and initial row and col */
  public function new(level : TiledLevel, x : Int, y : Int, o : TiledObject) {
    super(level, x, y, o, true, MOVE_SPEED, DEFAULT_SPRITE);
  }

  public override function getDirectionFacing() {
    return directionFacing;
  }

  public function isHoldingMirror() : Bool {
    return grabbedMirror != null;
  }

  public function grabMirror(mirror : Mirror) {
    grabbedMirror = mirror;
    tileOffset = Direction.getDirection(mirror.getCol() - getCol(), mirror.getRow() - getRow());
    moveVelocity = MOVE_WHILE_GRABBING_SPEED;
    grabbedMirror.setHoldingCharacter(this, tileOffset, MOVE_WHILE_GRABBING_SPEED);
    trace("Grabbed mirror with row col delta " + tileOffset);
    xOffset = mirror.x - x;
    yOffset = mirror.y - y;
  }

  /** Updates the character
    * - updates the move direction based on the current pressing of direction keys.
    * - calls super.update() to move the character based on this move direction.
    */
  override public function update() {

    directionFacing = Direction.None;

    if(UP()) {
      directionFacing = directionFacing.addDirec(Direction.Up);
    }
    if(DOWN()) {
      directionFacing = directionFacing.addDirec(Direction.Down);
    }
    if(RIGHT()) {
      directionFacing = directionFacing.addDirec(Direction.Right);
    }
    if(LEFT()) {
      directionFacing = directionFacing.addDirec(Direction.Left);
    }

    setMoveDirection(directionFacing);

    if(! GRAB() && grabbedMirror != null) {
      trace("Letting go of mirror");
      grabbedMirror.setHoldingCharacter(null, Direction.None);
      grabbedMirror = null;
      moveVelocity = MOVE_SPEED;
    }

//    if(grabbedMirror != null) {
//        if (getMoveDirection().equals(Direction.Left) && (x < grabbedMirror.x)){
//          grabbedMirror.x = x - xOffset;
//        }
//        else if (getMoveDirection().equals(Direction.Right) && (x > grabbedMirror.x)){
//          grabbedMirror.x = x - xOffset;
//        }
//        else if (getMoveDirection().equals(Direction.Up) && (y < grabbedMirror.y)){
//          grabbedMirror.y = y - yOffset;
//        }
//        else if (getMoveDirection().equals(Direction.Down) && (y > grabbedMirror.y) ){
//          grabbedMirror.y = y - yOffset;
//      }
//    }
    super.update();
  }
}

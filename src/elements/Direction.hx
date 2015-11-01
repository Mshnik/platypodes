package elements;
import flixel.FlxObject;
import flixel.util.FlxPoint;

/**
 * Direction is a small set of vector-like points that represent the relative directions
 * in a grid-based game.
 *
 * All access to the Direction class should be done through the public static final fields
 * that represent the directions. (No TopBar instances should be constructed outside of the
 * Direction class).
 * Because there is only one of each Direction, each is unique and can thus be compared
 * using == and != for equality/inequality.
 *
 * The Directions are constructed with coordinates (x,y), where (0,0) is in the top-left corner.
 **/
class Direction extends FlxPoint {

  public static inline var NONE_VAL = 0x0000;
  public static inline var LEFT_VAL = 0x0001; //FlxObject.LEFT;
  public static inline var RIGHT_VAL = 0x0010; //FlxObject.RIGHT;
  public static inline var UP_VAL = 0x0100; //FlxObject.UP;
  public static inline var DOWN_VAL = 0x1000; //FlxObject.DOWN;
  public static inline var UP_LEFT_VAL = 0x0101;
  public static inline var UP_RIGHT_VAL = 0x0110;
  public static inline var DOWN_LEFT_VAL = 0x1001;
  public static inline var DOWN_RIGHT_VAL = 0x1010;

  @final public static var None : Direction = new Direction(0, 0, NONE_VAL, "None");
  @final public static var Up : Direction = new Direction(0, -1, UP_VAL, "Up");
  @final public static var Up_Right : Direction= new Direction(1, -1, UP_RIGHT_VAL, "Up_Right");
  @final public static var Right : Direction = new Direction(1, 0, RIGHT_VAL, "Right");
  @final public static var Down_Right : Direction = new Direction(1, 1, DOWN_RIGHT_VAL, "Down_Right");
  @final public static var Down : Direction = new Direction(0, 1, DOWN_VAL, "Down");
  @final public static var Down_Left : Direction = new Direction(-1, 1, DOWN_LEFT_VAL, "Down_Left");
  @final public static var Left : Direction = new Direction(-1, 0, LEFT_VAL, "Left");
  @final public static var Up_Left : Direction = new Direction(-1, -1, UP_LEFT_VAL, "Up_Left");

  /**
   * True iff the x and y coordinates of this direction can no longer be changed.
   * True after construction, so that x and y are locked in their starting values.
   **/
  @final private var lockComponents : Bool;

  /** The simple int value that represents this direction.
   * Uses the constants FlxObject.UP, FlxObject.LEFT, FlxObject.RIGHT, FlxObject.DOWN.
   **/
  @final public var simpleDirec(default, null) : Int;

  /** The simple string value that represents this direction */
  @final public var simpleString(default, null) : String;

  /** Construct a TopBar Direction with the given x and y components, then lock the components */
  private function new(x : Float, y : Float, d : Int, s : String){
    super(Std.int(x),Std.int(y));
    simpleDirec = d;
    simpleString = s;
    lockComponents = true;
  }

  /** Set the x value of this Direction to x. Can only be done during construction */
  public override function set_x(x : Float) : Float  {
    if(lockComponents) {
      throw "Can't alter x value of direction after construction";
    }
    return super.set_x(x);
  }

  /** Set the y value of this Direction to y. Can only be done during construction */
  public override function set_y(y : Float) : Float  {
    if(lockComponents) {
      throw "Can't alter y value of direction after construction";
    }
    return super.set_y(y);
  }

  /** Return true if this direction is equal to d. True iff they have the same x and y values. */
  public function equals(d : Direction) {
    return x == d.x && y == d.y;
  }

  /** Throws an exception. Make sure that Directions are never added to a pool so they are not mutated */
  public override function put() {
    throw "Can't put a Direction into the pool - can't mutate them";
  }

  /** Returns the opposite of this Direction, in 2D geometry.
   *
   * None -> None
   * Up -> Down
   * Down -> Up
   * Right -> Left
   * Left -> Right
   * Up_Left -> Down_Right
   * Up_Right -> Down_Left
   * Down_Right -> Up_Left
   * Down_Left -> Up_Right
   **/
  public function opposite() : Direction  {
    if(x == 0) {
      if(y == 0) return Direction.None;
      if(y == 1) return Direction.Up;
      if(y == -1) return Direction.Down;
    }
    if(x == -1){
      if(y == 0) return Direction.Right;
      if(y == 1) return Direction.Up_Right;
      if(y == -1) return Direction.Down_Right;
    }
    if(x == 1){
      if(y == 0) return Direction.Left;
      if(y == 1) return Direction.Up_Left;
      if(y == -1) return Direction.Down_Left;
    }
    throw "Really bad problem - illegal direction created! " + this;
  }

  /** Return the direction corresponding to p's components.
   * Calls getDirection(p.x, p.y).
   **/
  public static function getDirectionOf(p : FlxPoint) : Direction {
    return getDirection(p.x, p.y);
  }

  /** Returns the direction corresponding to (dx, dy). Throws an exception if no such Direction */
  public static function getDirection(dx : Float, dy : Float) : Direction {
    if(dx == 0) {
      if(dy == 0) return Direction.None;
      if(dy == 1) return Direction.Down;
      if(dy == -1) return Direction.Up;
    }
    if(dx == -1){
      if(dy == 0) return Direction.Left;
      if(dy == 1) return Direction.Down_Left;
      if(dy == -1) return Direction.Up_Left;
    }
    if(dx == 1){
      if(dy == 0) return Direction.Right;
      if(dy == 1) return Direction.Down_Right;
      if(dy == -1) return Direction.Up_Right;
    }
    throw "Can't make direction from " + Std.string(dx) + ", " + Std.string(dy);
  }

  /** Returns the direction corresponding to the given simpleDirection value.
   * Should be a combination of the values FlxObject.LEFT, FlxObject.RIGHT, FlxObject.UP, FlxObject.DOWN.
   * 0 will return NONE. An unrecognized value will throw.
   * else -> Throws exception
   **/
  public static function fromSimpleDirection(i : Int) : Direction {
    switch i{
      case NONE_VAL: return Direction.None;
      case UP_VAL: return Direction.Up;
      case UP_RIGHT_VAL: return Direction.Up_Right;
      case RIGHT_VAL: return Direction.Right;
      case DOWN_RIGHT_VAL: return Direction.Down_Right;
      case DOWN_VAL: return Direction.Down;
      case DOWN_LEFT_VAL: return Direction.Down_Left;
      case LEFT_VAL: return Direction.Left;
      case UP_LEFT_VAL: return Direction.Up_Left;
      default: throw "Can't get direction for simpleVal " + Std.string(i);
    }
  }

  /** Returns true iff this is a cardinal direction: Up, Left, Down, Right */
  public inline function isCardinal() : Bool {
    return Math.abs(x) + Math.abs(y) == 1;
  }

  /** Returns true iff this is a diagonal direction: Up_Left, Up_Right, Down_Left, Down_Right */
  public inline function isDiagonal() : Bool {
    return Math.abs(x) + Math.abs(y) == 2;
  }

  /** Returns true iff this is a horizontal direction: Left, Right */
  public inline function isHorizontal() : Bool {
    return y == 0 && x != 0;
  }

  /** Returns true iff this is a vertical direction: Up, Down */
  public inline function isVertical() : Bool {
    return x == 0 && y != 0;
  }

  /** Returns true iff this direction is not None */
  public inline function isNonNone() : Bool {
    return x != 0 && y != 0;
  }

  /** Returns the direction that results from adding v to this direction, by componenet */
  public inline function addDirec(v : FlxPoint) {
    return getDirection(x + v.x, y + v.y);
  }
}

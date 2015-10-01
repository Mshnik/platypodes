package elements;
import flixel.util.FlxVector;
import flixel.util.FlxPoint;
import flixel.util.FlxVector;
class Direction extends FlxVector {

  @final private static var RT202 = 0.70710678118;

  @final public static var None : Direction = new Direction(0, 0);
  @final public static var Up : Direction = new Direction(0, -1);
  @final public static var Down : Direction = new Direction(0, 1);
  @final public static var Left : Direction = new Direction(-1, 0);
  @final public static var Right : Direction = new Direction(1, 0);
  @final public static var Up_Left : Direction = new Direction(-1, -1);
  @final public static var Up_Right : Direction= new Direction(1, -1);
  @final public static var Down_Right : Direction = new Direction(1, 1);
  @final public static var Down_Left : Direction = new Direction(-1, 1);

  private var lockComponents : Bool;

  private function new(x : Float, y : Float){
    super(Std.int(x),Std.int(y));
    lockComponents = true;
  }

  public override function set_x(x : Float) : Float  {
    if(lockComponents) {
      throw "Can't alter x value of direction after construction";
    }
    return super.set_x(x);
  }

  public override function set_y(y : Float) : Float  {
    if(lockComponents) {
      throw "Can't alter y value of direction after construction";
    }
    return super.set_y(y);
  }

  public static function getDirectionOf(p : FlxPoint) : Direction {
    return getDirection(p.x, p.y);
  }

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

  public static function fromSimpleDirection(i : Int) : Direction {
    switch i{
      case 0: return Direction.None;
      case 1: return Direction.Up;
      case 2: return Direction.Up_Right;
      case 3: return Direction.Right;
      case 4: return Direction.Down_Right;
      case 5: return Direction.Down;
      case 6: return Direction.Down_Left;
      case 7: return Direction.Left;
      case 8: return Direction.Up_Left;
      default: throw "Can't get direction for simpleVal " + Std.string(i);
    }
  }

  public function getSimpleDirection() : Int {
    if(x == 0) {
      if(y == 0) return 0;
      if(y == 1) return 5;
      if(y == -1) return 1;
    }
    if(x == -1){
      if(y == 0) return 7;
      if(y == 1) return 6;
      if(y == -1) return 8;
    }
    if(x == 1){
      if(y == 0) return 3;
      if(y == 1) return 4;
      if(y == -1) return 2;
    }
    throw "Really bad problem - illegal direction created! " + this;
  }

  public function getSimpleString() : String {
    if(x == 0) {
      if(y == 0) return "None";
      if(y == 1) return "Down";
      if(y == -1) return "Up";
    }
    if(x == -1){
      if(y == 0) return "Left";
      if(y == 1) return "Down_Left";
      if(y == -1) return "Up_Left";
    }
    if(x == 1){
      if(y == 0) return "Right";
      if(y == 1) return "Down_Right";
      if(y == -1) return "Up_Right";
    }
    throw "Really bad problem - illegal direction created! " + this;
  }

  public inline function isCardinal() : Bool {
    return Math.abs(x) + Math.abs(y) == 1;
  }

  /** Return true iff the vector from start to end is within 90 degrees of this vector */
  public function isInDirection(start : FlxPoint, end : FlxPoint) : Bool {
    var vec = FlxVector.get(end.x - start.x, end.y - start.y);
    var b = Math.abs(degreesBetween(vec)) < 90;
    vec.put();
    return b;
  }

  public inline function addDirec(v : FlxVector) {
    return new Direction(x + v.x, y + v.y);
  }

  public inline function isNonNone() : Bool {
    return x != 0 && y != 0;
  }
}
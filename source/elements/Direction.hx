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
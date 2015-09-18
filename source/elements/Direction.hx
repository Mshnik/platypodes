package elements;
import flixel.util.FlxVector;
class Direction extends FlxVector {

  @final private static var RT202 = 0.70710678118;

  @final public static var None = new Direction(0, 0);
  @final public static var Up = new Direction(0, -1);
  @final public static var Down = new Direction(0, 1);
  @final public static var Left = new Direction(-1, 0);
  @final public static var Right = new Direction(1, 0);
  @final public static var Up_Left = new Direction(-1, -1);
  @final public static var Up_Right = new Direction(1, -1);
  @final public static var Down_Right = new Direction(1, 1);
  @final public static var Down_Left = new Direction(-1, 1);

  public inline function addDirec(v : FlxVector) {
    return new Direction(x + v.x, y + v.y);
  }

  public inline function isNonNone() : Bool {
    return x != 0 && y != 0;
  }
}
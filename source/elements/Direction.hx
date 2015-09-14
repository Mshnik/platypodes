package elements;
class Direction {

  public static var None = new Direction(0, 0);
  public static var Up = new Direction(0, -1);
  public static var Down = new Direction(0, 1);
  public static var Left = new Direction(-1, 0);
  public static var Right = new Direction(1, 0);

  @final @range(-1, 1) public var x : Int;
  @final @range(-1, 1) public var y : Int;

  private function new(x : Int, y : Int) {
    this.x = x;
    this.y = y;
  }

  public function isNonNone() : Bool {
    return x != 0 && y != 0;
  }

  public function toString() : String {
    return "(" + x + "," + y + ")";
  }
}
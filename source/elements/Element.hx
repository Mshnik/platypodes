package elements;
import flixel.util.FlxStringUtil;
import flixel.FlxSprite;

@abstract
class Element extends FlxSprite {

  @final private static var MOVE_EDGE_MARGIN = 5;

  @final public var level:AbsLevel;

  private var moveable:Bool;
  private var moveVelocity:Float;
  private var moveDirection : Direction;

  private function new(level : AbsLevel, row : Int, col : Int, moveVelocity:Float, ?img:Dynamic) {
    super(level.toX(col), level.toY(row), img);
    this.level = level;
    this.moveable = moveVelocity > 0;
    this.moveVelocity = moveVelocity;
    this.moveDirection = Direction.None;
  }

  public override function toString() : String {
    return FlxStringUtil.getClassName(this, true) + " " + FlxStringUtil.getDebugString([
      LabelValuePair.weak("row", getRow()),
      LabelValuePair.weak("col", getCol()),
      LabelValuePair.weak("x", x),
      LabelValuePair.weak("y", y),
      LabelValuePair.weak("w", width),
      LabelValuePair.weak("h", height),
      LabelValuePair.weak("visible", visible),
      LabelValuePair.weak("velocity", velocity)]);
  }

  public inline function getRow() : Int {
    return level.getRowOf(this);
  }

  public inline function getCol() : Int {
    return level.getColOf(this);
  }

  public function setDirection(direction : Direction) {
    if(moveable) {
      moveDirection = direction;
    } else {
      throw "Can't set moveDirection of " + this;
    }
  }

  public override function update() {
    velocity.x = moveVelocity * moveDirection.x;
    velocity.y = moveVelocity * moveDirection.y;

    if (x <= MOVE_EDGE_MARGIN && velocity.x < 0 ||
        x + width >= level.getWidth() - MOVE_EDGE_MARGIN && velocity.x > 0) {
      velocity.x = 0;
    }
    if (y <= MOVE_EDGE_MARGIN && velocity.y < 0 ||
        y + height >= level.getHeight() - MOVE_EDGE_MARGIN && velocity.y > 0) {
      velocity.y = 0;
    }

    var oldRow = getRow();
    var oldCol = getCol();

    super.update();

    var newRow = getRow();
    var newCol = getCol();

    if (oldRow != newRow || oldCol != newCol) {
      level.elementMoved(this, oldRow, oldCol);
    }
  }
}

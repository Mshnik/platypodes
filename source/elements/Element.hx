package elements;
import flixel.FlxSprite;

@abstract
class Element extends FlxSprite {

  @final private static var MOVE_EDGE_MARGIN = 5;

  @final public var level:Level;

  private var moveable:Bool;
  private var moveVelocity:Float;
  private var moveDirection : Direction;

  private function new(level : Level, row : Int, col : Int, moveVelocity:Float) {
    super(level.toX(col), level.toY(row));
    this.level = level;
    this.moveable = moveVelocity > 0;
    this.moveVelocity = moveVelocity;
    this.moveDirection = Direction.None;
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

    super.update();
  }
}

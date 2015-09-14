package elements;
import flixel.FlxSprite;

@abstract
class Element extends FlxSprite {

  private var level:Level;

  private var row:Int;
  private var col:Int;

  private var moveable:Bool;
  private var moveVelocity:Float;
  private var moveDirection : Direction;

  private function new(level : Level, row : Int, col : Int, moveVelocity:Float) {
    this.level = level;
    this.row = row;
    this.col = col;
    this.moveable = moveVelocity > 0;
    this.moveVelocity = moveVelocity;
    this.moveDirection = Direction.None;
  }

  @final
  public function getLevel() : Level {
    return level;
  }

  @final
  public function getRow() : Int {
    return row;
  }

  @final
  public function getCol() : Int {
    return col;
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

    super.update();

    var newRow = getLevel().getRow(this);
    var newCol = getLevel().getCol(this);

    if (   (newRow == row && (moveDirection == Direction.Up || moveDirection == Direction.Down))
        || (newCol == col && (moveDirection == Direction.Left || moveDirection == Direction.Right))) {
      moveDirection = Direction.None;
      velocity.x = 0;
      velocity.y = 0;
    }
  }
}

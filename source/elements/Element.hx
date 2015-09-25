package elements;
import flixel.addons.editors.tiled.TiledObject;
import flixel.util.FlxStringUtil;
import flixel.FlxSprite;

@abstract
class Element extends FlxSprite {

  //Buffer to prevent movables to moving to edge of board
  //Value is in pixels
  @final private static var MOVE_EDGE_MARGIN = 5;

  @final public var level:TiledLevel; //The level this element belongs to

  private var tileObject:TiledObject; //The tiled object representing the element in the grid
  private var moveable:Bool; //True iff this element is movable
  private var moveVelocity:Float; //The velocity with which the element moves
  private var moveDirection : Direction; //The direction this element is currently moving (None if none).

  /** Construct a new element
   * level - the level this element belongs to
   * row - the row of the board this element is (initially) placed on
   * col - the col of the board this element is (initially) placed on
   * moveVelocity - the velocity this element moves at. 0 if this is not a moveable elemt.
   * img - the image to display for this element. If more complex than a simple image, don't supply here;
   *  change the graph content after calling this constructor.
   */
  private function new(level : TiledLevel, x : Int, y : Int, tileObject : TiledObject, moveVelocity:Float = 0, ?img:Dynamic) {
    super(x, y, img);
    this.tileObject = tileObject;
    this.level = level;
    this.moveable = moveVelocity > 0;
    this.moveVelocity = moveVelocity;
    this.moveDirection = Direction.None;
    centerOrigin();
  }

  /** Return a string representation of this element */
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

  /** Return the row of the board this element is currently occupying */
  public inline function getRow() : Int {
    return -1;
  }

  /** Return the col of the board this element is currently occupying */
  public inline function getCol() : Int {
    return -1;
  }

  /** Sets the movement direction of this element.
    * This function can't be called on non-moveable elements
    */
  public function setDirection(direction : Direction) {
    if(moveable) {
      moveDirection = direction;
    } else {
      throw "Can't set moveDirection of " + this;
    }
  }

  /** Updates this element:
    * - Updates the velocity values with the current value of moveDirection
    * - makes sure this wouldn't cause the element to move off of the board
    * - calls super.update() to cause movement to occur
    * - if the row and/or col changed as a result of this, tells the level that
    *     this element has moved.
    */
  public override function update() {
    velocity.x = moveVelocity * moveDirection.x;
    velocity.y = moveVelocity * moveDirection.y;

    if (x <= MOVE_EDGE_MARGIN && velocity.x < 0 ||
        x + width >= level.fullWidth - MOVE_EDGE_MARGIN && velocity.x > 0) {
      velocity.x = 0;
    }
    if (y <= MOVE_EDGE_MARGIN && velocity.y < 0 ||
        y + height >= level.fullHeight - MOVE_EDGE_MARGIN && velocity.y > 0) {
      velocity.y = 0;
    }

    var oldRow = getRow();
    var oldCol = getCol();

    super.update();

    var newRow = getRow();
    var newCol = getCol();

    if (oldRow != newRow || oldCol != newCol) {
      //level.elementMoved(this, oldRow, oldCol);
    }
  }
}

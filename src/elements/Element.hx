package elements;
import flixel.util.FlxRect;
import flixel.addons.editors.tiled.TiledObject;
import flixel.util.FlxStringUtil;
import flixel.FlxSprite;

@abstract
class Element extends FlxSprite {

  //Buffer to prevent movables to moving to edge of board
  //Value is in pixels
  @final private static var MOVE_EDGE_MARGIN = 5;

  @final public var state:GameState; //The state this element belongs to

  private var tileObject:TiledObject; //The tiled object representing the element in the grid

  private var moveable:Bool; //True iff this element is movable
  private var moveVelocity:Float; //The velocity with which the element moves
  private var moveDirection : Direction; //The direction this element is currently moving (None if none).

  public var squareHighlight : FlxSprite; //Sprite highlighting which square this element is on. For debuggin

  /** Construct a new element
   * level - the level this element belongs to
   * row - the row of the board this element is (initially) placed on
   * col - the col of the board this element is (initially) placed on
   * moveable - true if this element ever moves, false otherwise
   * moveVelocity - the velocity this element moves at initially
   * img - the image to display for this element. If more complex than a simple image, don't supply here;
   *  change the graph content after calling this constructor.
   */
  private function new(state : GameState, x : Int, y : Int, tileObject : TiledObject,
                       moveable : Bool = false, moveVelocity:Float = 0, ?img:Dynamic) {
    super(x, y, img);
    this.tileObject = tileObject;
    this.state = state;
    this.moveable = moveable;
    this.moveVelocity = moveVelocity;
    this.moveDirection = Direction.None;
    centerOrigin();

    squareHighlight = new FlxSprite(x, y);
    squareHighlight.makeGraphic(state.level.tileHeight, state.level.tileWidth, 0x88B36666);
    state.add(squareHighlight);

    flipX = TiledLevel.isFlippedX(tileObject);
    flipY = TiledLevel.isFlippedY(tileObject);
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
      LabelValuePair.weak("velocity", velocity),
      LabelValuePair.weak("directionFacing", getDirectionFacing().getSimpleString())]);
  }

  /** Return the row of the board this element is currently occupying. The top-left tile is (0,0) */
  public inline function getRow() : Int {
    return Std.int( (this.y + this.origin.y) / state.level.tileHeight);
  }

  /** Return the col of the board this element is currently occupying. The top-left tile is (0,0) */
  public inline function getCol() : Int {
    return Std.int( (this.x + this.origin.x) / state.level.tileWidth);
  }

  /**
   * Sets the movement speed of this element.
   * This can't change the moveability of an element, but can speed up or slow down
   * a moveable element
   **/
  public function setMoveSpeed(speed : Int) {
    if(moveable) {
      moveVelocity = speed;
    } else {
      throw "Can't set move speed of " + this;
    }
  }

  /** Sets the movement direction of this element.
    * This function can't be called on non-moveable elements
    */
  public function setMoveDirection(direction : Direction) {
    if(moveable) {
      moveDirection = direction;
    } else {
      throw "Can't set moveDirection of " + this;
    }
  }

  public inline function getMoveDirection() : Direction{
    return moveDirection;
  }

  /** Return the direction this element is facing. Override in subclasses
   * if this can rotate
   **/
  public function getDirectionFacing() : Direction {
    return Direction.None;
  }

  /** Return true iff the bounding box for e is entirely contained in the bounding box of this */
  public inline function containsBoundingBoxOf(e : Element) : Bool {
    return x <= e.x && e.x + e.width <= x + width && y <= e.y && e.y + e.height <= y + height;
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
        x + width >= state.level.fullWidth - MOVE_EDGE_MARGIN && velocity.x > 0) {
      velocity.x = 0;
    }
    if (y <= MOVE_EDGE_MARGIN && velocity.y < 0 ||
        y + height >= state.level.fullHeight - MOVE_EDGE_MARGIN && velocity.y > 0) {
      velocity.y = 0;
    }

    super.update();

    squareHighlight.x = getCol() * state.level.tileWidth;
    squareHighlight.y = getRow() * state.level.tileHeight;
  }
}

package elements;
import flixel.util.FlxRect;
import flixel.addons.editors.tiled.TiledObject;
import flixel.util.FlxStringUtil;
import flixel.FlxSprite;

@abstract
class Element extends FlxSprite {

  @final public var state:GameState; //The state this element belongs to
  @final private var tileObject:TiledObject; //The tiled object representing the element in the grid
  @final public var squareHighlight : FlxSprite; //Sprite highlighting which square this element is on. For debuggin

  /** Construct a new element
   * level - the level this element belongs to
   * moveable - true if this element ever moves, false otherwise
   * moveVelocity - the velocity this element moves at initially
   * img - the image to display for this element. If more complex than a simple image, don't supply here;
   *  change the graph content after calling this constructor.
   */
  private function new(state : GameState, tileObject : TiledObject, ?img:Dynamic) {
    super(tileObject.x, tileObject.y, img);
    this.tileObject = tileObject;
    this.state = state;
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
      LabelValuePair.weak("velocity", velocity)]);
  }

  /** Return the row of the board this element is currently occupying. The top-left tile is (0,0) */
  public inline function getRow() : Int {
    return Std.int( (this.y + this.origin.y) / state.level.tileHeight);
  }

  /** Return the col of the board this element is currently occupying. The top-left tile is (0,0) */
  public inline function getCol() : Int {
    return Std.int( (this.x + this.origin.x) / state.level.tileWidth);
  }

  /** Return a bounding box for this element */
  public inline function getBoundingBox(createNew : Bool = true) : FlxRect {
    if (createNew) {
      return new FlxRect(x,y,width,height);
    } else {
      return FlxRect.get(x,y,width,height);
    }
  }

  /** Return true if rect a contains rect b */
  public static inline function rectContainsRect(outer : FlxRect, inner : FlxRect) {
    return outer.left <= inner.left && outer.right >= inner.right && outer.top <= inner.top && outer.bottom >= inner.bottom;
  }

  /** Return true iff the bounding box for e is entirely contained in the bounding box of this */
  public inline function containsBoundingBoxOf(e : Element) : Bool {
    var b = getBoundingBox(false);
    var bb = e.getBoundingBox(false);
    var r = rectContainsRect(b, bb);
    b.put();
    bb.put();
    return r;
  }

  /** Updates this element:
    * - Updates the velocity values with the current value of moveDirection
    * - makes sure this wouldn't cause the element to move off of the board
    * - calls super.update() to cause movement to occur
    * - if the row and/or col changed as a result of this, tells the level that
    *     this element has moved.
    */
  public override function update() {
    super.update();

    squareHighlight.x = getCol() * state.level.tileWidth;
    squareHighlight.y = getRow() * state.level.tileHeight;
  }
}

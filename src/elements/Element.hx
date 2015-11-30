package elements;
import haxe.Timer;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.display.FlxExtendedSprite;
import flixel.util.FlxStringUtil;
import flixel.FlxSprite;

/** An Element is any game piece that exists on the board.
  * Terrain (unmovable walls, floors, holes) are not elements, and drawn light are not elements.
  * Every other game piece, such as light bulbs, switches, mirrors, characters, etc...
  * are all extetions of class Element.
  *
  * All elements within the game exist on a specific tile. Thus, the Element class handles calculating
  * which tile this Element exists within at any time. Collision detection is also handled
  * within the Element class.
  *
  * Elements that can move during the game should extend MovingElement, an extension of Element
  * that handles movement on top of Element's capabilities.
  **/
@abstract class Element extends FlxExtendedSprite {

  public static var updateTimeMap(default, null):Map<String, Float> = new Map<String, Float>();
  public static var drawTimeMap(default, null):Map<String, Float> = new Map<String, Float>();
  public static var updateCount(default, null):Map<String, Int> = new Map<String, Int>();
  public static var drawCount(default, null):Map<String, Int> = new Map<String, Int>();

  /** The GameState this Element exists within. */
  @final public var state:GameState;

  /** The TiledObject that this Element was created from when the level was read from a .tmx file */
  @final private var tileObject:TiledObject;

  /** The GID of the tileObject this Element was created from */
  public var gID(default, null) : Int;

  /** A square highlighting sprite that shows which tile this Element is on.
   * Can be displayed for debugging purposes.
   **/
  @final public var squareHighlight : FlxSprite;

  public var bbox : FlxSprite;

  /** Construct a TopBar element
   * state - the GameState this element belongs to
   * tileObject - the TiledObject that represents this Element in the level file.
   *              the Element's initial x and y coordinates, along with the graphical
   *              rotation and flipping are read from this object.
   * img - the image to display for this element. If more complex than a simple image, don't supply here;
   *  change the graph content after calling this constructor.
   */
  private function new(state : GameState, tileObject : TiledObject, ?img:Dynamic) {
    super(tileObject.x, tileObject.y, img);
    this.tileObject = tileObject;
    this.state = state;
    this.gID = tileObject.gid;
    centerOrigin();

    var tName = Type.getClassName(Type.getClass(this));
    if(! updateTimeMap.exists(tName)) {
      updateTimeMap.set(tName, 0);
      drawTimeMap.set(tName, 0);
      updateCount.set(tName, 0);
      drawCount.set(tName, 0);
    }

    squareHighlight = new FlxSprite(x, y);
    squareHighlight.makeGraphic(state.level.tileHeight, state.level.tileWidth, 0xffffffff);
    state.add(squareHighlight);
    setHighlightColor(0);

    flipX = TiledLevel.isFlippedX(tileObject);
    flipY = TiledLevel.isFlippedY(tileObject);
  }

  /** Return a string representation of this element. Used mainly for debugging. */
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
    return Std.int( (this.y + this.origin.y - offset.y) / state.level.tileHeight);
  }

  /** Return the col of the board this element is currently occupying. The top-left tile is (0,0) */
  public inline function getCol() : Int {
    return Std.int( (this.x + this.origin.x - offset.x) / state.level.tileWidth);
  }

  /** Return a point representing the graphical center of this Element */
  public inline function getCenter(createNew : Bool = false) : FlxPoint {
    if(createNew) {
      return new FlxPoint(x + origin.x - offset.x, y + origin.y - offset.y);
    } else {
      return FlxPoint.get(x + origin.x - offset.x, y + origin.y - offset.y);
    }
  }

  public function centerInTile() {
    var tile = state.getRectangleFor(getRow(), getCol());
    x = (tile.x + tile.width/2) - (width - offset.x) / 2;
    y = (tile.y + tile.height/2) - (height - offset.y) / 2;
    tile.put();
  }

  /** Return a bounding box for this element.
   * By default, a TopBar FlxRect is created. If createNew = false, FlxRect.get(..) is used.
   * This is more efficient, but has side-effects of possibly being modified after the method
   * call finishes, and remember to call .put() after using the boundingBox.
   **/
  public inline function getBoundingBox(createNew : Bool = true) : FlxRect {
    if (createNew) {
      return new FlxRect(x,y,width,height);
    } else {
      return FlxRect.get(x,y,width,height);
    }
  }

  /** A helper constant for the following function, because of float rounding errors */
  @final private static var RECT_TOLERANCE = 0.01;

  /** Return true if rect a contains rect b, with respect to the above tolerance */
  public static inline function rectContainsRect(outer : FlxRect, inner : FlxRect, tolerance : Int = 0) {
    var t = Math.max(RECT_TOLERANCE, tolerance);
    return outer.left - inner.left < t &&
           outer.right - inner.right > - t  &&
           outer.top - inner.top < t &&
           outer.bottom - inner.bottom > - t;
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

  /** Return true iff this element is entirely contained within a tile, false otherwise */
  public inline function isEntirelyWithinTile() : Bool {
    var b = getBoundingBox(false);
    var bb = state.getRectangleFor(getRow(), getCol(), false);
    var r = rectContainsRect(bb, b);
    b.put();
    bb.put();
    return r;
  }

  /** Set the color of this' square highlight sprite, in 0xAARRGGBB format */
  public function setHighlightColor(color : Int) {
    squareHighlight.color = 0x00ffffff & color;
    squareHighlight.alpha = ((0xff000000 & color) >>> 24) / 256;
  }

  /** Updates this element:
   * - moves the squareHighlight to the TopBar row and col.
   * - calls super.update().
   */
  public override function update() {
    squareHighlight.x = getCol() * state.level.tileWidth;
    squareHighlight.y = getRow() * state.level.tileHeight;

    if(bbox != null) {
      bbox.x = this.x + this.origin.x - offset.x;
      bbox.y = this.y + this.origin.y - offset.y;
    }

    super.update();

    var tName = Type.getClassName(Type.getClass(this));
    updateCount.set(tName, updateCount.get(tName)+1);
  }

  public override function draw() {
    var startTime = Timer.stamp();
    super.draw();
    var tName = Type.getClassName(Type.getClass(this));
    drawTimeMap.set(tName, drawTimeMap.get(tName) + (Timer.stamp() - startTime));
    drawCount.set(tName, drawCount.get(tName) + 1);
  }

  public function logUpdateTime(startTime : Float) {
    var tName = Type.getClassName(Type.getClass(this));
    updateTimeMap.set(tName, updateTimeMap.get(tName) + (Timer.stamp() - startTime));
  }

}

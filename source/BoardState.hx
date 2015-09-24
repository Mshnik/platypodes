package;

import haxe.ds.IntMap;
import flixel.util.FlxPoint;
import flixel.FlxBasic;
import elements.Direction;
import elements.Element;
import flixel.FlxSprite;
import flixel.FlxState;

/**
 * A Flx state (playable) that represents a level. Should be extended
 * in order to make a concrete level to display
 */
@abstract
class BoardState extends FlxState
{

  @final private static var SQUARE_SIZE : Int = 48;
  @final private static var SQUARE_MARGIN : Int = 4;
  @final private static var FLOOR_TILE_SPRITE = AssetPaths.floor_Tile__png;

  private var tiles = new IntMap<FlxSprite>(); //The tile images that make up the board
  private var board = new IntMap<Element>(); //A mapping of location -> which element is there, or null if none

  @:isVar private var rows(get, set) : Int; //Number of rows in this map
  @:isVar private var cols(get, set) : Int; //Number of cols in this map

  private var colsDigits : Int; //The number of digits necessary to represent cols. Set when cols is set.

	/**
	 * Function that is called up when to state is created to set it up.
	 * Make sture to set the number of rows and columns before calling this method
	 */
  override public function create():Void
	{
		super.create();

    var makeSquare = function(r : Int, c : Int) : FlxSprite {
      var square = new FlxSprite(c * SQUARE_SIZE + SQUARE_MARGIN/2,
                                 r * SQUARE_SIZE + SQUARE_MARGIN/2);
      square.loadGraphic(FLOOR_TILE_SPRITE, false, SQUARE_SIZE - SQUARE_MARGIN, SQUARE_SIZE - SQUARE_MARGIN);
      return square;
    }

    for(r in 0...rows) {
      for(c in 0...cols) {
        var point = asMapVal(r,c);
        board.set(point, null);
        var tile = makeSquare(r,c);
        tiles.set(point, tile);
        add(tile);
      }
    }
  }

  /**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();

    forEachOfType(Element, function(k) {
      //Do element stuff
    });
	}

  /** Return the number of rows on this level */
  public inline function get_rows() : Int {
    return rows;
  }

  /** Set the number of rows on this level. Number of rows should be positive */
  public function set_rows(rows : Int) {
    var oldRows = this.rows;
    this.rows = rows;
    return oldRows;
  }

  /** Returns the pixel height of this level */
  public inline function getHeight() : Int {
    return rows * SQUARE_SIZE;
  }

  /** Returns the number of cols on this level */
  public inline function get_cols() : Int {
    return cols;
  }

  /** Set the number of cols on this level. Number of cols should be positive */
  public inline function set_cols(cols : Int) {
    var oldCols = this.cols;
    this.cols = cols;
    colsDigits = Math.floor(Math.log(this.cols) / Math.log(10)) + 2;
    return oldCols;
  }

  /** Returns the pixel width of this level */
  public inline function getWidth() : Int {
    return cols * SQUARE_SIZE;
  }

  /** Returns the unique integer that corresponds to the given row and col,
   * for use in the maps that represent the board.
   */
  public inline function asMapVal(row : Int, col : Int) : Int {
    var m = row * 10 * colsDigits + col;
    return m;
  }

  /** Returns the unique integer that corresponds to the given point,
   * for use in the maps that represent the board.
   */
  public inline function asMapValOf(p : FlxPoint) : Int {
    return asMapVal(Std.int(p.y), Std.int(p.x));
  }

  /** Returns the row of the given unique integer that corresponds to a point on the board */
  public inline function rowFromMapVal(mapVal : Int) : Int {
    var r = Std.int(mapVal / (10 * colsDigits));
    return r;
  }

  /** Returns the col of the given unique integer that corresponds to a point on the board */
  public inline function colFromMapVal(mapVal : Int) : Int {
    var c = mapVal % (10 * colsDigits);
    return c;
  }

  /** Converts the given y coordinate in pixel space to a row index in board space */
  public inline function toRow(y : Float) : Int {
    return Std.int(y / SQUARE_SIZE);
  }

  /** Converts the given row coordinate in board space to a y coordinate in pixel space */
  public inline function toY(row : Int) : Float {
    return row * SQUARE_SIZE;
  }

  /** Converts the given x coordinate in pixel space to a col index in board space */
  public inline function toCol(x : Float) : Int {
    return Std.int(x / SQUARE_SIZE);
  }

  /** Converts the given col coordinate in board space to a x coordinate in pixel space */
  public inline function toX(col : Int) : Float {
    return col * SQUARE_SIZE;
  }

  /** Finds the y coordinate of the given element in pixel space, then
   * converts that y coordinate to a row index in board space
   */
  public inline function getRowOf(e : Element) : Int {
    return toRow(e.origin.y + e.y);
  }

  /** Finds the x coordinate of the given element in pixel space, then
   * converts that x coordinate to a col index in board space
   */
  public inline function getColOf(e : Element) : Int {
    return toRow(e.origin.x + e.x);
  }

  /** Returns a point that represents the position in board space of the
   * given element. If recycle is true, the point will be pulled out of the
   * Point pool. Otherwise a new point will be created.
   */
  public inline function getLocOf(e : Element, recycle : Bool = true) : FlxPoint {
    if (recycle) {
      return FlxPoint.get(getColOf(e), getRowOf(e));
    } else {
      return new FlxPoint(getColOf(e), getRowOf(e));
    }
  }

  /** Return true if the given element should be able to move in
    * direction d from its current location
    */
  public function canMove(e : Element, d : Direction) : Bool {
    if(d.isNonNone()) return true;

    var newRow = getRowOf(e) + d.y;
    var newCol = getColOf(e) + d.x;
    var point = getLocOf(e);

    return true;
  }

/** Adds the element to the board to keep track of the board state.
   * Make sure to call after adding an element to the stage (but not any other sprite).
   */
  public function onAddElement(e : Element) {
    elementMoved(e, e.getRow(), e.getCol());
  }

  /** Called by an element whenever it moves from (oldRow, oldCol) to its new current location.
    * Updates the board with the new location of the element, and also preforms a tinting change
    * to signify the board update. (tinting can be removed later)
    */
  public function elementMoved(e : Element, oldRow : Int, oldCol : Int) {
    var oldPoint = FlxPoint.get(oldCol, oldRow);
    var newPoint = getLocOf(e);
    var oldLoc = asMapValOf(oldPoint);
    var newLoc = asMapValOf(newPoint);

    board.set(oldLoc, null);
    board.set(newLoc, e);
    tiles.get(oldLoc).color = 0xffffff;
    tiles.get(newLoc).color = 0x00ffff;

    oldPoint.put();
    newPoint.put();
  }
}
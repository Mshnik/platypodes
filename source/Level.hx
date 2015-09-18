package;

import flixel.util.FlxPoint;
import flixel.FlxBasic;
import elements.Direction;
import haxe.ds.ObjectMap;
import elements.Element;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class Level extends FlxState
{

  @final private static var SQUARE_SIZE : Int = 48;
  @final private static var SQUARE_MARGIN : Int = 4;

  private var board = new ObjectMap<FlxPoint, Element>();
  private var rows : Int;
  private var cols : Int;

  private function new(rows : Int, cols : Int) {
    super();
    this.rows = rows;
    this.cols = cols;
  }

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();

    var makeSquare = function(r : Int, c : Int) : FlxSprite {
      var square = new FlxSprite(c * SQUARE_SIZE + SQUARE_MARGIN/2,
                                 r * SQUARE_SIZE + SQUARE_MARGIN/2);
      square.makeGraphic(SQUARE_SIZE - SQUARE_MARGIN, SQUARE_SIZE - SQUARE_MARGIN);
      return square;
    }

    for(r in 0...rows) {
      for(c in 0...cols) {
        board.set(new FlxPoint(c, r), null);
        add(makeSquare(r,c));
      }
    }
	}

  public function onAddElement(e : Element) {
    board.set(new FlxPoint(e.getCol(), e.getRow()), e);
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
	}

  public function getRows() : Int {
    return rows;
  }

  public function getWidth() : Int {
    return cols * SQUARE_SIZE;
  }

  public function getCols() : Int {
    return cols;
  }

  public function getHeight() : Int {
    return rows * SQUARE_SIZE;
  }

  public function toRow(y : Float) : Int {
    return Std.int(y / SQUARE_SIZE);
  }

  public function toY(row : Int) : Float {
    return row * SQUARE_SIZE;
  }

  public function toCol(x : Float) : Int {
    return Std.int(x / SQUARE_SIZE);
  }

  public function toX(col : Int) : Float {
    return col * SQUARE_SIZE;
  }

  public function getRowOf(e : Element) : Int {
    return toRow(e.y);
  }

  public function getColOf(e : Element) : Int {
    return toRow(e.x);
  }

  public function canMove(e : Element, d : Direction) : Bool {
    if(d.isNonNone()) return true;

    var newRow = getRowOf(e) + d.y;
    var newCol = getColOf(e) + d.x;
    var point = new FlxPoint(newCol, newRow);

    return board.exists(point) && board.get(point) == null;
  }
}
package;

import elements.Direction;
import haxe.ds.ObjectMap;
import elements.Element;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

typedef Point = {row : Int, col : Int}

/**
 * A FlxState which can be used for the actual gameplay.
 */
class Level extends FlxState
{

  private @final static var SQUARE_SIZE = 50;

  private var board = new ObjectMap<Point, Element>();
  private var rows : Int;
  private var cols : Int;

  private function new(rows : Int, cols : Int) {
    this.rows = rows;
    this.cols = cols;
  }

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();

    for(r in 0...rows) {
      for(c in 0...cols) {
        board.set(new Point(r,c), null);
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
	}

  public function getRows() : Int {
    return rows;
  }

  public function getCols() : Int {
    return cols;
  }

  public function getRow(y : Int) : Int {
    return y / SQUARE_SIZE;
  }

  public function getCol(x : Int) : Int {
    return x / SQUARE_SIZE;
  }

  public function getRowOf(e : Element) : Int {
    return getRow(e.y);
  }

  public function getColOf(e : Element) : Int {
    return getRow(e.x);
  }

  public function canMove(e : Element, d : Direction) : Bool {
    if(d == Direction.None) return true;

    var newRow = getRowOf(e) + d.y;
    var newCol = getRowOf(e) + d.x;
    var point = new Point(newRow, newCol);

    return board.exists(point) && board.get(point) == null;
  }
}
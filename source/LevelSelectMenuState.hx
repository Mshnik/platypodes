package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the game's level select menu.
 */
class LevelSelectMenuState extends FlxState
{

  @final static private var MARGIN : Float = 50;
  @final static private var SPACING : Float= 20;

	private var levels : Array<Dynamic>;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void {
		super.create();

    levels = new Array<Dynamic>();
    levels.push(AssetPaths.level0__tmx);
    levels.push(AssetPaths.level1__tmx);
    levels.push(AssetPaths.level2__tmx);


    var x = MARGIN;
    var y = MARGIN;
    var w : Float = -1;
    var h : Float = -1;
    for(i in 0...levels.length) {
      var button = new FlxButton(x, y, "Level " + Std.string(i));

      if (w == -1) {
        w = button.width;
      }
      if (h == -1) {
        h = button.height;
      }

      x += w + SPACING;
      if(x + w > FlxG.width - MARGIN) {
        x = MARGIN;
        y += h + SPACING;
      }

      add(button);
    }


  }
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void {
    levels = null;
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void {
		super.update();
	}	
}
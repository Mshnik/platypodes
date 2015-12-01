package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

/**
 * A FlxState which can be used for the game's level select menu.
 */
class LevelSelectMenuState extends FlxState
{

  @final static private var MARGIN_X : Float = 75;
  @final static private var MARGIN_Y : Float = 140;
  @final static private var SPACING : Float= 20;

    @final static private var BG_COLOR : Int = 0xff410d08;

	private var levels : Array<Dynamic>;
    private var background : FlxSprite;

	/**
	 * Function that is called up when to state is created to set it up.
	 * Creates buttons for each of the levels in levels.
	 */
	override public function create():Void {
      super.create();
        FlxG.camera.bgColor = BG_COLOR;
        background = new FlxSprite();
        background.loadGraphic(AssetPaths.level_select__png, false);
        background.setPosition(0, 50);
        add(background);

    var x = MARGIN_X;
    var y = MARGIN_Y;
    var w : Float = -1;
    var h : Float = -1;

    for(i in 0...PMain.levelPaths.length) {
      var str = "Level " + Std.string(i + 1 - PMain.NUMBER_OF_TUTORIAL_LEVELS);
      if (i < PMain.NUMBER_OF_TUTORIAL_LEVELS) {
        str =  "Tutorial " + Std.string(i + 1);
      }
      var button = new FlxButton(x, y, str, function(){ loadLevel(i); });

      if (w == -1) {
        w = button.width;
      }
      if (h == -1) {
        h = button.height;
      }
      add(button);

      if(PMain.levelBeaten[i]) {
        var check = new FlxSprite();
        check.loadGraphic(AssetPaths.check__png);
        check.setPosition(x + w - check.width/2, y + h - check.height);
        add(check);
      }

      x += w + SPACING;
      if(x + w > FlxG.width - MARGIN_X) {
        x = MARGIN_X;
        y += h + SPACING;
      }

      button.onUp.sound = FlxG.sound.load(AssetPaths.Lightning_Storm_Sound_Effect__mp3);
    }
  }

  /** Loads (Switches) to level at levels[index] */
  private function loadLevel(index : Int) : Void {
    var gameState = new GameState(index);
    FlxG.switchState(gameState);
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
package;

import flixel.addons.plugin.FlxMouseControl;
import flixel.FlxG;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flixel.FlxGame;
import flixel.FlxState;

class PMain extends Sprite
{
	public static var gameWidth:Int = 640; // Initial Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameHeight:Int = 480; // Initial Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = StartState; // The FlxState the game starts with.
	var updateFrameRate:Int = 60; // How many frames per second the game should run at.
	var drawFrameRate:Int = 60;
	var skipSplash:Bool = false; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

  public static inline var SPRITE_SIZE = 64;

	public static inline var NUMBER_OF_TUTORIAL_LEVELS:Int = 4;

  public static inline var TEAM_ID = 626; //THIS SHOULD NEVER CHANGE EVER EVER EVER
  public static inline var VERSION_ID = 300; //This can change when we do a big update
  public static inline var DEBUG_MODE = true; //Make sure this is false when we submit

	public static var A_VERSION(default, null) : Bool; //True if the game is in version A, false for version B
	public static var zoom : Float = -1; //Zoom in game. Her


	// You can pretty much ignore everything from here on - your code should go in your states.
	
	public static function main():Void {
		Lib.current.addChild(new PMain());
	}
	
	public function new() {
		super();
		
		if (stage != null) 
		{
			init();
		}
		else 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
	
	private function init(?E:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}
	
	private function setupGame():Void {
    Logging.getSingleton().initialize(TEAM_ID, VERSION_ID, DEBUG_MODE);
    Logging.getSingleton().recordPageLoad(""); //TODO?
    var abTestVal = Logging.getSingleton().assignABTestValue(0);
    Logging.getSingleton().recordABTestValue();

    A_VERSION = true;

    var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1) {
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		var g = new FlxGame(gameWidth, gameHeight, initialState, zoom, updateFrameRate, drawFrameRate, skipSplash, startFullscreen);
		FlxG.plugins.add(new FlxMouseControl());
		addChild(g);
	}

  /** A helper function - creates a range as an array */
  public static function rangeToArray(min : Int, max : Int) : Array<Int> {
    var arr = new Array<Int>();
    for(i in min...max) {
      arr.push(i);
    }
    return arr;
  }
}
package ;
import flixel.addons.plugin.FlxMouseControl;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
class StartState extends FlxState{

  private static inline var SPLASH_WIDTH = 640;
  private static inline var SPLASH_HEIGHT = 480;

  var playButton : FlxButton;

  public static var WIND_SOUND : FlxSound;

  public function new() {
    super();
  }

  public override function create(){
    super.create();
    var splash = new FlxSprite(0,0);
    splash.loadGraphic(AssetPaths.splashscreen__png);
    var scale = Math.min(FlxG.width / SPLASH_WIDTH, FlxG.height / SPLASH_HEIGHT);
    splash.scale.set(scale, scale);
    splash.updateHitbox();
    splash.setPosition(0, (FlxG.height - splash.height)/2);
    add(splash);

    var levels = new Array<Dynamic>();
    levels.push(AssetPaths.t0__tmx);
    levels.push(AssetPaths.t1__tmx);
    levels.push(AssetPaths.t2__tmx);
    levels.push(AssetPaths.t3__tmx);
    levels.push(AssetPaths.olivial0__tmx);
    levels.push(AssetPaths.olivial1__tmx);
    levels.push(AssetPaths.olivial2__tmx);
    levels.push(AssetPaths.olivial3__tmx);
    levels.push(AssetPaths.l0__tmx);
    levels.push(AssetPaths.l1__tmx);
    levels.push(AssetPaths.l2__tmx);
    levels.push(AssetPaths.l3__tmx);
    levels.push(AssetPaths.l4__tmx);
    levels.push(AssetPaths.l5__tmx);
    levels.push(AssetPaths.l6__tmx);
    levels.push(AssetPaths.oliviag0__tmx);
    levels.push(AssetPaths.oliviag1__tmx);
    levels.push(AssetPaths.g0__tmx);
    levels.push(AssetPaths.oliviag2__tmx);
    levels.push(AssetPaths.oliviag3__tmx);

    playButton = new FlxButton(0,0,"Play", function(){
      WIND_SOUND.fadeOut(5, 0);
      PMain.zoom = 0.7;
      FlxG.switchState(new GameState(levels, 0));
    });
    playButton.setPosition(462, 310);
    add(playButton);

    var startSound = FlxG.sound.load(AssetPaths.Lightning_Storm_Sound_Effect__mp3);
    startSound.persist = true;
    startSound.play();

    WIND_SOUND = FlxG.sound.load(AssetPaths.wind__mp3, 0.5, true);
    WIND_SOUND.persist = true;
    WIND_SOUND.play();

    var f = new FlxText(10,10, 200, "Ver-"+PMain.VERSION_ID + (PMain.A_VERSION ? ".1" : ".2"));
    add(f);
  }
}

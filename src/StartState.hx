package ;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
class StartState extends FlxState{

  private static inline var SPLASH_WIDTH = 960;
  private static inline var SPLASH_HEIGHT = 480;

  var playButton : FlxButton;

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

    playButton = new FlxButton(0,0,"Play", function(){
      FlxG.switchState(new GameState(levels, 0));
    });
    playButton.setPosition((FlxG.width - playButton.width)/2, FlxG.height - (FlxG.height - splash.height)/4 - playButton.height/2);
    add(playButton);

    var startSound = FlxG.sound.load(AssetPaths.Lightning_Storm_Sound_Effect__mp3);
    startSound.persist = true;
    startSound.play();
  }
}

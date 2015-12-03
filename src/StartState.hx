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

    playButton = new FlxButton(0,0,"Play", function(){
      WIND_SOUND.fadeOut(5, 0);
      PMain.zoom = 1;
      FlxG.switchState(new GameState(0));
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

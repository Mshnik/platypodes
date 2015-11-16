package ;
import flixel.FlxCamera;
import flixel.util.FlxPoint;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;

class HUD extends FlxTypedGroup<FlxSprite>{

  public static inline var HEIGHT =38;

  @final public var state : GameState;

  public var backTop(default, null) : FlxSprite;
  public var backBottom(default, null) : FlxSprite;

  public var doReset(default, null) : Bool;
  public var doLevelSelect(default, null) : Bool;

  public var levelSelectButton(default, null) : FlxButton;
  public var resetButton(default, null) : FlxButton;
  public var undoButton(default, null) : FlxButton;

  public var muteButton(default, null) : FlxButton;
  public var volDownButton(default, null) : FlxButton;
  public var volUpButton(default, null) : FlxButton;
  public var zoomOutButton(default, null) : FlxButton;
  public var zoomInButton(default, null) : FlxButton;

  public function new(state : GameState, camera : FlxCamera) {
    super();

    this.state = state;
    backTop = new FlxSprite().loadGraphic(AssetPaths.control_bar__png, false, FlxG.width, HEIGHT);
    backBottom = new FlxSprite().loadGraphic(AssetPaths.control_bar__png, false, FlxG.width, HEIGHT);
    backBottom.y = FlxG.height - HEIGHT;

    levelSelectButton = new FlxButton(0, 0, "Sel Lvl (Esc)", function(){doLevelSelect = true;});
    resetButton = new FlxButton(0, 0, "Reset (R)", function(){doReset = true;});
    undoButton = new FlxButton(0, 0, "Undo (Bksp)");
    muteButton = new FlxButton(0, 0, "Mute (0)", function(){
      FlxG.sound.muted = ! FlxG.sound.muted;
      FlxG.game.soundTray.show();
    });
    volDownButton = new FlxButton(0, 0, "Vol Down (-)", function(){
      FlxG.sound.muted = false;
      FlxG.sound.volume -= 0.1;
      FlxG.game.soundTray.show();
    });
    volUpButton = new FlxButton(0, 0, "Vol Up (+)", function(){
      FlxG.sound.muted = false;
      FlxG.sound.volume += 0.1;
      FlxG.game.soundTray.show();
    });
    zoomInButton = new FlxButton(0, 0, "Zoom In (1)");
    zoomOutButton = new FlxButton(0, 0, "Zoom Out (2)");

    levelSelectButton.setPosition(40, (HEIGHT - levelSelectButton.height) / 2);
    resetButton.setPosition(400, (HEIGHT - resetButton.height) / 2);
    undoButton.setPosition(520, (HEIGHT - undoButton.height) / 2);

    trace(muteButton.width);

    muteButton.setPosition(40, FlxG.height - ((HEIGHT - muteButton.height) * 3 / 2));
    volDownButton.setPosition(160, FlxG.height - ((HEIGHT - volDownButton.height) * 3 / 2));
    volUpButton.setPosition(280, FlxG.height - ((HEIGHT - volUpButton.height) * 3 / 2));
    zoomInButton.setPosition(400, FlxG.height - ((HEIGHT - zoomInButton.height) * 3 / 2));
    zoomOutButton.setPosition(520, FlxG.height - ((HEIGHT - zoomOutButton.height) * 3 / 2));

    add(backTop);
    add(backBottom);
    add(levelSelectButton);
    add(resetButton);
    add(undoButton);

    add(muteButton);
    add(volDownButton);
    add(volUpButton);

    add(zoomInButton);
    add(zoomOutButton);
    forEach(function(spr:FlxSprite) {
      spr.scrollFactor.set();
      spr.cameras = [camera];
    });
  }
}

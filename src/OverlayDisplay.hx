package ;
import flixel.FlxCamera;
import flixel.util.FlxPoint;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;

class OverlayDisplay extends FlxTypedGroup<FlxSprite>{

  public static inline var HEIGHT =38;

  @final public static var TEXT_COLOR : Int = 0xfff8dec0;

  @final public var state : GameState;

  public var backTop(default, null) : FlxSprite;
  public var backBottom(default, null) : FlxSprite;
  public var winSprite(default, null) : FlxSprite;
  public var deadSprite(default, null) : FlxSprite;

  public var showWinSprite(default, set) : Bool;
  public var showDeadSprite(default, set) : Bool;

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

  public var levelName(default, null): FlxText;

  public function new(state : GameState, camera : FlxCamera, hasNextLevel : Bool) {
    super();

    this.state = state;
    backTop = new FlxSprite().loadGraphic(AssetPaths.control_bar__png, false, FlxG.width, HEIGHT);
    backBottom = new FlxSprite().loadGraphic(AssetPaths.control_bar__png, false, FlxG.width, HEIGHT);
    backBottom.y = FlxG.height - HEIGHT;

    winSprite = new FlxSprite();
    if(hasNextLevel) {
      winSprite.loadGraphic(AssetPaths.success_popup__png);
    } else {
      winSprite.loadGraphic(AssetPaths.thanks_popup__png);
    }
    winSprite.setPosition((FlxG.width - winSprite.width)/2, -winSprite.height + HEIGHT);
    add(winSprite);
    deadSprite = new FlxSprite().loadGraphic(AssetPaths.fail_popup__png);
    deadSprite.setPosition((FlxG.width - deadSprite.width)/2, -deadSprite.height + HEIGHT);
    add(deadSprite);

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

    levelSelectButton.setPosition(280, (HEIGHT - levelSelectButton.height) / 2);
    resetButton.setPosition(400, (HEIGHT - resetButton.height) / 2);
    undoButton.setPosition(520, (HEIGHT - undoButton.height) / 2);

    muteButton.setPosition(40, FlxG.height - ((HEIGHT - muteButton.height) * 3 / 2));
    volDownButton.setPosition(160, FlxG.height - ((HEIGHT - volDownButton.height) * 3 / 2));
    volUpButton.setPosition(280, FlxG.height - ((HEIGHT - volUpButton.height) * 3 / 2));
    zoomInButton.setPosition(400, FlxG.height - ((HEIGHT - zoomInButton.height) * 3 / 2));
    zoomOutButton.setPosition(520, FlxG.height - ((HEIGHT - zoomOutButton.height) * 3 / 2));

    levelName = new FlxText();
    levelName.color = TEXT_COLOR;
    levelName.size = 10;
    levelName.text = this.state.levelName;
    levelName.setPosition(40, (HEIGHT - levelName.height) / 2);

    add(winSprite);
    add(deadSprite);
    add(backTop);
    add(backBottom);
    add(levelName);
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

  public function set_showDeadSprite(show : Bool) : Bool {
    if(! show) {
      deadSprite.y = -deadSprite.height + HEIGHT;
      deadSprite.velocity.y = 0;
    }
    return this.showDeadSprite = show;
  }

  public function set_showWinSprite(show : Bool) : Bool {
    if(! show) {
      winSprite.y = -winSprite.height + HEIGHT;
      winSprite.velocity.y = 0;
    }
    return this.showWinSprite = show;
  }

  public override function update(){
    if(showDeadSprite) {
      if(deadSprite.y > (FlxG.height - deadSprite.height) /2 - HEIGHT) {
        deadSprite.velocity.y *= 0.81;
      } else {
        deadSprite.velocity.y = 400;
      }
    }
    if(showWinSprite) {
      if(winSprite.y > (FlxG.height - winSprite.height) /2 - HEIGHT) {
        winSprite.velocity.y *= 0.81;
      } else {
        winSprite.velocity.y = 400;
      }
    }

    super.update();
  }
}

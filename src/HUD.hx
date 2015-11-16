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

  public var resetButton(default, null) : FlxButton;
  public var undoButton(default, null) : FlxButton;
  public var zoomOutButton(default, null) : FlxButton;
  public var zoomInButton(default, null) : FlxButton;

  public function new(state : GameState, camera : FlxCamera) {
    super();

    this.state = state;
    backTop = new FlxSprite().loadGraphic(AssetPaths.control_bar__png, false, FlxG.width, HEIGHT);
    backBottom = new FlxSprite().loadGraphic(AssetPaths.control_bar__png, false, FlxG.width, HEIGHT);
    backBottom.y = FlxG.height - HEIGHT;

    //Button events (pressed, ispressed, etc) are handled in GameState to unify with keyboard commands easily.
    resetButton = new FlxButton(0, 0, "Reset (R)", function(){doReset = true;});
    undoButton = new FlxButton(0, 0, "Undo (Bksp)");
    zoomInButton = new FlxButton(0, 0, "Zoom In (1)");
    zoomOutButton = new FlxButton(0, 0, "Zoom Out (2)");

    resetButton.setPosition(60, (HEIGHT - resetButton.height) / 2);
    undoButton.setPosition(210, (HEIGHT - undoButton.height) / 2);
    zoomInButton.setPosition(380, (HEIGHT - zoomInButton.height) / 2);
    zoomOutButton.setPosition(540, (HEIGHT - zoomOutButton.height) / 2);

    add(backTop);
    add(backBottom);
    add(resetButton);
    add(undoButton);
    add(zoomInButton);
    add(zoomOutButton);
    forEach(function(spr:FlxSprite) {
      spr.scrollFactor.set();
      spr.cameras = [camera];
    });
  }
}

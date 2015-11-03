package ;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.util.FlxPoint;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;

class TopBar extends FlxTypedGroup<FlxSprite>{

  public static inline var HEIGHT =38;

  @final public var state : GameState;

  public var back(default, null) : FlxSprite;
  private var resetButton : FlxButton;
  private var undoButton : FlxButton;
  private var zoomOutButton : FlxButton;
  private var zoomInButton : FlxButton;

  public function new(state : GameState, camera : FlxCamera) {
    super();

    this.state = state;
    back = new FlxSprite().loadGraphic(AssetPaths.control_bar_icons_off__png, false, FlxG.width, HEIGHT);

    resetButton = new FlxButton(0, 0, "Reset (R)", state.resetState);
    undoButton = new FlxButton(0, 0, "Undo (Bksp)", state.undoMove);
    zoomInButton = new FlxButton(0, 0, "Zoom In (1)");
    zoomOutButton = new FlxButton(0, 0, "Zoom Out (2)");

    resetButton.setPosition(60, (HEIGHT - resetButton.height) / 2);
    undoButton.setPosition(210, (HEIGHT - undoButton.height) / 2);
    zoomInButton.setPosition(380, (HEIGHT - zoomInButton.height) / 2);
    zoomOutButton.setPosition(540, (HEIGHT - zoomOutButton.height) / 2);

    add(back);
    add(resetButton);
    add(undoButton);
    add(zoomInButton);
    add(zoomOutButton);
    forEach(function(spr:FlxSprite) {
      spr.scrollFactor.set();
      spr.cameras = [camera];
    });
  }

  public override function update() {
    super.update();
    if(zoomOutButton.status == FlxButton.PRESSED) {
      state.zoomOut();
    } else if(zoomInButton.status == FlxButton.PRESSED) {
      state.zoomIn();
    }
  }
}

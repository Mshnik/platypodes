package ;
import flixel.FlxCamera;
import flixel.util.FlxPoint;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;

class TopBar extends FlxTypedGroup<FlxSprite>{

  @final public var state : GameState;

  public var back(default, null) : FlxSprite;
  private var resetButton : FlxButton;
  private var undoButton : FlxButton;
  private var zoomOutButton : FlxButton;
  private var zoomInButton : FlxButton;

  public function new(state : GameState, camera : FlxCamera) {
    super();

    this.state = state;
    back = new FlxSprite().makeGraphic(FlxG.width, GameState.HUD_HEIGHT, FlxColor.BLACK);

    resetButton = new FlxButton(5, 5, "Reset", state.resetState);
    undoButton = new FlxButton(100, 5, "Undo", state.undoMove);
    zoomOutButton = new FlxButton(200, 5, "Zoom Out");
    zoomInButton = new FlxButton(300, 5, "Zoom In");

    add(back);
    add(resetButton);
    add(undoButton);
    add(zoomOutButton);
    add(zoomInButton);
    forEach(function(spr:FlxSprite) {
      spr.scrollFactor.set();
      spr.cameras = [camera];
    });
  }
}

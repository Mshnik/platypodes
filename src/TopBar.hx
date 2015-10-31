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

    resetButton = new FlxButton(0, 0, "Reset (R)", state.resetState);
    undoButton = new FlxButton(0, 0, "Undo (Bksp)", state.undoMove);
    zoomInButton = new FlxButton(0, 0, "Zoom In (1)");
    zoomOutButton = new FlxButton(0, 0, "Zoom Out (2)");

    add(back);
    add(resetButton);
    add(undoButton);
    add(zoomInButton);
    add(zoomOutButton);
    forEach(function(spr:FlxSprite) {
      spr.scrollFactor.set();
      spr.cameras = [camera];
    });

    var buttonCount = 4;
    var i = 1;
    forEachOfType(FlxButton, function(b : FlxButton) {
      var centerX = (i / (buttonCount * 2)) * FlxG.width;
      b.x = centerX - b.width/2;
      b.y = (GameState.HUD_HEIGHT - b.height) / 2;
      i += 2;
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

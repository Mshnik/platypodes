package ;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;

class TopBar extends FlxTypedGroup<FlxSprite>{

  private static inline var HEIGHT = 100;

  private var back : FlxSprite;
  private var resetButton : FlxButton;
  private var undoButton : FlxButton;
  private var zoomOutButton : FlxButton;
  private var zoomInButton : FlxButton;

  public function new() {
    super();

    back = new FlxSprite().makeGraphic(Std.int(FlxG.width / FlxG.camera.zoom), HEIGHT, FlxColor.BLACK);

    resetButton = new FlxButton(5, 5, "Reset");
    undoButton = new FlxButton(100, 5, "Undo");
    zoomOutButton = new FlxButton(200, 5, "Zoom Out");
    zoomInButton = new FlxButton(300, 5, "Zoom In");

    add(back);
    add(resetButton);
    add(undoButton);
    add(zoomOutButton);
    add(zoomInButton);
    forEach(function(spr:FlxSprite) {
      spr.scrollFactor.set();
    });
  }

  public function fixZoom() {
    back.setGraphicSize(Std.int(back.width / FlxG.camera.zoom), Std.int(back.height / FlxG.camera.zoom));

    resetButton.setGraphicSize(Std.int(resetButton.width / FlxG.camera.zoom), Std.int(resetButton.height / FlxG.camera.zoom));
    undoButton.setGraphicSize(Std.int(undoButton.width / FlxG.camera.zoom), Std.int(undoButton.height / FlxG.camera.zoom));
    zoomOutButton.setGraphicSize(Std.int(zoomOutButton.width / FlxG.camera.zoom), Std.int(zoomOutButton.height / FlxG.camera.zoom));
    zoomInButton.setGraphicSize(Std.int(zoomInButton.width / FlxG.camera.zoom), Std.int(zoomInButton.height / FlxG.camera.zoom));

  }
}

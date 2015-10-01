package;

import flixel.group.FlxTypedGroup;
import elements.Exit;
import elements.LightSwitch;
import elements.LightBulb;
import flixel.FlxBasic;
import elements.Element;
import elements.Mirror;
import elements.Character;
import elements.Direction;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;

class GameState extends FlxState
{

  private static var menuButton = function() : Bool { return FlxG.keys.justPressed.ESCAPE; };

  @final private var levelPath : Dynamic;
  public var level:TiledLevel;

  public var player:Character;
  public var floor:FlxObject;
  public var exit:Exit;
  public var lightBulbs:FlxTypedGroup<LightBulb>;
  public var lightSwitches:FlxTypedGroup<LightSwitch>;
  public var mirrors:FlxTypedGroup<Mirror>;

  public function new(levelPath : Dynamic) {
    super();
    this.levelPath = levelPath;
  }

  override public function create():Void
  {
    FlxG.mouse.visible = false;

    //super.create();
    bgColor = 0xffaaaaaa;

    // Load the level's tilemaps
    level = new TiledLevel(levelPath);

    // Add tilemaps
    add(level.floorTiles);
    add(level.holeTiles);
    add(level.wallTiles);

    mirrors = new FlxTypedGroup<Mirror>();
    lightBulbs = new FlxTypedGroup<LightBulb>();
    lightSwitches = new FlxTypedGroup<LightSwitch>();

    // Load all objects
    level.loadObjects(onAddObject);

    //Make sure non-player objects are added to level after player is added to level
    //For ordering of the update loop
    add(exit);
    add(mirrors);
    add(lightBulbs);
    add(lightSwitches);
    add(player);
  }

  /** Returns the element at the given row and col, if any. Null otherwise */
  public function getElementAt(row : Int, col : Int) : Element {
    var check = function(e : Element) : Bool {
      return e.getRow() == row && e.getCol() == col;
    }

    for(lightSwitch in lightSwitches.members) {
      if (check(lightSwitch)) return lightSwitch;
    }
    for(mirror in mirrors.members) {
      if (check(mirror)) return mirror;
    }
    for(lightBulb in lightBulbs.members) {
      if (check(lightBulb)) return lightBulb;
    }
    if (check(exit)) return exit;
    if (check(player)) return player;
    return null;
  }

  public function updateLight() : Void {
    exit.isOpen = false;

    lightSwitches.forEach(function(l : LightSwitch) {
      l.isLit = false;
    });

    lightBulbs.forEach(function(l : LightBulb) {
      l.markLightDirty();
    });
  }

  override public function update():Void {
    if(menuButton()) {
      FlxG.switchState(new LevelSelectMenuState());
    }

    super.update();

    // Collide player with holes and walls
    level.collideWithLevel(player, false);

    FlxG.collide(player, lightBulbs);
    FlxG.collide(player, lightSwitches);

    //Collide with mirrors - don't let player walk through mirrors
    FlxG.overlap(player, mirrors, null, handleInitialPlayerMirrorCollision);

    FlxG.collide(mirrors, mirrors);

    //Collide mirrors with walls and holes, check for mirror rotation
    level.collideWithLevel(mirrors, true);

    //Check for victory
    if(! exit.isOpen) {
      var allLit = true;
      lightSwitches.forEach(function(l : LightSwitch) {
        allLit = allLit && l.isLit;
      });
      if(allLit ) {
        exit.set_isOpen(true);
      }
    }
  }

  private function handleInitialPlayerMirrorCollision(player : Character, mirror : Mirror) : Bool {
    mirror.immovable = true;
    FlxObject.separate(player, mirror);

    if(Character.ROT_CLOCKWISE()) {
      mirror.rotateClockwise();
      updateLight();
    }
    if(Character.ROT_C_CLOCKWISE()) {
      mirror.rotateCounterClockwise();
      updateLight();
    }

    if(Character.GRAB() && ! player.isHoldingMirror()) {
      player.grabMirror(mirror);
    }
    mirror.immovable = false;

    return true;
  }

  public function onAddObject(o : TiledObject, g : TiledObjectGroup, x : Int, y : Int) {
    switch (o.type.toLowerCase()) {
      case "player_start":
        var player = new Character(this, x, y, o);
        FlxG.camera.follow(player);
        this.player = player;

      case "mirror":
        var mirror = new Mirror(this, x, y, o);
        mirrors.add(mirror);

      case "lightorb":
        var lightBulb = new LightBulb(this, x, y, o);
        lightBulb.immovable = true;
        lightBulbs.add(lightBulb);

      case "lightswitch":
        var lightSwitch = new LightSwitch(this, x, y, o);
        lightSwitch.immovable = true;
        lightSwitches.add(lightSwitch);

      case "exit":
        var exit = new Exit(this, x, y, o);
        this.exit = exit;

      default:
        trace("Got unknown object " + o.type.toLowerCase());
    }
  }
}
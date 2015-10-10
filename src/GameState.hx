package;

import flixel.util.FlxRect;
import flixel.text.FlxText;
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

  private static var MENU_BUTTON = function() : Bool { return FlxG.keys.justPressed.ESCAPE; };
  public static var RESET = function() : Bool { return FlxG.keys.pressed.R; };

  @final private var levelPath : Dynamic;
  public var level:TiledLevel;

  public var player:Character;
  public var floor:FlxObject;
  public var exit:Exit;
  public var lightBulbs:FlxTypedGroup<LightBulb>;
  public var lightSwitches:FlxTypedGroup<LightSwitch>;
  public var mirrors:FlxTypedGroup<Mirror>;

  private var won : Bool;
  private var winText : FlxText;
  private var deadText : FlxText;

  public function new(levelPath : Dynamic) {
    super();
    this.levelPath = levelPath;
  }

  override public function create():Void
  {
    FlxG.mouse.visible = false;
    won = false;

    super.create();

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

  /** Returns a rectangle representing the given tile */
  public function getRectangleFor(row : Int, col : Int, createNew : Bool = false) : FlxRect {
    if (createNew) {
      return new FlxRect(col * level.tileWidth, row * level.tileHeight, level.tileWidth, level.tileHeight);
    } else {
      return FlxRect.get(col * level.tileWidth, row * level.tileHeight, level.tileWidth, level.tileHeight);
    }
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

    mirrors.forEach(function(m : Mirror){
      m.isLit = false;
    });

    lightSwitches.forEach(function(l : LightSwitch) {
      l.isLit = false;
    });

    lightBulbs.forEach(function(l : LightBulb) {
      l.markLightDirty();
    });
  }

  override public function update():Void {
    if(MENU_BUTTON()) {
      FlxG.switchState(new LevelSelectMenuState());
    } else if(RESET()) {
      FlxG.switchState(new GameState(levelPath));
    }

    super.update();

    //Only collide player with stuff she isn't holding a mirror
    if (player.mirrorHolding == null) {

      level.collideWithLevel(player, false);  // Collides player with walls

      FlxG.collide(player, lightBulbs);
      FlxG.collide(player, lightSwitches);

      //Collide player with light - don't kill player, just don't let them walk into it
      lightBulbs.forEach(function(l : LightBulb){
        for(lightsprite in l.get_light_sprites()) {
          FlxG.collide(player, lightsprite);
        }
      });

      //Collide with mirrors - don't let player walk through mirrors
      FlxG.collide(player, mirrors);
    } else {
      //Only collide player with the mirror they are holding
      FlxG.collide(player, player.mirrorHolding);
    }


    //Check for victory
    if(! exit.isOpen) {
      var allLit = true;
      lightSwitches.forEach(function(l : LightSwitch) {
        allLit = allLit && l.isLit;
      });
      if(allLit ) {
        exit.set_isOpen(true);
      }
    } else {
      if(exit.containsBoundingBoxOf(player)) {
        win();
      }
    }

    if (winText != null) {
      winText.x = FlxG.camera.scroll.x + 200;
      winText.y = FlxG.camera.scroll.y + 100;
    }
    if (deadText != null) {
      deadText.x = FlxG.camera.scroll.x + 200;
      deadText.y = FlxG.camera.scroll.y + 100;
    }
  }

  public function onAddObject(o : TiledObject, g : TiledObjectGroup) {
    switch (o.type.toLowerCase()) {
      case "player_start":
        var player = new Character(this, o);
        FlxG.camera.follow(player);
        this.player = player;

      case "mirror":
        var mirror = new Mirror(this, o);
        mirror.immovable = true;
        mirrors.add(mirror);

      case "lightorb":
        var lightBulb = new LightBulb(this, o);
        lightBulb.immovable = true;
        lightBulbs.add(lightBulb);

      case "lightswitch":
        var lightSwitch = new LightSwitch(this, o);
        lightSwitch.immovable = true;
        lightSwitches.add(lightSwitch);

      case "exit":
        var exit = new Exit(this, o);
        this.exit = exit;

      default:
        trace("Got unknown object " + o.type.toLowerCase());
    }
  }

  public function killPlayer() {
    player.kill();
    deadText = new FlxText(0, 0, 500, "You died - press R", 30);
    deadText.color = 0xFFFF0022;
    add(deadText);
  }

  public function win() {
    if(won) return;

    won = true;
    winText = new FlxText(0, 0, 500, "You win!!", 100);
    add(winText);
    player.kill();
  }

}

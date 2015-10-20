package;

import elements.*;
import flixel.FlxCamera;
import flixel.util.FlxRect;
import flixel.text.FlxText;
import flixel.group.FlxTypedGroup;
import flixel.FlxBasic;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flash.Lib;


class GameState extends FlxState {

  private static inline var INITAL_ZOOM_PROPERTY = "initial_zoom";
  public static var MENU_BUTTON = function() : Bool { return FlxG.keys.justPressed.ESCAPE; };
  public static var NEXT_LEVEL_BUTTON = function() : Bool { return FlxG.keys.justPressed.SPACE; };
  public static var RESET = function() : Bool { return FlxG.keys.pressed.R; };

  private static var ZOOM_IN = function() : Bool { return FlxG.keys.pressed.ONE; };
  private static var ZOOM_OUT = function() : Bool { return FlxG.keys.pressed.TWO;  };
  private static inline var ZOOM_MULT : Float = 1.02;

  @final private var levelPaths : Array<Dynamic>;
  @final private var levelPathIndex : Int;
  public var level:TiledLevel;
  private var savedZoom : Float; //The zoom that the player had before restarting

  public var player:Character;
  public var floor:FlxObject;
  public var exit:Exit;
  public var lightBulbs:FlxTypedGroup<LightBulb>;
  public var lightSwitches:FlxTypedGroup<LightSwitch>;
  public var lightSprites:FlxTypedGroup<LightSprite>;
  public var mirrors:FlxTypedGroup<Mirror>;

  private var won : Bool;
  private var winText : FlxText;
  private var deadText : FlxText;

  public function new(levelPaths : Array<Dynamic>, levelPathIndex : Int, savedZoom : Float = -1) {
    super();
    this.levelPaths = levelPaths;
    this.levelPathIndex = levelPathIndex;
    this.savedZoom = savedZoom;
  }

  override public function create():Void
  {
    FlxG.mouse.visible = false;
    won = false;

    super.create();

    // Load the level's tilemaps
    level = new TiledLevel(levelPaths[levelPathIndex]);

    // Add tilemaps
    add(level.floorTiles);
    add(level.holeTiles);
    add(level.wallTiles);
    add(level.tutorialTiles);

    mirrors = new FlxTypedGroup<Mirror>();
    lightBulbs = new FlxTypedGroup<LightBulb>();
    lightSwitches = new FlxTypedGroup<LightSwitch>();
    lightSprites = new FlxTypedGroup<LightSprite>();

    // Load all objects
    level.loadObjects(onAddObject);

    //Make sure non-player objects are added to level after player is added to level
    //For ordering of the update loop
    add(exit);
    add(lightSprites);
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

  /** Return true iff the given row and col is lighted.
   * This return true if the location has a lightbulb, lighted mirror, or a light beam on it.
   **/
  public function isLit(row : Int, col : Int) : Bool {
    var e : Element = getElementAt(row, col);
    if(Std.is(e, Lightable)) {
      var l : Lightable = cast e;
      return l.isLit;
    }
    var check = function(l : LightSprite) : Bool {
      return l.getRow() == row && l.getCol() == col;
    }

    for(lightSprite in lightSprites.members) {
      if(check(lightSprite)) return true;
    }
    return false;
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
    } else if(won && NEXT_LEVEL_BUTTON() && levelPathIndex + 1 < levelPaths.length){
      FlxG.switchState(new GameState(levelPaths, levelPathIndex + 1));
    } else if(RESET()) {
      FlxG.switchState(new GameState(levelPaths, levelPathIndex, savedZoom));
    } else if (ZOOM_IN()) {
      setZoom(FlxG.camera.zoom * ZOOM_MULT);
    } else if (ZOOM_OUT()) {
      setZoom(FlxG.camera.zoom / ZOOM_MULT);
    }

    super.update();

    //Only collide player with stuff she isn't holding a mirror
    if (player.mirrorHolding == null) {

      level.collideWithLevel(player, false);  // Collides player with walls

      FlxG.collide(player, lightBulbs);
      FlxG.collide(player, lightSwitches);

      //Collide player with light - don't kill player, just don't let them walk into it
      FlxG.collide(player, lightSprites);

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
  }

  public function onAddObject(o : TiledObject, g : TiledObjectGroup) {
    switch (o.type.toLowerCase()) {
      case "player_start":
        var player = new Character(this, o);
        this.player = player;
        FlxG.camera.follow(player, FlxCamera.STYLE_NO_DEAD_ZONE, 1);
        if(savedZoom == -1) {
          var initialZoom = o.custom.get(INITAL_ZOOM_PROPERTY);
          if (initialZoom == null) {
            trace(INITAL_ZOOM_PROPERTY + " unset for this level");
            setZoom(FlxG.camera.zoom);
          } else {
            setZoom(Std.parseFloat(initialZoom));
          }
        } else {
          setZoom(savedZoom);
        }

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

  private function setZoom(zoom:Float) {
    //Check for min and max zoom
    if (zoom < 0.25) zoom = 0.25;
    if (zoom > 1) zoom = 1;

    FlxG.camera.zoom = zoom;
    FlxG.camera.setSize(Std.int(Lib.current.stage.stageWidth / zoom), Std.int(Lib.current.stage.stageHeight / zoom));
    level.updateBuffers();
    FlxG.camera.focusOn(player.getMidpoint(null));

    savedZoom = zoom;
  }

  public function killPlayer() {
    player.animation.play(Character.DEATH_ANIMATION_KEY, true);
    deadText = new FlxText(0, 0, 0, "You died - press R", 60);
    deadText.x = FlxG.camera.scroll.x + (FlxG.camera.width - deadText.width) / 2;
    deadText.y = FlxG.camera.scroll.y + (FlxG.camera.height - deadText.height) / 2 + player.height;
    deadText.color = 0xFFFF0022;
    add(deadText);
  }

  public function win() {
    if(won) return;

    won = true;
    winText = new FlxText(0, 0, 0, "You WIN!" + (levelPathIndex + 1 == levelPaths.length ? "" : " - Press Space to continue"), 40);
    winText.x = FlxG.camera.scroll.x + (FlxG.camera.width - winText.width) / 2;
    winText.y = FlxG.camera.scroll.y + (FlxG.camera.height - winText.height) / 2;
    add(winText);
    player.kill();
  }

}

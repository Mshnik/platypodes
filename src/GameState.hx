package;

import elements.InteractableElement;
import logging.ActionElement;
import haxe.Timer;
import logging.ActionStack;
import flixel.system.FlxSound;
import elements.*;
import elements.impl.*;
import flixel.FlxCamera;
import flixel.util.FlxRect;
import flixel.text.FlxText;
import flixel.group.FlxTypedGroup;
import flixel.FlxBasic;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.plugin.FlxMouseControl;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.util.FlxPoint;
import flash.Lib;


class GameState extends FlxState {

  private static inline var DISPLAY_COORDINATES = false;

  private static inline var INITAL_ZOOM_PROPERTY = "initial_zoom";
  public static var MENU_BUTTON = function() : Bool { return false; }; //TODO - reinstate after friends
  public static var NEXT_LEVEL_BUTTON = function() : Bool { return FlxG.keys.justPressed.SPACE; };
  public static var RESET = function() : Bool { return FlxG.keys.pressed.R; };

  public var UNDO : Void -> Bool;

  private static var ZOOM_IN = function() : Bool { return FlxG.keys.pressed.ONE; };
  private static var ZOOM_OUT = function() : Bool { return FlxG.keys.pressed.TWO;  };
  private static inline var ZOOM_MULT : Float = 1.02;

  @final private var levelPaths : Array<Dynamic>;
  @final private var levelPathIndex : Int;
  public var level:TiledLevel;
  private var savedZoom : Float; //The zoom that the player had before restarting

  public var player:Character;
  public var tooltip:Tooltip;

  public var actionStack : ActionStack;
  private static inline var RE_LOGGING_TIME = 5000; //time in ms between whole stack (redundant) loggings
  private var actionStackTimer : Timer;

  public var floor:FlxObject;
  public var exit:Exit;
  public var lightBulbs:FlxTypedGroup<LightBulb>;
  public var lightSwitches:FlxTypedGroup<LightSwitch>;
  public var lightSprites:FlxTypedGroup<LightSprite>;
  public var mirrors:FlxTypedGroup<Mirror>;

  private var won : Bool;
  private var winText : FlxText;
  private var deadText : FlxText;

  private static var BACKGROUND_THEME : FlxSound;

  private var hud : TopBar;
  private var hudCamera : FlxCamera;

  private var sndWin : FlxSound;

  public function new(levelPaths : Array<Dynamic>, levelPathIndex : Int, savedZoom : Float = -1,
                      savedActionStack : ActionStack = null) {
    super();
    this.levelPaths = levelPaths;
    this.levelPathIndex = levelPathIndex;
    this.savedZoom = savedZoom;
    this.actionStack = savedActionStack;
  }

  override public function create():Void {
    FlxG.mouse.visible = true;
    FlxG.plugins.add(new FlxMouseControl());

    super.create();

    // Load the level's tilemaps
    level = new TiledLevel(this, levelPaths[levelPathIndex]);

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

    //Either create a TopBar action stack for the player, or set the saved action stack to use the TopBar player
    if (actionStack == null) {
      Logging.getSingleton().recordLevelStart(levelPathIndex); //TODO - add more?
      actionStack = new ActionStack(player);
    } else {
      actionStack.character = player;
    }
    actionStackTimer = new Timer(RE_LOGGING_TIME);
    actionStackTimer.run = actionStack.logStack;

    //Create Tooltip
    tooltip = new Tooltip(this);

    //Make sure non-player objects are added to level after player is added to level
    //For ordering of the update loop
    add(exit);
    add(mirrors);
    add(lightSprites);
    add(lightBulbs);
    add(lightSwitches);
    add(player);
    add(tooltip);

    UNDO = function(){
      return FlxG.keys.justPressed.BACKSPACE && ! player.tileLocked &&
        (player.mirrorHolding == null || player.mirrorHolding.moveDirection.equals(Direction.None));
    };

    if(DISPLAY_COORDINATES) {
      for(r in 0...level.height) {
        for(c in 0...level.width) {
          add(new FlxText(c * level.tileWidth, r * level.tileHeight, 0, "(" + r + "," + c + ")", 20));
        }
      }
    }

    setZoom(FlxG.camera.zoom);

    hudCamera = new FlxCamera(0, 0, FlxG.width, TopBar.HEIGHT, 1.0);
    FlxG.cameras.add(hudCamera);
    hud = new TopBar(this, hudCamera);
    add(hud);

    level.wallTiles.forEachOfType(FlxObject, function(ob : FlxObject){
      ob.cameras = [FlxG.camera];
    });


    if(BACKGROUND_THEME == null) {
      BACKGROUND_THEME = FlxG.sound.load(AssetPaths.Background__mp3, 0.95, true);
      BACKGROUND_THEME.persist = true;
      BACKGROUND_THEME.play();
    }

    sndWin = FlxG.sound.load(AssetPaths.Victory__mp3);
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

  /** Return true if the current space is open or contains a walkable element (character, exit) */
  public function isSpaceWalkable(row : Int, col : Int) : Bool {
    if(isLit(row, col)) {
      return false;
    }
    var elm = getElementAt(row, col);
    return elm == null || Std.is(elm, Exit) || Std.is(elm, Character);
  }

  /** Returns the tile coordinates of the tile that contains the given world coordinates */
  public function worldToTileCoordinates(worldCoord : FlxPoint) : FlxPoint{
    return new FlxPoint(worldCoord.x / level.tileWidth, worldCoord.y / level.tileHeight);
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
      actionStackTimer.stop();
      FlxG.switchState(new LevelSelectMenuState());
    } else if(won && NEXT_LEVEL_BUTTON() && levelPathIndex + 1 < levelPaths.length){
      BACKGROUND_THEME.resume();
      FlxG.switchState(new GameState(levelPaths, levelPathIndex + 1));
    } else if(RESET()) {
      resetState();
    } else if (UNDO() && !player.isDying) {
      undoMove();
    } else if (ZOOM_IN()) {
      zoomIn();
    } else if (ZOOM_OUT()) {
      zoomOut();
    }

    super.update();

    //Only collide player with stuff she isn't holding a mirror
    if (player.mirrorHolding == null) {

      level.collideWithLevel(player, false, function(a, a){player.playCollisionSound();});  // Collides player with walls

      FlxG.collide(player, lightBulbs, function(a, a){player.playCollisionSound();});
      FlxG.collide(player, lightSwitches, function(a, a){player.playCollisionSound();});

      //Collide player with light - don't kill player, just don't let them walk into it
      FlxG.collide(player, lightSprites, function(a, a){player.playCollisionSound();});

      //Collide with mirrors - don't let player walk through mirrors
      FlxG.collide(player, mirrors, function(a, a){player.playCollisionSound();});
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

    FlxG.mouse.load();
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
            setZoom(0.4);
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

  public inline function zoomIn() {
    setZoom(FlxG.camera.zoom * ZOOM_MULT);
  }

  public inline function zoomOut() {
    setZoom(FlxG.camera.zoom / ZOOM_MULT);
  }

  private function setZoom(zoom:Float) {
    //Check for min and max zoom
    if (zoom < 0.35) zoom = 0.35;
    if (zoom > 1) zoom = 1;

    FlxG.camera.zoom = zoom;
    FlxG.camera.setSize(Std.int(Lib.current.stage.stageWidth / zoom),
                        Std.int(Lib.current.stage.stageHeight / zoom));
    level.updateBuffers();
    FlxG.camera.focusOn(player.getMidpoint(null));
    savedZoom = zoom;
  }

  public function executeAction(a : ActionElement) {
    if(! a.isExecutable()) {
      trace("Can't execute non-executable action " + a);
      return;
    }

    if(player.getCol() != a.startX || player.getRow() != a.startY) {
      trace("Can't execute action " + a + " player is at " + player.getCol() + ", " + player.getRow());
    }

    if (a.id == ActionElement.MOVE) {
      if (! player.canMoveInDirection(a.moveDirection)) {
        trace("Can't execute action " + a + " can't move in direction " + a.moveDirection.simpleString);
        return;
      }
      player.moveDirection = a.moveDirection;
      player.directionFacing = a.directionFacing;
      player.tileLocked = true;
      return;
    }

    var elm : Element = getElementAt(a.elmY, a.elmX);
    if (elm == null || ! Std.is(elm, Mirror)) {
      trace("Can't execute action " + a + " can't push/rotate " + elm);
      return;
    }

    if (a.id == ActionElement.PUSHPULL && Std.is(elm, Mirror)) {
      var m : Mirror = Std.instance(elm, Mirror);
      if (player.alive && (! m.canMoveInDirection(a.moveDirection) || ! player.canMoveInDirectionWithMirror(a.moveDirection, m))) {
        trace("Can't execute action " + a + " can't move mirror " + m + " in direction " + a.moveDirection.simpleString);
        return;
      }

      m.holdingPlayer = player;
      m.moveDirection = a.moveDirection;
      player.moveDirection = a.moveDirection;
      player.directionFacing = a.directionFacing;
      player.moveSpeed = InteractableElement.MOVE_SPEED;
      player.tileLocked = true;
      return;
    }
    if (a.id == ActionElement.ROTATE && Std.is(elm, Mirror)) {
      var m : Mirror = Std.instance(elm, Mirror);
      if (a.rotateClockwise) {
        m.rotateClockwise();
      } else {
        m.rotateCounterClockwise();
      }
      return;
    }
  }

  public function resetState() {
    actionStackTimer.stop();
    actionStack.addReset();
    FlxG.switchState(new GameState(levelPaths, levelPathIndex, savedZoom, actionStack));
  }

  public function undoMove() {
    if(!player.isDying) {
      var action : ActionElement = actionStack.getHeadSkipDeath();
      if(action != null) {
        actionStack.addUndo();
        executeAction(action.getOpposite());
        if(! player.alive) {
          player.revive();
          remove(deadText);
        }
      }
    }
  }

  public function killPlayer() {
    player.mirrorHolding = null;
    player.deathSound.play();
    player.animation.play(Character.DEATH_ANIMATION_KEY, false);
    actionStack.addDie();
    deadText = new FlxText(0, 0, Std.int(400 / FlxG.camera.zoom), "You died - press Backspace to undo or R to reset", Std.int(30 / FlxG.camera.zoom));
    deadText.x = FlxG.camera.scroll.x + (FlxG.camera.width - deadText.width) / 2;
    deadText.y = FlxG.camera.scroll.y + deadText.height;
    deadText.color = 0xFFCC0022;
    add(deadText);
  }

  public function win() {
    if(won) return;

    won = true;
    actionStack.addWin();
    BACKGROUND_THEME.pause();
    sndWin.onComplete = function() {
      BACKGROUND_THEME.resume();
    }
    sndWin.play();
    winText = new FlxText(0, 0, 0, "You WIN!" + (levelPathIndex + 1 == levelPaths.length ? " Thanks for playing!!" : " - Press Space to continue"), Std.int(30 / FlxG.camera.zoom));
    winText.x = FlxG.camera.scroll.x + (FlxG.camera.width - winText.width) / 2;
    winText.y = FlxG.camera.scroll.y + winText.height;
    add(winText);
    player.kill();
    Logging.getSingleton().recordLevelEnd();
    actionStackTimer.stop();
  }

}

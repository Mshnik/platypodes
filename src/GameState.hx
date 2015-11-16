package;

import PMain;
import flixel.ui.FlxButton;
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
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.util.FlxPoint;
import flash.Lib;


class GameState extends FlxState {

  private static inline var DISPLAY_COORDINATES = false;

  public static var MENU_BUTTON : Void -> Bool;
  public static var NEXT_LEVEL_BUTTON = function() : Bool { return FlxG.keys.justPressed.SPACE; };

  public var RESET : Void -> Bool;
  private var UNDO : Void -> Bool;

  private static inline var UNDO_THROTTLE = 0.5; //At most 2 undos per second
  private var mostRecentUndoTimeStamp : Float = -1;

  private var ZOOM_IN : Void -> Bool;
  private var ZOOM_OUT : Void -> Bool;

  private static inline var ZOOM_MULT : Float = 1.03;

  @final private var levelPaths : Array<Dynamic>;
  @final private var levelPathIndex : Int;
  public var level:TiledLevel;

  public var player:Character;
  public var tooltip:Tooltip;

  public var actionStack : ActionStack;
  public var levelStartTime : Float;

  public var floor:FlxObject;
  public var exit:Exit;
  public var lightBulbs:FlxTypedGroup<LightBulb>;
  public var lightSwitches:FlxTypedGroup<LightSwitch>;
  public var lightSprites:FlxTypedGroup<LightSprite>;
  public var glassWalls:FlxTypedGroup<GlassWall>;

  public var interactables:FlxTypedGroup<InteractableElement>;

  private var won : Bool;
  private var winText : FlxText;
  private var deadText : FlxText;

  private static var BACKGROUND_THEME : FlxSound;

  private var hud : HUD;
  private var mainCamera : FlxCamera;
  private var hudCamera : FlxCamera;

  private var sndWin : FlxSound;
  private var sndWinDone : Bool;

  public function new(levelPaths : Array<Dynamic>, levelPathIndex : Int,
                      savedActionStack : ActionStack = null, levelStartTime: Float = -1) {
    super();
    this.levelPaths = levelPaths;
    this.levelPathIndex = levelPathIndex;
    this.actionStack = savedActionStack;
    this.levelStartTime = levelStartTime;
  }

  override public function create():Void {
    super.create();
    // Load the level's tilemaps
    level = new TiledLevel(this, levelPaths[levelPathIndex]);

    // Add tilemaps
    add(level.floorTiles);
    add(level.holeTiles);
    add(level.wallTiles);
    add(level.tutorialTiles);

    interactables = new FlxTypedGroup<InteractableElement>();
    lightBulbs = new FlxTypedGroup<LightBulb>();
    lightSwitches = new FlxTypedGroup<LightSwitch>();
    lightSprites = new FlxTypedGroup<LightSprite>();
    glassWalls = new FlxTypedGroup<GlassWall>();

    // Load all objects
    level.loadObjects(onAddObject);

    //Either create a TopBar action stack for the player, or set the saved action stack to use the TopBar player
    if (actionStack == null) {
      Logging.getSingleton().recordLevelStart(levelPathIndex); //TODO - add more?
      actionStack = new ActionStack(player);
      levelStartTime = Timer.stamp();
    } else {
      actionStack.character = player;
    }

    //Create Tooltip
    tooltip = new Tooltip(this);

    //Make sure non-player objects are added to level after player is added to level
    //For ordering of the update loop
    add(glassWalls);
    add(exit);
    add(interactables);
    add(lightSprites);
    add(lightBulbs);
    add(lightSwitches);
    add(player);
    add(tooltip);

    if(DISPLAY_COORDINATES) {
      for(r in 0...level.height) {
        for(c in 0...level.width) {
          add(new FlxText(c * level.tileWidth, r * level.tileHeight, 0, "(" + r + "," + c + ")", 20));
        }
      }
    }

    setZoom(PMain.zoom);

    level.wallTiles.forEachOfType(FlxObject, function(ob : FlxObject){
      ob.cameras = [FlxG.camera];
    });
    level.floorTiles.forEachOfType(FlxObject, function(ob : FlxObject){
      ob.cameras = [FlxG.camera];
    });
    level.holeTiles.forEachOfType(FlxObject, function(ob : FlxObject){
      ob.cameras = [FlxG.camera];
    });

    mainCamera = FlxG.camera;
    hudCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1.0);
    hudCamera.bgColor = 0x00000000;
    FlxG.cameras.add(hudCamera);
    this.hud = new HUD(this, hudCamera);
    add(this.hud);

    if(BACKGROUND_THEME == null) {
      BACKGROUND_THEME = FlxG.sound.load(AssetPaths.Background__mp3, 0.95, true);
      BACKGROUND_THEME.persist = true;
      BACKGROUND_THEME.play();
    }

    sndWin = FlxG.sound.load(AssetPaths.Victory__mp3);

    MENU_BUTTON = function(){
      return FlxG.keys.justPressed.ESCAPE || this.hud.doLevelSelect;
    }

    RESET = function(){
      return FlxG.keys.justPressed.R || this.hud.doReset;
    }

    UNDO = function(){
      return (FlxG.keys.pressed.BACKSPACE || this.hud.undoButton.status == FlxButton.PRESSED)
      && ! player.tileLocked
      && (player.elmHolding == null || player.elmHolding.moveDirection.equals(Direction.None));
    };

    ZOOM_IN = function() {
      return FlxG.keys.pressed.ONE || this.hud.zoomInButton.status == FlxButton.PRESSED;
    }

    ZOOM_OUT = function() {
      return FlxG.keys.pressed.TWO || this.hud.zoomOutButton.status == FlxButton.PRESSED;
    }
  }

  public override function destroy() {
    player.destroy();
    exit.destroy();
    lightBulbs.destroy();
    lightSprites.destroy();
    lightSprites.destroy();
    glassWalls.destroy();
    interactables.destroy();
    super.destroy();
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
    for(mirror in interactables.members) {
      if (check(mirror)) return mirror;
    }
    for(lightBulb in lightBulbs.members) {
      if (check(lightBulb)) return lightBulb;
    }
    for(glassWall in glassWalls.members) {
      if (check(glassWall)) return glassWall;
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

    interactables.forEachOfType(Lightable, function(l : Lightable){
      l.resetLightInDirection();
    });

    lightSwitches.forEach(function(l : LightSwitch) {
      l.resetLightInDirection();
    });

    glassWalls.forEach(function(w : GlassWall) {
      w.resetLightInDirection();
    });

    lightBulbs.forEach(function(l : LightBulb) {
      l.markLightDirty();
    });
  }



  override public function update():Void {
    if(MENU_BUTTON()) {
      FlxG.switchState(new LevelSelectMenuState());
    } else if(won && (NEXT_LEVEL_BUTTON() || sndWinDone) && levelPathIndex + 1 < levelPaths.length){
      BACKGROUND_THEME.resume();
      FlxG.switchState(new GameState(levelPaths, levelPathIndex + 1));
    } else if(RESET()) {
      resetState();
    } else if (UNDO() && !player.isDying) {
      undoAction();
    } else if (ZOOM_IN()) {
      zoomIn();
    } else if (ZOOM_OUT()) {
      zoomOut();
    }

    super.update();

    //Only collide player with stuff she isn't holding a mirror
    if (player.elmHolding == null || (player.elmHolding != null && player.elmHolding.destTile == null)) {

      level.collideWithLevel(player, false, function(a, a){player.playCollisionSound();});  // Collides player with walls

      FlxG.collide(player, lightBulbs, function(a, b){player.playCollisionSound();});
      FlxG.collide(player, lightSwitches, function(a, b){player.playCollisionSound();});
      FlxG.collide(player, glassWalls, function(a, b){player.playCollisionSound();});

      //Collide player with light - don't kill player, just don't let them walk into it
      FlxG.collide(player, lightSprites, function(a, b){player.playCollisionSound();});

      //Collide with mirrors - don't let player walk through mirrors
      FlxG.collide(player, interactables, function(a, b){player.playCollisionSound();});
    } else {
      //Only collide player with the mirror they are holding
      FlxG.collide(player, player.elmHolding);
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
        player.cameras = [FlxG.camera];
        FlxG.camera.follow(player, FlxCamera.STYLE_NO_DEAD_ZONE, 1);

      case "mirror":
        var mirror = AbsMirror.createMirror(this, o);
        mirror.immovable = true;
        mirror.cameras = [FlxG.camera];
        interactables.add(mirror);

      case "crystal":
        var crystal = new Crystal(this, o);
        crystal.immovable = true;
        crystal.cameras = [FlxG.camera];
        interactables.add(crystal);

      case "barrel":
        var barrel = new Barrel(this, o);
        barrel.immovable = true;
        barrel.cameras = [FlxG.camera];
        interactables.add(barrel);

      case "lightorb":
        var lightBulb = new LightBulb(this, o);
        lightBulb.immovable = true;
        lightBulb.cameras = [FlxG.camera];
        lightBulbs.add(lightBulb);

      case "lightswitch":
        var lightSwitch = new LightSwitch(this, o);
        lightSwitch.immovable = true;
        lightSwitch.cameras = [FlxG.camera];
        lightSwitches.add(lightSwitch);

      case "exit":
        var exit = new Exit(this, o);
        exit.cameras = [FlxG.camera];
        this.exit = exit;

      case "glasswall":
        var wall = new GlassWall(this, o);
        wall.immovable = true;
        wall.cameras = [FlxG.camera];
        glassWalls.add(wall);

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
    if (zoom > 0.7) zoom = 0.7;

    FlxG.camera.zoom = zoom;
    FlxG.camera.setSize(Std.int(Lib.current.stage.stageWidth / zoom),
                        Std.int(Lib.current.stage.stageHeight / zoom));
    level.updateBuffers();
    FlxG.camera.focusOn(player.getMidpoint(null));
    PMain.zoom = zoom;
  }

  public function executeAction(a : ActionElement, playSounds : Bool = false) : Bool {
    if(! a.isExecutable()) {
      trace("Can't execute non-executable action " + a);
      return false;
    }

    if(player.getCol() != a.startX || player.getRow() != a.startY) {
      trace("Can't execute action " + a + " player is at " + player.getCol() + ", " + player.getRow());
    }

    if (a.id == ActionElement.MOVE) {
      if (! player.canMoveInDirection(a.moveDirection)) {
        trace("Can't execute action " + a + " can't move in direction " + a.moveDirection.simpleString);
        if(playSounds) {
          player.playCollisionSound();
        }
        return false;
      }
      player.moveDirection = a.moveDirection;
      player.directionFacing = a.directionFacing;
      player.moveSpeed = Character.MOVE_SPEED;
      player.tileLocked = true;
      return true;
    }

    var elm : Element = getElementAt(a.elmY, a.elmX);
    if (elm == null || ! Std.is(elm, Mirror)) {
      trace("Can't execute action " + a + " can't push/rotate " + elm);
      return false;
    }

    if (a.id == ActionElement.PUSHPULL && Std.is(elm, InteractableElement)) {
      var m : InteractableElement = Std.instance(elm, InteractableElement);
      trace("Trying to push/pull " + m);
      if (player.alive && (! m.canMoveInDirection(a.moveDirection) || ! player.canMoveInDirectionWithElement(a.moveDirection, m))) {
        trace("Can't execute action " + a + " can't move mirror " + m + " in direction " + a.moveDirection.simpleString);
        if(playSounds) {
          player.playCollisionSound();
        }
        return false;
      }

      m.holdingPlayer = player;
      m.moveDirection = a.moveDirection;
      player.moveDirection = a.moveDirection;
      player.directionFacing = a.directionFacing;
      player.moveSpeed = InteractableElement.MOVE_SPEED;
      player.tileLocked = true;
      return true;
    }
    if (a.id == ActionElement.ROTATE && Std.is(elm, Mirror)) {
      var m : Mirror = Std.instance(elm, Mirror);
      if (a.rotateClockwise) {
        m.rotateClockwise();
      } else {
        m.rotateCounterClockwise();
      }
      return true;
    }
    return false;
  }

  public function resetState() {
    actionStack.addReset();
    FlxG.switchState(new GameState(levelPaths, levelPathIndex, actionStack, levelStartTime));
  }

  public function undoAction() {
    if(!player.isDying) {
      var action : ActionElement = actionStack.getFirstUndoable();
      var t = Timer.stamp();
      if(action != null && t - mostRecentUndoTimeStamp >= UNDO_THROTTLE) {
        actionStack.addUndo();
        executeAction(action.getOpposite());
        mostRecentUndoTimeStamp = t;
        if(! player.alive) {
          player.revive();
          remove(deadText);
        }
      }
    }
  }

  public function killPlayer() {
    player.elmHolding = null;
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
      sndWinDone = true;
    }
    sndWin.play();
    winText = new FlxText(0, 0, 0, "You WIN!" + (levelPathIndex + 1 == levelPaths.length ? " Thanks for playing!!" : " - Press Space to continue"), Std.int(30 / FlxG.camera.zoom));
    winText.x = FlxG.camera.scroll.x + (FlxG.camera.width - winText.width) / 2;
    winText.y = FlxG.camera.scroll.y + winText.height;
    add(winText);
    player.kill();
    exit.playVictoryAnimation();
    var compTime = Timer.stamp() - levelStartTime;
    Logging.getSingleton().recordEvent(ActionStack.LOG_LEVEL_COMPLETION_TIME_ID, "" + compTime);
    Logging.getSingleton().recordEvent(ActionStack.LOG_ACTION_COUNT_ON_LEVEL_COMPLETE, "" + actionStack.getInteractedActionCount());
    Logging.getSingleton().recordLevelEnd();
    //actionStackTimer.stop();
  }

}

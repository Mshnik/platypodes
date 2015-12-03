package;

import flixel.FlxSprite;
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

  @final public var levelPathIndex : Int;
  public var levelName : String;
  public var level(default, null):TiledLevel;

  public var player:Character;
  public var tooltip:Tooltip;
  public static var NO_ROTATE_LEVEL(default, null) = [1,2];

  public var actionStack : ActionStack;
  public var levelStartTime : Float;

  public var floor:FlxObject;
  public var exit:Exit;
  public var lightBulbs:FlxTypedGroup<LightBulb>;
  public var lightSwitches:FlxTypedGroup<LightSwitch>;
  public var lightSprites:FlxTypedGroup<LightSprite>;
  public var glassWalls:FlxTypedGroup<GlassWall>;

  public var interactables:FlxTypedGroup<InteractableElement>;

  public var won(default, null) : Bool;
  private var autoProgress : Bool;

  private static var BACKGROUND_THEME : FlxSound;

  private var hud : OverlayDisplay;
  public var mainCamera(default, null) : FlxCamera;
  public var hudCamera(default, null) : FlxCamera;

  private var sndWin : FlxSound;
  private var sndWinDone : Bool;

  public function new(levelPathIndex : Int, savedActionStack : ActionStack = null, levelStartTime: Float = -1) {
    super();
    this.levelPathIndex = levelPathIndex;
    this.actionStack = savedActionStack;
    this.levelStartTime = levelStartTime;
    this.levelName = "Level " + Std.string(levelPathIndex + 1);
  }

  override public function create():Void {
    super.create();

    // Load the level's tilemaps
    level = new TiledLevel(this, PMain.levelPaths[levelPathIndex]);

    // Add tilemaps
    add(level.floorMap);
    add(level.holeMap);
    add(level.wallMap);

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
    add(player.glowSprite);
    add(tooltip);

    if(DISPLAY_COORDINATES) {
      for(r in 0...level.height) {
        for(c in 0...level.width) {
          var t = new FlxText(c * level.tileWidth, r * level.tileHeight, 0, "(" + r + "," + c + ")", 8);
          t.cameras = [FlxG.camera];
          add(t);
        }
      }
    }

    level.holeMap.cameras = [FlxG.camera];
    level.floorMap.cameras = [FlxG.camera];
    level.wallMap.cameras = [FlxG.camera];

    mainCamera = FlxG.camera;
    hudCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1.0);
    hudCamera.bgColor = 0x00000000;
    FlxG.cameras.add(hudCamera);

    this.hud = new OverlayDisplay(this, hudCamera, levelPathIndex < PMain.levelPaths.length - 1);
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
      return (FlxG.keys.pressed.BACKSPACE || this.hud.undoButton.status == FlxButton.PRESSED
              || (! player.alive && FlxG.keys.pressed.SPACE))
      && ! player.tileLocked
      && (player.elmHolding == null || player.elmHolding.moveDirection.equals(Direction.None));
    };

    FlxG.camera.focusOn(player.getMidpoint(null));
    updateLight();
  }

  public override function destroy() {
    player.destroy();
    exit.destroy();
    lightBulbs.destroy();
    lightSprites.destroy();
    lightSprites.destroy();
    glassWalls.destroy();
    interactables.destroy();
    hud.destroy();
    mainCamera.destroy();
    hudCamera.destroy();
    tooltip.destroy();

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

  private function resetLightInDirection(l : Lightable) {
    l.resetLightInDirection();
  }

  private function markLightDirty(l : LightBulb) {
    l.markLightDirty();
  }

  private function updateGraphic(l : Lightable) {
    l.updateGraphic();
  }

  public function updateLight() : Void {
    exit.wasOpen = exit.isOpen;

    interactables.forEachOfType(Lightable, resetLightInDirection);

    lightSwitches.forEach(resetLightInDirection);

    glassWalls.forEach(resetLightInDirection);

    lightBulbs.forEach(markLightDirty);

    interactables.forEachOfType(Lightable, updateGraphic);

    lightSwitches.forEach(updateGraphic);

    glassWalls.forEach(updateGraphic);

    exit.isOpen = true;
    for(s in lightSwitches.members) {
      if(! s.isLit) {
        exit.isOpen = false;
        break;
      }
    }

    exit.updateGraphic();
  }

  private function playCollisionSound(a, b):Void{
    player.playCollisionSound();
  }

  override public function update():Void {
    var startTime = Timer.stamp();
    if(MENU_BUTTON()) {
      FlxG.switchState(new LevelSelectMenuState(levelPathIndex));
    } else if(won && (NEXT_LEVEL_BUTTON() || autoProgress) && levelPathIndex + 1 < PMain.levelPaths.length){
      BACKGROUND_THEME.resume();
      FlxG.switchState(new GameState(levelPathIndex + 1));
    } else if(RESET()) {
      resetState();
    } else if (UNDO() && !player.isDying) {
      undoAction();
    }

    super.update();

    //Only collide player with stuff she isn't holding a mirror
    if (player.elmHolding == null || (player.elmHolding != null && player.elmHolding.destTile == null)) {

      level.collideWithLevel(player, false, playCollisionSound);  // Collides player with walls

      if(! exit.isOpen) {
        FlxG.collide(player, exit, playCollisionSound);
      }

      FlxG.collide(player, lightBulbs, playCollisionSound);
      FlxG.collide(player, lightSwitches, playCollisionSound);
      FlxG.collide(player, glassWalls, playCollisionSound);

      //Collide player with light - don't kill player, just don't let them walk into it
      FlxG.collide(player, lightSprites, playCollisionSound);

      //Collide with mirrors - don't let player walk through mirrors
      FlxG.collide(player, interactables, playCollisionSound);
    } else {
      //Only collide player with the mirror they are holding
      FlxG.collide(player, player.elmHolding);
    }

    //Check for victory
    if(! exit.isOpen) {
      var allLit = true;
      var checkLit = function(l : LightSwitch) {
        allLit = allLit && l.isLit;
      }
      lightSwitches.forEach(checkLit);
      if(allLit ) {
        exit.set_isOpen(true);
      }
    } else {
      if(exit.containsBoundingBoxOf(player)) {
        win();
      }
    }

    //Check for finishing of animations
    hud.showDeadSprite = ! player.alive && !won;
    hud.showWinSprite = won && exit.animation.finished;
  }

  public function onAddObject(o : TiledObject, g : TiledObjectGroup) {
    switch (o.type.toLowerCase()) {
      case "player_start":
        var player = new Character(this, o);
        this.player = player;
        player.cameras = [FlxG.camera];
        player.glowSprite.cameras = [FlxG.camera];
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
        exit.immovable = true;
        this.exit = exit;

      case "glasswall":
        var wall = new GlassWall(this, o);
        wall.immovable = true;
        wall.cameras = [FlxG.camera];
        glassWalls.add(wall);

      case "tutorial images":
        var t = new TutorialImage(this, o);
        t.immovable = true;
        t.cameras = [FlxG.camera];
        add(t);

      default:
        trace("Got unknown object " + o.type.toLowerCase());
    }
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
      if(player.elmHolding != null) {
        player.elmHolding.holdingPlayer = null;
        player.grabbing = false;
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
    FlxG.switchState(new GameState(levelPathIndex, actionStack, levelStartTime));
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
          hud.showDeadSprite = false;
        }
      }
    }
  }

  public function killPlayer() {
    player.elmHolding = null;
    player.deathSound.play();
    player.animation.play(Character.DEATH_ANIMATION_KEY, false);
    actionStack.addDie();
  }

  public function win() {
    if(won) return;

    won = true;
    PMain.levelBeaten[levelPathIndex] = true;
    actionStack.addWin();
    BACKGROUND_THEME.pause();
    sndWin.onComplete = function() {
      BACKGROUND_THEME.resume();
      sndWinDone = true;
      Timer.delay(function(){autoProgress = true;}, 3000);
    }
    sndWin.play();
    player.kill();
    exit.playVictoryAnimation();
    var compTime = Timer.stamp() - levelStartTime;
    Logging.getSingleton().recordEvent(ActionStack.LOG_LEVEL_COMPLETION_TIME_ID, "" + compTime);
    Logging.getSingleton().recordEvent(ActionStack.LOG_ACTION_COUNT_ON_LEVEL_COMPLETE, "" + actionStack.getInteractedActionCount());
    Logging.getSingleton().recordLevelEnd();
  }

}

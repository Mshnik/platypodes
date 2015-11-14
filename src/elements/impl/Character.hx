package elements.impl;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;

/** Character is a MovingElement that represents the player in the game.
 * It has free movement, and moves using the arrow keys.
 * Characters are able to move and rotate mirrors.
 **/
class Character extends MovingElement {

  /** The Character's default move speed, when not interacting with anything */
  public static inline var MOVE_SPEED = 600;

  /** The Character's move speed when automatically moving towards center of tile */
  public static inline var AUTOMOVE_SPEED = 200;

  /** The distance the character moves per frame. This is the value when moving at velocity of 300
   * 60FPS, how the math works out */
  private static inline var MOVE_DIST_PER_FRAME = 3.2;

  /** True iff mouse movement should be allowed */
  private static inline var ALLOW_MOUSE_MOVEMENT = false;

  /** The clippng on the bounding box of the sprite, to make fitting though a one tile wide path easier */
  private static inline var BOUNDING_BOX_MARGIN_X = 30;
  private static inline var BOUNDING_BOX_MARGIN_TOP = 50;
  private static inline var BOUNDING_BOX_MARGIN_BOTTOM = 0;

/** Size of each character sprite, in px */
  @final private static var CHARACTER_SPRITE_SIZE = 128;

  /** Animated character sprite sheet location */
  private inline static var CHARACTER_SPRITE_SHEET = AssetPaths.playerSheet__png;

  /** Standard speed of animations for the Character class */
  public inline static var ANIMATION_SPEED = 10;

  /** The walking animation keys */
  public inline static var WALK_LEFT_RIGHT_ANIMATION_KEY = "Left-Right";
  public inline static var WALK_DOWN_ANIMATION_KEY = "Down";
  public inline static var WALK_UP_ANIMATION_KEY = "Up";

  /** The grab mirror animation keys */
  public inline static var GRAB_ANIMATION_PREFIX = "Grab";
  public inline static var GRAB_LEFT_RIGHT_ANIMATION_KEY = GRAB_ANIMATION_PREFIX + " Left-Right";
  public inline static var GRAB_DOWN_ANIMATION_KEY = GRAB_ANIMATION_PREFIX + " Down";
  public inline static var GRAB_UP_ANIMATION_KEY = GRAB_ANIMATION_PREFIX + " Up";

  /** The release mirror animation keys */
  public inline static var RELEASE_ANIMATION_PREFIX = "Release";
  public inline static var RELEASE_LEFT_RIGHT_ANIMATION_KEY = RELEASE_ANIMATION_PREFIX + " Left-Right";
  public inline static var RELEASE_DOWN_ANIMATION_KEY = RELEASE_ANIMATION_PREFIX + " Down";
  public inline static var RELEASE_UP_ANIMATION_KEY = RELEASE_ANIMATION_PREFIX + " Up";

  /** The push/pull mirror animation keys */
  /** Active when moving while holding a mirror */
  public inline static var PUSH_PULL_LEFT_RIGHT_ANIMATION_KEY = "Push-Pull Left-Right";
  public inline static var PUSH_PULL_DOWN_ANIMATION_KEY = "Push-Pull Down";
  public inline static var PUSH_PULL_UP_ANIMATION_KEY = "Push-Pull Up";

  /** The death animation key */
  public inline static var DEATH_ANIMATION_SPEED = 10;
  public inline static var DEATH_ANIMATION_KEY = "Die";

  /** True when the animation of going into or out of grab is playing */
  public var isChangingGrabStatus : Bool;

  /** True when the dying animation is playing */
  public var isDying(default, null) : Bool;

  /** Death sound */
  public var deathSound(default, null) : FlxSound;

  /** Collision sound */
  public var collisionSound(default, null) : FlxSound;

  /** The custom property on the Character object in Tiled maps that denotes the intial direction facing.
   * Valid values are 1 (Up), 3 (Right), 5 (Down), 7 (Left).
   **/
  @final private static var INITIAL_DIRECTION_FACING_PROPERTY = "direction_facing";

  /** The highlight for the tile the Character is occupying, in 0xAARRGGBB format */
  @final private static var HIGHLIGHT_COLOR = 0x00000000; //Change to a value to see square character occupies

  /** Return true iff the up key is pressed */
  public static var UP_PRESSED = function() : Bool { return FlxG.keys.pressed.UP; };

  /** Return true when the up key is pressed (once per press) */
  public static var UP_SINGLE = function() : Bool { return FlxG.keys.justPressed.UP; };

  /** Return true iff the down key is pressed */
  public static var DOWN_PRESSED = function() : Bool { return FlxG.keys.pressed.DOWN; };

  /** Return true when the up key is pressed (once per press) */
  public static var DOWN_SINGLE = function() : Bool { return FlxG.keys.justPressed.DOWN; };

  /** Return true iff the right key is pressed */
  public static var RIGHT_PRESSED = function() : Bool { return FlxG.keys.pressed.RIGHT; };

  /** Return true when the up key is pressed (once per press) */
  public static var RIGHT_SINGLE = function() : Bool { return FlxG.keys.justPressed.RIGHT; };

  /** Return true iff the left key is pressed */
  public static var LEFT_PRESSED = function() : Bool { return FlxG.keys.pressed.LEFT; };

  /** Return true when the up key is pressed (once per press) */
  public static var LEFT_SINGLE = function() : Bool { return FlxG.keys.justPressed.LEFT; };

  /** Return true iff the grab key is pressed */
  public static var GRAB = function() : Bool { return FlxG.keys.pressed.SPACE; };

  /** Return true when the rotate clockwise key is intially pressed */
  public var ROT_CLOCKWISE : Void -> Bool;

  /** Return true when the rotate counter clockwise key is intially pressed */
  public var ROT_C_CLOCKWISE : Void -> Bool;

  /** The mirror this character is currently holding, null if none */
  public var elmHolding(default, set) : InteractableElement;

  /** The old x value of the mirror this is holding before it started moving */
  private var elmHoldingOldX : Int;

  /** The old x value of the mirror this is holding before it started moving */
  private var elmHoldingOldY : Int;

  /** The list of move instructions to execute in the case of mouse movement */
  private var moveList : List<Direction>;

  private var moveSprites : Array<FlxSprite>;

  /** Constructs a TopBar character, belonging to the given state and represented by the given TiledObject */
  public function new(state : GameState, o : TiledObject) {
    super(state, o, false, MOVE_SPEED);

    setHighlightColor(HIGHLIGHT_COLOR);

    //Sprite loading and animating
    loadGraphic(CHARACTER_SPRITE_SHEET, true, CHARACTER_SPRITE_SIZE, CHARACTER_SPRITE_SIZE);
    setFacingFlip(FlxObject.RIGHT, false, false);
    setFacingFlip(FlxObject.LEFT, true, false);
    animation.add(WALK_DOWN_ANIMATION_KEY, [0,1,2,3], ANIMATION_SPEED, true);
    animation.add(WALK_UP_ANIMATION_KEY, [4,5,6,7], ANIMATION_SPEED, true);
    animation.add(WALK_LEFT_RIGHT_ANIMATION_KEY, [8,9,10,11], ANIMATION_SPEED, true);

    animation.add(GRAB_DOWN_ANIMATION_KEY, [16,17,18,19], ANIMATION_SPEED, false);
    animation.add(PUSH_PULL_DOWN_ANIMATION_KEY, [20,21,22,23], ANIMATION_SPEED, false);
    animation.add(RELEASE_DOWN_ANIMATION_KEY, [19,18,17,16], ANIMATION_SPEED, false);

    animation.add(GRAB_UP_ANIMATION_KEY, [24,25,26,27], ANIMATION_SPEED, false);
    animation.add(PUSH_PULL_UP_ANIMATION_KEY, [27, 28], ANIMATION_SPEED, false);
    animation.add(RELEASE_UP_ANIMATION_KEY, [27,26,25,24], ANIMATION_SPEED, false);

    animation.add(GRAB_LEFT_RIGHT_ANIMATION_KEY, [32,33,34,35], ANIMATION_SPEED, false);
    animation.add(PUSH_PULL_LEFT_RIGHT_ANIMATION_KEY, [35,36], ANIMATION_SPEED, false);
    animation.add(RELEASE_LEFT_RIGHT_ANIMATION_KEY, [35,34,33,32], ANIMATION_SPEED, false);

    animation.add(DEATH_ANIMATION_KEY, [40, 41, 42, 43, 44, 45, 46, 47, 48], DEATH_ANIMATION_SPEED, false);
    animation.callback = animationCallback;

    //Make bounding box slightly smaller than sprite for ease of movement
    this.offset.x += BOUNDING_BOX_MARGIN_X;
    this.offset.y += BOUNDING_BOX_MARGIN_TOP;
    this.width -= 2 * BOUNDING_BOX_MARGIN_X;
    this.height -= (BOUNDING_BOX_MARGIN_TOP + BOUNDING_BOX_MARGIN_BOTTOM);
    this.centerOrigin();

    this.x += BOUNDING_BOX_MARGIN_X;
    this.y += BOUNDING_BOX_MARGIN_TOP;

    var d = o.custom.get(INITIAL_DIRECTION_FACING_PROPERTY);
    if (d == null) {
      directionFacing = Direction.Left;
    } else {
      directionFacing = Direction.fromSimpleDirection(Std.parseInt(d));
    }

    ROT_CLOCKWISE = function() : Bool {
        if (!GRAB()) return false;
        return FlxG.keys.justPressed.A;
    }

    ROT_C_CLOCKWISE = function() : Bool {
      if (!GRAB()) return false;

      return FlxG.keys.justPressed.D;

    };

    isDying = false;
    collisionSound = FlxG.sound.load(AssetPaths.Collision8Bit__mp3, 0.5);
    deathSound = FlxG.sound.load(AssetPaths.crackle__mp3, 0.9);
    resetElmHoldingOldCoords();
  }

  public override function canMoveInDirection(d : Direction) : Bool {
    if (d.equals(Direction.None)) {
      return true;
    }

    var destRow = Std.int(getRow() + d.y);
    var destCol = Std.int(getCol() + d.x);
    var elm = state.getElementAt(destRow, destCol);

    return !state.level.hasWallAt(destCol, destRow) && (elm == null || Std.is(elm, Exit))
            && !state.isLit(destRow, destCol);
  }

  /** Return true iff this character can move in direction d,
   * given that it would be holding mirror m.
   * Should check that the tile this would move into is not a wall or another mirror,
   * and that it is free of light.
   **/
  public function canMoveInDirectionWithElement(d : Direction, e : InteractableElement) {
    var destRow = Std.int(getRow() + d.y);
    var destCol = Std.int(getCol() + d.x);
    var elm = state.getElementAt(destRow, destCol);

    return !state.level.hasWallAt(destCol, destRow) && (elm== null || elm == e || Std.is(elm, Exit))
            && (elm == e || !state.isLit(destRow, destCol));
  }

  /** Sets the elmHolding of this character to e. If this is used to release a element (by setting
   * equal to null), resets the movementspeed so this can move quickly again.
   **/
  public function set_elmHolding(e : InteractableElement) {
    if(! alive || isDying) return elmHolding = e;

    if (e == null) {
      isChangingGrabStatus = true;
      switch (this.directionFacing.simpleString) {
        //need release up sprites
        case "Up":
          animation.play(RELEASE_UP_ANIMATION_KEY);
        case "Down":
          animation.play(RELEASE_DOWN_ANIMATION_KEY);
        case "Left":
          animation.play(RELEASE_LEFT_RIGHT_ANIMATION_KEY);
        case "Right":
          animation.play(RELEASE_LEFT_RIGHT_ANIMATION_KEY);
        default:
      }
      elmHolding = e;
      return elmHolding;
    } else {
      isChangingGrabStatus = true;
      switch (this.directionFacing.simpleString) {
        //need grab up sprites
        case "Up":
          animation.play(GRAB_UP_ANIMATION_KEY);
        case "Down":
          animation.play(GRAB_DOWN_ANIMATION_KEY);
        case "Left":
          animation.play(GRAB_LEFT_RIGHT_ANIMATION_KEY);
        case "Right":
          animation.play(GRAB_LEFT_RIGHT_ANIMATION_KEY);
        default:
      }
      elmHolding = e;
      setElmHoldingOldCoords();
      return elmHolding;
    }
  }

  private function setElmHoldingOldCoords() {
    if(elmHoldingOldX == -1 && elmHoldingOldY == -1 ){
      elmHoldingOldX = elmHolding.getCol();
      elmHoldingOldY = elmHolding.getRow();
    }
  }

  private function resetElmHoldingOldCoords() {
    elmHoldingOldX = -1;
    elmHoldingOldY = -1;
  }

  /** Updates the character for this frame
    * - checks if facing a mirror (facing cardinal direction, tile this is facing towards contains a mirror).
    *     If so, check for rotate button pushses to rotate the mirror, or grab button to grab ahold of the mirror.
    * - If grab is released and the mirror this was moving is entirely within the tile, release the mirror
    * - If this is now holding a mirror, checks for direction pushes, and moves with the mirror
    *   Else, updates the move direction based on the current pressing of direction keys, and updated directionFacing.
    * - calls super.update() to move the character based on calculated move direction
    */
  override public function update() {
    if(!tileLocked) {
      if (directionFacing.isCardinal() && alive && ! isDying) {
        var elm = state.getElementAt(getRow() + Std.int(directionFacing.y), getCol() + Std.int(directionFacing.x));
        if (elm != null && Std.is(elm, AbsMirror)) {
          var mirror : AbsMirror = Std.instance(elm, AbsMirror);
          if(mirror.destTile == null && ROT_CLOCKWISE()) {
            state.actionStack.addRotate(mirror, true);
            mirror.rotateClockwise();
          }
          if(mirror.destTile == null && ROT_C_CLOCKWISE()) {
            state.actionStack.addRotate(mirror, false);
            mirror.rotateCounterClockwise();
          }
          if(GRAB() && elmHolding == null) {
            mirror.moveDirection = Direction.None;
            mirror.holdingPlayer = this;
          }
        }
      }

      if (isDying || ! alive) {
        moveDirection = Direction.None;
      } else if(elmHolding != null &&  (isDying || !GRAB() && elmHolding.destTile == null)) {
        elmHolding.holdingPlayer = null;
        moveSpeed = MOVE_SPEED;
        moveDirection = Direction.None;
        resetElmHoldingOldCoords();
      } else if (ALLOW_MOUSE_MOVEMENT && moveList != null) {
        tileLocked = true;
        moveDirection = moveList.pop();
        directionFacing = moveDirection;
      } else if(ALLOW_MOUSE_MOVEMENT && FlxG.mouse.justReleased) {
        moveDirection = Direction.None;
        tileLocked = false;
        var tileLoc = state.worldToTileCoordinates(new FlxPoint(FlxG.mouse.x, FlxG.mouse.y));
        var row = Std.int(tileLoc.y);
        var col = Std.int(tileLoc.x);
        setMoveTo(row, col);
      } else if (elmHolding == null) {
        moveDirection = Direction.None;
        moveSpeed = MOVE_SPEED;

        if(UP_PRESSED()) {
          moveDirection = moveDirection.addDirec(Direction.Up);
        }
        if(DOWN_PRESSED()) {
          moveDirection = moveDirection.addDirec(Direction.Down);
        }
        if(RIGHT_PRESSED()) {
          moveDirection = moveDirection.addDirec(Direction.Right);
        }
        if(LEFT_PRESSED()) {
          moveDirection = moveDirection.addDirec(Direction.Left);
        }

        if (!moveDirection.equals(Direction.None)) {
          directionFacing = moveDirection;
        }
      } else {
        if (GRAB() && elmHolding.destTile == null) {
          if (directionFacing.isHorizontal()) {
            if (LEFT_PRESSED()) {
              if(elmHolding.canMoveInDirection(Direction.Left)) {
                elmHolding.moveDirection = Direction.Left;
              } else {
                playCollisionSound();
              }
            } else if (RIGHT_PRESSED()) {
              if (elmHolding.canMoveInDirection(Direction.Right)) {
                elmHolding.moveDirection = Direction.Right;
              } else {
                playCollisionSound();
              }
            }
          } else if (directionFacing.isVertical()) {
            if (UP_PRESSED()) {
              if (elmHolding.canMoveInDirection(Direction.Up)) {
                elmHolding.moveDirection = Direction.Up;
              } else {
                playCollisionSound();
              }
            } else if (DOWN_PRESSED()) {
              if (elmHolding.canMoveInDirection(Direction.Down)) {
                elmHolding.moveDirection = Direction.Down;
              } else {
                playCollisionSound();
              }
            }
          }
          setElmHoldingOldCoords();
        }
        moveDirection = elmHolding.moveDirection;
        moveSpeed = elmHolding.moveSpeed;
      }
    }

    //If move direction is none, move towards center of tile
    if(elmHolding == null && !tileLocked && moveDirection.equals(Direction.None)) {
      var center = getCenter(false);
      var centerX = center.x;
      var centerY = center.y;
      var tileCenter = state.getRectangleFor(getRow(), getCol());
      var tileCenterX = tileCenter.x + tileCenter.width/2;
      var tileCenterY = tileCenter.y + tileCenter.height/2;

      center.put();
      tileCenter.put();

      var bestDist : Float = state.level.tileHeight * state.level.tileWidth; //Effectively maxval.

      for(d in Direction.VALS) {
        var newCenterX = centerX + MOVE_DIST_PER_FRAME * d.x;
        var newCenterY = centerY + MOVE_DIST_PER_FRAME * d.y;
        var newDist = Math.sqrt((tileCenterX - newCenterX) * (tileCenterX - newCenterX) + (tileCenterY - newCenterY) * (tileCenterY - newCenterY));
        if (newDist < bestDist) {
          moveDirection = d;
          bestDist = newDist;
        }
      }

      moveSpeed = AUTOMOVE_SPEED;
    }

    //Play the appropriate animation
    if(!isChangingGrabStatus && alive) {
      playMovementAnimation(directionFacing, elmHolding != null);
    }

    continueMoving = GRAB() && (UP_PRESSED() || DOWN_PRESSED() || LEFT_PRESSED() || RIGHT_PRESSED());

    super.update();
  }

  private function playMovementAnimation(d : Direction, holdingElm : Bool) {
    if (holdingElm) {
      switch (d.simpleString) {
        case "Up":
          animation.play(PUSH_PULL_UP_ANIMATION_KEY);
        case "Up_Right":
          animation.play(PUSH_PULL_UP_ANIMATION_KEY);
        case "Up_Left":
          animation.play(PUSH_PULL_UP_ANIMATION_KEY);
        case "Down":
          animation.play(PUSH_PULL_DOWN_ANIMATION_KEY);
        case "Down_Right":
          animation.play(PUSH_PULL_DOWN_ANIMATION_KEY);
        case "Down_Left":
          animation.play(PUSH_PULL_DOWN_ANIMATION_KEY);
        case "Left":
          animation.play(PUSH_PULL_LEFT_RIGHT_ANIMATION_KEY);
        case "Right":
          animation.play(PUSH_PULL_LEFT_RIGHT_ANIMATION_KEY);
      }
    } else {
      switch (d.simpleString) {
        case "Up":
          animation.play(WALK_UP_ANIMATION_KEY);
        case "Up_Right":
          animation.play(WALK_UP_ANIMATION_KEY);
        case "Up_Left":
          animation.play(WALK_UP_ANIMATION_KEY);
        case "Down":
          animation.play(WALK_DOWN_ANIMATION_KEY);
        case "Down_Right":
          animation.play(WALK_DOWN_ANIMATION_KEY);
        case "Down_Left":
          animation.play(WALK_DOWN_ANIMATION_KEY);
        case "Left":
          animation.play(WALK_LEFT_RIGHT_ANIMATION_KEY);
        case "Right":
          animation.play(WALK_LEFT_RIGHT_ANIMATION_KEY);
      }
    }
  }

  public override function destinationSet() {
    super.destinationSet();
  }

  public override function destinationReached() {
    super.destinationReached();
    moveDirection = Direction.None;
    tileLocked = false;
    if(moveList != null && moveList.isEmpty()) {
      moveList = null;
    }
  }

  public override function locationReached(oldRow : Int, oldCol : Int) {
    super.locationReached(oldRow, oldCol);
    if ((!tileLocked && elmHolding == null) || moveList != null) {
      state.actionStack.addMove(oldCol, oldRow);
    } else if(! tileLocked && elmHolding != null) {
      state.actionStack.addPushpull(oldCol, oldRow, elmHoldingOldX, elmHoldingOldY);
      resetElmHoldingOldCoords();
    }
  }

  public function setMoveTo(row : Int, col : Int) {
    if (!state.level.isWalkable(col, row) || !state.isSpaceWalkable(row, col) || (elmHolding != null)) {
      return;
    }

    var nodes:Array<Direction> = state.level.shortestPath(getRow(), getCol(), row, col);
    if(nodes == null || nodes.length == 0){
      return;
    } else {
      moveList = new List<Direction>();
      for(d in nodes) {
        moveList.add(d);
      }
      return;
    }
  }

  public function playCollisionSound() {
    collisionSound.play();
  }

  public override function revive() {
    super.revive();
    visible = true;
    isDying = false;
  }

  public override function kill() {
    super.kill();
    isDying = false;
    isChangingGrabStatus = false;
  }

  private function animationCallback(key : String, frameNumber : Int, frameIndex : Int) : Void {
    if(key == DEATH_ANIMATION_KEY) {
      isDying = true;
      if(frameNumber == 8) {
        kill();
      }
    }
    if(key.indexOf(GRAB_ANIMATION_PREFIX) != -1 && frameNumber == 3) {
      isChangingGrabStatus = false;
    }
    if(key.indexOf(RELEASE_ANIMATION_PREFIX) != -1 && frameNumber == 3) {
      isChangingGrabStatus = false;
    }
  }
}

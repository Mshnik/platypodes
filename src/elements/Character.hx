package elements;
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
  @final private static var MOVE_SPEED = 600;

  /** The clippng on the bounding box of the sprite, to make fitting though a one tile wide path easier */
  @final private static inline var BOUNDING_BOX_MARGIN_X = 30;
  @final private static inline var BOUNDING_BOX_MARGIN_Y = 5;

  /** Size of each character sprite, in px */
  @final private static var CHARACTER_SPRITE_SIZE = 128;

  /** Animated character sprite sheet location */
  private inline static var CHARACTER_SPRITE_SHEET = AssetPaths.playerSheet__png;

  /** Standard speed of animations for the Character class */
  public inline static var ANIMATION_SPEED = 15;

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
  @final private static var HIGHLIGHT_COLOR = 0x88FF00FF; //Change to a value to see square character occupies

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
  public var mirrorHolding(default, set) : Mirror;

  /** The old x value of the mirror this is holding before it started moving */
  private var mirrorHoldingOldX : Int;

  /** The old x value of the mirror this is holding before it started moving */
  private var mirrorHoldingOldY : Int;

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
    this.offset.y += BOUNDING_BOX_MARGIN_Y;
    this.x += BOUNDING_BOX_MARGIN_X;
    this.y += BOUNDING_BOX_MARGIN_Y;
    this.width -= 2 * BOUNDING_BOX_MARGIN_X;
    this.height -= 2 * BOUNDING_BOX_MARGIN_Y;

    var d = o.custom.get(INITIAL_DIRECTION_FACING_PROPERTY);
    if (d == null) {
      directionFacing = Direction.Left;
    } else {
      directionFacing = Direction.fromSimpleDirection(Std.parseInt(d));
    }

    ROT_CLOCKWISE = function() : Bool {
        if (!GRAB()) return false;

        if(directionFacing.equals(Direction.Left)) return DOWN_SINGLE();
        if(directionFacing.equals(Direction.Up)) return LEFT_SINGLE();
        if(directionFacing.equals(Direction.Right)) return UP_SINGLE();
        if(directionFacing.equals(Direction.Down)) return RIGHT_SINGLE();
        return false;
    }

    ROT_C_CLOCKWISE = function() : Bool {
      if (!GRAB()) return false;

      if(directionFacing.equals(Direction.Left)) return UP_SINGLE();
      if(directionFacing.equals(Direction.Up)) return RIGHT_SINGLE();
      if(directionFacing.equals(Direction.Right)) return DOWN_SINGLE();
      if(directionFacing.equals(Direction.Down)) return LEFT_SINGLE();
      return false;
    };

    isDying = false;
    collisionSound = FlxG.sound.load(AssetPaths.Collision8Bit__mp3);
    deathSound = FlxG.sound.load(AssetPaths.crackle__mp3);
    resetMirrorHoldingOldCoords();
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
  public function canMoveInDirectionWithMirror(d : Direction, m : Mirror) {
    var destRow = Std.int(getRow() + d.y);
    var destCol = Std.int(getCol() + d.x);
    var elm = state.getElementAt(destRow, destCol);

    return !state.level.hasWallAt(destCol, destRow) && (elm== null || elm == m || Std.is(elm, Exit))
            && !state.isLit(destRow, destCol);
  }

  /** Sets the mirrorHolding of this character to m. If this is used to release a mirror (by setting
   * equal to null), resets the movementspeed so this can move quickly again.
   **/
  public function set_mirrorHolding(m : Mirror) {
    if(! alive || isDying) return mirrorHolding = m;

    if (m == null) {
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
      mirrorHolding = m;
      return mirrorHolding;
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
      mirrorHolding = m;
      setMirrorHoldingOldChords();
      return mirrorHolding;
    }
  }

  private function setMirrorHoldingOldChords() {
    if(mirrorHoldingOldX == -1 && mirrorHoldingOldY == -1 ){
      mirrorHoldingOldX = mirrorHolding.getCol();
      mirrorHoldingOldY = mirrorHolding.getRow();
    }
  }

  private function resetMirrorHoldingOldCoords() {
    mirrorHoldingOldX = -1;
    mirrorHoldingOldY = -1;
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
        if (elm != null && Std.is(elm, Mirror)) {
          var mirror : Mirror = Std.instance(elm, Mirror);
          if(mirror.destTile == null && ROT_CLOCKWISE()) {
            state.actionStack.addRotate(mirror, true);
            mirror.rotateClockwise();
          }
          if(mirror.destTile == null && ROT_C_CLOCKWISE()) {
            state.actionStack.addRotate(mirror, false);
            mirror.rotateCounterClockwise();
          }
          if(GRAB() && mirrorHolding == null) {
            mirror.moveDirection = Direction.None;
            mirror.holdingPlayer = this;
          }
        }
      }

      if (isDying || ! alive) {
        moveDirection = Direction.None;
      } else if(mirrorHolding != null &&  (isDying || !GRAB() && mirrorHolding.destTile == null)) {
        mirrorHolding.holdingPlayer = null;
        moveSpeed = MOVE_SPEED;
        moveDirection = Direction.None;
        resetMirrorHoldingOldCoords();
      } else if (mirrorHolding == null) {
        moveDirection = Direction.None;

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
        if (GRAB() && mirrorHolding.destTile == null) {
          if (directionFacing.isHorizontal()) {
            if (LEFT_PRESSED()) {
              if(mirrorHolding.canMoveInDirection(Direction.Left)) {
                mirrorHolding.moveDirection = Direction.Left;
              } else {
                playCollisionSound();
              }
            } else if (RIGHT_PRESSED()) {
              if (mirrorHolding.canMoveInDirection(Direction.Right)) {
                mirrorHolding.moveDirection = Direction.Right;
              } else {
                playCollisionSound();
              }
            }
          } else if (directionFacing.isVertical()) {
            if (UP_PRESSED()) {
              if (mirrorHolding.canMoveInDirection(Direction.Up)) {
                mirrorHolding.moveDirection = Direction.Up;
              } else {
                playCollisionSound();
              }
            } else if (DOWN_PRESSED()) {
              if (mirrorHolding.canMoveInDirection(Direction.Down)) {
                mirrorHolding.moveDirection = Direction.Down;
              } else {
                playCollisionSound();
              }
            }
          }
          setMirrorHoldingOldChords();
        }
        moveDirection = mirrorHolding.moveDirection;
        moveSpeed = mirrorHolding.moveSpeed;
      }
    }

    //Play the appropriate animation
    if(!isChangingGrabStatus && alive) {
      if (mirrorHolding != null) {
        switch (directionFacing.simpleString) {
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
        switch (directionFacing.simpleString) {
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
    super.update();
  }

  public override function destinationSet() {
    super.destinationSet();
  }

  public override function destinationReached() {
    super.destinationReached();
    tileLocked = false;
  }

  public override function locationReached(oldRow : Int, oldCol : Int) {
    super.locationReached(oldRow, oldCol);
    if (!tileLocked && mirrorHolding == null) {
      state.actionStack.addMove(oldCol, oldRow);
    } else if(! tileLocked && mirrorHolding != null) {
      state.actionStack.addPushpull(oldCol, oldRow, mirrorHoldingOldX, mirrorHoldingOldY);
      resetMirrorHoldingOldCoords();
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

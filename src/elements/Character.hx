package elements;
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
  @final private static var BOUNDING_BOX_MARGIN = 5;

  /** Size of each character sprite, in px */
  @final private static var CHARACTER_SPRITE_SIZE = 128;

  /** Animated character sprite sheet location */
  @final private static var CHARACTER_SPRITE_SHEET = AssetPaths.player_sheet__png;

  /** The walking left or right animation key */
  public inline static var WALK_LEFT_RIGHT_KEY = "Left-Right";

  /** The walking down animation key */
  public inline static var WALK_DOWN_KEY = "Down";

  /** The death animation key */
  public inline static var DEATH_ANIMATION_KEY = "Die";

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
  public var mirrorHolding(default, set) : Mirror;

  /** Constructs a new character, belonging to the given state and represented by the given TiledObject */
  public function new(state : GameState, o : TiledObject) {
    super(state, o, false, MOVE_SPEED);

    setHighlightColor(HIGHLIGHT_COLOR);

    //Sprite loading and animating
    loadGraphic(CHARACTER_SPRITE_SHEET, true, CHARACTER_SPRITE_SIZE, CHARACTER_SPRITE_SIZE);
    setFacingFlip(FlxObject.RIGHT, false, false);
    setFacingFlip(FlxObject.LEFT, true, false);
    animation.add(WALK_LEFT_RIGHT_KEY, [8,9,10,11], 20, false);
    animation.add(WALK_DOWN_KEY, [0,1,2,3], 20, false);

    var arr : Array<Int> = Main.rangeToArray(32, 40);
    arr.push(4);
    animation.add(DEATH_ANIMATION_KEY, arr, 15, false);

    //Make bounding box slightly smaller than sprite for ease of movement
    this.offset.x += BOUNDING_BOX_MARGIN;
    this.offset.y += BOUNDING_BOX_MARGIN;
    this.width -= 2 * BOUNDING_BOX_MARGIN;
    this.height -= 2 * BOUNDING_BOX_MARGIN;

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
    if (m == null) {
      moveSpeed = MOVE_SPEED;
    }
    return mirrorHolding = m;
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

    if (directionFacing.isCardinal()) {
      var elm = state.getElementAt(getRow() + Std.int(directionFacing.y), getCol() + Std.int(directionFacing.x));
      if (elm != null && Std.is(elm, Mirror)) {
        var mirror : Mirror = Std.instance(elm, Mirror);
        if(ROT_CLOCKWISE()) {
          mirror.rotateClockwise();
        }
        if(ROT_C_CLOCKWISE()) {
          mirror.rotateCounterClockwise();
        }
        if(GRAB() && mirrorHolding == null) {
          mirror.moveDirection = Direction.None;
          mirror.holdingPlayer = this;
        }
      }
    }

    if(!GRAB() && mirrorHolding != null && mirrorHolding.destTile == null) {
      mirrorHolding.holdingPlayer = null;
    }

    if (mirrorHolding == null) {
      moveDirection = Direction.None;

      if(UP_PRESSED()) {
        moveDirection = moveDirection.addDirec(Direction.Up);
      }
      if(DOWN_PRESSED()) {
        moveDirection = moveDirection.addDirec(Direction.Down);
        animation.play(WALK_DOWN_KEY);
      }
      if(RIGHT_PRESSED()) {
        moveDirection = moveDirection.addDirec(Direction.Right);
        animation.play(WALK_LEFT_RIGHT_KEY);
      }
      if(LEFT_PRESSED()) {
        moveDirection = moveDirection.addDirec(Direction.Left);
        animation.play(WALK_LEFT_RIGHT_KEY);
      }

      if (!moveDirection.equals(Direction.None)) {
        directionFacing = moveDirection;
      }
    } else {
      if (GRAB() && mirrorHolding.destTile == null) {
        if (directionFacing.isHorizontal()) {
          if (LEFT_PRESSED() && mirrorHolding.canMoveInDirection(Direction.Left)) {
            mirrorHolding.moveDirection = Direction.Left;
          } else if (RIGHT_PRESSED() && mirrorHolding.canMoveInDirection(Direction.Right)) {
            mirrorHolding.moveDirection = Direction.Right;
          }
        } else if (directionFacing.isVertical()) {
          if (UP_PRESSED() && mirrorHolding.canMoveInDirection(Direction.Up)) {
            mirrorHolding.moveDirection = Direction.Up;
          } else if (DOWN_PRESSED() && mirrorHolding.canMoveInDirection(Direction.Down)) {
            mirrorHolding.moveDirection = Direction.Down;
          }
        }
      }
      moveDirection = mirrorHolding.moveDirection;
      moveSpeed = mirrorHolding.moveSpeed;
    }

    super.update();
  }
}

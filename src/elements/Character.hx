package elements;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;

/** Character is a MovingElement that represents the player in the game.
 * It has free movement, and moves using the arrow keys.
 **/
class Character extends MovingElement {

  /** The Character's default move speed, when not interacting with anything */
  @final private static var MOVE_SPEED = 300;

  /** The default sprite for the character. This will change to a set once direction facing sprites are added */
  @final private static var DEFAULT_SPRITE = AssetPaths.vampire__png;

  /** The clippng on the bounding box of the sprite, to make fitting though a one tile wide path easier */
  @final private static var BOUNDING_BOX_MARGIN = 5;

  /** The custom property on the Character object in Tiled maps that denotes the intial direction facing */
  @final private static var INITIAL_DIRECTION_FACING_PROPERTY = "direction_facing";

  /** The highlight for the tile the Character is occupying, in 0xAARRGGBB format */
  @final private static var HIGHLIGHT_COLOR = 0x00000000; //Change to a value to see square character occupies

  /** Return true iff the up key is pressed */
  public static var UP = function() : Bool { return FlxG.keys.pressed.UP; };

  /** Return true iff the down key is pressed */
  public static var DOWN = function() : Bool { return FlxG.keys.pressed.DOWN; };

  /** Return true iff the right key is pressed */
  public static var RIGHT = function() : Bool { return FlxG.keys.pressed.RIGHT; };

  /** Return true iff the left key is pressed */
  public static var LEFT = function() : Bool { return FlxG.keys.pressed.LEFT; };

  /** Return true iff the grab key is pressed */
  public static var GRAB = function() : Bool { return FlxG.keys.pressed.S; };

  /** Return true when the rotate clockwise key is intially pressed */
  public static var ROT_CLOCKWISE = function() : Bool { return FlxG.keys.justPressed.D; };

  /** Return true when the rotate counter clockwise key is intially pressed */
  public static var ROT_C_CLOCKWISE = function() : Bool { return FlxG.keys.justPressed.A; };

  /** The mirror this character is currently holding, null if none */
  public var mirrorHolding(default, set) : Mirror;

  /** Constructs a new character, belonging to the given state and represented by the given TiledObject */
  public function new(state : GameState, o : TiledObject) {
    super(state, o, false, MOVE_SPEED, DEFAULT_SPRITE);

    setHighlightColor(HIGHLIGHT_COLOR);

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

  public function set_mirrorHolding(m : Mirror) {
    if (m == null) {
      moveSpeed = MOVE_SPEED;
    }
    return mirrorHolding = m;
  }

  /** Updates the character
    * - updates the move direction based on the current pressing of direction keys.
    * - calls super.update() to move the character based on this move direction.
    */
  override public function update() {

    if (directionFacing.isCardinal()) {
      var elm = state.getElementAt(getRow() + Std.int(directionFacing.y), getCol() + Std.int(directionFacing.x));
      if (elm != null && Std.is(elm, Mirror)) {
        var mirror : Mirror = Std.instance(elm, Mirror);
        if(ROT_CLOCKWISE()) {
          mirror.rotateClockwise();
          state.updateLight();
        }
        if(ROT_C_CLOCKWISE()) {
          mirror.rotateCounterClockwise();
          state.updateLight();
        }
        if(GRAB() && mirrorHolding == null) {
          mirror.moveDirection = Direction.None;
          mirror.holdingPlayer = this;
        }
      }
    }

    if(!GRAB() && mirrorHolding != null && mirrorHolding.isEntirelyWithinTile() && isEntirelyWithinTile()) {
      mirrorHolding.holdingPlayer = null;
    }

    if (mirrorHolding == null) {
      moveDirection = Direction.None;

      if(UP()) {
        moveDirection = moveDirection.addDirec(Direction.Up);
      }
      if(DOWN()) {
        moveDirection = moveDirection.addDirec(Direction.Down);
      }
      if(RIGHT()) {
        moveDirection = moveDirection.addDirec(Direction.Right);
      }
      if(LEFT()) {
        moveDirection = moveDirection.addDirec(Direction.Left);
      }

      if (!moveDirection.equals(Direction.None)) {
        directionFacing = moveDirection;
      }
    } else {
      if (GRAB()) {
        if (directionFacing.isHorizontal()) {
          if (LEFT() && mirrorHolding.canMoveInDirection(Direction.Left)) {
            mirrorHolding.moveDirection = Direction.Left;
          } else if (RIGHT() && mirrorHolding.canMoveInDirection(Direction.Right)) {
            mirrorHolding.moveDirection = Direction.Right;
          }
        } else if (directionFacing.isVertical()) {
          if (UP() && mirrorHolding.canMoveInDirection(Direction.Up)) {
            mirrorHolding.moveDirection = Direction.Up;
          } else if (DOWN() && mirrorHolding.canMoveInDirection(Direction.Down)) {
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

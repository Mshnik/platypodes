package elements;
import flixel.addons.editors.tiled.TiledObject;

/** A mirror is a moveable element that reflects light.
 * It is tile locked, thus movement occurs in increments of tiles.
 * Each mirror has a reflective surface on either one or both of its sides, that
 * reflects light in 90 degree angles.
 **/
class Mirror extends MovingElement implements Lightable{

  /** The property in Tiled that denotes how many sides a mirror has. Valid values are 1 and 2 */
  private static inline var SIDES_PROPERTY_KEY = "sides";

  /** The sprite for an unlit one sided mirror */
  private static inline var UNLIT_SPRITE_ONE_SIDED = AssetPaths.light_sheet_0_2__png;

  /** The sprite for a lit one sided mirror */
  private static inline var LIT_SPRITE_ONE_SIDED = AssetPaths.light_sheet_1_2__png;

  /** The sprite for an unlit two sided mirror */
  private static inline var UNLIT_SPRITE_TWO_SIDED = ""; //TODO
  /** A two sided mirror is a subclass with obsoleted fields.*/

  /** The speed mirrors move with when being pushed or pulled by a character */
  public inline static var MOVE_SPEED = 400;

  /** The number of sides this mirror has that reflect light. Must be 1 or 2 */
  @final public var sides : Int;

  /** The character that is currently holding this mirror. Null if none */
  public var holdingPlayer(default, set) : Character;

  /** True iff this is currently reflecting light (on either of its sides), false otherwise */
  public var isLit(default,set):Bool;

  /** Constructs a new mirror belonging to the given game state and representing the given TiledObject */
  public function new(state : GameState, o : TiledObject) {
    super(state, o, true, MOVE_SPEED, setSidesAndGetInitialSprite(o));

    //Read the flipX and flipY fields to determine intial direction facing
    if (flipX && flipY) {
      directionFacing = Direction.Down_Left;
    } else if (flipX && ! flipY) {
      directionFacing = Direction.Up_Left;
    } else if (! flipX && flipY) {
      directionFacing = Direction.Down_Right;
    } else {
      directionFacing = Direction.Up_Right;
    }
  }

  /** Return the sprite that represents this mirror intitially. Used in construction */
  private function setSidesAndGetInitialSprite(o : TiledObject) : Dynamic {
    sides = Std.parseInt(o.custom.get(SIDES_PROPERTY_KEY));
    switch sides {
      case 1: return UNLIT_SPRITE_ONE_SIDED;
      case 2: return UNLIT_SPRITE_TWO_SIDED;
      default: throw "Illegal values of sides " + sides;
    }
  }

  /** Sets the value of isLit. Updates the sprite to reflect the new lit status */
  public function set_isLit(lit : Bool) : Bool {
    if(sides == 1) {
      if(lit) {
        loadGraphic(LIT_SPRITE_ONE_SIDED, false, Std.int(width), Std.int(height));
      } else {
        loadGraphic(UNLIT_SPRITE_ONE_SIDED, false, Std.int(width), Std.int(height));
      }
    } else {
      //TODO
    }

    return this.isLit = lit;
  }

  /** Return true iff this mirror can move in direction D.
   *    - If null or none, return true, as this mirror can stay where it is now
   *    - if non cardinal (diagonal), return false. Can only move in cardinal directions
   *    - if the destination has a hole or wall, return false.
   *    - Otherwise, determine what element is at the destination. If empty, return true,
   *        if character, check if the player is also moving, otherwise return false.
   **/
  public override function canMoveInDirection(d : Direction) {
    if (d == null || d.equals(Direction.None)){
      return true;
    }
    if (! d.isCardinal()) {
      return false;
    }

    var destRow = Std.int(getRow() + d.y);
    var destCol = Std.int(getCol() + d.x);
    if(state.level.hasHoleAt(destCol, destRow) || state.level.hasWallAt(destCol, destRow)){
      return false;
    }

    var elm = state.getElementAt(destRow, destCol);
    if (elm == null) {
      return true;
    } else if (Std.is(elm, Character)) {
      var player : Character = Std.instance(elm, Character);
      return player.canMoveInDirectionWithMirror(d, this);
    } else {
      return false;
    }
  }

  /** Called when the update() function of MovingElement sets the destination of this to move to
   * If this is being held by a Character, set the velocity of that player to match this.
   **/
  public override function destinationSet() {
    super.destinationSet();
    if(holdingPlayer != null) {
      holdingPlayer.velocity.x = velocity.x;
      holdingPlayer.velocity.y = velocity.y;
    }
  }

  /** Called when the update() function of MovingElement notices that this has reached its destination. */
  public override function destinationReached() {
    super.destinationReached();
    state.updateLight();
  }

  /** Rotate this mirror once clockwise, and update the directionFacing */
	public function rotateClockwise() {
		if (directionFacing.equals(Direction.Up_Left)) {
			directionFacing = Direction.Up_Right;
			flipX = ! flipX;
		} else if (directionFacing.equals(Direction.Up_Right)) {
			directionFacing = Direction.Down_Right;
			flipY = ! flipY;
		} else if (directionFacing.equals(Direction.Down_Right)) {
			directionFacing = Direction.Down_Left;
			flipX = ! flipX;
		} else if (directionFacing.equals(Direction.Down_Left)) {
			directionFacing = Direction.Up_Left;
			flipY = ! flipY;
		}
    state.updateLight();
  }

  /** Rotate this mirror once counter clockwise, and update the directionFacing */
  public function rotateCounterClockwise() {
		if (directionFacing.equals(Direction.Up_Right)) {
			directionFacing = Direction.Up_Left;
			flipX = ! flipX;
		} else if (directionFacing.equals(Direction.Down_Right)) {
			directionFacing = Direction.Up_Right;
			flipY = ! flipY;
		} else if (directionFacing.equals(Direction.Down_Left)) {
			directionFacing = Direction.Down_Right;
			flipX = ! flipX;
		} else if (directionFacing.equals(Direction.Up_Left)) {
			directionFacing = Direction.Down_Left;
			flipY = ! flipY;
		}
    state.updateLight();
  }

  /** Sets the holding player to the given character.
   * Updates the Character's mirrorHolding field to this,
   * and if the new character is null, updates the old character's mirrorHolding field to null.
   **/
  public function set_holdingPlayer(p : Character) {
    if(holdingPlayer != null) {
      holdingPlayer.mirrorHolding = null;
    }
    if(p != null) {
      p.mirrorHolding = this;
    }
    return holdingPlayer = p;
  }

  override public function update() {
		super.update();
  }
}

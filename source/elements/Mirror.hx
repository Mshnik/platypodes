package elements;
import flixel.addons.editors.tiled.TiledObject;
class Mirror extends Element {

  private static inline var SIDES_PROPERTY_KEY = "sides";
  private static inline var DEFAULT_SPRITE_ONE_SIDED = AssetPaths.mirror_1__png;
  private static inline var DEFAULT_SPRITE_TWO_SIDED = ""; //TODO

  @final public var sides : Int;  //1 or 2 sides
  private var directionFacing : Direction; //The direction this element is facing.
  private var holdingCharacter : Character; //The character holding this mirror, if any
  private var parallelDirection : Direction; //All movement must be parallel to this direction
                                             //This prevents strafing with a mirror

  public function new(state : GameState, x : Int, y : Int, o : TiledObject) {
    super(state, x, y, o, true, 0, setSidesAndGetInitialSprite(o));

    if (flipX && flipY) {
	    directionFacing = Direction.Down_Right;
    } else if (flipX && ! flipY) {
	    directionFacing = Direction.Up_Right;
    } else if (! flipX && flipY) {
	    directionFacing = Direction.Down_Left;
    } else {
	    directionFacing = Direction.Up_Left;
    }
  }

  private function setSidesAndGetInitialSprite(o : TiledObject) : Dynamic {
    sides = Std.parseInt(o.custom.get(SIDES_PROPERTY_KEY));
    switch sides {
      case 1: return DEFAULT_SPRITE_ONE_SIDED;
      case 2: return DEFAULT_SPRITE_TWO_SIDED;
      default: throw "Illegal values of sides " + sides;
    }
  }

	public override function getDirectionFacing() {
		return directionFacing;
	}

  public function setHoldingCharacter(holdingCharacter : Character, direction : Direction, vel : Float = 0) {
    this.holdingCharacter = holdingCharacter;
    this.parallelDirection = direction;
    this.moveVelocity = vel;
  }

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
	}

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
  }
  
  override public function update() {
    if (holdingCharacter != null) {
      var proj = holdingCharacter.getMoveDirection().projectToNormalized(parallelDirection);
      setMoveDirection(Direction.getDirectionOf(proj));
    }

    var oldRow = getRow();
    var oldCol = getCol();

		super.update();

    if(oldRow != getRow() || oldCol != getCol()) {
      state.updateLight();
    }
  }
}

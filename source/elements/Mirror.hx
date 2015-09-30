package elements;
import flixel.addons.editors.tiled.TiledObject;
class Mirror extends Element {

  private static inline var DEFAULT_SPRITE = AssetPaths.mirror_img__png;
  private var directionFacing : Direction; //The direction this element is facing.
  private var holdingCharacter : Character; //The character holding this mirror, if any
  private var parallelDirection : Direction; //All movement must be parallel to this direction
                                             //This prevents strafing with a mirror

  public function new(level : TiledLevel, x : Int, y : Int, o : TiledObject) {
    super(level, x, y, o, true, 0, DEFAULT_SPRITE);

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

		super.update();
  }
}

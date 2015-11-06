package elements;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledObject;
import flixel.system.FlxSound;
@abstract class AbsMirror extends InteractableElement implements Lightable {

  /** The property in Tiled that denotes how many sides a mirror has. Valid values are 1 and 2 */
  private static inline var SIDES_PROPERTY_KEY = "sides";

  /** The number of sides this mirror has that reflect light. Must be 1 or 2 */
  @final public var sides(default, null) : Int;

  public var isLit(default, null) : Bool;

  /** The direction is is receiving light from */
  public var lightInDirection(default, null) : Array<Direction>;

  /** Constructs a TopBar mirror belonging to the given game state and representing the given TiledObject */
  private function new(state : GameState, o : TiledObject, unlitSprite : Dynamic) {
    super(state, o, true, unlitSprite);

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

    sides = Std.parseInt(o.custom.get(SIDES_PROPERTY_KEY));
    if(sides != 1 && sides != 2 && PMain.DEBUG_MODE) throw "Illegal values of sides " + sides;
    resetLightInDirection();
    isLit = false;
  }

  public function isLightingTo(directionOut : Direction) : Bool {
    if(! isLit) {
      return false;
    }
    for(d in lightInDirection) {
      if(d.equals(directionOut)){
        return false;
      }
    }
    for(d in lightInDirection) {
      for(d2 in getReflection(d)) {
        if(directionOut.equals(d)) {
          return true;
        }
      }
    }
    return false;
  }

  public function resetLightInDirection() {
    lightInDirection = [];
  }

  /** Set to Direction.None or null to turn off light.
   * Should be overridden in subclasses to add graphic switch behavior
   **/
  public function addLightInDirection(d : Direction) {
    if(d == null || d == Direction.None) {
      return;
    }
    lightInDirection.push(d);
  }

  public function getReflection(directionIn : Direction) : Array<Direction> {
    throw "NOT IMPLEMENTED - MUST BE OVERRIDDEN";
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
    moveSound.play();
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
    moveSound.play();
    state.updateLight();
  }
}

package elements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledObject;
import flixel.system.FlxSound;
@abstract class AbsMirror extends InteractableElement implements Lightable {

  /** The property in Tiled that denotes how many sides a mirror has. Valid values are 1 and 2 */
  private static inline var SIDES_PROPERTY_KEY = "sides";

  /** The speed mirrors move with when being pushed or pulled by a character */
  public inline static var MOVE_SPEED = 400;

  /** The sound played when a mirror is pushed/pulled/rotated */
  public var moveSound(default, null) : FlxSound;

  /** The number of sides this mirror has that reflect light. Must be 1 or 2 */
  @final public var sides(default, null) : Int;

  /** The character that is currently holding this mirror. Null if none */
  public var holdingPlayer(default, set) : Character;

  /** The direction is is receiving light from */
  public var lightInDirection : Direction;

  /** Constructs a TopBar mirror belonging to the given game state and representing the given TiledObject */
  private function new(state : GameState, o : TiledObject, unlitSprite : FlxSprite) {
    super(state, o, true, MOVE_SPEED, unlitSprite);

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
    moveSound = FlxG.sound.load(AssetPaths.Scrape__wav, 0.75);
  }

  public function isLightingTo(directionOut : Direction) : Bool {
    for(d in getReflection(lightInDirection)) {
      if(directionOut.equals(d)) {
        return true;
      }
    }
    return false;
  }

  public function getReflection(directionIn : Direction) : Array<Direction> {
    throw "NOT IMPLEMENTED - MUST BE OVERRIDDEN";
  }

  /** Sets the move direction of this mirror, and deletes light sprites that occur after this chain */
  public override function set_moveDirection(d : Direction) {
    return super.set_moveDirection(d);
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
    moveSound.play();
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

  /** Sets the holding player to the given character.
   * Updates the Character's mirrorHolding field to this,
   * and if the TopBar character is null, updates the old character's mirrorHolding field to null.
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
    if (holdingPlayer != null) {
      continueMoving = holdingPlayer.canMoveInDirectionWithMirror(moveDirection, this) &&
      holdingPlayer.continueMoving;
    }
    super.update();
  }
}

package elements;

/** A InteractableElement element is an element that the player can push/pull/rotate */
import flixel.FlxG;
import flixel.addons.editors.tiled.TiledObject;
import flixel.system.FlxSound;
import elements.impl.Character;
@abstract class InteractableElement extends MovingElement {

  /** The sound played when a interactableElement is pushed/pulled/rotated */
  public var moveSound(default, null):FlxSound;

  /** The character that is currently holding this mirror. Null if none */
  public var holdingPlayer(default, set):Character;

  /** The speed mirrors move with when being pushed or pulled by a character */
  public inline static var MOVE_SPEED = 150;

  /** Sets the move direction of this mirror, and deletes light sprites that occur after this chain */
  public override function set_moveDirection(d:Direction) {
    return super.set_moveDirection(d);
  }

  private function new(state : GameState, tileObject : TiledObject, tileLocked : Bool = true, ?img : Dynamic) {
    super(state, tileObject, tileLocked, MOVE_SPEED, img);

    moveSound = FlxG.sound.load(AssetPaths.Scrape__wav, 0.75);
  }

  /** Return true iff this mirror can move in direction D.
   *    - If null or none, return true, as this mirror can stay where it is now
   *    - if non cardinal (diagonal), return false. Can only move in cardinal directions
   *    - if the destination has a hole or wall, return false.
   *    - Otherwise, determine what element is at the destination. If empty, return true,
   *        if character, check if the player is also moving, otherwise return false.
   **/
  public override function canMoveInDirection(d:Direction) {
    if (d == null || d.equals(Direction.None)) {
      return true;
    }
    if (!d.isCardinal()) {
      return false;
    }

    var destRow = Std.int(getRow() + d.y);
    var destCol = Std.int(getCol() + d.x);
    if (state.level.hasHoleAt(destCol, destRow) || state.level.hasWallAt(destCol, destRow)) {
      return false;
    }

    var elm = state.getElementAt(destRow, destCol);
    if (elm == null) {
      return true;
    } else if (Std.is(elm, Character)) {
      var player:Character = Std.instance(elm, Character);
      return player.canMoveInDirectionWithElement(d, this);
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
    if (holdingPlayer != null) {
      holdingPlayer.velocity.x = velocity.x;
      holdingPlayer.velocity.y = velocity.y;
    }
  }

  /** Sets the holding player to the given character.
   * Updates the Character's mirrorHolding field to this,
   * and if the TopBar character is null, updates the old character's mirrorHolding field to null.
   **/
  public function set_holdingPlayer(p : Character) {
    if(holdingPlayer != null) {
      holdingPlayer.elmHolding = null;
    }
    if(p != null) {
      p.elmHolding = this;
    }
    return holdingPlayer = p;
  }

  override public function update() {
    if (holdingPlayer != null) {
      continueMoving = holdingPlayer.canMoveInDirectionWithElement(moveDirection, this) &&
      holdingPlayer.continueMoving;
    }
    super.update();
  }

}

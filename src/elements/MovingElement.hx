package elements;

import flixel.util.FlxRect;
import flixel.addons.editors.tiled.TiledObject;
@abstract class MovingElement extends Element {

  /** Determines the type of movement that this MovingElement performs
   * If tileLocked == false, this has free movement. Tile is still updated when this moves
   * from tile to tile, but no checks are performed on movement, and collisions are used to
   * enforce movement constraints
   *
   * If tileLocked == true, this has tile locked movement. This can only move in increments
   * of a tile, and can only move in a direction if the tile it would occupy by moving
   * in that direction is legal. Collisions are basically unused (for the purposes of
   * movement of this object. It may still collide with other free-moving objects).
   **/
  public var tileLocked(default, null) : Bool;

  /**
   * If tileLocked, this is the tile this is currently traveling to.
   * If this isn't traveling, or isn't tileLocked, this is null.
   **/
  public var destTile(default, null) : FlxRect;

  /** Velocity this moves with when moving */
  public var moveSpeed(default, set) : Int;

  /** The direction this element is currently moving (Direction.None if none) */
  public var moveDirection(default, set) : Direction;

  /** The direction this character is facing. May not necessarily be equal to moveDireciton */
  public var directionFacing(default, set) : Direction;

  /** The row this MovingElement was on, before calling super.update() to move */
  private var oldRow : Int;

  /** The row this MovingElement was on, before calling super.update() to move */
  private var oldCol : Int;

  /** Construct a new moving element
   * state - the GameState this element belongs to
   * tileObject - the TiledObject that represents this Element in the level file.
   *              the Element's initial x and y coordinates, along with the graphical
   *              rotation and flipping are read from this object.
   * tileLocked - true if this object moves in increments of tiles, false for free movement.
   *              default (if unprovided) is true.
   * moveSpeed - the speed this moves with when it moves. Can be changed later. Can't be negative. Default 0
   * img - the image to display for this element. If more complex than a simple image, don't supply here;
   *  change the graph content after calling this constructor.
   */
  public function new(state : GameState, tileObject : TiledObject, tileLocked : Bool = true,
                      moveSpeed : Int = 0, ?img : Dynamic) {
    super(state, tileObject, img);

    this.tileLocked = tileLocked;
    destTile = null;
    this.moveSpeed = moveSpeed;
    this.moveDirection = Direction.None;

    oldRow = getRow();
    oldCol = getCol();
  }

  /** Sets the movement speed of this element. If negative, throws an exception */
  public function set_moveSpeed(speed : Int) {
    if (speed < 0) {
      throw "Can't set speed to negative number";
    }
    return moveSpeed = speed;
  }

  /** Sets the movement direction of this element. If direction is null, sets to Direction.NONE. */
  public function set_moveDirection(direction : Direction) {
    if(direction == null) {
      moveDirection = Direction.None;
    } else {
      moveDirection = direction;
    }
    return moveDirection;
  }

  /** Sets the facing direction of this element. If direction is null, sets to Direction.None */
  public function set_directionFacing(direction : Direction) {
    if(direction == null) {
      directionFacing = Direction.None;
    } else {
      directionFacing = direction;
    }
    facing = directionFacing.simpleDirec;
    return directionFacing;
  }

  /** Returns true iff this can move in Direction direction. Only used in tileLocked movingElements.
   * Default implementation throws an exception, as it is not implemented.
   * Called before movement starts.
   * Should always return true for Direction.None
   **/
  public function canMoveInDirection(direction : Direction) : Bool {
    throw "canMove should be overridden in subclass";
  }

  /** Called when the destination of a tileLocked movingElement is set.
   * Overriding functions should call super first, in case something is put here.
   **/
  public function destinationSet() {}

  /** Called when the destination of a tileLocked movingElement is reached.
   * Overriding functions should call super first, in case something is put here.
   **/
  public function destinationReached() {}

  /** Called when a new location is reached. Overriding functions should call
   * super first, in case something is put here
   **/
  public function locationReached(oldRow : Int, oldCol : Int){}

  /** Updates this element:
   * Check for location move. If moved, call locationReached, update oldRow and oldCol
   * If TileLocked:
   *    - Checks if destination is reached. If so, stop moving and call destinationReached.
   *    - Otherwise, check if destination is null (unset) and we want to move toward it.
   *       If so, start moving toward it and call destinationSet().
   * Else (not TileLocked):
   *    - Set velocity based off of moveDirection.
   *
   *- calls super.update().
   **/
  public override function update() {
    if (oldRow != getRow() || oldCol != getCol()) {
      locationReached(oldRow, oldCol);
      oldRow = getRow();
      oldCol = getCol();
    }

    if (tileLocked) {
      //Check if destination is reached
      var boundingBox = getBoundingBox(false);
      if(destTile != null && Element.rectContainsRect(destTile, boundingBox)) {
        velocity.x = 0;
        velocity.y = 0;
        moveDirection = Direction.None;
        destinationReached();
        destTile = null;
      }
      //Check if destination is unset and we have a non-None direction to move
      else if (destTile == null && !moveDirection.equals(Direction.None)) {
        velocity.x = moveSpeed * moveDirection.x;
        velocity.y = moveSpeed * moveDirection.y;
        destTile = state.getRectangleFor(getRow() + Std.int(moveDirection.y),
                                         getCol() + Std.int(moveDirection.x), true);
        destinationSet();
      }
      boundingBox.put();
    } else {
      velocity.x = moveSpeed * moveDirection.x;
      velocity.y = moveSpeed * moveDirection.y;
    }

    super.update();
  }
}

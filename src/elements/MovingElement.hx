package elements;

import flixel.addons.editors.tiled.TiledObject;
@abstract class MovingElement extends Element {

  //Buffer to prevent movables to moving to edge of board
  //Value is in pixels
  @final private static var MOVE_EDGE_MARGIN = 5;
  @final private static var DEST_UNSET = -1;

  @final public var tileLocked : Bool; //True if this element only moves in increments of tile, false for freemove

  private var destX : Int; //The x point (pixel) this is traveling to
  private var destY : Int; //The y point (pixel) this is traveling to

  public var moveSpeed(default, set) : Int; //Velocity this moves with when moving
  private var moveDirection(default, set) : Direction; //The direction this element is currently moving (None if none).
  private var directionFacing : Direction; //The direction this character is facing.

  public function new(state : GameState, tileObject : TiledObject, tileLocked : Bool = true,
                      moveSpeed : Int = 0, ?img : Dynamic) {
    super(state, tileObject, img);

    this.tileLocked = tileLocked;
    destX = DEST_UNSET;
    destY = DEST_UNSET;
    this.moveSpeed = moveSpeed;
    this.moveDirection = Direction.None;
  }

  /**
   * Sets the movement speed of this element.
   **/
  public inline function set_moveSpeed(speed : Int) {
    if (speed < 0) {
      throw "Can't set speed to negative number";
    }
    return moveSpeed = speed;
  }

  /** Sets the movement direction of this element. If direction is null, sets to Direction.NONE.
    */
  public inline function set_moveDirection(direction : Direction) {
    if(direction == null) {
      moveDirection = Direction.None;
    } else {
      moveDirection = direction;
    }
    return moveDirection;
  }

  /** Return the direction this element is facing. Override in subclasses
   * if this can rotate
   **/
  public function getDirectionFacing() : Direction {
    return Direction.None;
  }

 /**
  * Should be overridden in tileLocked classes. Checks whether a tile movement
  * in the given direction is valid from the current location.
  * Called before movement starts.
  * Should always return true for Direction.None
  *
  **/
  public function canMoveInDirection(direction : Direction) : Bool {
    throw "canMove should be overridden in subclass";
  }

  public override function update() {
    if (tileLocked) {
      //Check if destination is reached
      if(x == destX && y == destY) {
        moveDirection = Direction.None;
        destX = DEST_UNSET;
        destY = DEST_UNSET;
      } else if (destX == DEST_UNSET && destY == DEST_UNSET && ! moveDirection.equals(Direction.None)) {
        velocity.x = moveSpeed * moveDirection.x;
        velocity.y = moveSpeed * moveDirection.y;
        var destTile = state.getRectangleFor(getRow() + Std.int(moveDirection.y),
                                             getCol() + Std.int(moveDirection.x));
        destX = Std.int(destTile.x + destTile.width/2);
        destY = Std.int(destTile.y + destTile.height/2);
        destTile.put();
      }
    } else {
      velocity.x = moveSpeed * moveDirection.x;
      velocity.y = moveSpeed * moveDirection.y;

      if (x <= MOVE_EDGE_MARGIN && velocity.x < 0 ||
          x + width >= state.level.fullWidth - MOVE_EDGE_MARGIN && velocity.x > 0) {
        velocity.x = 0;
      }
      if (y <= MOVE_EDGE_MARGIN && velocity.y < 0 ||
          y + height >= state.level.fullHeight - MOVE_EDGE_MARGIN && velocity.y > 0) {
        velocity.y = 0;
      }
    }

    super.update();
  }
}

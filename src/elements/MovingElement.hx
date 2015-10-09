package elements;

import flixel.addons.editors.tiled.TiledObject;
@abstract class MovingElement extends Element {

  //Buffer to prevent movables to moving to edge of board
  //Value is in pixels
  @final private static var MOVE_EDGE_MARGIN = 5;

  @final public var tileLocked : Bool; //True if this element only moves in increments of tile, false for freemove
  public var moveSpeed(default, set) : Int; //Velocity this moves with when moving
  private var moveDirection(default, set) : Direction; //The direction this element is currently moving (None if none).
  private var directionFacing : Direction; //The direction this character is facing.

  public function new(state : GameState, tileObject : TiledObject, tileLocked : Bool = true,
                      moveSpeed : Int = 0, ?img : Dynamic) {
    super(state, tileObject, img);

    this.tileLocked = tileLocked;
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

  public override function update() {
    if (tileLocked) {

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

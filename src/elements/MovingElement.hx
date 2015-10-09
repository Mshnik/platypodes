package elements;

import flixel.addons.editors.tiled.TiledObject;
class MovingElement extends Element {

  private var tileLocked : Bool; //True if this element only moves in increments of tile, false for freemove
  private var moveVelocity:Float; //The velocity with which the element moves
  private var moveDirection : Direction; //The direction this element is currently moving (None if none).
  private var directionFacing : Direction; //The direction this character is facing.

  public function new(state : GameState, x : Int, y : Int, tileObject : TiledObject, ?img:Dynamic) {

  }
}

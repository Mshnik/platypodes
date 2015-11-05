package elements.impl;
import flixel.addons.editors.tiled.TiledObject;

class Barrel extends InteractableElement implements Lightable {
  private static inline var SPRITE="";//TODO

  public var isLit(default, null) : Bool;

  public var lightInDirection(default, null) : Direction;

  public function new(state:GameState,o:TiledObject){
    super(state,o,true,SPRITE);
  }

  /** Returns true iff this is giving out light from the given side */
  public function isLightingTo(directionOut : Direction) : Bool {
    return false;
  }

  /** Returns the directions light should be outputted if this is hit with light from the given direction */
  public function getReflection(directionIn : Direction) : Array<Direction> {
    return [];
  }
}

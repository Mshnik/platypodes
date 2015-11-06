package elements.impl;
import flixel.addons.editors.tiled.TiledObject;

class Barrel extends InteractableElement implements Lightable {
  private static inline var SPRITE="";//TODO

  public var isLit(default, null) : Bool;

  public var lightInDirection(default, null) : Array<Direction>;

  public function new(state:GameState,o:TiledObject){
    super(state,o,true,SPRITE);
    isLit = false;
    resetLightInDirection();
  }

  /** Returns true iff this is giving out light from the given side */
  public function isLightingTo(directionOut : Direction) : Bool {
    return false;
  }

  /** Returns the directions light should be outputted if this is hit with light from the given direction */
  public function getReflection(directionIn : Direction) : Array<Direction> {
    return [];
  }

  public function resetLightInDirection() {
    lightInDirection = [];
  }

  /** Set to Direction.None or null to turn off light */
  public function addLightInDirection(d : Direction) {
    if(d == null || d == Direction.None) {
      return;
    }
    lightInDirection.push(d);
  }

}

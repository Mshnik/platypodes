package elements;

/** Represents an element that is lightable - can be illuminated.
 *
 **/
interface Lightable {

  /** The variable that denotes lighting status. Get access must be public, but set can or can not be */
  public var isLit(default, null) : Bool;

  /** The direction this is lit from. Set whenever lighting is recalculated */
  public var lightInDirection(default, default) : Direction;

  /** Returns true iff this is giving out light from the given side */
  public function isLightingTo(directionOut : Direction) : Bool;

  /** Returns the directions light should be outputted if this is hit with light from the given direction */
  public function getReflection(directionIn : Direction) : Array<Direction>;

}

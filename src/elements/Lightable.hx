package elements;

/** Represents an element that is lightable - can be illuminated.
 *
 **/
interface Lightable {

  /** The variable that denotes lighting status. Get access must be public, but set can or can not be */
  public var isLit(default, null) : Bool;

}

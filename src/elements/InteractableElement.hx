package elements;

/** A InteractableElement element is an element that the player can push/pull/rotate */
@abstract class InteractableElement extends MovingElement {

  /** The character that is currently holding this InteractableElement. Null if none */
  public var holdingPlayer : Character;

}

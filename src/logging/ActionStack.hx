package logging;


import logging.ActionElement;
import elements.Element;
import elements.Direction;
import elements.Character;
class ActionStack {

  public var character : Character;
  private var elms : List<ActionElement>;

  public function new(c : Character) {
    this.character = c;
    elms = new List<ActionElement>();
  }

  private function add(a : ActionElement) {
    elms.push(a);
    trace(a);
    Logging.getSingleton().recordEvent(a.serialize(), "");
  }

  public function logStack() {
    Logging.getSingleton().recordEvent(Std.int(Math.pow(2, 32) - 1), elms.toString());
  }

  public function getHead() : ActionElement {
    return resolve(elms.iterator());
  }

  private function resolve(iter : Iterator<ActionElement>) : ActionElement {
    var e : ActionElement = iter.next();
    if (e.id == ActionElement.UNDO) {
      return resolve(iter).getOpposite();
    } else {
      return e;
    }
  }

  public function addUndo() {
    add(ActionElement.undo(character.getCol(), character.getRow(), character.directionFacing));
  }

  public function addReset() {
    add(ActionElement.reset(character.getCol(), character.getRow(), character.directionFacing));
  }

  public function addMove(oldX : Int, oldY : Int) {
    var moveDirection = Direction.getDirection(character.getCol() - oldX, character.getRow() - oldY);
    add(ActionElement.move(oldX, oldY, character.directionFacing, moveDirection));
  }

  public function addPushpull(oldX : Int, oldY : Int, elmOldX : Int, elmOldY : Int) {
    var moveDirection = Direction.getDirection(character.getCol() - oldX, character.getRow() - oldY);
    add(ActionElement.pushpull(oldX, oldY, character.directionFacing,
                               elmOldX, elmOldY, moveDirection));
  }

  public function addRotate(e : Element, rotateClockwise : Bool) {
    add(ActionElement.rotate(character.getCol(), character.getRow(), character.directionFacing,
                             e.getCol(), e.getRow(), rotateClockwise));
  }

  public function addDie() {
    add(ActionElement.die(character.getCol(), character.getRow(), character.directionFacing));
  }

  public function addWin() {
    add(ActionElement.win(character.getCol(), character.getRow(), character.directionFacing));
  }

}

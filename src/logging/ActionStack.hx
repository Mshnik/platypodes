package logging;


import elements.impl.Character;
import logging.ActionElement;
import elements.Element;
import elements.Direction;
class ActionStack {

  public var character : Character;
  private var elms : List<ActionElement>;

  public static inline var SINGLE_ACTION_LOGGING_ID = 4;
  public static inline var LOG_STACK_ACTION_ID = 5;
  public static inline var LOG_LEVEL_COMPLETION_TIME_ID = 6;
  public static inline var LOG_ACTION_COUNT_ON_LEVEL_COMPLETE = 7;

  public function new(c : Character) {
    this.character = c;
    elms = new List<ActionElement>();
  }

  public function add(a : ActionElement) {
    elms.push(a);
    trace(a.loggingString());
    Logging.getSingleton().recordEvent(SINGLE_ACTION_LOGGING_ID, a.loggingString());
  }

  public function logStack() {
    //Do nothing - wasn't useful
  }

  public function getFirst() : ActionElement {
    if (elms.isEmpty()) return null;
    else return elms.first();
  }

  public function getFirstUndoable() : ActionElement {
    return resolveFirstUndoable(elms.iterator(), 0);
  }

  public function getInteractedActionCount() {
    var c = 0;
    var i = elms.iterator();
    while(i.hasNext()) {
      var a : ActionElement = i.next();
      if(a.id == ActionElement.ROTATE || a.id == ActionElement.PUSHPULL) {
        c = c+1;
      }
    }
    return c;
  }

  private function resolveFirstUndoable(iter : Iterator<ActionElement>, undoCount : Int) : ActionElement {
    if(! iter.hasNext()) {
      return null;
    }
    var e : ActionElement = iter.next();
    if(e.id == ActionElement.RESET) {
      return null;
    } else if (e.id == ActionElement.UNDO) {
      return resolveFirstUndoable(iter, undoCount + 1);
    } else if (e.id == ActionElement.DIE){
      return resolveFirstUndoable(iter, undoCount);
    } else if (undoCount > 0){
      return resolveFirstUndoable(iter, undoCount - 1);
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

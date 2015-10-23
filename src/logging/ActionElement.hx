package logging;


import flixel.util.FlxStringUtil;
import elements.Direction;
class ActionElement {

  private static inline var MOVE = 1;
  private static inline var PUSHPULL = 2;
  private static inline var ROTATE = 3;

  private static inline var POS_SIZE : Int = 5;
  private static inline var ID_SIZE : Int = 2;
  private static inline var DIREC_SIZE : Int = 4;
  private static inline var ROTATE_SIZE : Int = 1;

  private static var START_X_MASK : Int;
  private static var START_Y_MASK : Int;
  private static var ID_MASK : Int;
  private static var DIRECT_FACING_MASK : Int;
  private static var ELM_X_MASK : Int;
  private static var ELM_Y_MASK : Int;
  private static var MOVE_DIREC_MASK : Int;
  private static var ROTATE_MASK : Int;

  private static var START_X_SHIFT : Int;
  private static var START_Y_SHIFT : Int;
  private static var ID_SHIFT : Int;
  private static var DIREC_FACING_SHIFT : Int;
  private static var ELM_X_SHIFT : Int;
  private static var ELM_Y_SHIFT : Int;
  private static var MOVE_DIREC_SHIFT : Int;
  private static var ROTATE_SHIFT : Int;

  static function __init__() {
    //Do left aligned fields
    var bits = 0;

    ROTATE_SHIFT = bits;
    bits += ROTATE_SIZE;
    ROTATE_MASK = bitMaskOfSize(ROTATE_SIZE, 0) << ROTATE_SHIFT;

    MOVE_DIREC_SHIFT = bits;
    bits += DIREC_SIZE;
    MOVE_DIREC_MASK = bitMaskOfSize(DIREC_SIZE, 0) << MOVE_DIREC_SHIFT;

    ELM_Y_SHIFT = bits;
    bits += POS_SIZE;
    ELM_Y_MASK = bitMaskOfSize(POS_SIZE, 0) << ELM_Y_SHIFT;

    ELM_X_SHIFT = bits;
    bits += POS_SIZE;
    ELM_X_MASK = bitMaskOfSize(POS_SIZE, 0) << ELM_X_SHIFT;

    DIREC_FACING_SHIFT = bits;
    bits += DIREC_SIZE;
    DIRECT_FACING_MASK = bitMaskOfSize(DIREC_SIZE, 0) << DIREC_FACING_SHIFT;

    START_Y_SHIFT = bits;
    bits += POS_SIZE;
    START_Y_MASK = bitMaskOfSize(POS_SIZE, 0) << START_Y_SHIFT;

    START_X_SHIFT = bits;
    bits += POS_SIZE;
    START_X_MASK = bitMaskOfSize(POS_SIZE, 0) << START_X_SHIFT;

    ID_SHIFT = bits;
    bits += ID_SIZE;
    ID_MASK = bitMaskOfSize(ID_SIZE, 0) << ID_SHIFT;

    trace(toBinString(ROTATE_MASK));
    trace(toBinString(MOVE_DIREC_MASK));
    trace(toBinString(ELM_Y_MASK));
    trace(toBinString(ELM_X_MASK));
    trace(toBinString(DIRECT_FACING_MASK));
    trace(toBinString(START_Y_MASK));
    trace(toBinString(START_X_MASK));
    trace(toBinString(ID_MASK));

    if(bits > 32) {
      throw "Too many bits used " + bits;
    }
  }


  private static function bitMaskOfSize(s : Int, acc : Int) {
    if(s == 0) return acc;
    return bitMaskOfSize(s-1, (acc << 1) + 1);
  }



//Used in all ActionElements - what square the character was standing on when this action started
  //Must be in range 0-31
  public var startX(default, null) : Int;
  public var startY(default, null) : Int;

  public var id(default, null) : Int;

  //Used in MOVE and PUSHPULL
  //What direction the character moved - gives the destination square as well
  public var moveDirection(default, null) : Direction;

  //Used in PUSHPULL and ROTATE
  //The x location of the element when the action occurred
  public var elmX(default, null) : Int;
  //The y location of the element when the action occurred
  public var elmY(default, null) : Int;
  //The direction the player was facing when the action occurred
  public var directionFacing(default, null) : Direction;

  //Used in ROTATE
  //1 if the rotation was clockwise, 0 otherwise
  public var rotateClockwise(default, null) : Bool;


  private function new(id : Int, startX : Int, startY : Int, directionFacing : Direction,
                       elmX : Int, elmY : Int, moveDirection : Direction, rotateClockwise : Bool) {
    if (id != MOVE && id != PUSHPULL && id != ROTATE) {
      throw "Illegal id " + id;
    }
    if (startX < 0 || startX > 31 || startY < 0 || startY > 31) {
      throw "Start x or y out of bounds " + startX + ", " + startY;
    }
    if (elmX < 0 || elmX > 31 || elmY < 0 || elmY > 31) {
      throw "Elm x or y out of bounds " + elmX + ", " + elmY;
    }
    this.id = id;
    this.startX = startX;
    this.startY = startY;
    this.directionFacing = directionFacing;
    this.elmX = elmX;
    this.elmY = elmY;
    this.moveDirection = moveDirection;
    this.rotateClockwise = rotateClockwise;
  }

  public static function move(startX : Int, startY : Int, directionFacing : Direction, moveDirection : Direction) : ActionElement {
    return new ActionElement(MOVE, startX, startY, directionFacing, 0, 0, moveDirection, false);
  }

  public static function pushpull(startX : Int, startY : Int, directionFacing : Direction,
                                  elmX : Int, elmY : Int, moveDirection : Direction) : ActionElement {
    return new ActionElement(PUSHPULL, startX, startY, directionFacing, elmX, elmY, moveDirection, false);
  }

  public static function rotate(startX : Int, startY : Int, directionFacing : Direction,
                                elmX : Int, elmY : Int, rotateClockwise : Bool) : ActionElement {
    return new ActionElement(ROTATE, startX, startY, directionFacing, elmX, elmY, Direction.None, rotateClockwise);
  }

  public static function deserialize(ser : Int) : ActionElement {
    return new ActionElement((ser & ID_MASK) >>> ID_SHIFT,
                              (ser & START_X_MASK) >>> START_X_SHIFT,
                              (ser & START_Y_MASK) >>> START_Y_SHIFT,
                              direcFrom3Bit((ser & DIRECT_FACING_MASK) >>> DIREC_FACING_SHIFT),
                              (ser & ELM_X_MASK) >>> ELM_X_SHIFT,
                              (ser & ELM_Y_MASK) >>> ELM_Y_SHIFT,
                              direcFrom3Bit((ser & MOVE_DIREC_MASK) >>> MOVE_DIREC_SHIFT),
                              (ser & ROTATE_MASK) >>> ROTATE_SHIFT == 1
                             );
  }

 /** Serializes this ActionElement to an int. */
  public function serialize() : Int {
    trace("Serializing" + (startY << START_Y_SHIFT));
    return (id << ID_SHIFT) +
           (startX << START_X_SHIFT) +
           (startY << START_Y_SHIFT) +
           (direcTo3Bit(directionFacing) << DIREC_FACING_SHIFT) +
           (elmX << ELM_X_SHIFT) +
           (elmY << ELM_Y_SHIFT) +
           (direcTo3Bit(moveDirection) << MOVE_DIREC_SHIFT) +
           ((rotateClockwise ? 1 : 0) << ROTATE_SHIFT);
  }

  /** Translates a direction to a 3 bit number (0-8) */
  private static function direcTo3Bit(d : Direction) : Int {
    if(d == null) {
      return 0;
    }
    switch d.simpleDirec {
      case Direction.NONE_VAL: return 0;
      case Direction.UP_VAL: return 1;
      case Direction.UP_RIGHT_VAL: return 2;
      case Direction.RIGHT_VAL: return 3;
      case Direction.DOWN_RIGHT_VAL: return 4;
      case Direction.DOWN_VAL: return 5;
      case Direction.DOWN_LEFT_VAL: return 6;
      case Direction.LEFT_VAL: return 7;
      case Direction.UP_LEFT_VAL: return 8;
      default: throw "Illegal direction constructed " + d;
      }
    }

  /** Translates into direction from a 3 bit number (0-8) */
  private static function direcFrom3Bit(i : Int) : Direction {
    switch i{
      case 0: return Direction.None;
      case 1: return Direction.Up;
      case 2: return Direction.Up_Right;
      case 3: return Direction.Right;
      case 4: return Direction.Down_Right;
      case 5: return Direction.Down;
      case 6: return Direction.Down_Left;
      case 7: return Direction.Left;
      case 8: return Direction.Up_Left;
      default: throw "Can't get direction for simpleVal " + Std.string(i);
    }
  }

  public function toString() : String {
    var t = "__INVALID__";
    if (id==MOVE) {
      t = "Move";
    } else if(id == PUSHPULL) {
      t = "Push/Pull";
    } else if (id == ROTATE) {
      t = "Rotate";
    }

    return  FlxStringUtil.getDebugString([
      LabelValuePair.weak("type", t),
      LabelValuePair.weak("startX", startX),
      LabelValuePair.weak("startY", startY),
      LabelValuePair.weak("directionFacing", directionFacing.simpleString),
      LabelValuePair.weak("elmX", elmX),
      LabelValuePair.weak("elmY", elmY),
      LabelValuePair.weak("moveDirection", moveDirection.simpleString),
      LabelValuePair.weak("rotateDirection", rotateClockwise ? "Clockwise" : "Counter-clockwise")]);
  }

  private static function toBinString(numb : Int) : String{
    if (numb == 0) {
      return "00000000000000000000000000000000";
    }

    var s = "";
    while (numb > 0) {
      s = (numb % 2) + s;
      numb = Std.int(numb/2);
    }

    while(s.length < 32) {
      s = "0" + s;
    }

    return s;
  }
}

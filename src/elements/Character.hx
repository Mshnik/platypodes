package elements;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;
class Character extends MovingElement {

  @final private static var MOVE_SPEED = 300;
  @final private static var MOVE_WHILE_GRABBING_SPEED = 200;
  @final private static var DEFAULT_SPRITE = AssetPaths.vampire__png;
  @final private static var BOUNDING_BOX_MARGIN = 4;

  public static var UP = function() : Bool { return FlxG.keys.pressed.UP; };
  public static var DOWN = function() : Bool { return FlxG.keys.pressed.DOWN; };
  public static var RIGHT = function() : Bool { return FlxG.keys.pressed.RIGHT; };
  public static var LEFT = function() : Bool { return FlxG.keys.pressed.LEFT; };

  public static var GRAB = function() : Bool { return FlxG.keys.pressed.X; };
  public static var ROT_CLOCKWISE = function() : Bool { return FlxG.keys.justPressed.C; };
  public static var ROT_C_CLOCKWISE = function() : Bool { return FlxG.keys.justPressed.Z; };

  private var grabbedMirror:Mirror;
  private var tileOffset : Direction;
  private var xOffset : Float; //equal to player.x - mirror.x
  private var yOffset : Float; //equal to player.y - mirror.y;

/** Constructs a new character, with the given level, and initial row and col */
  public function new(state : GameState, o : TiledObject) {
    super(state, o, false, MOVE_SPEED, DEFAULT_SPRITE);

    //Make bounding box slightly smaller than sprite for ease of movement
    this.offset.x += BOUNDING_BOX_MARGIN;
    this.offset.y += BOUNDING_BOX_MARGIN;
    this.width -= 2 * BOUNDING_BOX_MARGIN;
    this.height -= 2 * BOUNDING_BOX_MARGIN;
  }

  public override function getDirectionFacing() {
    return directionFacing;
  }

  public function isHoldingMirror() : Bool {
    return grabbedMirror != null;
  }

  public function grabMirror(mirror : Mirror) {
    try{
      tileOffset = Direction.getDirection(mirror.getCol() - getCol(), mirror.getRow() - getRow());
    } catch(msg : String) {
      return;
    }
    if( ! tileOffset.isCardinal()) {
      return;
    }
    grabbedMirror = mirror;
    moveSpeed = MOVE_WHILE_GRABBING_SPEED;
    grabbedMirror.setHoldingCharacter(this, tileOffset, MOVE_WHILE_GRABBING_SPEED);
    xOffset = mirror.x - x;
    yOffset = mirror.y - y;
  }

  public function letGoOfMirror() {
    grabbedMirror.setHoldingCharacter(null, Direction.None);
    grabbedMirror = null;
    moveSpeed = MOVE_SPEED;
  }

  /** Updates the character
    * - updates the move direction based on the current pressing of direction keys.
    * - calls super.update() to move the character based on this move direction.
    */
  override public function update() {

    directionFacing = Direction.None;

    if(UP()) {
      directionFacing = directionFacing.addDirec(Direction.Up);
    }
    if(DOWN()) {
      directionFacing = directionFacing.addDirec(Direction.Down);
    }
    if(RIGHT()) {
      directionFacing = directionFacing.addDirec(Direction.Right);
    }
    if(LEFT()) {
      directionFacing = directionFacing.addDirec(Direction.Left);
    }

    moveDirection = directionFacing;

    if(grabbedMirror != null) {
      var dRow = Math.abs(grabbedMirror.getRow() - getRow());
      var dCol = Math.abs(grabbedMirror.getCol() - getCol());

      if(!GRAB() || dRow > Math.abs(tileOffset.y) * 2 || dCol > Math.abs(tileOffset.x) * 2) {
        letGoOfMirror();
      }
    }
    super.update();
  }
}

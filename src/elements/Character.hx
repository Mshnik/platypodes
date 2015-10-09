package elements;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;
class Character extends MovingElement {

  @final private static var MOVE_SPEED = 300;
  @final private static var MOVE_WHILE_GRABBING_SPEED = 200;
  @final private static var DEFAULT_SPRITE = AssetPaths.vampire__png;
  @final private static var BOUNDING_BOX_MARGIN = 5;

  public static var UP = function() : Bool { return FlxG.keys.pressed.UP; };
  public static var DOWN = function() : Bool { return FlxG.keys.pressed.DOWN; };
  public static var RIGHT = function() : Bool { return FlxG.keys.pressed.RIGHT; };
  public static var LEFT = function() : Bool { return FlxG.keys.pressed.LEFT; };

  public static var PUSH = function() : Bool { return FlxG.keys.justPressed.W; };
  public static var PULL = function() : Bool { return FlxG.keys.justPressed.S; };
  public static var ROT_CLOCKWISE = function() : Bool { return FlxG.keys.justPressed.A; };
  public static var ROT_C_CLOCKWISE = function() : Bool { return FlxG.keys.justPressed.D; };

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

  public override function canMoveInDirection(d : Direction) {
    var destRow = Std.int(getRow() + d.y);
    var destCol = Std.int(getCol() + d.x);

    return !state.level.hasWallAt(destCol, destRow) && state.getElementAt(destRow, destCol) == null;
  }

  public function canMoveInDirectionWithMirror(d : Direction, m : Mirror) {
    var destRow = Std.int(getRow() + d.y);
    var destCol = Std.int(getCol() + d.x);
    var elm = state.getElementAt(destRow, destCol);

    return !state.level.hasWallAt(destCol, destRow) && (elm== null || elm == m);
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

    super.update();
  }
}

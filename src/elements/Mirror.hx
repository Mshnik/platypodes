package elements;
import flixel.addons.editors.tiled.TiledObject;
class Mirror extends MovingElement {

  private static inline var SIDES_PROPERTY_KEY = "sides";
  private static inline var UNLIT_SPRITE_ONE_SIDED = AssetPaths.mirror_1__png;
  private static inline var LIT_SPRITE_ONE_SIDED = AssetPaths.mirror_1_light__png;
  private static inline var UNLIT_SPRITE_TWO_SIDED = ""; //TODO
  private static inline var LIT_SPRITE_TWO_SIDED = ""; //TODO

  @final private static var MOVE_SPEED = 200;
  @final public var sides : Int;  //1 or 2 sides

  public var holdingPlayer(default, set) : Character;


  public var isLit(default,set):Bool;

  public function new(state : GameState, o : TiledObject) {
    super(state, o, true, MOVE_SPEED, setSidesAndGetInitialSprite(o));

    if (flipX && flipY) {
	    directionFacing = Direction.Down_Right;
    } else if (flipX && ! flipY) {
	    directionFacing = Direction.Up_Right;
    } else if (! flipX && flipY) {
	    directionFacing = Direction.Down_Left;
    } else {
	    directionFacing = Direction.Up_Left;
    }
  }

  private function setSidesAndGetInitialSprite(o : TiledObject) : Dynamic {
    sides = Std.parseInt(o.custom.get(SIDES_PROPERTY_KEY));
    switch sides {
      case 1: return UNLIT_SPRITE_ONE_SIDED;
      case 2: return UNLIT_SPRITE_TWO_SIDED;
      default: throw "Illegal values of sides " + sides;
    }
  }

  public function set_isLit(lit : Bool) : Bool {
    if(sides == 1) {
      if(lit) {
        loadGraphic(LIT_SPRITE_ONE_SIDED, false, Std.int(width), Std.int(height));
      } else {
        loadGraphic(UNLIT_SPRITE_ONE_SIDED, false, Std.int(width), Std.int(height));
      }
    } else {
      //TODO
    }

    return this.isLit = lit;
  }

  public override function canMoveInDirection(d : Direction) {
    if (d == null || d.equals(Direction.None)){
      return true;
    }
    if (! d.isCardinal()) {
      return false;
    }

    var destRow = Std.int(getRow() + d.y);
    var destCol = Std.int(getCol() + d.x);
    if(state.level.hasHoleAt(destCol, destRow) || state.level.hasWallAt(destCol, destRow)){
      return false;
    }

    var elm = state.getElementAt(destRow, destCol);
    if (elm == null) {
      return true;
    } else if (Std.is(elm, Character)) {
      var player : Character = Std.instance(elm, Character);
      return player.canMoveInDirectionWithMirror(d, this);
    } else {
      return false;
    }
  }

  public override function destinationSet() {
    super.destinationSet();
    if(holdingPlayer != null) {
      holdingPlayer.velocity.x = velocity.x;
      holdingPlayer.velocity.y = velocity.y;
    }
  }

  public override function destinationReached() {
    super.destinationReached();
    set_holdingPlayer(null);
    state.updateLight();
  }

	public override function getDirectionFacing() {
		return directionFacing;
	}

	public function rotateClockwise() {
		if (directionFacing.equals(Direction.Up_Left)) {
			directionFacing = Direction.Up_Right;
			flipX = ! flipX;
		} else if (directionFacing.equals(Direction.Up_Right)) {
			directionFacing = Direction.Down_Right;
			flipY = ! flipY;
		} else if (directionFacing.equals(Direction.Down_Right)) {
			directionFacing = Direction.Down_Left;
			flipX = ! flipX;
		} else if (directionFacing.equals(Direction.Down_Left)) {
			directionFacing = Direction.Up_Left;
			flipY = ! flipY;
		}
	}

	public function rotateCounterClockwise() {
		if (directionFacing.equals(Direction.Up_Right)) {
			directionFacing = Direction.Up_Left;
			flipX = ! flipX;
		} else if (directionFacing.equals(Direction.Down_Right)) {
			directionFacing = Direction.Up_Right;
			flipY = ! flipY;
		} else if (directionFacing.equals(Direction.Down_Left)) {
			directionFacing = Direction.Down_Right;
			flipX = ! flipX;
		} else if (directionFacing.equals(Direction.Up_Left)) {
			directionFacing = Direction.Down_Left;
			flipY = ! flipY;
		}
  }

  public function set_holdingPlayer(p : Character) {
    if(holdingPlayer == p) return p;

    if(holdingPlayer != null) {
      holdingPlayer.mirrorHolding = null;
    }
    if(p != null) {
      p.mirrorHolding = this;
    }
    return holdingPlayer = p;
  }

  override public function update() {
		super.update();
  }
}

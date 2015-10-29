package elements;
import flixel.FlxSprite;
import elements.LightSwitch;
class Lighting {

  public static inline var TERMINARY = -1; //Represents light hitting a terminating tile (wall/switch)
  public static inline var NONE = 0; //Represents no light going through a tile
  public static inline var HORIZONTAL = 1; //Represents light going horizontally through a tile
  public static inline var VERTICAL = 2; //Represents light going vertically through a tile
  //3 left for both horizontal and vertical together.
  public static inline var LIT_MIRROR = 4; //Represents light hitting an object and stopping here

  private static inline var HORIZONTAL_SPRITE = AssetPaths.light_sheet_0_0__png;
  private static inline var VERTICAL_SPRITE = AssetPaths.light_sheet_1_0__png;

  private static inline var HIT_WALL_DOWN_SPRITE = AssetPaths.light_sheet_0_1__png;
  private static inline var HIT_WALL_UP_SPRITE = AssetPaths.light_sheet_1_1__png;
  private static inline var HIT_WALL_RIGHT_SPRITE = AssetPaths.light_sheet_2_1__png;
  private static inline var HIT_WALL_LEFT_SPRITE = AssetPaths.light_sheet_3_1__png;

  private var state : GameState;
  private var light_trace:Array<Array<Int>>;
  private var start_x:Int;
  private var start_y:Int;
  private var start_direction:Direction;

  private function createLightForSquare(x : Int, y : Int, d : Direction, nonCollision : Bool) : LightSprite {
    if (! d.isCardinal()) {
      throw "Can't make light for non-cardinal direction";
    }

    var spr : Dynamic = null;
    if(nonCollision) {
      spr = (d.isHorizontal() ? HORIZONTAL_SPRITE : VERTICAL_SPRITE);
    } else {
      switch d.simpleString {
        case "Down" : spr = HIT_WALL_DOWN_SPRITE;
        case "Up" : spr = HIT_WALL_UP_SPRITE;
        case "Right" : spr = HIT_WALL_RIGHT_SPRITE;
        case "Left" : spr = HIT_WALL_LEFT_SPRITE;
      }
    }

    var light = new LightSprite(state, y, x, d, spr);
    return light;
  }

  public function new(state : GameState, lightBulb : LightBulb) {
    this.state = state;
    var xmax = state.level.width;
    var ymax = state.level.height;
    light_trace = new Array<Array<Int>>();
    for (x in 0...xmax + 1) {
      light_trace.push(new Array<Int>());
      for (y in 0...ymax + 1) {
        light_trace[x].push(NONE);
      }
    }
    start_x = lightBulb.getCol();
    start_y = lightBulb.getRow();
    start_direction = lightBulb.directionFacing;
  }

  public function redraw_light() {
    for (x in 0...light_trace.length) {
      for (y in 0...light_trace[x].length) {
        light_trace[x][y] = NONE;
      }
    }
    draw_light();
  }

  private function trace_light(x:Int, y:Int, direction:Direction):Bool {
    if (! direction.isCardinal()) {
      throw "Illegal direction in trace light";
    }

    if (state.level.hasWallAt(x,y)){
      light_trace[x][y] = TERMINARY;
      return false;
    }
    var e:Element = state.getElementAt(y, x);

    if (e == null || Std.is(e, Character)) {
      if(Std.is(e, Character)) {
        state.killPlayer();
      }

      light_trace[x][y] += getVerticalOrHorizontal(direction);
      var nonCollision = trace_light(x + Std.int(direction.x), y + Std.int(direction.y), direction);
      var light_sprite = createLightForSquare(x,y, direction, nonCollision);
      state.lightSprites.add(light_sprite);
      return true;
    } else if (Std.is(e, Mirror)) {
      // the mirror is assumed to only be one sided
      var m:Mirror = Std.instance(e, Mirror);
      if (direction.equals(Direction.Right)) {
        if (m.directionFacing.equals(Direction.Up_Left)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x, y - 1, Direction.Up);
          return true;
        }
        else if (m.directionFacing.equals(Direction.Down_Left)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x, y + 1, Direction.Down);
          return true;
        }

        return false;
      }
      else if (direction.equals(Direction.Left)) {
        if (m.directionFacing.equals(Direction.Down_Right)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x, y + 1, Direction.Down);
          return true;
        }
        else if (m.directionFacing.equals(Direction.Up_Right)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x, y - 1, Direction.Up);
          return true;
        }

        return false;
      }
      else if (direction.equals(Direction.Up)) {
        if (m.directionFacing.equals(Direction.Down_Right)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x + 1, y, Direction.Right);
          return true;
        }
        else if (m.directionFacing.equals(Direction.Down_Left)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x - 1, y, Direction.Left);
          return true;
        }

        return false;
      }
      else if (direction.equals(Direction.Down)) {
        if (m.directionFacing.equals(Direction.Up_Left)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x - 1, y, Direction.Left);
          return true;
        }
        else if (m.directionFacing.equals(Direction.Up_Right)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x + 1, y, Direction.Right);
          return true;
        }

        return false;
      }
    } else if (Std.is(e, LightSwitch)) {
      var lightSwitch : LightSwitch = Std.instance(e, LightSwitch);
      lightSwitch.isLit = true;
      return true;
    }

    return false;
  }

  private function getVerticalOrHorizontal(direction:Direction) : Int {
    if (direction.isVertical()) {
      return VERTICAL;
    }
    else if (direction.isHorizontal()) {
      return HORIZONTAL;
    }
    throw "Got non-cardinal direction - bad time!";
  }

  private function draw_light() {
    state.lightSprites.clear();
    trace_light(start_x + Std.int(start_direction.x), start_y + Std.int(start_direction.y), start_direction);
  }

 /**
  * Returns the light going through the given grid coordinates.
  * Possible return values are NONE, HORIZONTAL, VERTICAL, HORIZONTAL_AND_VERTICAL.
  **/
  public function check_light(x:Int, y:Int) {
    return light_trace[x][y];
  }

  //we shouldnt need this function until we implement crystal walls
  private function light_exists(direction:Direction):Bool {
    return false;
  }
}
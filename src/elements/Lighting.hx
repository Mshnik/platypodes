package elements;
import elements.LightSwitch;
import flixel.FlxSprite;
class Lighting {

  private static inline var HORIZONTAL_SPRITE = AssetPaths.light_horizontal__png;
  private static inline var VERTICAL_SPRITE = AssetPaths.light_vertical__png;

  public static inline var TERMINARY = -1; //Represents light hitting a terminating tile (wall/switch)
  public static inline var NONE = 0; //Represents no light going through a tile
  public static inline var HORIZONTAL = 1; //Represents light going horizontally through a tile
  public static inline var VERTICAL = 2; //Represents light going vertically through a tile
  //3 left for both horizontal and vertical together.
  public static inline var LIT_MIRROR = 4; //Represents light hitting an object and stopping here

  private var state : GameState;
  private var light_trace:Array<Array<Int>>;
  private var start_x:Int;
  private var start_y:Int;
  private var start_direction:Direction;

  private function createLightForSquare(x : Int, y : Int, d : Direction) : FlxSprite {
    if (! d.isCardinal()) {
      throw "Can't make light for non-cardinal direction";
    }

    var spr = d.isHorizontal() ? HORIZONTAL_SPRITE : VERTICAL_SPRITE;
    var light = new FlxSprite(x * state.level.tileWidth, y * state.level.tileHeight, spr);
    if(d.isHorizontal()) {
      light.y += 17; //TODO - fix Hacky bullshit woooo!!
      if(x%2 == 1) light.flipX = true;
    }
    if(d.isVertical()) {
      light.x += 15; //TODO - fix Hacky bullshit woooo!!
      if(y%2 == 1) light.flipY = true;
    }
    light.immovable = true;
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
    start_direction = lightBulb.getDirectionFacing();
  }

  public function redraw_light() {
    for (x in 0...light_trace.length) {
      for (y in 0...light_trace[x].length) {
        light_trace[x][y] = NONE;
      }
    }
    draw_light();
  }

  private function trace_light(x:Int, y:Int, direction:Direction):Void {
    if (state.level.hasWallAt(x,y)){
      light_trace[x][y] = TERMINARY;
      return;
    }
    var e:Element = state.getElementAt(y, x);

    if (e == null || Std.is(e, Character)) {
      if(Std.is(e, Character)) {
        state.killPlayer();
      }
      var light_sprite = createLightForSquare(x,y, direction);
      state.lightSprites.add(light_sprite);
      light_trace[x][y] += getVerticalOrHorizontal(direction);
      trace_light(x + Std.int(direction.x), y + Std.int(direction.y), direction);
    }
    else if (Std.is(e, Mirror)) {
      // the mirror is assumed to only be one sided
      var m:Mirror = Std.instance(e, Mirror);
      if (direction.equals(Direction.Right)) {
        if (m.getDirectionFacing().equals(Direction.Up_Left)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x, y - 1, Direction.Up);
        }
        else if (m.getDirectionFacing().equals(Direction.Down_Left)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x, y + 1, Direction.Down);
        }
      }
      else if (direction.equals(Direction.Left)) {
        if (m.getDirectionFacing().equals(Direction.Down_Right)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x, y + 1, Direction.Down);
        }
        else if (m.getDirectionFacing().equals(Direction.Up_Right)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x, y - 1, Direction.Up);
        }
      }
      else if (direction.equals(Direction.Up)) {
        if (m.getDirectionFacing().equals(Direction.Down_Right)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x + 1, y, Direction.Right);
        }
        else if (m.getDirectionFacing().equals(Direction.Down_Left)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x - 1, y, Direction.Left);
        }
      }
      else if (direction.equals(Direction.Down)) {
        if (m.getDirectionFacing().equals(Direction.Up_Left)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x - 1, y, Direction.Left);
        }
        else if (m.getDirectionFacing().equals(Direction.Up_Right)) {
          light_trace[x][y] = LIT_MIRROR;
          m.isLit = true;
          trace_light(x + 1, y, Direction.Right);
        }
      }
    } else if (Std.is(e, LightSwitch)) {
      var lightSwitch : LightSwitch = Std.instance(e, LightSwitch);
      lightSwitch.set_isLit(true);
    }
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
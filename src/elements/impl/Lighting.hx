package elements.impl;
import elements.AbsMirror;
class Lighting {

  public static inline var TERMINARY = -1; //Represents light hitting a terminating tile (wall/switch/barrel)
  public static inline var NONE = 0; //Represents no light going through a tile
  public static inline var HORIZONTAL = 1; //Represents light going horizontally through a tile
  public static inline var VERTICAL = 2; //Represents light going vertically through a tile
  //3 reserved for both horizontal and vertical together.
  public static inline var LIT_MIRROR = 4; //Represents light hitting an object and stopping here
  //8 reserved for a doubly-lit mirror
  public static inline var LIT_CRYSTAL = 16;

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

  public var lightSprites(default, null) : List<LightSprite>;

  private function createLightForSquare(x : Int, y : Int, d : Direction,
                                        nonCollision : Bool, mostRecentMirror : AbsMirror) : LightSprite {
    if (! d.isCardinal()) {
      if(PMain.DEBUG_MODE) throw "Can't make light for non-cardinal direction";
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

    var light = new LightSprite(state, y, x, d, mostRecentMirror, spr);
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
    lightSprites = new List<LightSprite>();
  }

  public function redraw_light() {
    for (x in 0...light_trace.length) {
      for (y in 0...light_trace[x].length) {
        light_trace[x][y] = NONE;
      }
    }
    draw_light();
  }

  private static inline var OK = 0; //Returned if the previous call is good to make a sprite
  private static inline var HIT_WALL = 1; //Returned iff this call hit a wall, previous call should make a hit wall sprite
  private static inline var DUPLICATE = 2;//Returned iff this was an overlap

  private function trace_light(x:Int, y:Int, direction:Direction, mostRecentMirror : AbsMirror):Int {
    if (! direction.isCardinal() && PMain.DEBUG_MODE) {
      throw "Illegal direction in trace light";
    }

    if(light_exists(x,y,direction)){
      return DUPLICATE;
    }

//    light_trace[x][y]+=getVerticalOrHorizontal(direction);
//    var nonCollision=trace_light(x+Std.int(direction.x),y+Std.int(direction.y),direction);
//    var light_sprite=createLightForSquare(x,y,direction,nonCollision);
//    state.lightSprites.add(light_sprite);
//    return true;
//
    var e:Element = state.getElementAt(y, x);

    if (state.level.hasOpaqueWallAt(x,y)) {
      light_trace[x][y] = TERMINARY;
      return HIT_WALL;
    } else if (state.level.hasGlassWallAt(x,y)) {
      //TODO - make this glass wall light up
      trace_light(x+Std.int(direction.x),y+Std.int(direction.y),direction);
      return OK;
    } else if(Std.is(e, Lightable)) {
      var l : Lightable = Std.instance(e, Lightable);
      l.lightInDirection = direction;
      for(dNext in l.getReflection(direction)) {
        trace_light(x+Std.int(dNext.x),y+Std.int(dNext.y),dNext);
      }
      return Std.is(l, Barrel) ? HIT_WALL : OK;
    }




    else if (e == null || Std.is(e, Character)) {
      if(Std.is(e, Character)) {
        state.killPlayer();
      }
      light_trace[x][y] += getVerticalOrHorizontal(direction);
      var nonCollision = trace_light(x + Std.int(direction.x), y + Std.int(direction.y), direction, mostRecentMirror);
      var light_sprite = createLightForSquare(x,y, direction, nonCollision != HIT_WALL, mostRecentMirror);
      lightSprites.push(light_sprite);
      state.lightSprites.add(light_sprite);
      var nextE = state.getElementAt(y + Std.int(direction.y), x + Std.int(direction.x));
      if (Std.is(nextE, AbsMirror)){
        var m : AbsMirror = Std.instance(nextE, AbsMirror);
        light_sprite.followingMirror = m;
      }
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
    if(PMain.DEBUG_MODE) throw "Got non-cardinal direction - bad time!";
    return VERTICAL;
  }

  private function draw_light() {
    state.lightSprites.clear();
    trace_light(start_x + Std.int(start_direction.x), start_y + Std.int(start_direction.y), start_direction, null);
  }

/**
  * Returns the light going through the given grid coordinates.
  * Possible return values are NONE, HORIZONTAL, VERTICAL, HORIZONTAL_AND_VERTICAL.
  **/
  public function check_light(x:Int, y:Int) {
    return light_trace[x][y];
  }

//we shouldnt need this function until we implement crystal walls
  private function light_exists(x:Int,y:Int,direction:Direction):Bool {
    if(Std.is(state.getElementAt(x,y),Crystal)){
      return light_trace[x][y]==LIT_CRYSTAL;}
    var hv:Int=getVerticalOrHorizontal(direction);
    if(hv==VERTICAL){
      return light_trace[x][y]==VERTICAL||
             light_trace[x][y]==VERTICAL+HORIZONTAL;}
    else{
      return light_trace[x][y]==HORIZONTAL||
             light_trace[x][y]==VERTICAL+HORIZONTAL;}}
}
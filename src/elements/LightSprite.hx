package elements;

import flixel.FlxSprite;
class LightSprite extends FlxSprite implements Lightable{

  private static inline var HORIZONTAL_SPRITE = AssetPaths.light_horizontal__png;
  private static inline var VERTICAL_SPRITE = AssetPaths.light_vertical__png;

  public var state : GameState;
  public var isLit(default, null) : Bool;

  public function new(state : GameState, row : Int, col : Int, d : Direction) {
    super(col * state.level.tileWidth, row * state.level.tileHeight, d.isHorizontal() ? HORIZONTAL_SPRITE : VERTICAL_SPRITE);
    if(d.isHorizontal() && col%2 == 1) {
      flipX = true;
    }
    if(d.isVertical() && col%2 == 1) {
      flipY = true;
    }
    this.state = state;
    isLit = true;
    immovable = true;
  }

  /** Return the row of the board this element is currently occupying. The top-left tile is (0,0) */
  public inline function getRow() : Int {
    return Std.int( (this.y + this.origin.y) / state.level.tileHeight);
  }

  /** Return the col of the board this element is currently occupying. The top-left tile is (0,0) */
  public inline function getCol() : Int {
    return Std.int( (this.x + this.origin.x) / state.level.tileWidth);
  }
}

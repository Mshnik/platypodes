package elements;

import flixel.FlxSprite;
class LightSprite extends FlxSprite{

  private static inline var HORIZONTAL_SPRITE = AssetPaths.light_horizontal__png;
  private static inline var VERTICAL_SPRITE = AssetPaths.light_vertical__png;

  public function new(state : GameState, row : Int, col : Int, d : Direction) {
    super(col * state.level.tileWidth, row * state.level.tileHeight, d.isHorizontal() ? HORIZONTAL_SPRITE : VERTICAL_SPRITE);
    if(d.isHorizontal()) {
      y += 17; //TODO - fix Hacky bullshit woooo!!
      if(col%2 == 1) flipX = true;
    }
    if(d.isVertical()) {
      x += 15; //TODO - fix Hacky bullshit woooo!!
      if(col%2 == 1) flipY = true;
    }
    immovable = true;
  }
}

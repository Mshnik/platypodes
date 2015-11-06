package elements.impl;

import flixel.FlxSprite;
class LightSprite extends FlxSprite {

  public var state : GameState;
  public var isLit(default, null) : Bool;

  public function new(state : GameState, row : Int, col : Int, d : Direction, spr : Dynamic) {
    super(col * state.level.tileWidth, row * state.level.tileHeight, spr);
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

  public override function update(){
    //TODO - reinstate after friends
//    if(leadingMirror != null) {
//      if(getRow() == leadingMirror.getRow() && leadingMirror.moveDirection.isHorizontal()) {
//        var diff : Float = Math.abs(leadingMirror.x - x);
//        scale.x = diff/frameWidth;
//        updateHitbox();
//      } else if(getCol() == leadingMirror.getCol() && leadingMirror.moveDirection.isVertical()) {
//        var diff : Float = Math.abs(leadingMirror.y - y);
//        scale.y = diff/frameHeight;
//        updateHitbox();
//      }
//    }
//    if(followingMirror != null) {
//      velocity.x = followingMirror.velocity.x;
//      velocity.y = followingMirror.velocity.y;
//    }
    super.update();
  }
}

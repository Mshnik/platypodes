package elements.impl;

import flixel.FlxSprite;
class LightSprite extends FlxSprite implements Lightable{

  public var state : GameState;
  public var isLit(default, null) : Bool;

  /** The mirror this is directly leading into. May be used for resizing in update */
  public var leadingMirror(default, default) : Mirror;

  /** The mirror this is following. May be used for movement in update */
  public var followingMirror(default, default) : Mirror;

  public function new(state : GameState, row : Int, col : Int, d : Direction, m : Mirror, spr : Dynamic) {
    super(col * state.level.tileWidth, row * state.level.tileHeight, spr);
    this.state = state;
    isLit = true;
    immovable = true;
    followingMirror = m;
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

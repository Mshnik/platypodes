package elements.impl;

import haxe.Timer;
import flixel.FlxSprite;
class LightSprite extends FlxSprite {

  public var state : GameState;
  public var isLit(default, null) : Bool;

  public function new(state : GameState, row : Int, col : Int, d : Direction, spr : Dynamic) {
    super(col * state.level.tileWidth, row * state.level.tileHeight, spr);
    this.state = state;
    isLit = true;
    immovable = true;
    var tName = Type.getClassName(Type.getClass(this));
    if(! Element.delayMap.exists(tName)) {
      Element.delayMap.set(tName, 0);
      Element.updateCount.set(tName, 0);
    }
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
    var startTime = Timer.stamp();
    super.update();
    var tName = Type.getClassName(Type.getClass(this));
    Element.delayMap.set(tName, Element.delayMap.get(tName) + (Timer.stamp() - startTime));
    Element.updateCount.set(tName, Element.updateCount.get(tName) + 1);
  }
}

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
    cameras = [state.mainCamera];
    var tName = Type.getClassName(Type.getClass(this));
    if(! Element.updateTimeMap.exists(tName)) {
      Element.updateTimeMap.set(tName, 0);
      Element.updateCount.set(tName, 0);
      Element.drawTimeMap.set(tName, 0);
      Element.drawCount.set(tName, 0);
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

  public override function draw() {
    var startTime = Timer.stamp();
    super.draw();
    var tName = Type.getClassName(Type.getClass(this));
    Element.drawTimeMap.set(tName, Element.drawTimeMap.get(tName) + (Timer.stamp() - startTime));
    Element.drawCount.set(tName, Element.drawCount.get(tName) + 1);
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
    Element.updateTimeMap.set(tName, Element.updateTimeMap.get(tName) + (Timer.stamp() - startTime));
    Element.updateCount.set(tName, Element.updateCount.get(tName) + 1);
  }
}

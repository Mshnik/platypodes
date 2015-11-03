package elements;

import flixel.FlxSprite;
class LightSprite extends FlxSprite implements Lightable{

  public var state : GameState;
  public var isLit(default, null) : Bool;

  /** The mirror this is directly leading into. May be used for resizing in update */
  public var mirror(default, default) : Mirror;

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
    if(mirror != null && mirror.moveDirection.isNonNone()) {
      var mirrorDelta : Direction = Direction.getDirection(mirror.getCol() - getCol(), mirror.getRow() - getRow());
      if(mirrorDelta.isHorizontal() && mirror.moveDirection.isHorizontal()) {
        var diff : Float = Math.abs(mirror.x - x);
        scale.x = diff/frameWidth;
      } else if(mirrorDelta.isVertical() && mirror.moveDirection.isVertical()) {
        var diff : Float = Math.abs(mirror.y - y);
        scale.y = diff/frameHeight;
      }
    }
    super.update();
  }
}

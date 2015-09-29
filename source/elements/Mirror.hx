package elements;
import flixel.addons.editors.tiled.TiledObject;
class Mirror extends Element {

  public var directionFacing : Direction;

  public function new(level : TiledLevel, x : Int, y : Int, o : TiledObject, ?img:Dynamic) {
    super(level, x, y, o, 0, img);

    this.directionFacing = Direction.Up_Left;
  }
  
  private function rot_clock() {
	  switch this.directionFacing {
		  case Direction.Up_Left: setDirection(Direction.Up_Right);
		  case Direction.Up_Right: setDirection(Direction.Down_Right);
		  case Direction.Down_Right: setDirection(Direction.Down_Left);
		  case Direction.Down_Left: setDirection(Direction.Up_Left);
	  }
  }
  
  private function rot_c_clock() {
	  switch this.directionFacing {
	  	case Direction.Up_Left: setDirection(Direction.Down_Left);
	  	case Direction.Up_Right: setDirection(Direction.Up_Left);
	  	case Direction.Down_Right: setDirection(Direction.Up_Right);
	  	case Direction.Down_Left: setDirection(Direction.Down_Right);
	  }
  }
  
  override public function update() {
	  if(character.ROT_CLOCKWISE) {
		  rot_clock();
	  }
	  if(character.ROT_CLOCKWISE) {
		  rot_c_clock();
	  }
  }
}

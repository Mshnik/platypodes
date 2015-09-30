package elements;
import flixel.addons.editors.tiled.TiledObject;
class LightBulb extends Element {

  @final private static var DEFAULT_SPRITE = AssetPaths.light_orb__png;
  @final private static var DIRECTION_PROPERTY_KEY = "direction"; //Name of direction property in Tiled
  private var direction:Direction;//the direction that the light is shining at

  /** Constructs a light bulb, light source, with the given level, and initial row and col */
  public function new(state : GameState, row : Int, col : Int, o : TiledObject) {
    super(state, row, col, o, false, 0, DEFAULT_SPRITE);
    direction= Direction.fromSimpleDirection(Std.parseInt(o.custom.get(DIRECTION_PROPERTY_KEY)));
  }


  override public function update() {
    super.update();
  }
}

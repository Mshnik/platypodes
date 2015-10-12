package elements;
import flixel.addons.editors.tiled.TiledObject;
class LightBulb extends Element {

  @final private static var DEFAULT_SPRITE = AssetPaths.light_orb__png;
  @final private static var DIRECTION_PROPERTY_KEY = "direction"; //Name of direction property in Tiled

  public var directionFacing (default, null):Direction;//the direction that the light is shining at
  private var lighting : Lighting; //The Lighting object that represents the lighting of this bulb
  private var light_dirty : Bool;  //True if the lighting needs to be recalculated on the next update

  /** Constructs a light bulb, light source, with the given level, and initial row and col */
  public function new(state : GameState, o : TiledObject) {
    super(state, o, DEFAULT_SPRITE);
    directionFacing = Direction.fromSimpleDirection(Std.parseInt(o.custom.get(DIRECTION_PROPERTY_KEY)));
    light_dirty = true;
    lighting = new Lighting(state, this);
  }

  /** Mark this bulb as having to update lighting on the next frame */
  public function markLightDirty() {
    light_dirty = true;
  }

  override public function update() {

    if(light_dirty) {
      light_dirty = false;
      lighting.redraw_light();
    }

    super.update();
  }
}

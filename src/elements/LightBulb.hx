package elements;
import flixel.addons.editors.tiled.TiledObject;

class LightBulb extends Element implements Lightable{

  @final private static var DEFAULT_SPRITE = [
    AssetPaths.light_sheet_0_4__png,
    AssetPaths.light_sheet_1_4__png,
    AssetPaths.light_sheet_2_4__png,
    AssetPaths.light_sheet_3_4__png
  ];
  @final private static var DIRECTION_PROPERTY_KEY = "direction"; //Name of direction property in Tiled

  public var directionFacing (default, null):Direction;//the direction that the light is shining at
  private var lighting : Lighting; //The Lighting object that represents the lighting of this bulb
  private var light_dirty : Bool;  //True if the lighting needs to be recalculated on the next update

  public var isLit(default, null) : Bool;

  /** Constructs a light bulb, light source, with the given level, and initial row and col */
  public function new(state : GameState, o : TiledObject) {
    super(state, o);
    directionFacing = Direction.fromSimpleDirection(Std.parseInt(o.custom.get(DIRECTION_PROPERTY_KEY)));
    switch directionFacing.simpleString {
      case "Up": loadGraphic(DEFAULT_SPRITE[0]);
      case "Down": loadGraphic(DEFAULT_SPRITE[1]);
      case "Left": loadGraphic(DEFAULT_SPRITE[2]);
      case "Right": loadGraphic(DEFAULT_SPRITE[3]);
      default: throw "IllegalDirection for " + this;
    }

    light_dirty = true;
    lighting = new Lighting(state, this);
    isLit = true;
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

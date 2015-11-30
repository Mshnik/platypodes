package elements.impl;
import haxe.Timer;
import flixel.addons.editors.tiled.TiledObject;

class LightBulb extends Element implements Lightable{

  @final private static var DEFAULT_SPRITE = [
    AssetPaths.orb_on_1__png,
    AssetPaths.orb_on_3__png,
    AssetPaths.orb_on_2__png,
    AssetPaths.orb_on_4__png
  ];
  @final private static var DIRECTION_PROPERTY_KEY = "direction"; //Name of direction property in Tiled

  public var directionFacing (default, null):Direction;//the direction that the light is shining at
  private var lighting : Lighting; //The Lighting object that represents the lighting of this bulb
  private var light_dirty : Bool;  //True if the lighting needs to be recalculated on the next update

  public var lightInDirection(default, null) : Array<Direction>;
  public var isLit(default, null) : Bool;

  /** Constructs a light bulb, light source, with the given level, and initial row and col */
  public function new(state : GameState, o : TiledObject) {
    super(state, o);
    directionFacing = Direction.fromSimpleDirection(Std.parseInt(o.custom.get(DIRECTION_PROPERTY_KEY)));
    switch directionFacing.simpleString {
      case "Up": loadGraphic(DEFAULT_SPRITE[0]);
      case "Down": loadGraphic(DEFAULT_SPRITE[1]);
      case "Left": loadGraphic(DEFAULT_SPRITE[3]);
      case "Right": loadGraphic(DEFAULT_SPRITE[2]);
      default:
        if(PMain.DEBUG_MODE) throw "IllegalDirection for " + this;
        else loadGraphic(DEFAULT_SPRITE[3]);
    }

    resetLightInDirection();
    light_dirty = true;
    lighting = new Lighting(state, this);
    isLit = true;
  }

  /** Returns true iff this is giving out light from the given side */
  public function isLightingTo(directionOut : Direction) : Bool {
    return directionFacing.equals(directionOut);
  }

  /** Returns the directions light should be outputted if this is hit with light from the given direction */
  public function getReflection(directionIn : Direction) : Array<Direction> {
    return [directionFacing];
  }

  /** Mark this bulb as having to update lighting on the next frame */
  public function markLightDirty() {
    light_dirty = true;
  }

  override public function update() {
    var startTime = Timer.stamp();
    if(light_dirty) {
      light_dirty = false;
      lighting.redraw_light();
    }

    super.update();
    logUpdateTime(startTime);
  }

  public function resetLightInDirection() {
    lightInDirection = [];
  }

  /** Set to Direction.None or null to turn off light */
  public function addLightInDirection(d : Direction) {
    if(d == null || d == Direction.None) {
      return;
    }
    lightInDirection.push(d);
  }

}

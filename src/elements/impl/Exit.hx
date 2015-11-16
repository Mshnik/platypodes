package elements.impl;
import flixel.addons.editors.tiled.TiledObject;

class Exit extends Element {

  public static inline var OPEN_ANIMATION_KEY = "open";
  public static inline var CLOSE_ANIMATION_KEY = "close";

  private static inline var ANIMATION_SPEED = 10;

  public var isOpen(default, set) : Bool;

/** Constructs an exit, with the given level, and initial row and col */
  public function new(level : GameState, o : TiledObject) {
    super(level, o);
    isOpen = false;
    loadGraphic(AssetPaths.gate_sheet__png, true, PMain.SPRITE_SIZE, PMain.SPRITE_SIZE);
    animation.add(OPEN_ANIMATION_KEY, [0,2,4,5,6,8], ANIMATION_SPEED, false);
    animation.add(CLOSE_ANIMATION_KEY, [8,6,5,4,2,0], ANIMATION_SPEED, false);
  }

  public function set_isOpen(open : Bool) : Bool {
    if(isOpen != open){
      if(open) {
        animation.play(OPEN_ANIMATION_KEY);
      } else {
        animation.play(CLOSE_ANIMATION_KEY);
      }
    }
    return this.isOpen = open;
  }

  override public function update() {
    super.update();
  }
}

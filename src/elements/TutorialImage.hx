package elements;
import haxe.Timer;
import flixel.addons.editors.tiled.TiledObject;
class TutorialImage extends Element {

  private static inline var WIDTH = 4 * PMain.SPRITE_SIZE;
  private static inline var HEIGHT = 2 * PMain.SPRITE_SIZE;
  private static inline var ANIMATION_PATH_A = AssetPaths.ASheet__png;
  private static inline var ANIMATION_PATH_B = AssetPaths.BSheet__png;

  private static inline var FRAME_RATE = 4;
  private static inline var ANIMATION_KEY = "play";
  private static inline var MOVE_LEVEL = 0;
  private static inline var PUSH_ONLY_LEVEL = 1;
  private static inline var ROTATE_ONLY_LEVEL = 2;
  private static inline var PUSH_AND_ROTATE_LEVEL = 3;

  public function new(s : GameState, o : TiledObject) {
    super(s, o);
    var tName = Type.getClassName(Type.getClass(this));
    if(! Element.updateTimeMap.exists(tName)) {
      Element.updateTimeMap.set(tName, 0);
      Element.updateCount.set(tName, 0);
      Element.drawTimeMap.set(tName, 0);
      Element.drawCount.set(tName, 0);
    }

    if(PMain.A_VERSION) {
      loadGraphic(ANIMATION_PATH_A, true, WIDTH, HEIGHT);
    } else {
      loadGraphic(ANIMATION_PATH_B, true, WIDTH, HEIGHT);
    }

    var arr :Array<Int>;
    if(s.levelPathIndex == MOVE_LEVEL) {
      arr = [20];
    } else if (s.levelPathIndex == PUSH_ONLY_LEVEL) {
      if(PMain.A_VERSION) arr = [0,1,2,3,4,5,6,7,8,9,10,11,12,13];
      else arr = [0,1,2,3,4,5,6,7,8,9,10,11,12];
    } else if(s.levelPathIndex == ROTATE_ONLY_LEVEL) {
      arr = [0,1,2,3,14,15,16,17,18,19];
    } else {
      if(PMain.A_VERSION) arr = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19];
      else arr = [0,1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17,18,19];
    }
    animation.add(ANIMATION_KEY, arr, FRAME_RATE, s.levelPathIndex != MOVE_LEVEL);
    animation.play(ANIMATION_KEY);
  }

  public override function draw() {
    var startTime = Timer.stamp();
    super.draw();
    var tName = Type.getClassName(Type.getClass(this));
    Element.drawTimeMap.set(tName, Element.drawTimeMap.get(tName) + (Timer.stamp() - startTime));
    Element.drawCount.set(tName, Element.drawCount.get(tName) + 1);
  }

  public override function update(){
    var startTime = Timer.stamp();
    super.update();
    var tName = Type.getClassName(Type.getClass(this));
    Element.updateTimeMap.set(tName, Element.updateTimeMap.get(tName) + (Timer.stamp() - startTime));
    Element.updateCount.set(tName, Element.updateCount.get(tName) + 1);
  }
}

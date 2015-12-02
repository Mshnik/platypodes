package;
import haxe.Timer;
import flixel.FlxG;
import logging.ActionElement;
import flixel.util.FlxPoint;
import flixel.addons.display.FlxExtendedSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxRect;
import flixel.FlxSprite;
import elements.*;
import elements.impl.*;

class Tooltip extends FlxGroup {

  private var game:GameState;

  private var cwArrowButton:FlxExtendedSprite; //clockwise Arrow
  private var ccwArrowButton:FlxExtendedSprite; //counter clock-wise arrow
  private var pullArrowButton:FlxExtendedSprite; //pull arrow
  private var pushArrowButton:FlxExtendedSprite; //push arrow
  private var pushMirrorDirection:Direction;
  private var pullMirrorDirection:Direction;

  /** Rotation arrow graphic for scheme A **/
  private inline static var A_ROTATE_ARROW_PATH = AssetPaths.new_up_tip__png; //clockwise
  /** Pull/push arrow graphic for scheme A**/
  private inline static var A_PUSH_ARROW_PATH = AssetPaths.new_side_tip__png; //pointing up

  /** Rotation arrow graphic for scheme B **/
  private inline static var B_ROTATE_ARROW_PATH = AssetPaths.B_rotate_arrow__png; //clockwise
  /** Pull/push arrow graphic for scheme A**/
  private inline static var B_PUSH_ARROW_PATH = AssetPaths.B_push_pull__png; //pointing up

  /** Scale factor for arrow and key sprite images **/
  private inline static var B_VERSION_ARROW_SPRITE_SCALE = 0.9;

  /** Animation descriptors **/
  private inline static var ANIMATION_SPEED = 7;
  private inline static var GLOW_ANIMATION_KEY = "glow";
  private inline static var RED_GLOW_ANIMATION_KEY = "redGlow";
  private inline static var A_SPRITE_SIZE = 48;
  private inline static var B_SPRITE_SIZE = 200;

  public function new(currGame:GameState) {
    super();
    this.visible = false;

    //PULL ARROW
    pullArrowButton = new FlxExtendedSprite();
    if(PMain.A_VERSION)
    {
      pullArrowButton.loadGraphic(A_PUSH_ARROW_PATH, true, A_SPRITE_SIZE, A_SPRITE_SIZE);
    }
    else
    {
      pullArrowButton.loadGraphic(B_PUSH_ARROW_PATH, true, B_SPRITE_SIZE, B_SPRITE_SIZE);
      pullArrowButton.scale.set(B_VERSION_ARROW_SPRITE_SCALE, B_VERSION_ARROW_SPRITE_SCALE);
    }
    pullArrowButton.animation.add(GLOW_ANIMATION_KEY, [0, 1, 2, 3], ANIMATION_SPEED);
    pullArrowButton.animation.add(RED_GLOW_ANIMATION_KEY, [4, 5, 6, 7], ANIMATION_SPEED);
    pullArrowButton.updateHitbox();
    pullArrowButton.centerOrigin();

    //PUSH ARROW
    pushArrowButton = new FlxExtendedSprite();
    if(PMain.A_VERSION)
    {
      pushArrowButton.loadGraphic(A_PUSH_ARROW_PATH, true, A_SPRITE_SIZE, A_SPRITE_SIZE);
    }
    else
    {
      pushArrowButton.loadGraphic(B_PUSH_ARROW_PATH, true, B_SPRITE_SIZE, B_SPRITE_SIZE);
      pushArrowButton.scale.set(B_VERSION_ARROW_SPRITE_SCALE, B_VERSION_ARROW_SPRITE_SCALE);
    }
    pushArrowButton.animation.add(GLOW_ANIMATION_KEY, [0, 1, 2, 3], ANIMATION_SPEED);
    pushArrowButton.animation.add(RED_GLOW_ANIMATION_KEY, [4, 5, 6, 7], ANIMATION_SPEED);
    pushArrowButton.updateHitbox();
    pushArrowButton.centerOrigin();

    //CW ARROW
    cwArrowButton = new FlxExtendedSprite();
    if(PMain.A_VERSION)
    {
      cwArrowButton.loadGraphic(A_ROTATE_ARROW_PATH, true, A_SPRITE_SIZE, A_SPRITE_SIZE);
    }//Create 4 rotations for the rotate arrows
    else
    {
      cwArrowButton.loadGraphic(B_ROTATE_ARROW_PATH, true, B_SPRITE_SIZE, B_SPRITE_SIZE);
      cwArrowButton.scale.set(B_VERSION_ARROW_SPRITE_SCALE, B_VERSION_ARROW_SPRITE_SCALE);
    }
    cwArrowButton.animation.add(GLOW_ANIMATION_KEY, [0, 1, 2, 3], ANIMATION_SPEED);
    cwArrowButton.animation.add(RED_GLOW_ANIMATION_KEY, [4, 5, 6, 7], ANIMATION_SPEED);
    cwArrowButton.updateHitbox();
    cwArrowButton.centerOrigin();

    //CCW ARROW
    ccwArrowButton = new FlxExtendedSprite();
    ccwArrowButton.flipX = true;
    if(PMain.A_VERSION){
      ccwArrowButton.loadGraphic(A_ROTATE_ARROW_PATH, true, A_SPRITE_SIZE, A_SPRITE_SIZE);
    }
    else
    {
      ccwArrowButton.loadGraphic(B_ROTATE_ARROW_PATH, true, B_SPRITE_SIZE, B_SPRITE_SIZE);
      ccwArrowButton.scale.set(B_VERSION_ARROW_SPRITE_SCALE, B_VERSION_ARROW_SPRITE_SCALE);
    }
    ccwArrowButton.animation.add(GLOW_ANIMATION_KEY, [0, 1, 2, 3], ANIMATION_SPEED);
    ccwArrowButton.animation.add(RED_GLOW_ANIMATION_KEY, [4, 5, 6, 7], ANIMATION_SPEED);
    ccwArrowButton.updateHitbox();
    ccwArrowButton.centerOrigin();


    if(! PMain.A_VERSION){
      pushArrowButton.enableMouseClicks(true);
      pullArrowButton.enableMouseClicks(true);
      ccwArrowButton.enableMouseClicks(true);
      cwArrowButton.enableMouseClicks(true);

      pullArrowButton.mousePressedCallback = pullMirrorCallback;
      pushArrowButton.mousePressedCallback = pushMirrorCallback;
      cwArrowButton.mouseReleasedCallback = rotateCWCallback;
      ccwArrowButton.mouseReleasedCallback = rotateCCWCallback;
    }

    pullArrowButton.cameras = [FlxG.camera];
    pushArrowButton.cameras = [FlxG.camera];
    cwArrowButton.cameras = [FlxG.camera];
    ccwArrowButton.cameras = [FlxG.camera];

    if(! PMain.arrayContains(GameState.NO_PUSHPULL_LEVEL, currGame.levelPathIndex)) {
      this.add(pullArrowButton);
      this.add(pushArrowButton);
    }
    if(! PMain.arrayContains(GameState.NO_ROTATE_LEVEL, currGame.levelPathIndex)){
      this.add(cwArrowButton);
      this.add(ccwArrowButton);
    }
    game = currGame;
  }

  override public function update():Void {

    var startTime = Timer.stamp();
    var player = game.player;
    var mirror = game.player.elmHolding;

    if ((mirror == null) || (player == null) || (mirror.holdingPlayer == null) || (mirror.moveDirection != Direction.None)) {
      this.visible = false;
      super.update();
      return;
    }

    this.visible = true;

    check_animation();

    var mBox = mirror.getBoundingBox();
    var mWidthDiv2 = mBox.width/2;
    var mHeightDiv2 = mBox.height/2;

    if (player.getRow() == mirror.getRow()) {
      if (player.getCol() < mirror.getCol()) {
        //PLAYER TO THE LEFT OF MIRROR
        pullArrowButton.setPosition(player.x - pullArrowButton.width, mBox.top);
        if(!PMain.A_VERSION)
        {
          pullArrowButton.setPosition(player.x - pullArrowButton.width, mBox.top - (pullArrowButton.height / 6));
        }
        pullArrowButton.angle = 0;
        pullMirrorDirection = Direction.Left;

        pushArrowButton.setPosition(mBox.right, mBox.top);
        if(!PMain.A_VERSION)
        {
          pushArrowButton.setPosition(mBox.right, mBox.top - (pullArrowButton.height / 6));
        }
        pushArrowButton.angle = 180;
        pushMirrorDirection = Direction.Right;
      }
      else if (player.getCol() > mirror.getCol()) {

//PLAYER TO THE RIGHT OF MIRROR
        pullArrowButton.setPosition(player.x + player.width, mBox.top);
        if(!PMain.A_VERSION)
        {
          pullArrowButton.setPosition(player.x + player.width, mBox.top - (pullArrowButton.height / 6));
        }
        pullArrowButton.angle = 180;
        pullMirrorDirection = Direction.Right;

        pushArrowButton.setPosition(mBox.left - pushArrowButton.width, mBox.top);
        if(!PMain.A_VERSION)
        {
          pushArrowButton.setPosition(mBox.left - pushArrowButton.width, mBox.top - (pullArrowButton.height / 6));
        }
        pushArrowButton.angle = 0;
        pushMirrorDirection = Direction.Left;
      }
    }
    else if (player.getCol() == mirror.getCol()) {
      if (player.getRow() < mirror.getRow()) {
        //PLAYER ABOVE MIRROR
        pullArrowButton.setPosition(mBox.left + mWidthDiv2 - (pullArrowButton.width/2), player.y - player.offset.y - pullArrowButton.height);
        pullArrowButton.angle = 90;
        pullMirrorDirection = Direction.Up;

        pushArrowButton.setPosition(mBox.left + mWidthDiv2 - (pushArrowButton.width/2), mBox.bottom);
        pushArrowButton.angle = 270;
        pushMirrorDirection = Direction.Down;
      }
      else if (player.getRow() > mirror.getRow()) {
        //PLAYER BELOW MIRROR
        pullArrowButton.setPosition(mBox.left + mWidthDiv2 - (pullArrowButton.width/2), player.y + player.height);
        pullArrowButton.angle = 270;
        pullMirrorDirection = Direction.Down;

        pushArrowButton.setPosition(mBox.left+ mWidthDiv2 - (pushArrowButton.width/2), mBox.top - pushArrowButton.height);
        pushArrowButton.angle = 90;
        pushMirrorDirection = Direction.Up;
      }
    }
    configureRotateArrows(pushMirrorDirection, mBox);
    mBox.put();
    super.update();
  }

  //Determines which tooltips get animated
  private function check_animation(){
    var animate : Bool = false;
    if(PMain.A_VERSION)
    {
      animate = true;
    }

    if(! pullArrowButton.mouseOver || animate){
      pullArrowButton.animation.play(GLOW_ANIMATION_KEY);
    }
    else
    {
      pullArrowButton.animation.play(RED_GLOW_ANIMATION_KEY);
    }
    if(! pushArrowButton.mouseOver || animate){
      pushArrowButton.animation.play(GLOW_ANIMATION_KEY);
    }
    else
    {
      pushArrowButton.animation.play(RED_GLOW_ANIMATION_KEY);
    }
    if(! cwArrowButton.mouseOver || animate){
      cwArrowButton.animation.play(GLOW_ANIMATION_KEY);
    }
    else
    {
      cwArrowButton.animation.play(RED_GLOW_ANIMATION_KEY);
    }
    if(! ccwArrowButton.mouseOver || animate){
      ccwArrowButton.animation.play(GLOW_ANIMATION_KEY);
    }
    else
    {
      ccwArrowButton.animation.play(RED_GLOW_ANIMATION_KEY);
    }
  }

/** Configure the positions of the rotate arrows. If the player is horizontal to the mirror, horizontal = true.
    Otherwise, horizontal = false.***/

  private function configureRotateArrows(d:Direction, mBox : FlxRect):Void {
    try {
      if (d.isHorizontal()) {
        cwArrowButton.setPosition(mBox.left, mBox.top - cwArrowButton.height);
        cwArrowButton.angle = 0;

        ccwArrowButton.setPosition(mBox.left, mBox.bottom);
        ccwArrowButton.angle = 180;

      } else if (d.isVertical()) {
        cwArrowButton.setPosition(mBox.right, mBox.bottom - ccwArrowButton.height);
        if(!PMain.A_VERSION)
        {
          cwArrowButton.setPosition(mBox.right, mBox.bottom - ccwArrowButton.height + (cwArrowButton.height/6));
        }
        cwArrowButton.angle = 90;


        ccwArrowButton.setPosition(mBox.left - cwArrowButton.width, mBox.bottom - cwArrowButton.height);
        if(!PMain.A_VERSION)
        {
          ccwArrowButton.setPosition(mBox.left - cwArrowButton.width, mBox.bottom - cwArrowButton.height + (ccwArrowButton.height/6));
        }
        ccwArrowButton.angle = 270;
      }
    }catch(msg : String) {
      //TODO - This was thrown once. Do something?
    }
  }


  /**MOUSECLICK CALLBACK FUNCTIONS **/

  private function pullMirrorCallback(obj:FlxExtendedSprite, x:Int, y:Int):Void {
    var mirror = game.player.elmHolding;
    if (mirror != null) {
      var action:ActionElement = ActionElement.pushpull(game.player.getCol(), game.player.getRow(), game.player.directionFacing, mirror.getCol(), mirror.getRow(), pullMirrorDirection);
      if (game.executeAction(action, true)){
        game.actionStack.add(action);
      }
    }
  }

  private function pushMirrorCallback(obj:FlxExtendedSprite, x:Int, y:Int):Void {
    var mirror = game.player.elmHolding;
    if (mirror != null) {
      var action:ActionElement = ActionElement.pushpull(game.player.getCol(), game.player.getRow(), game.player.directionFacing, mirror.getCol(), mirror.getRow(), pushMirrorDirection);
      if (game.executeAction(action, true)){
        game.actionStack.add(action);
      }
    }
  }


  private function rotateCWCallback(obj:FlxExtendedSprite, x:Int, y:Int):Void {
    var mirror = game.player.elmHolding;
    if (mirror != null) {
      var action:ActionElement = ActionElement.rotate(game.player.getCol(), game.player.getRow(), game.player.directionFacing, mirror.getCol(), mirror.getRow(), true);
      if (game.executeAction(action, true)){
        game.actionStack.add(action);
      }
    }
  }

  private function rotateCCWCallback(obj:FlxExtendedSprite, x:Int, y:Int):Void {
    var mirror = game.player.elmHolding;
    if (mirror != null) {
      var action:ActionElement = ActionElement.rotate(game.player.getCol(), game.player.getRow(), game.player.directionFacing, mirror.getCol(), mirror.getRow(), false);
      if (game.executeAction(action, true)){
        game.actionStack.add(action);
      }
    }
  }

  public override function destroy() {
    if(cwArrowButton != null) cwArrowButton.destroy();
    if(ccwArrowButton!= null) ccwArrowButton.destroy();
    if(pullArrowButton != null) pullArrowButton.destroy();
    if (pushArrowButton != null) pushArrowButton.destroy();
    if(pushMirrorDirection != null)pushMirrorDirection.destroy();
    if(pullMirrorDirection != null)pullMirrorDirection.destroy();
    super.destroy();
  }

}

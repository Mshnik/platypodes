package;

import flixel.FlxBasic;
import elements.Element;
import elements.Mirror;
import elements.Character;
import elements.Direction;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;

class GameState extends FlxState
{

  private static var menuButton = function() : Bool { return FlxG.keys.justPressed.ESCAPE; };

  @final private var levelPath : Dynamic;
  public var level:TiledLevel;

  public var coins:FlxGroup;
  public var player:Character;
  public var floor:FlxObject;
  public var exit:FlxSprite;
  public var mirrors:FlxGroup;

  //Variables used for pulling
  private var mirrorToPull:Mirror;
  private var xOffset : Float; //equal to player.x - mirror.x
  private var yOffset : Float; //equal to player.y - mirror.y;

  private static var youDied:Bool = false;

  public function new(levelPath : Dynamic) {
    super();
    this.levelPath = levelPath;
  }

  override public function create():Void
  {
    FlxG.mouse.visible = false;

    //super.create();
    bgColor = 0xffaaaaaa;

    // Load the level's tilemaps
    level = new TiledLevel(levelPath);

    // Add tilemaps
    add(level.floorTiles);
    add(level.holeTiles);
    add(level.wallTiles);

    // Draw mirrors first
    mirrors = new FlxGroup();
    add(mirrors);

    // Load player objects
    level.loadObjects(onAddObject);

  }

  override public function update():Void {
    if(menuButton()) {
      FlxG.switchState(new LevelSelectMenuState());
    }

    if(!Character.PUSH()){
      mirrorToPull = null;
    }

    super.update();


    // Collide player with holes and walls
    level.collideWithLevel(player, false);

    //Collide with mirrors - don't let player walk through mirrors
    FlxG.overlap(player, mirrors, null, function(player : Character, mirror : Mirror) {

      xOffset = player.x - mirror.x;
      yOffset = player.y - mirror.y;

      if(Character.ROT_CLOCKWISE()) {
        mirror.rotateClockwise();
      }
      if(Character.ROT_C_CLOCKWISE()) {
        mirror.rotateCounterClockwise();
      }

      //Prevent the mirrors from moving if push button isn't held
      if(Character.PUSH()) {
        mirror.immovable = false;
        mirrorToPull = mirror;
      } else {
        mirror.immovable = true;
        mirrorToPull = null;
      }

      //Push the mirror
      return FlxObject.separate(player, mirror);


    });

    if((mirrorToPull != null) && Character.PUSH()){
      trace('YO');
      trace(player.getDirection());
      if(player.getDirection().equals(Direction.Left) && (player.x < mirrorToPull.x)){
        trace("LEFT");
        mirrorToPull.x = player.x - xOffset;
      }
      else if (player.getDirection().equals(Direction.Right) && (player.x > mirrorToPull.x)){
        trace("RIGHT");
        mirrorToPull.x = player.x - xOffset;
      }
      else if (player.getDirection().equals(Direction.Up) && (player.y < mirrorToPull.y)){
        trace("UP");
        mirrorToPull.y = player.y - yOffset;
      }
      else if (player.getDirection().equals(Direction.Down) && (player.y > mirrorToPull.y) ){
        trace("DOWN");
        mirrorToPull.y = player.y - yOffset;
      }
    }


//Collide mirrors with walls and holes, check for mirror rotation
    mirrors.forEachOfType(FlxObject,
      function(mirror : FlxObject){
        level.collideWithLevel(mirror, true);
      }
    );

    //Re-collide player with mirrors to prevent player from moving past mirror that can't move
    FlxG.collide(player, mirrors);

  }

  public function getElementAt(row : Int, col : Int) : Element {
    return null;
  }

  public function onAddObject(o : TiledObject, g : TiledObjectGroup, x : Int, y : Int) {
    switch (o.type.toLowerCase()) {
      case "player_start":
        var player = new Character(level, x, y, o);
        FlxG.camera.follow(player);
        this.player = player;
        add(player);

      case "mirror":
        var mirror = new Mirror(level, x, y, o);
        mirrors.add(mirror);

      case "exit":
        // Create the level exit
        var exit = new FlxSprite(x, y);
        exit.makeGraphic(32, 32, 0xff3f3f3f);
        exit.exists = false;
        this.exit = exit;
        add(exit);
    }
  }
}
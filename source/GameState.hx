package;

import elements.Mirror;
import elements.Character;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;

class GameState extends FlxState
{

  private static var menuButton = function() { return FlxG.keys.justPressed.ESCAPE; };

  @final private var levelPath : Dynamic;
  public var level:TiledLevel;

  public var coins:FlxGroup;
  public var player:Character;
  public var floor:FlxObject;
  public var exit:FlxSprite;
  public var mirrors:FlxGroup;

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

    super.update();

    // Collide with foreground tile layer
    level.collideWithLevel(player, false);

    FlxG.overlap(exit, player, win);

    if (FlxG.overlap(player, floor))
    {
      youDied = true;
      FlxG.resetState();
    }
  }

  public function win(Exit:FlxObject, Player:FlxObject):Void {
    player.kill();
  }

  public function getCoin(Coin:FlxObject, Player:FlxObject):Void {
    Coin.kill();
    if (coins.countLiving() == 0)
    {
      exit.exists = true;
    }
  }

  public function onAddObject(o : TiledObject, g : TiledObjectGroup, x : Int, y : Int) {
    trace("processing " + o.type);
    switch (o.type.toLowerCase()) {
      case "player_start":
        var player = new Character(level, x, y, o);
        FlxG.camera.follow(player);
        this.player = player;
        add(player);

      case "mirror":
        var tileset = g.map.getGidOwner(o.gid);
        var mirror = new Mirror(level, x, y, o);
        mirror.loadGraphic("assets/images/mirror_img.png");
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
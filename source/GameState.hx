package;

import elements.Mirror;
import elements.Character;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

class GameState extends FlxState
{
  public var level:TiledLevel;

  public var coins:FlxGroup;
  public var player:FlxSprite;
  public var floor:FlxObject;
  public var exit:FlxSprite;
  public var mirrors:FlxGroup;

  private static var youDied:Bool = false;

  override public function create():Void
  {
    FlxG.mouse.visible = false;

//super.create();
    bgColor = 0xffaaaaaa;

// Load the level's tilemaps
    level = new TiledLevel(AssetPaths.level0__tmx);

// Add tilemaps
    add(level.collidableTiles);

// Add background tiles after adding level objects, so these tiles render on behind player, but on top of collidable tiles
    add(level.backgroundTiles);

// Draw mirrors first
    mirrors = new FlxGroup();
    add(mirrors);

// Load player objects
    level.loadObjects(onAddObject);

// Add background tiles after adding level objects, so these tiles render on top of player
    add(level.foregroundTiles);

  }

  override public function update():Void {
    super.update();

    // Collide with foreground tile layer
    level.collideWithLevel(player);

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
    switch (o.type.toLowerCase()) {
      case "player_start":
        var player = new Character(level, x, y, o);
        FlxG.camera.follow(player);
        this.player = player;
        add(player);

      case "floor":
        var floor = new FlxObject(x, y, o.width, o.height);
        this.floor = floor;

      case "mirror":
        trace("got mirror");
        var tileset = g.map.getGidOwner(o.gid);
        trace(TiledLevel.c_PATH_LEVEL_TILESHEETS);
        trace(tileset.imageSource);
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
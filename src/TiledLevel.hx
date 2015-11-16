package ;
import elements.Direction;
import flixel.FlxBasic;
import haxe.io.Path;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTileSet;

typedef Loc = {row : Int, col : Int};

/**
 * @author Samuel Batista
 */
class TiledLevel extends TiledMap {

  @final public inline static var FLOOR_LAYER_NAME = "Floor";
  @final public inline static var HOLE_LAYER_NAME = "Holes";
  @final public inline static var WALL_LAYER_NAME = "Walls";
  @final public inline static var TUTORIAL_LAYER_NAME = "Tutorial Images";

  @final public var state : GameState;

  private var tileMaps : Array<FlxTilemap>;

  public var floorTiles(default, null) : FlxGroup;
  public var floorMap(default, null) : FlxTilemap;
  public var holeTiles(default, null) : FlxGroup;
  private var holeMap(default, null) : FlxTilemap;
  public var wallTiles(default, null) : FlxGroup;
  private var wallMap(default, null) : FlxTilemap;
  public var tutorialTiles(default, null) : FlxGroup;

  private var walkableTileWidth : Int;
  private var walkableTileHeight : Int;
  private var walkableImagePath : String;
  public var walkableMap : FlxTilemap;

  /** For non -1 gids, upper 4 bits are flags for flipping. Remove those bits for regular Gid */
  public static function fixGid(gid : Int) : Int {
    return gid == -1 ? -1 : gid & 0x3fffffff;
  }

  /** Does correct horizontal flipping detection. Built in cast doesn't handle non-1 true values correctly.
   * Use this instead of o.flippedHorizontally.
   **/
  public static function isFlippedX(o : TiledObject) : Bool {
    return o.gid != -1 && o.gid & TiledObject.FLIPPED_HORIZONTALLY_FLAG != 0;
  }

  /** Does correct horizontal flipping detection. Built in cast doesn't handle non-1 true values correctly.
   * Use this instead of o.flippedVertically.
   **/
  public static function isFlippedY(o : TiledObject) : Bool {
    return o.gid != -1 && o.gid & TiledObject.FLIPPED_VERTICALLY_FLAG != 0;
  }

  public function new(state : GameState, tiledLevel:Dynamic) {
    super(tiledLevel);

    this.state = state;

    tileMaps = new Array<FlxTilemap>();
    floorTiles = new FlxGroup();
    holeTiles = new FlxGroup();
    wallTiles = new FlxGroup();
    tutorialTiles = new FlxGroup();

    FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);

    // Load Tile Maps
    for (tileLayer in layers) {
      var tileSheetName:String = tileLayer.properties.get("tileset");

      if (tileSheetName == null)
        if(PMain.DEBUG_MODE) throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";

      var tileSet:TiledTileSet = null;
      for (ts in tilesets) {
        if (ts.name == tileSheetName) {
          tileSet = ts;
          break;
        }
      }

      if (tileSet == null)
        if(PMain.DEBUG_MODE) throw "Tileset '" + tileSheetName + " not found. Did you mispell the 'tilesheet' property in " + tileLayer.name + "' layer?";

      var imagePath = new Path(tileSet.imageSource);
      var processedPath = AssetPaths.IMAGE_ROOT + imagePath.file + "." + imagePath.ext;

      var tilemap:FlxTilemap = new FlxTilemap();
      var fixedArray = tileLayer.tileArray.map(function(i) {
        var v = tileSet.fromGid(i);
        return v > 0 ? v : -1;
      });

      tilemap.widthInTiles = width;
      tilemap.heightInTiles = height;
      tilemap.loadMap(fixedArray, processedPath, tileSet.tileWidth, tileSet.tileHeight, 0, 1, 1, 1);

      tileMaps.push(tilemap);

      switch(tileLayer.name) {
        case FLOOR_LAYER_NAME:
          floorTiles.add(tilemap);
          floorMap = tilemap;
          walkableImagePath = processedPath;
          walkableTileWidth = tileSet.tileWidth;
          walkableTileHeight = tileSet.tileHeight;

        case HOLE_LAYER_NAME:
          holeTiles.add(tilemap);
          holeMap = tilemap;

        case WALL_LAYER_NAME:
          wallTiles.add(tilemap);
          wallMap = tilemap;

        case TUTORIAL_LAYER_NAME:
          tutorialTiles.add(tilemap);

        default:
          throw "Unexpected tilelayer name " + tileLayer.name;
      }
    }


    walkableMap = new FlxTilemap();
    walkableMap.widthInTiles = width;
    walkableMap.heightInTiles = height;

    var arr : Array<Int> = new Array<Int>();
    for(r in 0...height) {
      for(c in 0...width) {
        arr.push(isWalkable(c, r) ? 1 : -1);
      }
    }

    walkableMap.loadMap(arr, walkableImagePath, walkableTileWidth, walkableTileHeight, 0, 1, 1, 1);
    walkableMap.setTileProperties(1, FlxObject.NONE);
  }

  public function loadObjects(processCallback:TiledObject->TiledObjectGroup->Void) {
    for (group in objectGroups) {
      for (o in group.objects) {
        loadObject(o, group, processCallback);
      }
    }
  }

  private function loadObject(o:TiledObject, g:TiledObjectGroup, processCallback:TiledObject->TiledObjectGroup->Void) {
    // objects in tiled are aligned bottom-left (top-left in flixel)
    if (o.gid != -1) {
      o.y -= g.map.getGidOwner(fixGid(o.gid)).tileHeight;
    }

    processCallback(o, g);
  }

  public function collideWithLevel(objOrGroup:FlxBasic, collideWithHoles : Bool = true, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool {

    // IMPORTANT: Always collide the map with objects, not the other way around.
    // 			  This prevents odd collision errors (collision separation code off by 1 px).
    var b = false;
    if (holeTiles != null && collideWithHoles) {
        b = FlxG.overlap(holeMap, objOrGroup, notifyCallback, processCallback != null ? processCallback : FlxObject.separate) || b;
    }
    if (wallTiles != null) {
        b = FlxG.overlap(wallMap, objOrGroup, notifyCallback, processCallback != null ? processCallback : FlxObject.separate) || b;
    }
    return b;
  }

  public function hasFloorAt(x : Int, y : Int) : Bool {
    return floorMap.getTile(x,y) != -1;
  }

  public function hasHoleAt(x : Int, y : Int) : Bool {
    return holeMap.getTile(x,y) != -1;
  }

  public function isWalkable(x : Int, y : Int) : Bool {
    return hasFloorAt(x, y) || hasHoleAt(x, y);
  }

  public function hasWallAt(x : Int, y : Int) : Bool {
    return wallMap.getTile(x,y) != -1;
  }

  public function updateBuffers() : Void {
    for(tilemap in tileMaps) {
      tilemap.updateBuffers();
    }
  }

  //Return the highest tile index number of a FlxTilemap
  public static function getMaxTileIndex(map : FlxTilemap) : Int {
    var max = 0;
    for (index in map.getData().iterator()){
      if (index > max){
        max = index;
      }
    }
    return max;
  }

  /** Return an array of cardinal directions from here tile to the destination tile.
   * On the walkableMap
   **/
  public function shortestPath(startRow : Int, startCol : Int, endRow : Int, endCol : Int) : Array<Direction> {
    if(startRow < 0 || startRow >= walkableMap.heightInTiles || startCol < 0 || startCol >= walkableMap.widthInTiles
    || endRow < 0 || endRow >= walkableMap.heightInTiles || endCol < 0 || endCol >= walkableMap.widthInTiles) {
      trace("Can't find shortest path from (" + startRow + "," + startCol + ") to (" + endRow + "," + endCol + ") - OOB");
      return null;
    }

    if(! isWalkable(startCol, startRow) || ! isWalkable(endCol, endRow) ||
       ! state.isSpaceWalkable(startRow, startCol) || ! state.isSpaceWalkable(endRow, endCol)) {
      trace("Can't find shortest path from (" + startRow + "," + startCol + ") to (" + endRow + "," + endCol + ") - invalid start/end");
      return null;
    }

    if (startRow == endRow && startCol == endCol) {
      return [];
    }

    var directionArray = [Direction.Up, Direction.Right, Direction.Down, Direction.Left];

    var distVals : Array<Array<Int>> = new Array<Array<Int>>();
    var prev : Array<Array<Loc>> = new Array<Array<Loc>>();
    for(r in 0...walkableMap.heightInTiles) {
      distVals.push(new Array<Int>());
      prev.push(new Array<Loc>());
      for(c in 0...walkableMap.widthInTiles) {
        distVals[r].push(walkableMap.totalTiles + 1); //This is effectively max val - no path can take this many tiles
        prev[r].push(null);
      }
    }

    distVals[startRow][startCol] = 0;
    var pQueue = new Array<Loc>();
    pQueue.push({row:startRow, col:startCol});

    while(pQueue.length > 0) {
      pQueue.sort(function(a : Loc, b : Loc){return distVals[b.row][b.col] - distVals[a.row][a.col];});
      var currentLoc : Loc = pQueue.pop(); //Pop removes from the end. WTF?

      //Handle end case - found path. Assemble direction array and return
      if(currentLoc.row == endRow && currentLoc.col == endCol) {
        var arr : Array<Direction> = new Array<Direction>();
        var loc = currentLoc;
        while(loc.row != startRow || loc.col != startCol) {
          var prevLoc = prev[loc.row][loc.col];
          arr.insert(0, Direction.getDirection(loc.col - prevLoc.col, loc.row - prevLoc.row));
          loc = prevLoc;
        }
        return arr;
      }

      var currentDist = distVals[currentLoc.row][currentLoc.col];
      for(d in directionArray) {
        var destLoc : Loc = {row: Std.int(d.y) + currentLoc.row, col: Std.int(d.x) + currentLoc.col};
        var destDist = distVals[destLoc.row][destLoc.col];
        if(isWalkable(destLoc.col, destLoc.row) && currentDist + 1 < destDist && state.isSpaceWalkable(destLoc.row, destLoc.col)) {
          distVals[destLoc.row][destLoc.col] = currentDist + 1;
          prev[destLoc.row][destLoc.col] = currentLoc;
          pQueue.push(destLoc);
        } else {
        }
      }
    }

    //No path found
    return null;
  }

}
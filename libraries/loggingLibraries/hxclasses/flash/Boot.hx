package flash;

@:keep extern class Boot extends flash.display.MovieClip {
	function new() : Void;
	static var skip_constructor : Bool;
	static function __clear_trace() : Void;
	@:has_untyped static function __instanceof(v : Dynamic, t : Dynamic) : Bool;
	static function __set_trace_color(rgb : UInt) : Void;
	@:has_untyped static function __string_rec(v : Dynamic, str : String) : String;
	static function __trace(v : Dynamic, pos : haxe.PosInfos) : Void;
	static function enum_to_string(e : {tag : String, params : Array<Dynamic>}) : String;
	@:has_untyped static function filterDynamic(d : Dynamic, f : Dynamic) : Unknown;
	static function getTrace() : flash.text.TextField;
	@:has_untyped static function mapDynamic(d : Dynamic, f : Dynamic) : Unknown;
}

package logging;
extern class Logging {
  function new() : Void;
  function initialize(p1 : UInt, p2 : UInt, p3 : Bool) : Void;
  function recordABTestValue(p1 : UInt) : UInt;
  function recordEvent(p1 : UInt, ?p2 : String) : Void;
  function recordLevelEnd() : Void;
  function recordLevelStart(p1 : Float, ?p2 : String) : Void;
  function recordPageLoad(?p1 : String) : Void;
  static function getSingleton() : Logging;
}
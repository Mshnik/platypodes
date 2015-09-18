package ;
import elements.Character;
class DummyLevel extends Level{

  public function new() {
    super(8, 15);
  }

  override public function create() {
    super.create();

    var character = new Character(this, 0, 0);
    add(character);
    onAddElement(character);
  }

}

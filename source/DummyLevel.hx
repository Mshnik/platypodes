package ;
import elements.Character;
class DummyLevel extends AbsLevel{

  override public function create() {
    set_rows(8);
    set_cols(8);

    super.create();

    var character = new Character(this, 0, 0);
    add(character);
    onAddElement(character);
  }

}

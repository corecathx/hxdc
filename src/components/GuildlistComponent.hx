package components;

import haxe.ui.containers.VBox;

@:build(haxe.ui.ComponentBuilder.build("assets/custom/guildlist.xml"))
class GuildlistComponent extends VBox {
    public function new(name:String, id:String) {
        super();
        this.id = id;
        chatname.text = name;
    }
}
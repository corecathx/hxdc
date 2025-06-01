package components;

import haxe.ui.containers.VBox;

@:build(haxe.ui.ComponentBuilder.build("assets/custom/serverlist.xml"))
class ServerlistComponent extends VBox {
    public function new(resURL:String, id:String) {
        super();
        this.id = id;

        pfp.resource = resURL;
    }
}
package components;

import haxe.ui.events.MouseEvent;
import haxe.ui.containers.TreeViewNode;
import haxe.ui.containers.VBox;

@:build(haxe.ui.ComponentBuilder.build("assets/custom/channelgroup.xml"))
class ChannelgroupComponent extends VBox {
    var rootwawa:TreeViewNode;
    public function new(name:String) {
        super();
        rootwawa = treewawa.addNode({text:name});
        rootwawa.expanded = true;
    }

    public function addChannel(a:String, call:MouseEvent->Void) {
        var c:TreeViewNode = rootwawa.addNode({text:a,icon:"res/icons/hashtag.png"});
        c.onClick = call;
    }
}
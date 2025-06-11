package components;

import sys.thread.Thread;
import haxe.ui.events.UIEvent;
import haxe.ui.components.Image;
import hxdiscord.types.structTypes.Attachment;
import haxe.ui.containers.VBox;

using StringTools;
@:build(haxe.ui.ComponentBuilder.build("assets/custom/message.xml"))
class MessageComponent extends VBox {
    public function new(usn:String, msg:String, img:String = "", attachments:Array<Attachment>, lastSender:String = "", timewawa:String = "") {
        super();
        username.text = usn;
        message.text = msg;
        timestamp.text = Utils.formatISOTimestamp(timewawa);

        if (message.text.trim() == ""){
            removeComponent(message);
        }
        profile.resource = img;

        if (lastSender == usn) {
            removeComponent(username);
            removeComponent(profile);
        }
        //Thread.create(()->{
            for (i in attachments) {
                var ui:Image = new Image();
                ui.resource = i.proxy_url;
                atchContainer.addComponent(ui);
    
                //trace(ui.resource);
                ui.registerEvent(UIEvent.CHANGE, (_)->{
                    //trace(ui.originalWidth + " // " +  ui.originalHeight);
                    var ratio:Float = ui.originalHeight / ui.originalWidth;
    
                    var targetWidth:Float = 500;
                    var targetHeight:Float = targetWidth * ratio;
                    
                    ui.width = targetWidth;
                    ui.applyStyle({
                        width: targetWidth,
                        height: targetHeight
                    });
                    
                });
            }
        //});
    }
}
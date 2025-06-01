package views;

import haxe.ui.HaxeUIApp;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.VBox;
using StringTools;

@:build(haxe.ui.ComponentBuilder.build("assets/login-view.xml"))
class LoginView extends VBox {
    public function new() {
        super();
        loginButton.onClick = (_) -> {
            if (tokenInput.text == "") {
                Dialogs.messageBox("That token looks empty, isn't it? Because it is.", "Error", "error");
                return;
            }
            Config.instance.token = tokenInput.text;
            Config.save();
            Discord.init();

            // eh idk if this is how to change views or not lols
            HaxeUIApp.instance.removeComponent(this);
            HaxeUIApp.instance.addComponent(new MainView());
        }
    }
}
package;

import views.MainView;
import views.LoginView;

import haxe.ui.notifications.NotificationType;
import haxe.ui.notifications.NotificationManager;
import haxe.Timer;
import haxe.ui.containers.dialogs.Dialogs;
import components.WindowComponent;
import lime.app.Application;
import haxe.ui.Toolkit;
import haxe.ui.HaxeUIApp;
class Main {
    public static var discord:Discord;
    public static function main() {
        #if !hxdc
        discord = new Discord();
        discord.client.connect();
        #else
        Toolkit.theme = "dark";
        Application.current.window.stage.color = 0x202020;
        var app = new HaxeUIApp();
        app.ready(function() {
            // we need to check if internet connection is present.
            var onConnect:Void->Void = ()->{
                //app.addComponent(new WindowComponent());
                Config.load();
                if (Config.instance.token == "") {
                    app.addComponent(new LoginView());
                } else {
                    Config.save();
                    Discord.init();
                    app.addComponent(new MainView());
                }
                app.start();
                Dialogs.messageBox(
                    'This is an unofficial Discord client. Using it violates Discord\'s Terms of Service, which can result in your account being permanently banned.\n\nProceeding means you accept full responsibility for any consequences, including account loss.\n\nI am not responsible for any damages.',
                    'Heads Up!',
                    'warning'
                );
            }
            var wa:Timer = new Timer(5000);
            var retryTime:Int = 0;
            var checkNet:Void->Void = ()->{
                if (Utils.hasNetwork()) {
                    onConnect();
                    NotificationManager.instance.addNotification({
                        title: "HXDC",
                        body: "Connecting...",
                        type: NotificationType.Info
                    });
                    wa.stop();
                } else {
                    retryTime++;
                    NotificationManager.instance.addNotification({
                        title: "HXDC",
                        body: "Could not connect to Discord, do you have internet connection?\n\nRetrying in 5 seconds."+(retryTime>10?"\n\n(If it still doesn't work, try restarting the app.)":""),
                        type: NotificationType.Error
                    });
                }
            }
            wa.run = checkNet;
        });
        #end
    }
}

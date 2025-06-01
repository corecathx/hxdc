package views;

import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.Dialog;
import sys.io.File;
import haxe.ui.components.SectionHeader;
import components.ChannelgroupComponent;
import haxe.ui.events.UIEvent;
import components.ServerlistComponent;
import haxe.Timer;
import haxe.ui.notifications.NotificationType;
import haxe.ui.notifications.NotificationManager;
import haxe.Json;
import hxdiscord.types.structTypes.MessageS;
import haxe.ui.core.Component;
import hxdiscord.types.structTypes.Guild;
import components.MessageComponent;
import components.GuildlistComponent;

import haxe.ui.ComponentBuilder;
import hxdiscord.types.Message;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
using StringTools;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {
    public var currentAttachments:Array<SelectedFileInfo> = [];
    public function new() {
        super();
        Main.discord.client.onMessageCreate = onMessageCreate;
        Main.discord.client.onGuildUpdate = (g:Guild) -> {
            trace(g);
        }

        Main.discord.client.onReady = () ->{
            userpfp.resource =  Utils.getUserPfp(Main.discord.client.user);
            userName.text = Utils.getDisplayName(Main.discord.client.user);
            userHandle.text = "@" + Main.discord.client.username;
            
            trace("We're ready.");
            NotificationManager.instance.addNotification({
                title: "HXDC",
                body: "Connected, Hello " + userName.text + "!",
                type: NotificationType.Success
            });
            fetchUntilFound();
        }

        fetchUntilFound();
        sendbutton.onClick = (_) -> {
            Main.discord.sendMessage(Main.discord.currentChannel, messagebox.text, ()->{
                NotificationManager.instance.addNotification({
                    title: "HXDC [debug]",
                    body: "Message send to " + Main.discord.currentChannel,
                    type: NotificationType.Success
                });
                messagebox.text = "";
            }, (m)->{
                NotificationManager.instance.addNotification({
                    title: "HXDC [debug]",
                    body: "Error occured: " + m,
                    type: NotificationType.Error
                });
            });
        }

        atButton.onClick = (_) -> {
            Dialogs.openBinaryFile("Select a file.", FileDialogTypes.ANY, (file:SelectedFileInfo) -> {
                currentAttachments.push(file);
            });
        }
    }

    public function fetchUntilFound() {
        if (Main.discord.isBot) {
            if (Lambda.count(Main.discord.client.cache.guilds) > 0) {
                NotificationManager.instance.addNotification({
                    title: "HXDC [debug]",
                    body: "Found guildlist. ",
                    type: NotificationType.Success
                });
                updateServerList();
            } else {
                trace("Guild list isn't updated yet..");
                Timer.delay(fetchUntilFound, 1000);
            }
        } else {
            Main.discord.getUserGuilds((data:String) -> {
                var guilds:Array<Dynamic> = Json.parse(data);

                var remaining = guilds.length;
                for (g in guilds) {
                    Main.discord.getGuildChannels(g.id, (channels) -> {
                        g.channels = channels;
                        Main.discord.client.cache.guilds.set(g.id, g);
                        remaining--;
                        if (remaining <= 0)
                            updateServerList(); 
                    }, (err) -> {
                        trace("Failed to load channels for " + g.name + ": " + err);
                        remaining--;
                        if (remaining <= 0) {
                            updateServerList();
                        }
                    });
                }
            }, (err) -> {
                trace("Couldn't fetch guilds: " + err);
            });
        }
    }
    

    public function onMessageCreate(msg:Message) {
        if (msg.guild_id == Main.discord.currentGuild && msg.channel_id == Main.discord.currentChannel)
            addMessage(msg);
        //trace(Main.discord.client.cache.guilds);
    }

    var lastUsn:String = "";
    function addMessage(msg:Message) {
        var avatar:String = Utils.getUserPfp(msg.author);
        var com:MessageComponent = new MessageComponent(Utils.getDisplayName(msg.author), msg.content, avatar, msg.attachments, lastUsn, msg.timestamp);
        com.id = "MESSAGE"+chatlist.childComponents.length;
        chatlist.addComponent(com);

        //trace(chatscroller.vscrollPos + " // " + chatscroller.vscrollMax);
        chatscroller.vscrollPos = chatscroller.vscrollMax;

        //lastUsn = usn;
    }

    inline function clear(c:Component) {
        while (c.childComponents.length > 0) {
            c.removeComponent(c.childComponents[0]);
        } 
    }
    public function updateServerList() {
        clear(serverContainer);
        var g = Main.discord.client.cache.guilds;
        for (i in g.keys()) {
            var a = g[i];
            if (a == null) continue;
            ///trace(a.icon);
            //var aicon:String = "";
            //if (a.icon == null)
            //    aicon = '${a.icon}.${a.icon.startsWith("a_") ? "gif" : "png"}';
            var iconURL = 'https://cdn.discordapp.com/icons/${a.id}/${a.icon}.png';

            //trace(iconURL);
            var com:ServerlistComponent = new ServerlistComponent(iconURL,a.id);
            com.onClick = (m:MouseEvent) -> {
                clear(chatlist);
                lastUsn = "";
                Main.discord.currentChannel = "";
                Main.discord.currentGuild = a.id;
                //trace(a.id);
                updateChannelList(a.id);
            }
            serverContainer.addComponent(com);
        }
    }
    public function updateChannelList(srvId:String) {
        //remember: 0 is text channel, 2 is voice channel, 4 is category
        clear(sidebar);
        var g = Main.discord.client.cache.guilds;
        var a = g[srvId];
        var c:Array<Dynamic> = a.channels;
        
        //var json:String = Json.stringify(c);
        //File.saveContent("./file.json",json);
        var categories:Map<String, SectionHeader> = new Map();

        for (z in c) {
            if (z.type == 4) {
                var cg = new SectionHeader();
                cg.text = z.name;
                sidebar.addComponent(cg);
                categories.set(z.id, cg);
            }
        }
        
        for (z in c) {
            if (z.type == 0 || z.type == 2) {
                var parent = z.parent_id;
                var com = new GuildlistComponent(z.name, z.id);
                com.onClick = (_) -> {
                    channelname.text = z.name;
                    channeldesc.text = z.topic != null ? z.topic : "";
                    messagebox.placeholder = "Message #"+z.name;
                    lastUsn = "";
                    clear(chatlist);
                    Main.discord.currentChannel = z.id;
                    Main.discord.getMessage(z.id, (data:String) -> {
                        var messages:Array<MessageS> = Json.parse(data);
                        messages.reverse();
                        for (m in messages) addMessage(Main.discord.client.nMessage(m, m));
                    }, (_) -> trace('fail ' + _));
                };
        
                if (categories.exists(parent)) {
                    categories.get(parent).addComponent(com); // put under its category
                } else {
                    sidebar.addComponent(com); // fallback: no parent
                }
            }
        }
    }
}
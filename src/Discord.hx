package;

import openfl.net.URLLoaderDataFormat;
import hxdiscord.types.Guild;
import hxdiscord.types.Message;
import hxdiscord.utils.Intents;
import hxdiscord.DiscordClient;

import openfl.net.URLRequest;
import openfl.net.URLLoader;
import openfl.net.URLRequestHeader;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import haxe.Json;

class Discord {
    public static var instance:Discord;
    public var client:DiscordClient;
    public var currentChannel:String = "";
    public var currentGuild:String = "";
    public var isBot:Bool = false;

    public static function init():Void {
        instance = new Discord();
        instance.client.connect();
        Main.discord = instance; // just reference this one.
    }
    public function new() {
        DiscordClient.isBot = isBot;
        client = new DiscordClient(Config.instance.token, [Intents.ALL], false);
        DiscordClient.authHeader = (isBot?"Bot " : "") + Config.instance.token;
    }

    public function getMessage(channelID:String, onSuccess:Dynamic->Void, onError:String->Void):Void {
        
        var url = 'https://discord.com/api/v10/channels/' + channelID + '/messages';
        var request = new URLRequest(url);
        request.method = "GET";
    
        request.requestHeaders.push(new URLRequestHeader("Authorization", DiscordClient.authHeader));
        request.requestHeaders.push(new URLRequestHeader("User-Agent", "hxdc (https://github.com/corecathx/hxdc)"));
        request.requestHeaders.push(new URLRequestHeader("Content-Type", "application/json"));
    
        var loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;
    
        loader.addEventListener(Event.COMPLETE, function(e:Event) {
            //try {
                onSuccess(loader.data.toString());
            //} catch (err:Dynamic) {
                //onError('Failed to parse JSON: ' + err);
           // }
        });
    
        loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) {
            onError('Request failed: ' + e.text);
        });
    
        loader.load(request);
    }

    public function sendMessage(channelID:String, content:String, onSuccess:Void->Void, onError:String->Void):Void {
        
        
        var url = 'https://discord.com/api/v10/channels/' + channelID + '/messages';
        var request = new URLRequest(url);
        request.method = "POST";

        request.requestHeaders.push(new URLRequestHeader("Authorization", DiscordClient.authHeader));
        request.requestHeaders.push(new URLRequestHeader("User-Agent", "hxdc (https://github.com/corecathx/hxdc)"));
        request.requestHeaders.push(new URLRequestHeader("Content-Type", "application/json"));
    
        var messagePayload = Json.stringify({
            content: content
        });
        request.data = messagePayload;
    
        var loader = new URLLoader();
    
        loader.addEventListener(Event.COMPLETE, function(e:Event) {
            onSuccess();
        });
    
        loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) {
            onError('Failed to send message: ' + e.text);
        });
    
        loader.load(request);
    }
 
    /**
     * most of these functions below this comment are used for user token support brah :wilted_flower:
     */

    public function getUserGuilds(onSuccess:Dynamic->Void, onError:String->Void):Void {
        var url = 'https://discord.com/api/v10/users/@me/guilds';
        var request = new URLRequest(url);
        request.method = "GET";
    
        request.requestHeaders.push(new URLRequestHeader("Authorization", DiscordClient.authHeader));
        request.requestHeaders.push(new URLRequestHeader("User-Agent", "hxdc (https://github.com/corecathx/hxdc)"));
        request.requestHeaders.push(new URLRequestHeader("Content-Type", "application/json"));
    
        var loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;
    
        loader.addEventListener(Event.COMPLETE, function(e:Event) {
            onSuccess(loader.data.toString());
        });
    
        loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) {
            onError('Failed to fetch guilds: ' + e.text);
        });
    
        loader.load(request);
    }
    
    public function getGuildChannels(guildId:String, onSuccess:Array<Dynamic>->Void, onError:String->Void):Void {
        
        
        var url = 'https://discord.com/api/v10/guilds/$guildId/channels';
        var request = new URLRequest(url);
        request.method = "GET";
    
        request.requestHeaders.push(new URLRequestHeader("Authorization", DiscordClient.authHeader));
        request.requestHeaders.push(new URLRequestHeader("User-Agent", "hxdc (https://github.com/corecathx/hxdc)"));
        request.requestHeaders.push(new URLRequestHeader("Content-Type", "application/json"));
    
        var loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;
    
        loader.addEventListener(Event.COMPLETE, function(e:Event) {
            try {
                var data:Array<Dynamic> = Json.parse(loader.data.toString());
                onSuccess(data);
            } catch (err:Dynamic) {
                onError('Failed to parse channels: ' + err);
            }
        });
    
        loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) {
            onError('Failed to fetch channels: ' + e.text);
        });
    
        loader.load(request);
    }

    public function setUserStatus(text:String, ?emoji:String, ?expiresAt:String, ?onSuccess:Void->Void, ?onError:String->Void):Void {
        
        
        var url = 'https://discord.com/api/v6/users/@me/settings';
        var request = new URLRequest(url);
        request.method = "PATCH";
    
        request.requestHeaders.push(new URLRequestHeader("Authorization", DiscordClient.authHeader));
        request.requestHeaders.push(new URLRequestHeader("User-Agent", "hxdc (https://github.com/corecathx/hxdc)"));
        request.requestHeaders.push(new URLRequestHeader("Content-Type", "application/json"));
    
        var payload:Dynamic = {
            custom_status: {
                text: text
            }
        };
    
        if (emoji != null) payload.custom_status.emoji_name = emoji;
        if (expiresAt != null) payload.custom_status.expires_at = expiresAt;
    
        request.data = Json.stringify(payload);
    
        var loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;
    
        loader.addEventListener(Event.COMPLETE, function(e:Event) {
            if (onSuccess != null) onSuccess();
        });
    
        loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) {
            if (onError != null) onError('Failed to set status: ' + e.text);
        });
    
        loader.load(request);
    }

    public function getGuildMember(guildId:String, userId:String, onSuccess:Dynamic->Void, onError:String->Void):Void {
        var url = 'https://discord.com/api/v10/guilds/$guildId/members/$userId';
        var request = new URLRequest(url);
        request.method = "GET";
    
        request.requestHeaders.push(new URLRequestHeader("Authorization", DiscordClient.authHeader));
        request.requestHeaders.push(new URLRequestHeader("User-Agent", "hxdc (https://github.com/corecathx/hxdc)"));
        request.requestHeaders.push(new URLRequestHeader("Content-Type", "application/json"));
    
        var loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;
    
        loader.addEventListener(Event.COMPLETE, function(e:Event) {
            try {
                var data:Dynamic = Json.parse(loader.data.toString());
                onSuccess(data);
            } catch (err:Dynamic) {
                onError('Failed to parse member data: ' + err);
            }
        });
    
        loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) {
            onError('Failed to fetch member data: ' + e.text);
        });
    
        loader.load(request);
    }
    
}


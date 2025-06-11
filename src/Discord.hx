package;

import openfl.net.*;
import openfl.events.*;
import haxe.Json;

import hxdiscord.types.Guild;
import hxdiscord.types.Message;
import hxdiscord.utils.Intents;
import hxdiscord.DiscordClient;

class Discord {
    public static var instance:Discord;
    public var client:DiscordClient;
    public var currentChannel:String = "";
    public var currentGuild:String = "";
    public var isBot:Bool = false;

    public static function init():Void {
        instance = new Discord();
        instance.client.connect();
        Main.discord = instance;
    }

    public function new() {
        DiscordClient.isBot = isBot;
        client = new DiscordClient(Config.instance.token, [Intents.ALL], false);
        DiscordClient.authHeader = (isBot ? "Bot " : "") + Config.instance.token;
    }

    private function makeRequest(method:String, url:String, ?data:Dynamic, onSuccess:String->Void, onError:String->Void):Void {
        var request:URLRequest = new URLRequest(url);
        request.method = method;
        request.requestHeaders = [
            new URLRequestHeader("Authorization", DiscordClient.authHeader),
            new URLRequestHeader("User-Agent", "hxdc (https://github.com/corecathx/hxdc)"),
            new URLRequestHeader("Content-Type", "application/json")
        ];

        if (data != null)
            request.data = Json.stringify(data);

        var loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;

        loader.addEventListener(Event.COMPLETE, function(_) {
            onSuccess(loader.data);
        });

        loader.addEventListener(IOErrorEvent.IO_ERROR, function(e) {
            onError('Request failed: ' + e.text);
        });

        loader.load(request);
    }

    public function getMessage(channelID:String, onSuccess:String->Void, onError:String->Void):Void {
        makeRequest("GET", 'https://discord.com/api/v10/channels/$channelID/messages', null, onSuccess, onError);
    }

    public function sendMessage(channelID:String, content:String, onSuccess:Void->Void, onError:String->Void):Void {
        makeRequest("POST", 'https://discord.com/api/v10/channels/$channelID/messages', { content: content }, _ -> onSuccess(), onError);
    }

    public function getUserGuilds(onSuccess:String->Void, onError:String->Void):Void {
        makeRequest("GET", "https://discord.com/api/v10/users/@me/guilds", null, onSuccess, onError);
    }

    public function getGuildChannels(guildId:String, onSuccess:Array<Dynamic>->Void, onError:String->Void):Void {
        makeRequest("GET", 'https://discord.com/api/v10/guilds/$guildId/channels', null, (res) -> {
            try {
                var data:Array<Dynamic> = Json.parse(res);
                onSuccess(data);
            } catch (err:Dynamic) {
                onError('Failed to parse channels: ' + err);
            }
        }, onError);
    }

    public function setUserStatus(text:String, ?emoji:String, ?expiresAt:String, ?onSuccess:Void->Void, ?onError:String->Void):Void {
        var payload:Dynamic = {
            custom_status: {
                text: text
            }
        };
        if (emoji != null) payload.custom_status.emoji_name = emoji;
        if (expiresAt != null) payload.custom_status.expires_at = expiresAt;

        makeRequest("PATCH", 'https://discord.com/api/v6/users/@me/settings', payload, (_) -> if (onSuccess != null) onSuccess(), onError);
    }

    public function getGuildMember(guildId:String, userId:String, onSuccess:Dynamic->Void, onError:String->Void):Void {
        makeRequest("GET", 'https://discord.com/api/v10/guilds/$guildId/members/$userId', null, (res) -> {
            try {
                var data:Dynamic = Json.parse(res);
                onSuccess(data);
            } catch (err:Dynamic) {
                onError('Failed to parse member data: ' + err);
            }
        }, onError);
    }
}

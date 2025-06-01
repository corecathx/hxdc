package;

import haxe.ws.WebSocket;
import sys.net.Host;
import openfl.net.Socket;
import hxdiscord.types.User;

class Utils {
    public static function hasNetwork():Bool {
        try {
            var socket = new Socket("8.8.8.8", 53);
            socket.close();
            return true;
        } catch (e) {
            trace(e);
            return false;
        }
    }
    public static function parseISODate(iso:String):Date {
        var clean:String = iso.split(".")[0];
        var dateTime:Array<String> = clean.split("T");
        if (dateTime.length != 2) throw "Invalid ISO format";

        var datePart:Array<String> = dateTime[0].split("-");
        var timePart:Array<String> = dateTime[1].split(":");

        if (datePart.length != 3 || timePart.length != 3) throw "Invalid ISO format";

        var year:Int = Std.parseInt(datePart[0]);
        var month:Int = Std.parseInt(datePart[1]) - 1;
        var day:Int = Std.parseInt(datePart[2]);

        var hour:Int = Std.parseInt(timePart[0]);
        var minute:Int = Std.parseInt(timePart[1]);
        var second:Int = Std.parseInt(timePart[2]);

        return new Date(year, month, day, hour, minute, second);
    }

    
    public static function formatISOTimestamp(iso:String):String {
        var dt = parseISODate(iso);
        var now = Date.now();

        var sameDay = dt.getFullYear() == now.getFullYear()
            && dt.getMonth() == now.getMonth()
            && dt.getDate() == now.getDate();

        var y = now.getFullYear();
        var m = now.getMonth();
        var d = now.getDate() - 1;
        var yesterday = new Date(y, m, d, 0, 0, 0);

        var isYesterday = dt.getFullYear() == yesterday.getFullYear()
            && dt.getMonth() == yesterday.getMonth()
            && dt.getDate() == yesterday.getDate();

        var hour = dt.getHours();
        var minute = dt.getMinutes();
        var ampm = hour >= 12 ? "PM" : "AM";
        hour = hour % 12;
        if (hour == 0) hour = 12;

        var minuteStr = (minute < 10 ? "0" : "") + minute;
        var timePart = '$hour:$minuteStr $ampm';

        if (sameDay) {
            return timePart;
        } else {
            var month = dt.getMonth() + 1;
            var day = dt.getDate();
            var year = dt.getFullYear();
            return '$month/$day/$year $timePart';
        }
    }
    
    public inline static function getUserPfp(user:User) {
        if (user == null) return "https://cdn.discordapp.com/embed/avatars/0.png";
        return 'https://cdn.discordapp.com/avatars/${user.id}/${user.avatar}.png';
    }

    public inline static function getDisplayName(user:User) {
        return user.global_name != null ? user.global_name : user.username;
    }

    public inline static function getClientTarget():String {
        #if cpp
        return "cpp";
        #elseif cppia
        return "cppia";
        #elseif cs
        return "cs";
        #elseif eval
        return "eval";
        #elseif hl
        return "hl";
        #elseif java
        return "java";
        #elseif js
        return "js";
        #elseif lua
        return "lua";
        #elseif neko
        return "neko";
        #elseif php
        return "php";
        #elseif python
        return "python";
        #elseif swf
        return "swf";
        #end
    }

    public static inline function isDebug() {
        #if debug
        return true;
        #else
        return false;
        #end
    }
}
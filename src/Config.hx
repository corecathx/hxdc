package;

import sys.FileSystem;
import haxe.Json;
import sys.io.File;

@:structInit
class Config {
    public static var instance:Config = {};
    /**
     * User's Discord Account token.
     */
    public var token:String = "";

    /**
     * Saves current configuration to a file.
     */
    public static function save():Void {
        trace("saving");
        var content:String = Json.stringify(instance);
        File.saveContent("./config.json", content);
        trace("ok i guess: " + content);
    }

    
    /**
     * Loads an existing configuration file.
     */
    public static function load():Void {
        trace("loading");
        if (!FileSystem.exists("./config.json")){
            trace("no config :(");
            return;
        }
        var content:String = File.getContent("./config.json");
        instance = fromDynamic(Json.parse(content));
        trace("ooo we got: " + content);
    }

    public static function fromDynamic(data:Dynamic):Config {
        // Uncaught exception: Can't cast dynobj to Config
        // hashlink i swear to god i hate you
        return {
            token: data.token
        }
    }
}
/**
    FOR ANYONE WHO'S READING THIS (i hope so)
    I'M HAVING SOME SERIOUS TROUBLES DOING THIS, COLLABORATIONS ARE HIGHLY APPRECIATED
    I MAY REMOVE THIS AND PRETEND NOTHING HAPPENED

    NOTE (12/03/2023): Don't expect this to be done in a few months or so. I just found out that Discord requires RTP packets, and there are no haxelibs available for it. So I will have to take my own on this
    NOTE (24/03/2023): gotta commit this again because of a grammar issue :sob:, also, i think i've found the solution for the rtp packets, not sure tho
**/

package hxdiscord;

import haxe.ws.WebSocket;
import hxdiscord.DiscordClient;
import sys.net.Host;
import sys.FileSystem;
import sys.net.Address;
import sys.io.File;
import haxe.io.Bytes;
import haxe.Timer;
import haxe.io.BytesOutput;
import sys.net.UdpSocket;
import haxe.crypto.XSalsa20;
//import haxe.crypto.Poly1305;

using StringTools;

/**
    VoiceClient, I'm still working on this so please do not bother using it as it won't work
**/

class VoiceClient {
    var guild_id:String;
    var channel_id:String;
    var session_id:String;
    var websocket:WebSocket;
    var hasCredentials:Bool = false;
    private var client:DiscordClient;
    var buf = haxe.io.Bytes.alloc(1024);
    var hb_interval:Int = 0;
    var user_id:String;
    var hb_timer:Timer;
    var udpConnection:UdpSocket;
    var ip:String = "";
    var port:Int = 0;
    var loop:Timer;
    var socketData:BytesOutput;
    var address:Address;
    var canSendVoiceData:Bool = false;
    var somethingIsPlaying:Bool = false;

    public function new(guild_id:String, channel_id:String, user_id:String) {
        this.guild_id = guild_id;
        this.channel_id = channel_id;
        this.session_id = "";
        this.user_id = user_id;
        /*trace("A new voice client instance has been created");
        trace("Awaiting for the gateway credentials..");*/
    }

    function handleShit(str:String, dyn:Dynamic) {
        trace("kekw");
        var _:String = str;
        var d = dyn;
        var data:Dynamic = haxe.Json.parse(_);
        trace(_);
        switch (data.op) {
            case 8:
                hb_interval = data.d.heartbeat_interval;
                websocket.send(
                    haxe.Json.stringify({
                        op: 0,
                        d: {
                            server_id: this.guild_id,
                            user_id: this.user_id,
                            session_id: this.session_id,
                            token: d.token
                        }
                    })
                );
                websocket.send(haxe.Json.stringify({
                    op: 3,
                    d: null
                }));
                hb_timer = new Timer(this.hb_interval);
                hb_timer.run = function()
                {
                    trace("SENT");
                    websocket.send(haxe.Json.stringify({
                        op: 3,
                        d: null
                    }));
                }
            case 2:
                var data:Dynamic = ipDiscovery(data);
                trace(data);
                websocket.send(haxe.Json.stringify(
                    {
                        "op": 1,
                        "d": {
                            "protocol": "udp",
                            "data": {
                                "address": data[0],
                                "port": data[1],
                                "mode": "xsalsa20_poly1305"
                            }
                        }
                    }
                ));
            case 4:
                canSendVoiceData = true;
                var timer:Timer = new Timer(1);
                timer.run = () -> {
                    udpConnection.waitForRead();
                        var bytes:Bytes = Bytes.alloc(8192);
                        var kekw:Address = new Address();
                        var funky:Int = udpConnection.readFrom(bytes, 0, bytes.length, kekw);
                        //trace(bytes);
                }
                websocket.send(haxe.Json.stringify({
                    op: 5,
                    d: {
                        speaking: 5,
                        delay: 0,
                        ssrc: 1
                    }
                }));
        }
    }

    public function play(file:String) {
        if (FileSystem.exists(file)) {
            //do your ffmpeg shit here
            somethingIsPlaying = true;
            websocket.send(haxe.Json.stringify({
                op: 5,
                d: {
                    speaking: 5,
                    delay: 0,
                    ssrc: 1
                }
            }));
        }
    }

    function ipDiscovery(data:Dynamic) {
        var ipDiscoveryPacket:Bytes = Bytes.alloc(74);
        ipDiscoveryPacket.setUInt16(0, (1 << 8));
        ipDiscoveryPacket.setUInt16(2, (70 << 8));
        ipDiscoveryPacket.setInt32(4, (data.d.ssrc << 8));

        udpConnection = new UdpSocket();
        var kekwke:Address = new Address();
        kekwke.host = new Host(data.d.ip).ip;
        kekwke.port = data.d.port;
        udpConnection.sendTo(ipDiscoveryPacket, 0, ipDiscoveryPacket.length, kekwke);
        trace("sent, now wait");
        udpConnection.waitForRead();
        var bytes:Bytes = Bytes.alloc(8192);
        var kekw:Address = new Address();
        var funky:Int = udpConnection.readFrom(bytes, 0, bytes.length, kekw);
        
        var discordResponse:Bytes = bytes;
        var responseType:Int = (discordResponse.getUInt16(0) >> 8);
        var length:Int = (discordResponse.getUInt16(2) >> 8);
        var ssrc:Int = ((discordResponse.getInt32(4) >> 8)+1);
        var address:String = discordResponse.getString(8, discordResponse.length-10);
        address = address.replace(address.split(".")[3].substring(4, 0).split("")[address.split(".")[3].substring(4, 0).split("").length-1], "").trim().trim();
        address = address.substring(0, address.length - 2);
        var port:Int = (discordResponse.getUInt16(71));

        var realPort:Int = udpConnection.host().port;
        trace(realPort);

        var data:Dynamic = [];
        data.push(address);
        data.push(realPort);
        return data;
    }

    function getUInt32BE(n:Int):Bytes {
        var b = Bytes.alloc(4);
        b.set(0, (n >> 24) & 0xff);
        b.set(1, (n >> 16) & 0xff);
        b.set(2, (n >> 8) & 0xff);
        b.set(3, n & 0xff);
        return b;
    }

    function readAllBytes(udpSocket:UdpSocket) {
        trace("called?");
        var readed:Bool = false;
        while (!readed) {
            var bytesRead = 0;
            var allocBytes = Bytes.alloc(1024);
            try {
                bytesRead = udpSocket.input.readBytes(allocBytes, 0, allocBytes.length);
            } catch (err) {
                readed = true;
            }
            if (bytesRead == 1024) {
                socketData.writeFullBytes(allocBytes, 0, allocBytes.length);
                readAllBytes(udpSocket);
            } else if (bytesRead != 0 && bytesRead < 1024) {
                socketData.writeFullBytes(allocBytes, 0, allocBytes.length);
                readed = true;
            }
        }
        trace(socketData.getBytes().toString());
        socketData = new BytesOutput();
    }

    public function giveCredentials(d:Dynamic) {
        if (!hasCredentials) {
            /*trace("Credentials given!");
            trace("our credentials: " + haxe.Json.stringify(d));
            trace("session id: " + session_id);*/
            trace("wss://" + d.endpoint.split(":443")[0] + "/?v=4");
            websocket = new WebSocket("wss://" + d.endpoint.split(":443")[0] + "/?v=4"); //to all those discord developers, why did you add :443? :skull:
            websocket.onmessage = (dd:haxe.ws.Types.MessageType) -> {
                switch(dd) {
                    case StrMessage(content):
                        haxe.EntryPoint.runInMainThread(handleShit.bind(content, d));
                    case BytesMessage(content):
                        trace(content);
                }
            }
            websocket.onclose = () -> {
                trace("closed");
                this.destroy();
            }
            websocket.onerror = (_) -> {
                trace("errored " + _);
                this.destroy();
            }
            hasCredentials = true;
        }
        else {
            trace("Credentials have already been given");
        }
    }

    /*public function play(path:String) {
        if (!FileSystem.exists(path)) {
            trace("The path of the file you have specified does not exist.");
        } else {
            if (!path.endsWith(".opus")) {
                throw "[!] WARNING [!]\nPlaying files in hxdiscord for now it's a beta thing. You can only play .opus files for now.";
            }
            else {
                trace("a");
                websocket.send(haxe.Json.stringify({
                    op: 5,
                    d: {
                        speaking: 5,
                        delay: 0,
                        ssrc: 1
                    }
                }));

                /*var fileBytes = File.getBytes(path);
                var size = FileSystem.stat(path).size;

                var buf = haxe.io.Bytes.alloc(12 + size);
                buf.set(0, 0x80); // Versión: 2 (10), Padding: 0, Extension: 0, CSRC count: 0 (0000)
                buf.set(1, 0x78); // Marker: 0, Payload type: 120 (01111000) - perfil dinámico
                buf.setUInt16(2, 1); // Sequence number: 1
                buf.setInt32(4, 123456789); // Timestamp: algún valor arbitrario
                buf.setInt32(8, 987654321); // SSRC identifier: algún valor arbitrario

                fileBytes.blit(0, buf, 12, size);
                var len = udpConnection.sendTo(buf, 0, buf.length, addr);
                trace("Se enviaron " + len + " bytes");
            }
        }
    }*/

    public function destroy() {
        this.websocket.close();
        this.websocket = null;
        this.hb_timer.stop();
    }
}
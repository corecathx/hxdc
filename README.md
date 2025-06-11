<p align="center">
  <img src="res/logo.png" alt="Logo" height="100">
</p>

<h2 align="center">A Discord Client Made with Haxe</h2>

> This client uses a modified version of [furretpaws'](https://github.com/furretpaws) [`hxdiscord`](https://github.com/furretpaws/hxdiscord) library, shout out to them!!! :]

![Preview](res/screenshot.png)

This is a fun little Discord client I made using [Haxe](https://haxe.org/) and [HaxeUI](https://haxeui.org).  
It uses your **user token** since, well, this client is intended for it.

I don't store or send your token anywhere, your token is stored locally on the client's ./config.json file.

Use this client at your own risk. If you lose your account, that's on you.

## Features
Right now, it only supports pretty basic stuff, such as:
- Browse servers and channels
- Read and send messages

But hey, it's also:
- Built with [HaxeUI](https://haxeui.org/)!

## Building

You need to have `openfl`, `haxeui-core` and `haxeui-openfl` libraries installed to get this working, then you could run

```
lime test <target>
```

... where `<target>` is your preferred exporting target (hl, cpp, and others...)

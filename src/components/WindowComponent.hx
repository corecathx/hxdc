package components;

import lime.ui.MouseCursor;
import lime.app.Application;
import lime.ui.Window;
import openfl.events.Event;
import openfl.Lib;
import haxe.ui.containers.VBox;

//EXTREMELYWIP AASDASDASD
@:build(haxe.ui.ComponentBuilder.build("assets/custom/window.xml"))
class WindowComponent extends VBox {
    var isDragging:Bool = false;
    var startX:Float = 0;
    var startY:Float = 0;

    var isResizing:Bool = false;
    var resizeStartX:Float = 0;
    var resizeStartY:Float = 0;
    var initialWidth:Int = 0;
    var initialHeight:Int = 0;

    final RESIZE_MARGIN:Int = 8;

    public function new() {
        super();
        trace("HXDC custom window init");

        var win:Window = Application.current.window;
        win.borderless = false;

        closeButton.onClick = (_) -> win.close();
        maxButton.onClick = (_) -> {
            win.maximized = !win.maximized;
            maxButton.icon = win.maximized ?
                "res/icons/window/unmaximize.png" :
                "res/icons/window/maximize.png";
        };
        minButton.onClick = (_) -> win.minimized = true;

        win.onMouseDown.add(onWinMouseDown);
        win.onMouseMove.add(onWinMouseMove);
        win.onMouseUp.add(onWinMouseUp);

        //windowContent.addComponent(new MainView());
    }

    function onWinMouseDown(x:Float, y:Float, button:Dynamic):Void {
        var win = Application.current.window;

        if (x >= win.width - RESIZE_MARGIN && y >= win.height - RESIZE_MARGIN) {
            isResizing = true;
            resizeStartX = x;
            resizeStartY = y;
            initialWidth = win.width;
            initialHeight = win.height;
        } else if (titleBar.hitTestPoint(x, y, false)) {
            isDragging = true;
            startX = x;
            startY = y;
        }
    }

    function onWinMouseMove(x:Float, y:Float):Void {
        var win = Application.current.window;

        if (isDragging) {
            var dx:Int = Std.int(x - startX);
            var dy:Int = Std.int(y - startY);
            win.x += dx;
            win.y += dy;
        } else if (isResizing) {
            var dw:Int = Std.int(x - resizeStartX);
            var dh:Int = Std.int(y - resizeStartY);
            win.resize(initialWidth + dw, initialHeight + dh);
        } else {
            if (x >= win.width - RESIZE_MARGIN && y >= win.height - RESIZE_MARGIN)
                Lib.current.stage.window.cursor = MouseCursor.RESIZE_NWSE;
            else 
                Lib.current.stage.window.cursor = MouseCursor.DEFAULT;
        }
    }

    function onWinMouseUp(x:Float, y:Float, button:Dynamic):Void {
        if (isDragging)
            isDragging = false;
        if (isResizing)
            isResizing = false;
    }
}

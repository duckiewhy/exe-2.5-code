package;

import sys.FileSystem;
#if android
//import android.Hardware;
import android.Permissions;
import android.os.Environment;
import android.widget.Toast;
#end
import flash.system.System;
import flixel.FlxG;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import lime.app.Application;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import flixel.FlxState;
import flixel.addons.ui.FlxUIButton;
import flixel.text.FlxText;
import openfl.utils.Assets;
import sys.io.File;
import flixel.util.FlxColor;
using StringTools;

/**
* @author: Sirox (all code here is stolen /j)
* @version: 1.1
* extension-androidtools by @M.A. Jigsaw
*/
class Generic {
	
	public static var mode:Modes = ROOTDATA;
	private static var path:String = null;
	public static var initState:FlxState = null;
	
	/**
	* returns some paths depending on current 'mode' variable or you can force it to any mode by typing it into ()
	*/
	public static function returnPath(m:Modes = ROOTDATA):String {
		#if android
		if (m == ROOTDATA && mode != ROOTDATA) { // the most stupid checking i made
			m = mode;
		}
		switch (m) {
			case ROOTDATA:
				path = lime.system.System.applicationStorageDirectory;
			case INTERNAL:
			    path = Environment.getExternalStorageDirectory() + '/' + '.' + Application.current.meta.get('file') + '/';
				if (!FileSystem.exists(path)) {
					FileSystem.createDirectory(path);
				}
			/*case ANDROIDDATA:
			    path = Environment.getDataDirectory() + '/';*/
		}
		if (path != null && path.length > 0) {
			trace(path);
			return path;
		}
		trace('DEATH');
		return null;
		#else
		path = '';
		return path;
		#end
	}
	
	/**
	 * crash handler (it works only with exceptions thrown by haxe, for example glsl death or fatal signals wouldn't be saved using this)
     * @author: sqirra-rng
     * @edit: Saw (M.A. Jigsaw)
	 */
	public static function initCrashHandler()
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(u:UncaughtErrorEvent)
		{
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var errMsg:String = '';

			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case CFunction:
						errMsg += 'a C function\n';
					case Module(m):
						errMsg += 'module ' + m + '\n';
					case FilePos(s, file, line, column):
						errMsg += file + ' (line ' + line + ')\n';
					case Method(cname, meth):
						errMsg += cname == null ? "<unknown>" : cname + '.' + meth + '\n';
					case LocalFunction(n):
						errMsg += 'local function ' + n + '\n';
				}
			}

			errMsg += u.error;

			try
			{
				var lmao:String = returnPath();
					if (!FileSystem.exists(lmao + 'logs')) {
						FileSystem.createDirectory(lmao + 'logs');
					}
				    File.saveContent(lmao
					+ 'logs/'
					+ Application.current.meta.get('file')
					+ '-'
					+ Date.now().toString().replace(' ', '-').replace(':', "'")
					+ '.log',
					errMsg
					+ '\n');
			}
			#if android
			catch (e:Dynamic)
			Toast.makeText("Error!\nClouldn't save the crash dump because:\n" + e, Toast.LENGTH_LONG);
			#end

			Sys.println(errMsg);
			Application.current.window.alert(errMsg, 'Error!');

			System.exit(1);
		});
	}
	
	public static function trace(thing:Dynamic, var_name:String, alert:Bool = false) {
		var dateNow:String = Date.now().toString();
		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");
		var fp:String = returnPath() + "logs/" + var_name + dateNow + ".txt";
		
		var thingToSave:String = forceToString(thing);
		
		if (alert) {
			Application.current.window.alert(thingToSave, 'FileTrace');
		}

		if (!FileSystem.exists(returnPath() + 'logs')) {
			FileSystem.createDirectory(returnPath() + 'logs');
		}
		
		/*if (FileSystem.exists(fp)) {
			for (i in 0.0...Math.POSITIVE_INFINITY) {
				fp = fp + i;
				if (FileSystem.exists(fp)) {
					fp = fp.replace(i, '');
				} else {
					break;
				}
			}
		}*/
		File.saveContent(fp, var_name + " = " + thingToSave + "\n");
	}
	
	public static function forceToString(shit:Dynamic):String {
		var result:String = '';
		if (!Std.isOfType(shit, String)) {
			result = Std.string(shit);
		} else {
			result = shit;
		}
		return result;
	}
	
	public static function match(val1:Dynamic, val2:Dynamic) {
		return Std.isOfType(val1, val2);
	}
	
	public static function copyContent(copyPath:String, savePath:String)
	{
			trace(returnPath());
			trace('saving dir: ' + returnPath() + savePath);
			trace(copyPath);
			var fileName:String = Paths.video("StoryStart");
			trace(fileName);
			trace('FileSystem.exists(fileName) = ' + FileSystem.exists(fileName));
			trace('FileSystem.exists(returnPath() + savePath) = ' + FileSystem.exists(returnPath() + savePath));
			trace('Assets.exists(copyPath) = ' + Assets.exists(copyPath));
			if (!FileSystem.exists(returnPath() + savePath)/* && Assets.exists(copyPath)*/) {
				File.saveBytes(returnPath() + savePath, Assets.getBytes('videos:' + copyPath));
			    trace('saved');
			}
	}
}

class PermsState extends FlxState {
	var permsbutton:FlxUIButton;
	var continuebutton:FlxUIButton;
	var text:FlxText;
	public static var callback:Void->Void = null;
	override public function create():Void
	{
		text = new FlxText(0,0, FlxG.width, "PERMISSIONS" + "\n" + "this game needs storage permissions to work" + "\n" + "press 'Ask Permissions' to ask them" + "\n" + "press 'continue' to run the game", 32);
		text.setFormat("VCR OSD Mono", 32);
		text.screenCenter(XY);
		text.y -= FlxG.height / 4;
		text.alignment = CENTER;
		add(text);
		permsbutton = new FlxUIButton(0,0,"Ask Permissions", () -> {
            Permissions.requestPermissions([Permissions.WRITE_EXTERNAL_STORAGE, Permissions.READ_EXTERNAL_STORAGE]);
        });
        permsbutton.screenCenter(XY);
        permsbutton.x -= 400;
        permsbutton.y += 100;
        permsbutton.resize(250,50);
		permsbutton.setLabelFormat("VCR OSD Mono",24,FlxColor.BLACK,"center");
		add(permsbutton);
        continuebutton = new FlxUIButton(0,0,"continue", () -> {
			if (callback != null) {
				callback();
			}
        	FlxG.switchState(Type.createInstance(Main.initialState, []));
        });
        continuebutton.screenCenter(XY);
        continuebutton.x += 300;
        continuebutton.y += 100;
		continuebutton.resize(250,50);
		continuebutton.setLabelFormat("VCR OSD Mono",24,FlxColor.BLACK,"center");
		add(continuebutton);
		
		super.create();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}

enum Modes {
	ROOTDATA;
	INTERNAL;
}
package;

import flixel.system.scaleModes.RatioScaleMode;
import FunkinLua;
import Section.SwagSection;
import Song.SwagSong;
import StageData;
import openfl.system.Capabilities;
import WiggleEffect.WiggleEffectType;
import editors.CharacterEditorState;
import editors.ChartingState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.display.Stage;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.math.FlxRandom;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIButton;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import modchart.*;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFlAssets;
import sys.FileSystem;
import sys.io.File;
import lime.app.Application;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.BaseScaleMode;

/*import mobile.flixel.FlxHitbox;
import mobile.MobileControls;*/

using StringTools;

#if desktop
import Discord.DiscordClient;
#end
#if sys
import sys.FileSystem;
#end
#if VIDEOS_ALLOWED
import hxcodec.VideoHandler;
import hxcodec.VideoSprite;
#end

typedef BasicSpeedChange = {
	var time:Float;
	var mult:Float;
}

class PlayState extends MusicBeatState
{
	var modchartedSongs:Array<String> = ['perdition', 'hedge']; // PUT THE SONG NAME HERE IF YOU WANT TO USE THE ANDROMEDA MODIFIER SYSTEM!!

	// THEN GOTO MODCHARTSHIT.HX TO DEFINE MODIFIERS ETC
	// IN THE SETUPMODCHART FUNCTION
	public var useModchart:Bool = false;

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public var center:FlxPoint;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], // From 0% to 19%
		['Shit', 0.4], // From 20% to 39%
		['Bad', 0.5], // From 40% to 49%
		['Bruh', 0.6], // From 50% to 59%
		['Meh', 0.69], // From 60% to 68%
		['Nice', 0.7], // 69%
		['Good', 0.8], // From 70% to 79%
		['Great', 0.9], // From 80% to 89%
		['Sick!', 1], // From 90% to 99%
		['Perfect!!', 1] // The value on this one isn't used actually, since Perfect is always "1"
	];

	#if (haxe >= "4.0.0")
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	#else
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, Dynamic>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	#end

	public var basicSpeedChanges:Array<BasicSpeedChange> = [];
	// event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var noteKillOffset:Float = 350;

	public static var current:PlayState;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	var heyTimer:Float;

	public var vocals:FlxSound;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<Dynamic> = [];

	public var modManager:ModManager;
	public var downscrollOffset = FlxG.height - 150;
	public var upscrollOffset = 50;

	private var strumLine:FlxSprite;

	// Handles the new epic mega sexy cam code that i've done
	// needed to make em public static vars to get the skew working
	public static var camFollow:FlxPoint;
	public static var camFollowPos:FlxObject;
	public static var prevCamFollow:FlxPoint;
	public static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	// fuck whoever removed this i like cool shit
	public var camZooming:Bool = false;

	public static var curSong:String = ""; // changing private to public static is uhh.. ok?

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;

	public var songPercent:Float = 0;
	var songPercentFuckles:Float = 0;
	var timeTxt:FlxText;

	private var updateTime:Bool = true;
	private var shakeCam:Bool = false;
	private var shakeCam2:Bool = false;
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	public var endingSong:Bool = false;

	public static var practiceMode:Bool = false;
	public static var usedPractice:Bool = false;
	public static var changedDifficulty:Bool = false;
	public static var cpuControlled:Bool = false;

	var botplaySine:Float = 0;
	var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camNotes:FlxCamera;
	public var camGame:FlxCamera; // i hope this doesn't completely fuck up the game somehow
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;
	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var drainMisses:Float = 0; // EEE OOO EH OO EE AAAAAAAAA
	public var ghostMisses:Int = 0;
	public var scoreTxt:FlxText;

	var scoreTxtTween:FlxTween;
	public static var checkpoint:Float = 0; // here goes nothing (no no no no we aint doin this lol get good)

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	public var inCutscene:Bool = false;
	var songLength:Float = 0;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	var songRPC = SONG.song;
	#end
	// Lua shit (we gotta remove this)
	private var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';
	//for the credits at beginning of song lol!
	var creditsText:FlxTypedGroup<FlxText>;
	var creditoText:FlxText;
	var box:FlxSprite;
	// sonic.exe (ycr/triple trouble)
	var pickle:FlxSprite;
	var fgTrees:BGSprite;
	var genesis:FlxTypedGroup<FlxSprite>;
	// - xenophanes
	var vg:FlxSprite;
	var p3staticbg:FlxSprite;
	var backtreesXeno:BGSprite;
	var fgTree1Xeno:BGSprite;
	var fgTree2Xeno:BGSprite;
	var grassXeno:BGSprite;
	var flooooor:FlxSprite;
	var fgTree1:BGSprite;
	var fgTree2:BGSprite;
	//variables for stuff (strumline spins, zoom bools, etc...) shit
	public static var isFixedAspectRatio:Bool = false;
	public var superZoomShit:Bool = false;
	public var supersuperZoomShit:Bool = false;
	public var weedSpinningTime:Bool = false;
	var cooltext:String = '';
	var deezNuts:Array<Int> = [4, 5];
	var ballsinyojaws:Int = 0;
	var ezTrail:FlxTrail;
	// - song start intro bullshit
	var blackFuck:FlxSprite;
	var blackFuck2:FlxSprite;
	var whiteFuck:FlxSprite;
	var startCircle:FlxSprite;
	var startText:FlxSprite;
	// - dad 2 things (namely needlemouse)
	public var dad2:Character;
	public var dad2Group:FlxSpriteGroup; // going to use this for needle/sarah (avery)
	// - camera bullshit
	var dadCamThing:Array<Int> = [0, 0];
	var bfCamThing:Array<Int> = [0, 0];
	var cameramove:Bool = FlxG.save.data.cammove;
	// - cutscene shit
	var topBar:FlxSprite;
	var bottomBar:FlxSprite;
	// - healthbar based things for mechanic use (like my horizon lol)
	var healthMultiplier:Float = 1; // fnf
	var healthDrop:Float = 0;
	var dropTime:Float = 0;
	// - healthbar flip shit
	public var healthbarval:Float = 1; // I'm fucking stupid but ok it works
	var bfIsLeft:Bool = false;
	// - dodge mechanic bullshit
	var canDodge:Bool = false;
	var dodging:Bool = false;
	// - colors for sanic i think
	var colorAmount:Float = 0;
	var trippinBalls:Bool = false;
	var weedVis:WeedVision;
	// - coldsteels spins
	var SpinAmount:Float = 0;
	var IsNoteSpinning:Bool = false;
	var isPlayersSpinning:Bool = false;
	// - jumpscare things
	var daJumpscare:FlxSprite = new FlxSprite(0, 0);
	var balling:FlxSprite = new FlxSprite(0, 0);
	// - flying shit
	var flyTarg:Character;
	var flyState:String = '';
	var floaty:Float = 0;
	var floaty2:Float = 0;
	var tailscircle:String = '';
	// - ring counter bullshit
	var ringCounter:FlxSprite;
	var counterNum:FlxText;
	var cNum:Int = 0;
	// mazin stuff
	var fgmajin:BGSprite;
	var fgmajin2:BGSprite;
	// needlemouse shit
	var conkCreet:BGSprite;
	var needleBuildings:BGSprite;
	var needleMoutains:BGSprite;
	var needleSky:BGSprite;
	var needleRuins:BGSprite;
	var needleFg:FlxSprite;
	//sunky stuff (no swearing.....)
	var aspectRatio:Bool = false;
	public var sunkerTimebarFuckery:Bool = false;
	public var sunkerTimebarNumber:Int;
	var cereal:FlxSprite;
	var munch:FlxSprite;
	var pose:FlxSprite;
	var sunker:FlxSprite;
	var spoOoOoOky:FlxSprite;
	// fatal error shit
	var base:FlxSprite;
	var domain:FlxSprite;
	var domain2:FlxSprite;
	var trueFatal:FlxSprite;
	// mechanic shit + moving funne window for fatal error
	#if windows
	var windowX:Float = Lib.application.window.x;
	var windowY:Float = Lib.application.window.y;
	var Xamount:Float = 0;
	var Yamount:Float = 0;
	var IsWindowMoving:Bool = false;
	var IsWindowMoving2:Bool = false;
	#end
	var errorRandom:FlxRandom = new FlxRandom(666); // so that every time you play the song, the error popups are in the same place
	// keeps it all nice n fair n shit
	//fleetways shit
	var wall:FlxSprite;
	var porker:FlxSprite;
	var thechamber:FlxSprite;
	var floor:FlxSprite;
	var fleetwaybgshit:FlxSprite;
	var emeraldbeam:FlxSprite;
	var emeraldbeamyellow:FlxSprite;
	var pebles:FlxSprite;
	var warning:FlxSprite;
	var dodgething:FlxSprite;
	// Preload vars so no null obj ref
	var daNoteStatic:FlxSprite;
	var preloaded:Bool = false;
	// fuckles
	public var fucklesDrain:Float = 0;
	public var fucklesMode:Bool = false;
	//our horizon
	var fucklesBGPixel:BGSprite;
	var fucklesFGPixel:BGSprite;
	var fucklesAmyBg:FlxSprite;
	var fucklesVectorBg:FlxSprite;
	var fucklesKnuxBg:FlxSprite;
	var fucklesEspioBg:FlxSprite;
	var fucklesCharmyBg:FlxSprite;
	var fucklesMightyBg:FlxSprite;
	var fucklesFuckedUpBg:FlxSprite;
	var fucklesFuckedUpFg:BGSprite;
	var fucklesTheHealthHog:Array<Float>;
	// starved shit
	var stardustBgPixel:FlxTiledSprite;
	var stardustFloorPixel:FlxTiledSprite;
	var stardustFurnace:FlxSprite;
	var hungryManJackTime:Int = 0;
	// - fight or flight
	var deadHedgehog:BGSprite;
	var mcdonaldTowers:BGSprite;
	var burgerKingCities:BGSprite;
	var wendysLight:FlxSprite;
	var pizzaHutStage:BGSprite;
	// - the fear mechanic
	var fearUi:FlxSprite;
	var fearUiBg:FlxSprite;
	var fearTween:FlxTween;
	var fearTimer:FlxTimer;
	public var fearNo:Float = 0;
	public var fearBar:FlxBar;
	public static var isFear:Bool = false;
	var doFearCheck = false;
	var fearNum:FlxText;
	//x-terion shit
	var xterionFloor:Floor;
	var xterionSky:BGSprite;
	//slash shit slhop slhop slhop slhop (mariostarterbrothers)
	var slashBg:BGSprite;
	var slashFloor:BGSprite;
	var slashAssCracks:FlxSprite;
	var slashLava:FlxSprite;
	// - fov shit
	var slashBgPov:BGSprite;
	var slashFloorPov:BGSprite;
	var slashLavaPov:FlxSprite;
	//curse shit lololololol
	var curseStatic:FlxSprite;
	var hexTimer:Float = 0;
	var hexes:Float = 0;
	var fucklesSetHealth:Float = 0;
	var barbedWires:FlxTypedGroup<WireSprite>;
	var wireVignette:FlxSprite;
	//hjog shit dlskafj;lsa
	var hogBg:BGSprite;
	var hogMotain:BGSprite;
	var hogWaterFalls:FlxSprite;
	var hogFloor:FlxSprite;
	var hogLoops:FlxSprite;
	var hogTrees:BGSprite;
	var hogRocks:BGSprite;
	var hogOverlay:BGSprite;
	//satanos stage shit
	var satBackground:BGSprite;
	var satFloor:BGSprite;
	var satFgPlant:FlxSprite;
	var satFgTree:FlxSprite;
	var satFgFlower:FlxSprite;
	var satBgTree:BGSprite;
	var satBgFlower:BGSprite;
	var satBgPlant:BGSprite;

	public var ringsNumbers:Array<SonicNumber>=[];
	public var minNumber:SonicNumber;
	public var sonicHUD:FlxSpriteGroup;
	public var scoreNumbers:Array<SonicNumber>=[];
	public var missNumbers:Array<SonicNumber>=[];
	public var secondNumberA:SonicNumber;
	public var secondNumberB:SonicNumber;
	public var millisecondNumberA:SonicNumber;
	public var millisecondNumberB:SonicNumber;

	public var sonicHUDSongs:Array<String> = [
		"my-horizon",
		"our-horizon",
		"prey",
		"you-cant-run", // for the pixel part in specific
		"fatality",
		"b4cksl4sh",
	];

	var hudStyle:String = 'sonic2';
	public var sonicHUDStyles:Map<String, String> = [

		"fatality" => "sonic3",
		"prey" => "soniccd",
		"you-cant-run" => "sonic1", // because its green hill zone so it should be sonic1
		"our-horizon" => "chaotix",
		"my-horizon" => "chaotix"
		// "songName" => "styleName",

		// styles are sonic2 and sonic3
		// defaults to sonic2 if its in sonicHUDSongs but not in here
	];

	//Nah they ain't fr using 2 games :skull:
	var noteLink:Bool = true;
	var file15Ready:Bool;
	var file25Ready:Bool;
	var fileHealth:Float;
	var fileTime:Float;
	// i have no idea what this is for -avery

	//nebs modchart shit
	var curShader:ShaderFilter;

	override function draw()
	{
		super.draw();
		// trace('it is being called');
		/*holdRenderer.drawHoldNotes(camHUD.canvas.graphics);
			@:privateAccess
			camHUD.canvas.graphics.__dirty = true; */

		// ^^ this does NOT work and I have no clue why
		// if someone wants to fix it, then go ahead
	}

	override public function create()
	{
		current=this;
		Paths.clearStoredMemory();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		practiceMode = false;
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camNotes);
		FlxG.cameras.add(camOther);

		modManager = new ModManager(this);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		// FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		var preloadGroup:FlxSpriteGroup = new FlxSpriteGroup();
		// Preloader.initialize(SONG.song.toLowerCase(), preloadGroup);
		preloadGroup.visible = false;
		add(preloadGroup);

		sonicHUD = new FlxSpriteGroup();
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = '' + CoolUtil.difficultyStuff[storyDifficulty][0];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
			songRPC = '???';
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		// I KNOW BLACKFUCK EXISTS BUT I AM SERIOUSLY STUPID
		topBar = new FlxSprite(0, -170).makeGraphic(1280, 170, FlxColor.BLACK);
		bottomBar = new FlxSprite(0, 720).makeGraphic(1280, 170, FlxColor.BLACK);
		blackFuck = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		blackFuck2 = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);

		startCircle = new FlxSprite();
		startText = new FlxSprite();

		GameOverSubstate.resetVariables();

		var songName:String = Paths.formatToSongPath(SONG.song);
		curStage = PlayState.SONG.stage;
		trace('stage is: ' + curStage);
		if (PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1)
		{
			switch (songName)
			{
				default:
					curStage = 'stage';
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100]
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;

		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		dad2Group = new FlxSpriteGroup(DAD_X, DAD_Y); // should load right on top of dad? hopefully lmao (avery)
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'too-slow': // somncic!!!!
				var sky:BGSprite = new BGSprite('PolishedP1/BGSky', -600, -200, 1, 1);
				sky.setGraphicSize(Std.int(sky.width * 1.4));
				add(sky);

				var midTrees1:BGSprite = new BGSprite('PolishedP1/TreesMidBack', -600, -200, 0.7, 0.7);
				midTrees1.setGraphicSize(Std.int(midTrees1.width * 1.4));
				add(midTrees1);

				var treesmid:BGSprite = new BGSprite('PolishedP1/TreesMid', -600, -200,  0.7, 0.7);
				midTrees1.setGraphicSize(Std.int(midTrees1.width * 1.4));
				add(treesmid);

				var treesoutermid:BGSprite = new BGSprite('PolishedP1/TreesOuterMid1', -600, -200, 0.7, 0.7);
				treesoutermid.setGraphicSize(Std.int(treesoutermid.width * 1.4));
				add(treesoutermid);

				var treesoutermid2:BGSprite = new BGSprite('PolishedP1/TreesOuterMid2', -600, -200,  0.7, 0.7);
				treesoutermid2.setGraphicSize(Std.int(treesoutermid2.width * 1.4));
				add(treesoutermid2);

				var lefttrees:BGSprite = new BGSprite('PolishedP1/TreesLeft', -600, -200,  0.7, 0.7);
				lefttrees.setGraphicSize(Std.int(lefttrees.width * 1.4));
				add(lefttrees);

				var righttrees:BGSprite = new BGSprite('PolishedP1/TreesRight', -600, -200, 0.7, 0.7);
				righttrees.setGraphicSize(Std.int(righttrees.width * 1.4));
				add(righttrees);

				var outerbush:BGSprite = new BGSprite('PolishedP1/OuterBush', -600, -150, 1, 1);
				outerbush.setGraphicSize(Std.int(outerbush.width * 1.4));
				add(outerbush);

				var outerbush2:BGSprite = new BGSprite('PolishedP1/OuterBushUp', -600, -200, 1, 1);
				outerbush2.setGraphicSize(Std.int(outerbush2.width * 1.4));
				add(outerbush2);

				var grass:BGSprite = new BGSprite('PolishedP1/Grass', -600, -150, 1, 1);
				grass.setGraphicSize(Std.int(grass.width * 1.4));
				add(grass);

				var deadegg:BGSprite = new BGSprite('PolishedP1/DeadEgg', -600, -200, 1, 1);
				deadegg.setGraphicSize(Std.int(deadegg.width * 1.4));
				deadegg.isGore = true;
				add(deadegg);

				var deadknux:BGSprite = new BGSprite('PolishedP1/DeadKnux', -600, -200, 1, 1);
				deadknux.setGraphicSize(Std.int(deadknux.width * 1.4));
				deadknux.isGore = true;
				add(deadknux);

				var deadtailz:BGSprite = new BGSprite('PolishedP1/DeadTailz', -700, -200, 1, 1);
				deadtailz.setGraphicSize(Std.int(deadtailz.width * 1.4));
				deadtailz.isGore = true;
				add(deadtailz);

				var deadtailz1:BGSprite = new BGSprite('PolishedP1/DeadTailz1', -600, -200, 1, 1);
				deadtailz1.setGraphicSize(Std.int(deadtailz1.width * 1.4));
				deadtailz1.isGore = true;
				add(deadtailz1);

				var deadtailz2:BGSprite = new BGSprite('PolishedP1/DeadTailz2', -600, -400, 1, 1);
				deadtailz2.setGraphicSize(Std.int(deadtailz2.width * 1.4));
				deadtailz2.isGore = true;
				add(deadtailz2);

				fgTrees = new BGSprite('PolishedP1/TreesFG', -610, -200, 1.1, 1.1);
				fgTrees.setGraphicSize(Std.int(fgTrees.width * 1.45));


			case 'endless-forest': // lmao
				PlayState.SONG.splashSkin = 'noteSplashes';
				var SKY:BGSprite = new BGSprite('FunInfiniteStage/sonicFUNsky', -600, -200, 1.0, 1.0);
				add(SKY);

				var bush:BGSprite = new BGSprite('FunInfiniteStage/Bush 1', -42, 171, 1.0, 1.0);
				add(bush);

				var pillars2:BGSprite = new BGSprite('FunInfiniteStage/Majin Boppers Back', 182, -100, 1.0, 1.0, ['MajinBop2 instance 1'], true);
				add(pillars2);

				var bush2:BGSprite = new BGSprite('FunInfiniteStage/Bush2', 132, 354, 1.0, 1.0);
				add(bush2);

				var pillars1:BGSprite = new BGSprite('FunInfiniteStage/Majin Boppers Front', -169, -167, 1.0, 1.0, ['MajinBop1 instance 1'], true);
				add(pillars1);

				var floor:BGSprite = new BGSprite('FunInfiniteStage/floor BG', -340, 660, 1.0, 1.0);
				add(floor);

				fgmajin = new BGSprite('FunInfiniteStage/majin FG1', 1126, 903, 1.0, 1.0, ['majin front bopper1'], true);

				fgmajin2 = new BGSprite('FunInfiniteStage/majin FG2', -393, 871, 1.0, 1.0, ['majin front bopper2'], true);

			case 'void':
				whiteFuck = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
				add(whiteFuck);

			case 'TDP2':
				trace("henlo :3");

			case 'cycles-hills': // lmao
				var SKY:BGSprite = new BGSprite('LordXStage/sky', -1900, -1006, 1.0, 1.0);
				SKY.setGraphicSize(Std.int(SKY.width * .5));
				add(SKY);

				var hills:BGSprite = new BGSprite('LordXStage/hills1', -1440, -806 + 200, 1.0, 1.0);
				hills.setGraphicSize(Std.int(hills.width * .5));
				add(hills);

				var floor:BGSprite = new BGSprite('LordXStage/floor', -1400, -496, 1.0, 1.0);
				floor.setGraphicSize(Std.int(floor.width * .55));
				add(floor);

				var eyeflower:BGSprite = new BGSprite('LordXStage/WeirdAssFlower_Assets', 100 - 500, 100, 1.0, 1.0, ['flower'], true);
				eyeflower.setGraphicSize(Std.int(eyeflower.width * 0.8));
				add(eyeflower);

				var notknuckles:BGSprite = new BGSprite('LordXStage/NotKnuckles_Assets', 100 - 300, -400 + 25, 1.0, 1.0, ['Notknuckles'], true);
				notknuckles.setGraphicSize(Std.int(notknuckles.width * .5));
				add(notknuckles);

				var smallflower:BGSprite = new BGSprite('LordXStage/smallflower', -1500, -506, 1.0, 1.0);
				smallflower.setGraphicSize(Std.int(smallflower.width * .6));
				add(smallflower);

				var bfsmallflower:BGSprite = new BGSprite('LordXStage/smallflower', -1500 + 300, -506 - 50, 1.0, 1.0);
				bfsmallflower.setGraphicSize(Std.int(smallflower.width * .6));
				add(bfsmallflower);

				var smallflower2:BGSprite = new BGSprite('LordXStage/smallflowe2', -1500, -506 - 50, 1.0, 1.0);
				smallflower2.setGraphicSize(Std.int(smallflower.width * .6));
				add(smallflower2);

				var tree:BGSprite = new BGSprite('LordXStage/tree', -1900 + 650 - 100, -1006 + 350, 1.0, 1.0);
				tree.setGraphicSize(Std.int(tree.width * .7));
				add(tree);

			case 'cant-run-xd': // HOLY FUCK I AM HAVING SEXUAL INTERCOURSE WITH YOUR MOM!!!!!!!!!!!!
				genesis = new FlxTypedGroup<FlxSprite>();
				var sky:BGSprite = new BGSprite('run/sky', -600, -200, 1.0, 1.0);
				genesis.add(sky);

				var grassback:BGSprite = new BGSprite('run/GrassBack', -600, -200, 1.0, 1.0);
				genesis.add(grassback);

				var trees:BGSprite = new BGSprite('run/trees', -600, -200, 1.0, 1.0);
				genesis.add(trees);

				var grass:BGSprite = new BGSprite('run/Grass', -600, -200, 1.0, 1.0);
				genesis.add(grass);

				var treesfront:BGSprite = new BGSprite('run/TreesFront', -600, -200, 1.0, 1.0);
				genesis.add(treesfront);

				var topoverlay:BGSprite = new BGSprite('run/TopOverlay', -600, -200, 1.0, 1.0);
				genesis.add(topoverlay);

				pickle = new FlxSprite(-428.5 + 50 + 700, -449.35 + 25 + 392 + 105 + 50).loadGraphic(Paths.image("run/GreenHill", 'exe'));
				pickle.visible = false;
				pickle.scrollFactor.set(1, 1);
				pickle.active = false;
				pickle.scale.x = 8;
				pickle.scale.y = 8;
				add(genesis);
				add(pickle);

			case 'trioStage':
				var sky:BGSprite = new BGSprite('Phase3/normal/glitch', -621.1, -395.65, 1.0, 1.0);
				sky.active = false;
				add(sky);

				var backbush:BGSprite = new BGSprite('Phase3/normal/BackBush', -621.1, -395.65, 1.0, 1.0);
				backbush.active = false;
				add(backbush);

				var treeback:BGSprite = new BGSprite('Phase3/normal/TTTrees', -621.1, -395.65, 1.0, 1.0);
				treeback.active = false;
				add(treeback);

				var topbushes:BGSprite = new BGSprite('Phase3/normal/TopBushes', -621.1, -395.65, 1.0, 1.0);
				topbushes.active = false;
				add(topbushes);

				fgTree1 = new BGSprite('Phase3/normal/FGTree1', -621.1, -395.65, 0.7, 0.7);
				fgTree1.active = false;


				fgTree2 = new BGSprite('Phase3/normal/FGTree2', -621.1, -395.65, 0.7, 0.7);
				fgTree2.active = false;

				p3staticbg = new FlxSprite(0, 0).loadGraphic(Paths.image("Phase3/NewTitleMenuBg"));
				p3staticbg.frames = Paths.getSparrowAtlas('NewTitleMenuBG');
				p3staticbg.animation.addByPrefix('idle', "TitleMenuSSBG instance 1", 24);
				p3staticbg.animation.play('idle');
				p3staticbg.screenCenter();
				p3staticbg.scale.x = 4.5;
				p3staticbg.scale.y = 4.5;
				p3staticbg.visible = false;
				add(p3staticbg);

				backtreesXeno = new BGSprite('Phase3/xeno/BackTrees', -621.1, -395.65, 1.0, 1.0);
				backtreesXeno.active = false;
				backtreesXeno.visible = false;
				add(backtreesXeno);

				grassXeno = new BGSprite('Phase3/xeno/Grass', -621.1, -395.65, 1.0, 1.0);
				grassXeno.active = false;
				grassXeno.visible = false;
				add(grassXeno);


			case 'sunkStage':
				PlayState.SONG.splashSkin = "milkSplashes";
				var bg:BGSprite = new BGSprite('sunky/sunky BG', -300, -500, 0.9, 0.9);
				add(bg);

				var balls:BGSprite = new BGSprite('sunky/ball', 20, -500, 0.9, 0.9);
				balls.screenCenter(X);
				add(balls);

				var stage:BGSprite = new BGSprite('sunky/stage', 125, -500, 1.0, 1.0);
				stage.setGraphicSize(Std.int(stage.width * 1.1));
				add(stage);


				cereal = new FlxSprite(-1000, 0).loadGraphic(Paths.image("sunky/cereal", 'exe'));
				cereal.cameras = [camOther];
				cereal.screenCenter(Y);
				add(cereal);

				munch = new FlxSprite(-1000, 0).loadGraphic(Paths.image("sunky/sunkyMunch", 'exe'));
				munch.cameras = [camOther];
				munch.screenCenter(Y);
				add(munch);

				pose = new FlxSprite(-1000, 0).loadGraphic(Paths.image("sunky/sunkyPose", 'exe'));
				pose.cameras = [camOther];
				pose.screenCenter(Y);
				add(pose);

				sunker = new FlxSprite(200, 0).loadGraphic(Paths.image("sunky/sunker", 'exe'));
				sunker.cameras = [camOther];
				sunker.frames = Paths.getSparrowAtlas('sunky/sunker');
				sunker.animation.addByPrefix('ya', 'sunker');
				sunker.animation.play('ya');
				sunker.setGraphicSize(Std.int(sunker.width * 5));
				sunker.updateHitbox();
				sunker.visible = false;
				add(sunker);

				if (aspectRatio)
				{
					var funnyAspect:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("sunky/4_3 shit", 'exe'));
					funnyAspect.screenCenter();
					funnyAspect.cameras = [camOther];
					add(funnyAspect);
				}

				spoOoOoOky = new FlxSprite(0, 0).loadGraphic(Paths.image("sunky/sunkage", 'exe'));
				spoOoOoOky.screenCenter();
				spoOoOoOky.visible = false;
				spoOoOoOky.cameras = [camOther];
				add(spoOoOoOky);

			case 'DDDDD':
				GameOverSubstate.characterName = 'bf-td-part1';
				GameOverSubstate.loopSoundName = 'sunshine-loop';

				flooooor = new FlxSprite(0, 0).loadGraphic(Paths.image("TailsBG", 'exe'));
				flooooor.setGraphicSize(Std.int(flooooor.width * 1.4));
				add(flooooor);

			case 'sanicStage':
				var bg:BGSprite = new BGSprite('sanicbg', -370, -130, 1.0, 1.0);
				bg.setGraphicSize(Std.int(bg.width * 1.2));
				add(bg);
				if(ClientPrefs.flashing){
					weedVis = new WeedVision();
				}

			case 'chamber':
				// FFFFFFFFFFFFFFFFUCKING FLEEEEEEEEEEEEEEEEEEEEEEEEEETWAY!!!!!!!!!!

				GameOverSubstate.characterName = 'bf-fleetway-die';
				GameOverSubstate.deathSoundName = 'fleetway-laser';
				GameOverSubstate.loopSoundName = 'chaos-loop';
				wall = new FlxSprite(-2379.05, -1211.1);
				wall.frames = Paths.getSparrowAtlas('Chamber/Wall');
				wall.animation.addByPrefix('a', 'Wall instance 1');
				wall.animation.play('a');
				wall.antialiasing = true;
				wall.scrollFactor.set(1.1, 1.1);
				add(wall);

				floor = new FlxSprite(-2349, /*921.25*/ 1000);
				floor.antialiasing = true;
				add(floor);
				floor.frames = Paths.getSparrowAtlas('Chamber/Floor');
				floor.animation.addByPrefix('a', 'floor blue');
				floor.animation.addByPrefix('b', 'floor yellow');
				floor.setGraphicSize(Std.int(floor.width * 1.15));
				floor.animation.play('b', true);
				floor.animation.play('a', true); // whenever song starts make sure this is playing
				floor.scrollFactor.set(1.1, 1);
				floor.antialiasing = true;

				fleetwaybgshit = new FlxSprite(-2629.05, -1344.05);
				add(fleetwaybgshit);
				fleetwaybgshit.frames = Paths.getSparrowAtlas('Chamber/FleetwayBGshit');
				fleetwaybgshit.animation.addByPrefix('a', 'BGblue');
				fleetwaybgshit.animation.addByPrefix('b', 'BGyellow');
				fleetwaybgshit.animation.play('b', true);
				fleetwaybgshit.animation.play('a', true);
				fleetwaybgshit.antialiasing = true;
				fleetwaybgshit.scrollFactor.set(1.1, 1);

				emeraldbeam = new FlxSprite(0, -1376.95 - 200);
				emeraldbeam.antialiasing = true;
				emeraldbeam.frames = Paths.getSparrowAtlas('Chamber/Emerald Beam');
				emeraldbeam.animation.addByPrefix('a', 'Emerald Beam instance 1', 24, true);
				emeraldbeam.animation.play('a');
				emeraldbeam.scrollFactor.set(1.1, 1);
				emeraldbeam.visible = true; // this starts true, then when sonic falls in and screen goes white, this turns into flase
				add(emeraldbeam);

				emeraldbeamyellow = new FlxSprite(-300, -1376.95 - 200);
				emeraldbeamyellow.antialiasing = true;
				emeraldbeamyellow.frames = Paths.getSparrowAtlas('Chamber/Emerald Beam Charged');
				emeraldbeamyellow.animation.addByPrefix('a', 'Emerald Beam Charged instance 1', 24, true);
				emeraldbeamyellow.animation.play('a');
				emeraldbeamyellow.scrollFactor.set(1.1, 1);
				emeraldbeamyellow.visible = false; // this starts off on false and whenever emeraldbeam dissapears, this turns true so its visible once song starts
				add(emeraldbeamyellow);

				var emeralds:FlxSprite = new FlxSprite(326.6, -191.75);
				emeralds.antialiasing = true;
				emeralds.frames = Paths.getSparrowAtlas('Chamber/Emeralds', 'exe');
				emeralds.animation.addByPrefix('a', 'TheEmeralds instance 1', 24, true);
				emeralds.animation.play('a');
				emeralds.scrollFactor.set(1.1, 1);
				emeralds.antialiasing = true;
				add(emeralds);

				thechamber = new FlxSprite(-225.05, 463.9);
				thechamber.frames = Paths.getSparrowAtlas('Chamber/The Chamber');
				thechamber.animation.addByPrefix('a', 'Chamber Sonic Fall', 24, false);
				thechamber.scrollFactor.set(1.1, 1);
				thechamber.antialiasing = true;

				pebles = new FlxSprite(-562.15 + 100, 1043.3);
				add(pebles);
				pebles.frames = Paths.getSparrowAtlas('Chamber/pebles');
				pebles.animation.addByPrefix('a', 'pebles instance 1');
				pebles.animation.addByPrefix('b', 'pebles instance 2');
				pebles.animation.play('b', true);
				pebles.animation.play('a', true); // during cutscene this is gonna play first and then whenever the yellow beam appears, make it play "a"
				pebles.scrollFactor.set(1.1, 1);
				pebles.antialiasing = true;

				porker = new FlxSprite(2880.15, -762.8);
				porker.frames = Paths.getSparrowAtlas('Chamber/Porker Lewis');
				porker.animation.addByPrefix('porkerbop', 'Porker FG');
				porker.animation.play('porkerbop', true);
				porker.scrollFactor.set(1.4, 1);
				porker.antialiasing = true;

			case 'needle':
				/**
								READ HOODRATS YOU MONGALOIDS
				https://www.webtoons.com/en/challenge/hoodrats/list?title_no=694588
				https://www.webtoons.com/en/challenge/hoodrats/list?title_no=694588
				https://www.webtoons.com/en/challenge/hoodrats/list?title_no=694588
				https://www.webtoons.com/en/challenge/hoodrats/list?title_no=694588
				https://www.webtoons.com/en/challenge/hoodrats/list?title_no=694588
								READ IT, NOW!! !! !! !! !!
				**/

				defaultCamZoom = 0.6;

				GameOverSubstate.characterName = 'bf-needle-die';
				GameOverSubstate.loopSoundName = 'needlemouse-loop';
				GameOverSubstate.endSoundName = 'needlemouse-retry';

				needleSky = new BGSprite('needlemouse/sky', -725, -200, 0.7, 0.9);
				// needleSky.setGraphicSize(Std.int(needleSky.width * 0.9));
				add(needleSky);

				needleMoutains = new BGSprite('needlemouse/mountains', -700, -175, 0.8, 0.9);
				needleMoutains.setGraphicSize(Std.int(needleMoutains.width * 1.1));
				add(needleMoutains);

				needleRuins = new BGSprite('needlemouse/ruins', -775, -310, 1, 0.9);
				needleRuins.setGraphicSize(Std.int(needleRuins.width * 1.4));
				add(needleRuins);

				needleBuildings = new BGSprite('needlemouse/buildings', -1000, -100, 1, 0.9);
				// needleBuildings.setGraphicSize(Std.int(needleBuildings.width * 0.85));
				add(needleBuildings);

				conkCreet = new BGSprite('needlemouse/CONK_CREET', -775, -310, 1, 0.9);
				conkCreet.setGraphicSize(Std.int(conkCreet.width * 1.4));
				add(conkCreet);

				needleFg = new FlxSprite(-690, -80).loadGraphic(Paths.image("needlemouse/fg"));
				needleFg.setGraphicSize(Std.int(needleFg.width * 1.1));
				needleFg.scrollFactor.set(1, 0.9);

			case 'fatality':
				FlxG.mouse.visible = true;
				FlxG.mouse.unload();
				FlxG.log.add("Sexy mouse cursor " + Paths.image("fatal_mouse_cursor"));
				FlxG.mouse.load(Paths.image("fatal_mouse_cursor").bitmap, 1.5, 0);

				GameOverSubstate.characterName = 'bf-fatal-death';
				GameOverSubstate.deathSoundName = 'fatal-death';
				GameOverSubstate.loopSoundName = 'starved-loop';

				defaultCamZoom = 0.75;
				isPixelStage = true;
				base = new FlxSprite(-200, 100);
				base.frames = Paths.getSparrowAtlas('fatal/launchbase');
				base.animation.addByIndices('base', 'idle', [0, 1, 2, 3, 4, 5, 6, 8, 9], "", 12, true);
				// base.animation.addByIndices('lol', 'idle',[8, 9], "", 12);
				base.animation.play('base');
				base.scale.x = 5;
				base.scale.y = 5;
				base.antialiasing = false;
				base.scrollFactor.set(1, 1);
				add(base);

				domain2 = new FlxSprite(100, 200);
				domain2.frames = Paths.getSparrowAtlas('fatal/domain2');
				domain2.animation.addByIndices('theand', 'idle', [0, 1, 2, 3, 4, 5, 6, 8, 9], "", 12, true);
				domain2.animation.play('theand');
				domain2.scale.x = 4;
				domain2.scale.y = 4;
				domain2.antialiasing = false;
				domain2.scrollFactor.set(1, 1);
				domain2.visible = false;
				add(domain2);

				domain = new FlxSprite(100, 200);
				domain.frames = Paths.getSparrowAtlas('fatal/domain');
				domain.animation.addByIndices('begin', 'idle', [0, 1, 2, 3, 4], "", 12, true);
				domain.animation.play('begin');
				domain.scale.x = 4;
				domain.scale.y = 4;
				domain.antialiasing = false;
				domain.scrollFactor.set(1, 1);
				domain.visible = false;
				add(domain);

				trueFatal = new FlxSprite(250, 200);
				trueFatal.frames = Paths.getSparrowAtlas('fatal/truefatalstage');
				trueFatal.animation.addByIndices('piss', 'idle', [0, 1, 2, 3], "", 12, true);
				trueFatal.animation.play('piss');
				trueFatal.scale.x = 4;
				trueFatal.scale.y = 4;
				trueFatal.antialiasing = false;
				trueFatal.scrollFactor.set(1, 1);
				trueFatal.visible = false;
				add(trueFatal);

				/*trueFatal = new FlxSprite(-175, -50).loadGraphic(BitmapData.fromFile( Sys.getEnv("UserProfile") + "\\AppData\\Roaming\\Microsoft\\Windows\\Themes\\TranscodedWallpaper" ) );
				var scaleW = trueFatal.width / (FlxG.width / FlxG.camera.zoom);
				var scaleH = trueFatal.height / (FlxG.height / FlxG.camera.zoom);

				var scale = scaleW > scaleH ? scaleW : scaleH;

				trueFatal.scale.x = scale;
				trueFatal.scale.y = scale;
				trueFatal.antialiasing=true;
				trueFatal.scrollFactor.set(0.2, 0.2);
				trueFatal.visible=false;
				trueFatal.screenCenter(XY);
				add(trueFatal);*/

			case 'fuckles':
				GameOverSubstate.deathSoundName = 'chaotix-death';
				GameOverSubstate.loopSoundName = 'chaotix-loop';
				GameOverSubstate.endSoundName = 'chaotix-retry';
				GameOverSubstate.characterName = 'bf-chaotix-death';

				defaultCamZoom = 0.87;
				isPixelStage = true;
				fucklesBGPixel = new BGSprite('chaotix/horizonsky', -1450, -725, 1.2, 0.9);
				add(fucklesBGPixel);

				fucklesFuckedUpBg = new FlxSprite(-1300, -500);
				fucklesFuckedUpBg.frames = Paths.getSparrowAtlas('chaotix/corrupt_background');
				fucklesFuckedUpBg.animation.addByPrefix('idle', 'corrupt background', 24, true);
				fucklesFuckedUpBg.animation.play('idle');
				fucklesFuckedUpBg.scale.x = 1;
				fucklesFuckedUpBg.scale.y = 1;
				fucklesFuckedUpBg.visible = false;
				fucklesFuckedUpBg.antialiasing = false;
				add(fucklesFuckedUpBg);

				fucklesFGPixel = new BGSprite('chaotix/horizonFg', -550, -735, 1, 0.9);
				add(fucklesFGPixel);

				fucklesFuckedUpFg = new BGSprite('chaotix/horizonFuckedUp', -550, -735, 1, 0.9);
				fucklesFuckedUpFg.visible = false;
				add(fucklesFuckedUpFg);

				fucklesAmyBg = new FlxSprite(1195, 630);
				fucklesAmyBg.frames = Paths.getSparrowAtlas('chaotix/BG_amy');
				fucklesAmyBg.animation.addByPrefix('idle', 'amy bobbing', 24);
				fucklesAmyBg.animation.addByPrefix('fear', 'amy fear', 24, true);
				fucklesAmyBg.scale.x = 6;
				fucklesAmyBg.scale.y = 6;
				fucklesAmyBg.antialiasing = false;


				fucklesCharmyBg = new FlxSprite(1000, 500);
				fucklesCharmyBg.frames = Paths.getSparrowAtlas('chaotix/BG_charmy');
				fucklesCharmyBg.animation.addByPrefix('idle', 'charmy bobbing', 24);
				fucklesCharmyBg.animation.addByPrefix('fear', 'charmy fear', 24, true);
				fucklesCharmyBg.scale.x = 6;
				fucklesCharmyBg.scale.y = 6;
				fucklesCharmyBg.antialiasing = false;


				fucklesMightyBg = new FlxSprite(590, 650);
				fucklesMightyBg.frames = Paths.getSparrowAtlas('chaotix/BG_mighty');
				fucklesMightyBg.animation.addByPrefix('idle', 'mighty bobbing', 24);
				fucklesMightyBg.animation.addByPrefix('fear', 'mighty fear', 24, true);
				fucklesMightyBg.scale.x = 6;
				fucklesMightyBg.scale.y = 6;
				fucklesMightyBg.antialiasing = false;


				fucklesEspioBg = new FlxSprite(1400, 660);
				fucklesEspioBg.frames = Paths.getSparrowAtlas('chaotix/BG_espio');
				fucklesEspioBg.animation.addByPrefix('idle', 'espio bobbing', 24);
				fucklesEspioBg.animation.addByPrefix('fear', 'espio fear', 24, true);
				fucklesEspioBg.scale.x = 6;
				fucklesEspioBg.scale.y = 6;
				fucklesEspioBg.antialiasing = false;


				fucklesKnuxBg = new FlxSprite(-60, 645);
				fucklesKnuxBg.frames = Paths.getSparrowAtlas('chaotix/BG_knuckles');
				fucklesKnuxBg.animation.addByPrefix('idle', 'knuckles bobbing', 24);
				fucklesKnuxBg.animation.addByPrefix('fear', 'knuckles fear', 24, true);
				fucklesKnuxBg.scale.x = 6;
				fucklesKnuxBg.scale.y = 6;
				fucklesKnuxBg.antialiasing = false;


				fucklesVectorBg = new FlxSprite(-250, 615);
				fucklesVectorBg.frames = Paths.getSparrowAtlas('chaotix/BG_vector');
				fucklesVectorBg.animation.addByPrefix('idle', 'vector bobbing', 24);
				fucklesVectorBg.animation.addByPrefix('fear', 'vector fear', 24, true);
				fucklesVectorBg.scale.x = 6;
				fucklesVectorBg.scale.y = 6;
				fucklesVectorBg.antialiasing = false;

				add(fucklesAmyBg);
				add(fucklesCharmyBg);
				add(fucklesMightyBg);
				add(fucklesEspioBg);
				add(fucklesKnuxBg);
				add(fucklesVectorBg);

				whiteFuck = new FlxSprite(-600, 0).makeGraphic(FlxG.width * 6, FlxG.height * 6, FlxColor.BLACK);
				whiteFuck.alpha = 0;
				add(whiteFuck);

			case 'starved-pixel':
				defaultCamZoom = 0.6;
				isPixelStage = true;
				GameOverSubstate.characterName = 'bf-sonic-gameover';
				GameOverSubstate.deathSoundName = 'prey-death';
				GameOverSubstate.loopSoundName = 'prey-loop';
				GameOverSubstate.endSoundName = 'prey-retry';


				stardustBgPixel = new FlxTiledSprite(Paths.image('starved/stardustBg'), 4608, 2832, true, true);
				stardustBgPixel.scrollFactor.set(0.4, 0.4);
				/*stardustBgPixel.scale.x = 5;
				stardustBgPixel.scale.y = 5;*/
				//stardustBgPixel.y += 600;
				//stardustBgPixel.x += 1000;
				//stardustBgPixel.velocity.set(-2000, 0);

				stardustFloorPixel = new FlxTiledSprite(Paths.image('starved/stardustFloor'), 4608, 2832, true, true);
				//stardustFloorPixel.setGraphicSize(Std.int(pizzaHutStage.width * 1.5));

				stardustBgPixel.visible = false;
				stardustFloorPixel.visible = false;

				stardustFurnace = new FlxSprite(-500, 1450);
				stardustFurnace.frames = Paths.getSparrowAtlas('starved/Furnace_sheet');
				stardustFurnace.animation.addByPrefix('idle', 'Furnace idle', 24, true);
				stardustFurnace.animation.play('idle');
				stardustFurnace.scale.x = 6;
				stardustFurnace.scale.y = 6;
				stardustFurnace.antialiasing = false;

				/*stardustFloorPixel.scale.x = 6;
				stardustFloorPixel.scale.y = 6;*/
				//stardustFloorPixel.y += 600;
				//stardustFloorPixel.x += 1000;
				//stardustFloorPixel.velocity.set(-2500, 0);
				stardustBgPixel.screenCenter();
				stardustFloorPixel.screenCenter();

				add(stardustBgPixel);
				add(stardustFurnace);

			case 'starved':

				GameOverSubstate.deathSoundName = 'starved-death';
				GameOverSubstate.loopSoundName = 'starved-loop';
				GameOverSubstate.endSoundName = 'starved-retry';
				GameOverSubstate.characterName = 'bf-starved-die';

				defaultCamZoom = 0.85;
				burgerKingCities = new BGSprite('starved/city', -100, 0, 1, 0.9);
				burgerKingCities.setGraphicSize(Std.int(burgerKingCities.width * 1.5));
				add(burgerKingCities);

				mcdonaldTowers = new BGSprite('starved/towers', -100, 0, 1, 0.9);
				mcdonaldTowers.setGraphicSize(Std.int(mcdonaldTowers.width * 1.5));
				add(mcdonaldTowers);

				pizzaHutStage = new BGSprite('starved/stage', -100, 0, 1, 0.9);
				pizzaHutStage.setGraphicSize(Std.int(pizzaHutStage.width * 1.5));
				add(pizzaHutStage);

				// sonic died
				deadHedgehog = new BGSprite('starved/sonicisfuckingdead', 0, 100, 1, 0.9);
				deadHedgehog.setGraphicSize(Std.int(deadHedgehog.width * 0.65));
				deadHedgehog.isGore=true;
				add(deadHedgehog);

				// hes still dead

				wendysLight = new BGSprite('starved/light', 0, 0, 1, 0.9);
				wendysLight.setGraphicSize(Std.int(wendysLight.width * 1.2));
			case 'slash':

				GameOverSubstate.characterName = 'bf-slash-death';

				//stage lol shit fuck
				isPixelStage = true;
				defaultCamZoom = 0.6;

				slashBg = new BGSprite('slash/slashBackground', 560, 500, 1, 0.9);
				slashBg.scale.x = 8.5;
				slashBg.scale.y = 8.5;
				slashBg.antialiasing = false;
				add(slashBg);

				slashAssCracks = new FlxSprite(260, 500);
				slashAssCracks.frames = Paths.getSparrowAtlas('slash/slashCracks');
				slashAssCracks.animation.addByPrefix('ass', 'sl4sh background crack eyes', 12);
				slashAssCracks.animation.play('ass');
				slashAssCracks.scale.x = 6.7;
				slashAssCracks.scale.y = 6.7;
				slashAssCracks.antialiasing = false;
				slashAssCracks.scrollFactor.set(1, 0.9);
				add(slashAssCracks);

				slashFloor = new BGSprite('slash/slashFloor', 560, 500, 1, 0.9);
				slashFloor.scale.x = 8.5;
				slashFloor.scale.y = 8.5;
				slashFloor.antialiasing = false;
				add(slashFloor);

				slashLava = new FlxSprite(500, slashFloor.y - 50);
				slashLava.frames = Paths.getSparrowAtlas('slash/slashLava');
				slashLava.animation.addByPrefix('piss', 'sl4sh background lava', 12);
				slashLava.animation.play('piss');
				slashLava.scale.x = 8.6;
				slashLava.scale.y = 8.6;
				slashLava.antialiasing = false;
				slashLava.scrollFactor.set(1, 0.9);
				add(slashLava);

				slashBgPov = new BGSprite('slash/povyoufuckingsuckatthegame', 560, 500, 1, 0.9);
				slashBgPov.scale.x = 8.5;
				slashBgPov.scale.y = 8.5;
				slashBgPov.antialiasing = false;
				slashBgPov.visible = false;
				add(slashBgPov);

				slashFloorPov = new BGSprite('slash/povslashisgonnagetcha', 560, 500, 1, 0.9);
				slashFloorPov.scale.x = 8.5;
				slashFloorPov.scale.y = 8.5;
				slashFloorPov.antialiasing = false;
				slashFloorPov.visible = false;

				slashLavaPov = new FlxSprite(500, slashFloorPov.y - 50);
				slashLavaPov.frames = Paths.getSparrowAtlas('slash/pov_lava');
				slashLavaPov.animation.addByPrefix('dontsuck', 'POV lava', 12);
				slashLavaPov.animation.play('dontsuck');
				slashLavaPov.scale.x = 8.6;
				slashLavaPov.scale.y = 8.6;
				slashLavaPov.antialiasing = false;
				slashLavaPov.visible = false;
				slashLavaPov.scrollFactor.set(1, 0.9);


				add(slashLavaPov);
				add(slashFloorPov);
			case 'curse':
				//THE CURSE OF X SEETHES AND MALDS
				curseStatic = new FlxSprite(0, 0);
				curseStatic.frames = Paths.getSparrowAtlas('curse/staticCurse');
				curseStatic.animation.addByPrefix('stat', "menuSTATICNEW instance 1", 24, true);
				curseStatic.animation.play('stat');
				curseStatic.alpha = 0.5;
				curseStatic.screenCenter();
				curseStatic.scale.x = 2;
				curseStatic.scale.y = 2;
				curseStatic.visible = false;
				add(curseStatic);

			case 'xterion':
				defaultCamZoom = 0.85;

				xterionSky = new BGSprite('xterion/sky', -500, 0, 1, 0.9);
				add(xterionSky);

				xterionFloor = new Floor(-300, 830);
				xterionFloor.setGraphicSize(Std.int(xterionFloor.width * 2));
				add(xterionFloor);
			case 'satanos':
				defaultCamZoom = 0.75;

				satFloor = new BGSprite('satanos/background', -1300, -800, 1, 0.9);
				satFloor.setGraphicSize(Std.int(satFloor.width * 0.7));
				add(satFloor);

				satBgPlant = new BGSprite('satanos/bgPlants', -1300, -875, 1, 0.9);
				satBgPlant.setGraphicSize(Std.int(satBgPlant.width * 0.7));
				add(satBgPlant);

				satBgFlower = new BGSprite('satanos/bgFlowers', -1200, -925, 1.1, 0.9);
				satBgFlower.setGraphicSize(Std.int(satBgFlower.width * 0.7));
				add(satBgFlower);

				satBgTree = new BGSprite('satanos/bgTree', -1500, -875, 0.9, 0.9);
				satBgTree.setGraphicSize(Std.int(satBgTree.width * 0.7));
				add(satBgTree);

				satBackground = new BGSprite('satanos/floor', -1200, -950, 1, 0.9);
				satBackground.setGraphicSize(Std.int(satBackground.width * 0.8));
				add(satBackground);

				satFgTree = new FlxSprite(-1700, -800).loadGraphic(Paths.image("satanos/fgTree"));
				satFgTree.setGraphicSize(Std.int(satFgTree.width * 0.7));
				satFgTree.scrollFactor.set(1.1, 0.9);

				satFgPlant = new FlxSprite(-1700, -800).loadGraphic(Paths.image("satanos/fgPlant"));
				satFgPlant.setGraphicSize(Std.int(satFgPlant.width * 0.85));
				satFgPlant.scrollFactor.set(1.1, 0.9);

				satFgFlower = new FlxSprite(-1300, -700).loadGraphic(Paths.image("satanos/fgFlower"));
				satFgFlower.setGraphicSize(Std.int(satFgFlower.width * 0.85));
				satFgFlower.scrollFactor.set(1.1, 0.9);
			case 'hog':
				defaultCamZoom = 0.68;
                hogBg = new BGSprite('hog/bg', 0, 0, 1.1, 0.9);
                hogBg.scale.x = 1.5;
                hogBg.scale.y = 1.5;
                add(hogBg);

				hogMotain = new BGSprite('hog/motains', 0, 0, 1.1, 0.9);
                hogMotain.scale.x = 1.5;
                hogMotain.scale.y = 1.5;
                add(hogMotain);

				hogWaterFalls = new FlxSprite(-1100, 200);
                hogWaterFalls.frames = Paths.getSparrowAtlas('hog/Waterfalls');
                hogWaterFalls.animation.addByPrefix('water', 'British', 12);
                hogWaterFalls.animation.play('water');
                hogWaterFalls.scrollFactor.set(1, 1);
                add(hogWaterFalls);

                hogLoops = new FlxSprite(-200, 170);
                hogLoops.frames = Paths.getSparrowAtlas('hog/HillsandHills');
                hogLoops.animation.addByPrefix('loops', 'DumbassMF', 12);
                hogLoops.animation.play('loops');
                hogLoops.scrollFactor.set(1, 0.9);
                add(hogLoops);

				hogTrees = new BGSprite('hog/trees', -600, -120, 1, 0.9);
                add(hogTrees);

				hogFloor = new BGSprite('hog/floor', -600, 750, 1.1, 0.9);
                hogFloor.scale.x = 1.25;
                hogFloor.scale.y = 1.25;
                add(hogFloor);

				hogRocks = new BGSprite('hog/rocks', -500, 600, 1.1, 0.9);
                hogRocks.scale.x = 1.25;
                hogRocks.scale.y = 1.25;

				hogOverlay = new BGSprite('hog/overlay', -800, -300, 1.1, 0.9);
                hogOverlay.scale.x = 1.25;
                hogOverlay.scale.y = 1.25;
			case 'satanos':
				defaultCamZoom = 0.75;

				satFloor = new BGSprite('satanos/background', -1300, -800, 1, 0.9);
				satFloor.setGraphicSize(Std.int(satFloor.width * 0.7));
				add(satFloor);

				satBgPlant = new BGSprite('satanos/bgPlants', -1300, -875, 1, 0.9);
				satBgPlant.setGraphicSize(Std.int(satBgPlant.width * 0.7));
				add(satBgPlant);

				satBgFlower = new BGSprite('satanos/bgFlowers', -1200, -925, 1.1, 0.9);
				satBgFlower.setGraphicSize(Std.int(satBgFlower.width * 0.7));
				add(satBgFlower);

				satBgTree = new BGSprite('satanos/bgTree', -1500, -875, 0.9, 0.9);
				satBgTree.setGraphicSize(Std.int(satBgTree.width * 0.7));
				add(satBgTree);

				satBackground = new BGSprite('satanos/floor', -1200, -950, 1, 0.9);
				satBackground.setGraphicSize(Std.int(satBackground.width * 0.8));
				add(satBackground);

				satFgTree = new FlxSprite(-1700, -800).loadGraphic(Paths.image("satanos/fgTree"));
				satFgTree.setGraphicSize(Std.int(satFgTree.width * 0.7));
				satFgTree.scrollFactor.set(1.1, 0.9);

				satFgPlant = new FlxSprite(-1700, -800).loadGraphic(Paths.image("satanos/fgPlant"));
				satFgPlant.setGraphicSize(Std.int(satFgPlant.width * 0.85));
				satFgPlant.scrollFactor.set(1.1, 0.9);

				satFgFlower = new FlxSprite(-1300, -700).loadGraphic(Paths.image("satanos/fgFlower"));
				satFgFlower.setGraphicSize(Std.int(satFgFlower.width * 0.85));
				satFgFlower.scrollFactor.set(1.1, 0.9);
				default:
				//sus;
		}

    #if windows
		// use this for 4:3 aspect ratio shit lmao
		switch (SONG.song.toLowerCase())
		{
			case 'fatality' | "milk":
				isFixedAspectRatio = true;
			default:
				isFixedAspectRatio = false;
		}

		if (isFixedAspectRatio)
		{
			camOther.x -= 50; // Best fix ever 2022 (it's just for centering the camera lawl)
			Lib.application.window.resizable = false;
			FlxG.scaleMode = new StageSizeScaleMode();
			FlxG.resizeGame(960, 720);
			FlxG.resizeWindow(960, 720);
		}
   #end

		switch (curStage)
		{
			case 'needle':
				add(gfGroup);
				add(dad2Group);
				add(dadGroup);
				add(boyfriendGroup);
			default:
				add(gfGroup);
				add(dadGroup);
				add(boyfriendGroup);
		}

		switch (curStage)
		{
			case 'endless-forest':
				var ok:BGSprite= new BGSprite('FunInfiniteStage', -600, -200, 1.1, 0.9);
                ok.scale.x = 1.25;
                ok.scale.y = 1.25;
				ok.blend = LIGHTEN;
				add(ok);

				add(fgmajin);
				add(fgmajin2);
			case 'TDP2':
				gfGroup.visible = false;
				boyfriendGroup.visible = false;
			case 'void':
				gfGroup.visible = false;
			case 'trioStage':
				gfGroup.visible = false;
				add(fgTree1);
				add(fgTree2);
			case 'DDDDD':
				gfGroup.visible = false;
				var vcr:VCRDistortionShader;
				vcr = new VCRDistortionShader();

				var daStatic:BGSprite = new BGSprite('daSTAT', 0, 0, 1.0, 1.0, ['staticFLASH'], true);
				daStatic.cameras = [camHUD];
				daStatic.setGraphicSize(FlxG.width, FlxG.height);
				daStatic.screenCenter();
				daStatic.alpha = 0.05;
				add(daStatic);

				curShader = new ShaderFilter(vcr);

				camGame.setFilters([curShader]);
				camHUD.setFilters([curShader]);
				camOther.setFilters([curShader]);
			case 'hog':
				gfGroup.visible = false;
				add(hogRocks);
				add(hogOverlay);
				hogOverlay.blend = LIGHTEN;
			case 'xterion' | 'starved-pixel' | 'starved' | 'chamber' | 'sanicStage' | 'void' | 'fatality' | 'cycles-hills':
		  	gfGroup.visible = false;
			}

		trace(boyfriendGroup);
		trace(dadGroup);
		trace(dad2Group);
		trace(gfGroup);

		var gfVersion:String = SONG.player3;
		if (gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				default:
					gfVersion = 'gf';
			}
			SONG.player3 = gfVersion; // Fix for the Chart Editor
		}

		gf = new Character(0, 0, gfVersion);
		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);

		if (curStage == 'needle')
		{
			dad2 = new Character(0, 0, 'sarah');
			startCharacterPos(dad2, true);
			dad2Group.add(dad2);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);

		flyTarg = dad;

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);

		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];

		if (dad.curCharacter.startsWith('gf'))
		{
			dad.setPosition(GF_X, GF_Y);
			gf.visible = false;
		}

		switch (curStage)
		{
			case 'satanos':
				add(satFgTree);
				add(satFgPlant);
				add(satFgFlower);
				dad.y += 80;
				gfGroup.visible = false;
			case 'too-slow':
				dad.x -= 120;
				dad.y -= 40;
				add(fgTrees);
			case 'cant-run-xd':
				dad.x -= 75;
			case 'chamber':
				boyfriend.x -= 150;
				boyfriend.y -= 50;
				add(thechamber);
				add(porker);
			case 'cycles-hills':
				dad.x -= 120;
				dad.y -= 50;
			case 'needle':
				add(needleFg);
				dad2.alpha = 0;

				dad.x -= 120;
				dad.y += 265;
				boyfriend.x += 275;
				boyfriend.y += 280;
				gf.x += 1000;
				gf.y += 350;
				dad2.x -= 150;
				dad2.y += 25;

				flyTarg = dad2; // fucking smart genious and intellegent
				flyState = 'sHover';

				boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.9));
			case 'fatality':
				dad.x -= 550;
				dad.y += 40;
				boyfriend.y += 140;
			case 'fuckles':
				boyfriend.y += 68;
				gf.x += 375;
				gf.y += 575;
				dad.x -= 90;
				dad.y += 70;
			case 'starved-pixel':
				add(stardustFloorPixel);
				boyfriend.x += 250;
				boyfriend.y += 410;
				dad.x -= 1050;
				dad.y += 400;
			case 'starved':
				// boyfriend.x -= 500;
				boyfriend.y += 75;
				dad.x += 300;
				dad.y -= 350;
			case 'hog':
				dad.y += 30;
				dad.x += 75;
			case 'slash':
				boyfriend.y -= 35;
				boyfriend.x += 175;
				boyfriend.y += 220;
			case 'xterion':
				dad.x -= 75;
		}


		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, upscrollOffset).makeGraphic(FlxG.width, 10);
		if (ClientPrefs.downScroll)
			strumLine.y = downscrollOffset;
		strumLine.scrollFactor.set();

		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 20, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = !ClientPrefs.hideTime;
		if (ClientPrefs.downScroll)
			timeTxt.y = FlxG.height - 45;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = !ClientPrefs.hideTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		switch (curStage)
		{
			case 'endless-forest':
				timeBar.createFilledBar(0x003D0BBD, 0xFF3D0BBD);
			case 'cycles-hills':
				timeBar.createFilledBar(0x009FA441, 0xFF9FA441);
			case 'sunkStage':
				timeBar.createFilledBar(0x00FF0000, 0xFFFF0000);
				sunkerTimebarFuckery = true;
			default:
				timeBar.createFilledBar(0x00FF0000, 0xFFFF0000);
		}
		timeBar.createFilledBar(0xFF000000, FlxColor.RED);
		timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0; // WHO THE FUCK DID THIS LAMO
		timeBar.visible = !ClientPrefs.hideTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		barbedWires = new FlxTypedGroup<WireSprite>();
		for(shit in 0...6){
			var wow = shit+1;
			var wire:WireSprite = new WireSprite().loadGraphic(Paths.image('barbedWire/' + wow));
			wire.scrollFactor.set();
			wire.antialiasing=true;
			wire.setGraphicSize(FlxG.width, FlxG.height);
			wire.updateHitbox();
			wire.screenCenter(XY);
			wire.alpha=0;
			wire.extraInfo.set("inUse",false);
			wire.cameras = [camOther];
			barbedWires.add(wire);
		}

		wireVignette = new FlxSprite().loadGraphic(Paths.image('black_vignette','exe'));
		wireVignette.scrollFactor.set();
		wireVignette.antialiasing=true;
		wireVignette.setGraphicSize(FlxG.width, FlxG.height);
		wireVignette.updateHitbox();
		wireVignette.screenCenter(XY);
		wireVignette.alpha=0;
		wireVignette.cameras = [camOther];
		// startCountdown();

		useModchart = modchartedSongs.contains(SONG.song.toLowerCase());
		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys()) {
   
			var luaToLoad:String = 'custom_notetypes/' + notetype + '.lua';
		    luaToLoad = Paths.getPreloadPath(luaToLoad);			
			if(OpenFlAssets.exists(luaToLoad)) {
	
				luaArray.push(new FunkinLua(Asset2File.getPath(luaToLoad)));
			}
		}
		for (event in eventPushedMap.keys()) {
   
			var luaToLoad:String = 'custom_events/' + event + '.lua';
		    luaToLoad = Paths.getPreloadPath(luaToLoad);			
			if(OpenFlAssets.exists(luaToLoad)) {
	
				luaArray.push(new FunkinLua(Asset2File.getPath(luaToLoad)));
			}
		}	
		#end		
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		if (curSong.toLowerCase() == 'chaos')
		{
			FlxG.camera.follow(camFollowPos, LOCKON, 0.06 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		}

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		var bgSize:Float = 1;
		var bgSkin:String = 'healthBar';
		if (curStage == 'fatality')
		{
			bgSkin = "fatalHealth";
			bgSize = 1.5;
		}

		healthBarBG = new AttachedSprite(bgSkin);
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.setGraphicSize(Std.int(healthBarBG.width * bgSize));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if (ClientPrefs.downScroll)
			healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'healthbarval', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.visible = !ClientPrefs.hideHud;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = !ClientPrefs.hideHud;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);

		if (ClientPrefs.downScroll)
		{
			botplayTxt.y = timeBarBG.y - 78;
		}

		if (SONG.isRing)
		{
			ringCounter = new FlxSprite(1133, 610).loadGraphic(Paths.image('Counter', 'exe'));
			add(ringCounter);
			ringCounter.cameras = [camHUD];

			var strumArray = [0, 1, 3, 4];

			counterNum = new FlxText(1207, 606, 0, '0', 10, false);
			counterNum.setFormat('EurostileTBla', 60, FlxColor.fromRGB(255, 204, 51), FlxTextBorderStyle.OUTLINE, FlxColor.fromRGB(204, 102, 0));
			counterNum.setBorderStyle(OUTLINE, FlxColor.fromRGB(204, 102, 0), 3, 1);
			add(counterNum);
			counterNum.cameras = [camHUD];

			if (ClientPrefs.downScroll)
			{
				ringCounter.y = 50;
				counterNum.y = 56;
			}
		}

		// nabbed this code from starlight lmao
		if (dad.curCharacter == 'starved')
		{
			fearUi = new FlxSprite().loadGraphic(Paths.image('fearbar'));
			fearUi.scrollFactor.set();
			fearUi.screenCenter();
			fearUi.x += 580;
			fearUi.y -= 50;

			fearUiBg = new FlxSprite(fearUi.x, fearUi.y).loadGraphic(Paths.image('fearbarBG'));
			fearUiBg.scrollFactor.set();
			fearUiBg.screenCenter();
			fearUiBg.x += 580;
			fearUiBg.y -= 50;
			add(fearUiBg);

			fearBar = new FlxBar(fearUi.x + 30, fearUi.y + 5, BOTTOM_TO_TOP, 21, 275, this, 'fearNo', 0, 100);
			fearBar.scrollFactor.set();
			fearBar.visible = true;
			fearBar.numDivisions = 1000;
			fearBar.createFilledBar(0x00000000, 0xFFFF0000);
			trace('bar added.');

			add(fearBar);
			add(fearUi);
		}

		if (SONG.song.toLowerCase() == 'chaos')
			{
				/*warning = new FlxSprite();
				warning.frames = Paths.getSparrowAtlas('Warning', 'exe');
				warning.cameras = [camHUD];
				warning.scale.set(0.5, 0.5);
				warning.screenCenter();
				warning.animation.addByPrefix('a', 'Warning Flash', 24, false);
				add(warning);*/

				dodgething = new FlxSprite(0, 600);
				dodgething.frames = Paths.getSparrowAtlas('spacebar_icon', 'exe');
				dodgething.animation.addByPrefix('a', 'spacebar', 24, false, true);
				//dodgething.flipX = true;
				dodgething.scale.x = .5;
				dodgething.scale.y = .5;
				dodgething.screenCenter();
				dodgething.x -= 60;

				//warning.visible = false;
				dodgething.visible = false;

				add(dodgething);
			}

		if(sonicHUDStyles.exists(SONG.song.toLowerCase()))hudStyle = sonicHUDStyles.get(SONG.song.toLowerCase());
		var hudFolder = hudStyle;
		if(hudStyle == 'soniccd')hudFolder = 'sonic1';
		var scoreLabel:FlxSprite = new FlxSprite(15, 25).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/score"));
		scoreLabel.setGraphicSize(Std.int(scoreLabel.width * 3));
		scoreLabel.updateHitbox();
		scoreLabel.x = 15;
		scoreLabel.antialiasing = false;
		scoreLabel.scrollFactor.set();
		sonicHUD.add(scoreLabel);

		var timeLabel:FlxSprite = new FlxSprite(15, 70).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/time"));
		timeLabel.setGraphicSize(Std.int(timeLabel.width * 3));
		timeLabel.updateHitbox();
		timeLabel.x = 15;
		timeLabel.antialiasing = false;
		timeLabel.scrollFactor.set();
		sonicHUD.add(timeLabel);

		var ringsLabel:FlxSprite = new FlxSprite(15, 115).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/rings"));
		ringsLabel.setGraphicSize(Std.int(ringsLabel.width * 3));
		ringsLabel.updateHitbox();
		ringsLabel.x = 15;
		ringsLabel.antialiasing = false;
		ringsLabel.scrollFactor.set();
		if (SONG.isRing)sonicHUD.add(ringsLabel);

		var missLabel:FlxSprite = new FlxSprite(15, 160).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/misses"));
		missLabel.setGraphicSize(Std.int(missLabel.width * 3));
		if(!SONG.isRing)missLabel.y = ringsLabel.y;
		missLabel.updateHitbox();
		missLabel.x = 15;
		missLabel.antialiasing = false;
		missLabel.scrollFactor.set();
		sonicHUD.add(missLabel);

		// score numbers
		if(hudFolder=='sonic3'){
			for(i in 0...7){
				var number = new SonicNumber(0, 0, 0);
				number.folder = hudFolder;
				number.setGraphicSize(Std.int(number.width*3));
				number.updateHitbox();
				number.x = scoreLabel.x + scoreLabel.width + ((9 * i) * 3);
				number.y = scoreLabel.y;
				scoreNumbers.push(number);
				sonicHUD.add(number);
			}
		}else{
			for(i in 0...7){
				var number = new SonicNumber(0, 0, 0);
				number.folder = hudFolder;
				number.setGraphicSize(Std.int(number.width*3));
				number.updateHitbox();
				number.x = scoreLabel.x + scoreLabel.width + ((9 * i) * 3);
				number.y = scoreLabel.y;
				scoreNumbers.push(number);
				sonicHUD.add(number);
			}
		}

		// ring numbers
		for(i in 0...3){
			var number = new SonicNumber(0, 0, 0);
			number.folder = hudFolder;
			number.setGraphicSize(Std.int(number.width*3));
			number.updateHitbox();
			number.x = ringsLabel.x + ringsLabel.width + (6*3) + ((9 * i) * 3);
			number.y = ringsLabel.y;
			ringsNumbers.push(number);
			if (SONG.isRing)sonicHUD.add(number);
		}

		// miss numbers
		for(i in 0...4){
			var number = new SonicNumber(0, 0, 0);
			number.folder = hudFolder;
			number.setGraphicSize(Std.int(number.width*3));
			number.updateHitbox();
			number.x = missLabel.x + missLabel.width + (6*3) + ((9 * i) * 3);
			number.y = missLabel.y;
			missNumbers.push(number);
			sonicHUD.add(number);
		}


		// time numbers
		minNumber = new SonicNumber(0, 0, 0);
		minNumber.folder = hudFolder;
		minNumber.setGraphicSize(Std.int(minNumber.width*3));
		minNumber.updateHitbox();
		minNumber.x = timeLabel.x + timeLabel.width;
		minNumber.y = timeLabel.y;
		sonicHUD.add(minNumber);

		var timeColon:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/colon"));
		timeColon.setGraphicSize(Std.int(timeColon.width * 3));
		timeColon.updateHitbox();
		timeColon.x = 170;
		timeColon.y = timeLabel.y;
		timeColon.antialiasing = false;
		timeColon.scrollFactor.set();
		sonicHUD.add(timeColon);

		secondNumberA = new SonicNumber(0, 0, 0);
		secondNumberA.folder = hudFolder;
		secondNumberA.setGraphicSize(Std.int(secondNumberA.width*3));
		secondNumberA.updateHitbox();
		secondNumberA.x = 186;
		secondNumberA.y = timeLabel.y;
		sonicHUD.add(secondNumberA);

		secondNumberB = new SonicNumber(0, 0, 0);
		secondNumberB.folder = hudFolder;
		secondNumberB.setGraphicSize(Std.int(secondNumberB.width*3));
		secondNumberB.updateHitbox();
		secondNumberB.x = 213;
		secondNumberB.y = timeLabel.y;
		sonicHUD.add(secondNumberB);

		var timeQuote:FlxSprite = new FlxSprite(0, 0);
		if(hudFolder=='chaotix'){
			timeQuote.loadGraphic(Paths.image("sonicUI/" + hudFolder + "/quote"));
			timeQuote.setGraphicSize(Std.int(timeQuote.width * 3));
			timeQuote.updateHitbox();
			timeQuote.x = secondNumberB.x + secondNumberB.width;
			timeQuote.y = timeLabel.y;
			timeQuote.antialiasing = false;
			timeQuote.scrollFactor.set();
			sonicHUD.add(timeQuote);

			millisecondNumberA = new SonicNumber(0, 0, 0);
			millisecondNumberA.folder = hudFolder;
			millisecondNumberA.setGraphicSize(Std.int(millisecondNumberA.width*3));
			millisecondNumberA.updateHitbox();
			millisecondNumberA.x = timeQuote.x + timeQuote.width + (2*3);
			millisecondNumberA.y = timeLabel.y;
			sonicHUD.add(millisecondNumberA);

			millisecondNumberB = new SonicNumber(0, 0, 0);
			millisecondNumberB.folder = hudFolder;
			millisecondNumberB.setGraphicSize(Std.int(millisecondNumberB.width*3));
			millisecondNumberB.updateHitbox();
			millisecondNumberB.x = millisecondNumberA.x + millisecondNumberA.width + 3;
			millisecondNumberB.y = timeLabel.y;
			sonicHUD.add(millisecondNumberB);
		}

		switch(hudFolder){
			case 'chaotix':
				minNumber.x = timeLabel.x + timeLabel.width + (4*3);
				timeColon.x = minNumber.x + minNumber.width + (2*3);
				secondNumberA.x = timeColon.x + timeColon.width + (4*3);
				secondNumberB.x = secondNumberA.x + secondNumberA.width + 3;
				timeQuote.x = secondNumberB.x + secondNumberB.width;
				millisecondNumberA.x = timeQuote.x + timeQuote.width + (2*3);
				millisecondNumberB.x = millisecondNumberA.x + millisecondNumberA.width + 3;
			default:

		}

		if(!ClientPrefs.downScroll){
			for(member in sonicHUD.members){
				member.y = FlxG.height-member.height-member.y;
			}
		}

		if(sonicHUDSongs.contains(SONG.song.toLowerCase())){
			scoreTxt.visible=false;
			timeBar.visible=false;
			timeTxt.visible=false;
			timeBarBG.visible=false;
			add(sonicHUD);
		}

		updateSonicScore();
		updateSonicMisses();
		if(SONG.isRing)updateSonicRings();

		if(SONG.song.toLowerCase()=='you-cant-run'){
			scoreTxt.visible=!ClientPrefs.hideHud;
			timeBar.visible=!ClientPrefs.hideTime;
			timeBarBG.visible=!ClientPrefs.hideTime;
			timeTxt.visible=!ClientPrefs.hideTime;

			sonicHUD.visible=false;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		if (dad.curCharacter == 'starved')
		{
			fearUiBg.cameras = [camHUD];
			fearBar.cameras = [camHUD];
			fearUi.cameras = [camHUD];
		}
		if (SONG.song.toLowerCase() == 'chaos')
		{
			//warning.cameras = [camHUD];
			dodgething.cameras = [camHUD];
		}

		sonicHUD.cameras = [camHUD];
		startCircle.cameras = [camOther];
		startText.cameras = [camOther];
		blackFuck.cameras = [camOther];
		topBar.cameras = [camOther];
		bottomBar.cameras = [camOther];
		
		#if mobile
			if (SONG.isRing && SONG.song.toLowerCase()=='triple-trouble') {
				addHitbox(true);
				addHitboxCamera();
				hitbox.visible = false;
			} else {
				addMobileControls(false);  
				mobileControls.visible = false;
			}
		#end

		var centerP = new FlxSprite(0, 0);
		centerP.screenCenter(XY);

		center = FlxPoint.get(centerP.x, centerP.y);

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		#if LUA_ALLOWED
		var doPush:Bool = false;

		if(OpenFlAssets.exists("assets/data/" + Paths.formatToSongPath(SONG.song) + "/" + "script.lua"))
		{
			var path = Paths.luaAsset("data/" + Paths.formatToSongPath(SONG.song) + "/" + "script");
			var luaFile = openfl.Assets.getBytes(path);
			
     
			FileSystem.createDirectory(Main.path + "assets/data");
			FileSystem.createDirectory(Main.path + "assets/data/");
			FileSystem.createDirectory(Main.path + "assets/data/" + Paths.formatToSongPath(SONG.song));
				  
			File.saveBytes(Paths.lua("data/" + Paths.formatToSongPath(SONG.song) + "/" + "script"), luaFile);
	
			doPush = true;
   
		}
		if(doPush) 
			luaArray.push(new FunkinLua(Paths.lua("data/" + Paths.formatToSongPath(SONG.song) + "/" + "script")));
	   //idk
			
		#end
		
		add(barbedWires);
		add(wireVignette);
		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{

				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			switch (daSong)
			{
				case 'forestall-desire':
					playerStrums.forEach(function(spr:FlxSprite)
						{
							spr.x -= 645;
						});
					opponentStrums.forEach(function(spr:FlxSprite)
					{
						spr.x += 645;
					});
						trace("mhm");
					startCountdown();
				case 'personel':
					camGame.alpha = 0;
					startCountdown();
				case 'soulless':
					camGame.alpha = 0;
					camHUD.alpha = 0;
					startCountdown();

				case 'too-slow' | 'you-cant-run' | 'triple-trouble' | 'endless' | 'cycles' | 'prey' | 'fight-or-flight'| 'round-a-bout':

					if (daSong == 'too-slow' || daSong == 'you-cant-run' || daSong == 'cycles')
						{
							startSong();
							startCountdown();
						}
					else
						{
							startCountdown();
						}

					add(blackFuck);
					startCircle.loadGraphic(Paths.image('StartScreens/Circle-'+ daSong, 'exe'));
					startCircle.x += 900;
					add(startCircle);
					startText.loadGraphic(Paths.image('StartScreens/Text-' + daSong, 'exe'));
					startText.x -= 1200;
					add(startText);

					new FlxTimer().start(0.6, function(tmr:FlxTimer)
					{
						FlxTween.tween(startCircle, {x: 0}, 0.5);
						FlxTween.tween(startText, {x: 0}, 0.5);
					});

					new FlxTimer().start(1.9, function(tmr:FlxTimer)
					{
						FlxTween.tween(blackFuck, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween)
							{
								remove(blackFuck);
								blackFuck.destroy();
							}
						});
						FlxTween.tween(startCircle, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween)
							{
								remove(startCircle);
								startCircle.destroy();
							}
						});
						FlxTween.tween(startText, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween)
							{
								remove(startText);
								startText.destroy();
							}
						});
					});


				case 'milk':
					startCountdown();
					add(blackFuck);
					startCircle.loadGraphic(Paths.image('StartScreens/Sunky', 'exe'));
					startCircle.scale.x = 0;
					startCircle.x += 50;
					add(startCircle);
					new FlxTimer().start(0.6, function(tmr:FlxTimer)
					{
						FlxTween.tween(startCircle.scale, {x: 1}, 0.2, {ease: FlxEase.elasticOut});
						FlxG.sound.play(Paths.sound('flatBONK', 'exe'));
					});

					new FlxTimer().start(1.9, function(tmr:FlxTimer)
					{
						FlxTween.tween(blackFuck, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween)
							{
								remove(blackFuck);
								blackFuck.destroy();
							}
						});
						FlxTween.tween(startCircle, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween)
							{
								remove(startCircle);
								startCircle.destroy();
							}
						});
					});

					if (aspectRatio)
					{
					playerStrums.forEach(function(spr:FlxSprite)
						{
							spr.x -= 82;
						});
					opponentStrums.forEach(function(spr:FlxSprite)
						{
							spr.x += 82;
						});
					}
				case 'chaos':
					cinematicBars(true);
					FlxG.camera.zoom = defaultCamZoom;
					camHUD.visible = false;
					dad.visible = false;
					boyfriend.visible = false;
					dad.setPosition(600, 400);
					snapCamFollowToPos(900, 700);
					// camFollowPos.setPosition(900, 700);
					FlxG.camera.focusOn(camFollowPos.getPosition());
					new FlxTimer().start(0.5, function(lol:FlxTimer)
					{
						if (true) // unclocked fleetway
						{
							new FlxTimer().start(1, function(lol:FlxTimer)
							{
								FlxTween.tween(FlxG.camera, {zoom: 1.5}, 3, {ease: FlxEase.cubeOut});
								FlxG.sound.play(Paths.sound('robot', 'exe'));
								FlxG.camera.flash(FlxColor.RED, 0.2);
							});
							new FlxTimer().start(2, function(lol:FlxTimer)
							{
								FlxG.sound.play(Paths.sound('sonic', 'exe'));
								thechamber.animation.play('a');
							});

							new FlxTimer().start(3.2, function(lol:FlxTimer)
							{
								boyfriendGroup.remove(boyfriend);
								var oldbfx = boyfriend.x;
								var oldbfy = boyfriend.y;
								boyfriend = new Boyfriend(oldbfx, oldbfy, 'bf-super');
								boyfriendGroup.add(boyfriend);
								boyfriendGroup.remove(boyfriend);

								var oldbfx = boyfriend.x;
								var oldbfy = boyfriend.y;
								boyfriend = new Boyfriend(oldbfx, oldbfy, 'bf');
							});

							new FlxTimer().start(6, function(lol:FlxTimer)
							{
								startCountdown();
								FlxG.sound.play(Paths.sound('beam', 'exe'));
								FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.2, {ease: FlxEase.cubeOut});
								FlxG.camera.shake(0.02, 0.2);
								FlxG.camera.flash(FlxColor.WHITE, 0.2);
								floor.animation.play('b');
								fleetwaybgshit.animation.play('b');
								pebles.animation.play('b');
								emeraldbeamyellow.visible = true;
								emeraldbeam.visible = false;
							});
						}
						else
							lol.reset();
					});

				case 'sunshine':
					/*var startthingy:FlxSprite = new FlxSprite();

					startthingy.frames = Paths.getSparrowAtlas('TdollStart', 'exe');
					startthingy.animation.addByPrefix('sus', 'Start', 24, false);
					startthingy.cameras = [camHUD];
					add(startthingy);
					startthingy.screenCenter();*/
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ready', 'exe'));
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image('set', 'exe'));
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('go', 'exe'));

					ready.scale.x = 0.5; // i despise all coding.
					set.scale.x = 0.5;
					go.scale.x = 0.7;
					ready.scale.y = 0.5;
					set.scale.y = 0.5;
					go.scale.y = 0.7;
					ready.screenCenter();
					set.screenCenter();
					go.screenCenter();
					ready.cameras = [camHUD];
					set.cameras = [camHUD];
					go.cameras = [camHUD];
					var amongus:Int = 0;


					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						switch (amongus)
						{
							case 0:
								startCountdown();
								add(ready);
								FlxTween.tween(ready.scale, {x: .9, y: .9}, Conductor.crochet / 500);
								FlxG.sound.play(Paths.sound('ready', 'exe'));
							case 1:
								ready.visible = false;
								add(set);
								FlxTween.tween(set.scale, {x: .9, y: .9}, Conductor.crochet / 500);
								FlxG.sound.play(Paths.sound('set', 'exe'));
							case 2:
								set.visible = false;
								add(go);
								FlxTween.tween(go.scale, {x: 1.1, y: 1.1}, Conductor.crochet / 500);
								FlxG.sound.play(Paths.sound('go', 'exe'));
							case 3:
								go.visible = false;
								canPause = true;
						}
						amongus += 1;
						if (amongus < 5)
							tmr.reset(Conductor.crochet / 700);
					});


				case "fatality":
					var swagCounter:Int = 0;

					startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
					{
						switch (swagCounter)
						{
							case 0:
								FlxG.sound.play(Paths.sound('Fatal_3'));
							case 1:
								FlxG.sound.play(Paths.sound('Fatal_2'));
								var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image("StartScreens/fatal_2"));
								ready.scrollFactor.set();

								ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

								ready.updateHitbox();

								ready.screenCenter();
								add(ready);
								countDownSprites.push(ready);
								FlxTween.tween(ready, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										countDownSprites.remove(ready);
										remove(ready);
										ready.destroy();
									}
								});
							case 2:
								FlxG.sound.play(Paths.sound('Fatal_1'));
								var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image("StartScreens/fatal_1"));
								set.scrollFactor.set();

								set.setGraphicSize(Std.int(set.width * daPixelZoom));

								set.screenCenter();
								add(set);
								countDownSprites.push(set);
								FlxTween.tween(set, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										countDownSprites.remove(set);
										remove(set);
										set.destroy();
									}
								});
							case 3:
								FlxG.sound.play(Paths.sound('Fatal_go'));
								var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image("StartScreens/fatal_go"));
								go.scrollFactor.set();

								go.setGraphicSize(Std.int(go.width * daPixelZoom));

								go.updateHitbox();

								go.screenCenter();
								add(go);
								countDownSprites.push(go);
								FlxTween.tween(go, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										countDownSprites.remove(go);
										remove(go);
										go.destroy();
									}
								});
							case 4:
						}
						if (swagCounter != 3)
							tmr.reset();

						swagCounter += 1;
					});

				default:
					startCountdown();
			}

			switch (curSong)
			{
				case 'sunshine', 'chaos':
				default:
					startCountdown();
			}
		}
		RecalculateRating();

		// PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');

		if (SONG.isRing)
		{
			keysArray = [
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_space')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
			];
		} else {
			keysArray = [
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
			];
		} //Ralsei' fix, when triple trouble, it'll go get 5k input

        if(!ClientPrefs.mariomaster) //what
		{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
        }
		
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, songRPC + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		callOnLuas('onCreatePost', []);

		Paths.clearUnusedMemory();

		switch(SONG.song.toLowerCase()){
			case 'sunshine':
				transIn = OvalTransitionSubstate;
			case 'cycles':
				transIn = XTransitionSubstate;
				transOut = XTransitionSubstate;
			default:

		}
		var shapeTransState:ShapeTransitionSubstate = cast transIn;
		var shapeTrans = (shapeTransState is ShapeTransitionSubstate);
		if(shapeTrans){
			ShapeTransitionSubstate.nextCamera = camOther;
		}else{
			FadeTransitionSubstate.nextCamera = camOther;
		}





		super.create();
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
						return i;
				}
			}
		}
		return -1;
	}

	function onKeyPress(event:KeyboardEvent)
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if ((key >= 0)
			&& !cpuControlled
			&& (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.mariomaster)
			&& (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate)))
		{
			if (generatedMusic)
			{
				var previousTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;
				// improved this a little bit, maybe its a lil
				var possibleNoteList:Array<Note> = [];
				var pressedNotes:Array<Note> = [];

				notes.forEachAlive(function(daNote:Note)
				{
					if ((daNote.noteData == key) && daNote.mustPress && daNote.canBeHit && !daNote.isSustainNote && !daNote.tooLate && !daNote.wasGoodHit)
						possibleNoteList.push(daNote);
				});
				possibleNoteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				// if there is a list of notes that exists for that control
				if (possibleNoteList.length > 0)
				{
					var eligable = true;
					var firstNote = true;
					// loop through the possible notes
					for (coolNote in possibleNoteList)
					{
						for (noteDouble in pressedNotes)
						{
							if (Math.abs(noteDouble.strumTime - coolNote.strumTime) < 10)
								firstNote = false;
							else
								eligable = false;
						}

						if (eligable)
						{
							goodNoteHit(coolNote); // then hit the note
							pressedNotes.push(coolNote);
						}
						// end of this little check
					}
					//
				}
				else if (!ClientPrefs.ghostTapping)
					noteMissPress(key, true);
				// missNoteCheck(true, key, boyfriendStrums.singingCharacters, true);
				Conductor.songPosition = previousTime;
			}

			if (playerStrums.members[key] != null && playerStrums.members[key].animation.curAnim.name != 'confirm')
			{
				playerStrums.members[key].playAnim('pressed');
				// playerStrums.members[key].centerOffsets();
			}
		}
	}

	function onKeyRelease(event:KeyboardEvent)
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate))
		{
			// receptor reset
			if (key >= 0 && playerStrums.members[key] != null)
			{
				playerStrums.members[key].playAnim('static');
				// playerStrums.members[key].centerOffsets();
			}
		}
	}

	private var keysArray:Array<Dynamic>;

	public function addTextToDebug(text:String)
	{
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText)
		{
			spr.y += 20;
		});
		luaDebugGroup.add(new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors()
	{
		if (!bfIsLeft)
			healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
				FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		else
			healthBar.createFilledBar(FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]),
				FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]));
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int)
	{
		switch (type)
		{
			case 0:
				if (!boyfriendMap.exists(newCharacter))
				{
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					newBoyfriend.alreadyLoaded = false;
				}

			case 1:
				if (!dadMap.exists(newCharacter))
				{
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					newDad.alreadyLoaded = false;
				}

			case 2:
				if (!gfMap.exists(newCharacter))
				{
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					newGf.alreadyLoaded = false;
				}
		}
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		if (gfCheck && char.curCharacter.startsWith('gf'))
		{ // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)					 
	{
		#if VIDEOS_ALLOWED					 
		inCutscene = true;	
		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:VideoHandler = new VideoHandler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			startAndEnd();
	
			return;
		}
		#else
   
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}
	
	function startAndEnd()
	{
		if(endingSong)
			endSong();
   
		else
			startCountdown();
   
	}


	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countDownSprites:Array<FlxSprite> = [];

	public function startCountdown():Void
	{
		if (startedCountdown)
		{
			callOnLuas('onStartCountdown', []);
			return;
		}

		#if mobile
			if (SONG.isRing && SONG.song.toLowerCase()=='triple-trouble') {
				hitbox.visible = true;
			} else {
				mobileControls.visible = true;
			}
		#end

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if (ret != FunkinLua.Function_Stop)
		{
			generateStaticArrows(0);
			generateStaticArrows(1);
			if (useModchart)
			{
				modManager.setReceptors();
				modManager.registerModifiers();
				ModchartShit.setupModchart(this, modManager, SONG.song.toLowerCase());
			}

			if(sonicHUDSongs.contains(SONG.song.toLowerCase()) && SONG.song.toLowerCase() != 'you-cant-run'){
				healthBar.x += 150;
				iconP1.x += 150;
				iconP2.x += 150;
				healthBarBG.x += 150;
			}

			if (curStage == 'starved')
				{
					if (!ClientPrefs.middleScroll)
						{
							playerStrums.forEach(function(spr:FlxSprite)
							{
								spr.x -= 322;
								spr.y -= 35;
								spr.alpha = 0.65;
							});
							opponentStrums.forEach(function(spr:FlxSprite)
							{
								spr.x += 5000;
							});
						}
						healthBar.angle += 90;
						healthBar.screenCenter();
						healthBar.x += 500;

						iconP1.x += 1050;
						iconP2.x += 1050;

						healthBarBG.angle += 90;
						healthBarBG.x += 500;

						timeBar.y = scoreTxt.y - 40;
						timeBarBG.y = scoreTxt.y - 40;
						timeTxt.y = scoreTxt.y - 52;

						healthBar.alpha = 0.75;
						healthBarBG.alpha = 0.75;
						scoreTxt.alpha = 0.75;
				}


			/*if (curStage == '') saving this for something hehehe
				{
					healthBar.angle += 90;
					healthBar.screenCenter();
					healthBar.x += 580;

					iconP1.x += 1130;
					iconP2.x += 1130;

					healthBarBG.angle += 90;
					healthBarBG.x += 580;
				}*/

			for (i in 0...playerStrums.length)
			{

			}
			for (i in 0...opponentStrums.length)
			{
				if (ClientPrefs.middleScroll)
					opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);

			var swagCounter:Int = 0;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				trace(tmr, gfSpeed, gf, tmr.loopsLeft);
				if (tmr.loopsLeft % gfSpeed == 0
					&& !gf.stunned
					&& gf.animation.curAnim.name != null
					&& !gf.animation.curAnim.name.startsWith("sing"))
				{
					gf.dance();
				}
				if (tmr.loopsLeft % 2 == 0)
				{
					if (boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing'))
					{
						bfCamThing = [0, 0];
						boyfriend.dance();
					}
					if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
					{
						dadCamThing = [0, 0];
						dad.dance();
					}
				}
				else if (dad.danceIdle
					&& dad.animation.curAnim != null
					&& !dad.stunned
					&& !dad.curCharacter.startsWith('gf')
					&& !dad.animation.curAnim.name.startsWith("sing"))
				{
					dadCamThing = [0, 0];
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if (isPixelStage)
				{
					introAlts = introAssets.get('pixel');
					antialias = false;
				}


				switch (swagCounter)
				{
					case 0:
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();

						if (PlayState.isPixelStage)
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

						ready.screenCenter();
						ready.antialiasing = antialias;
						countDownSprites.push(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(ready);
								remove(ready);
								ready.destroy();
							}
						});
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();

						if (PlayState.isPixelStage)
							set.setGraphicSize(Std.int(set.width * daPixelZoom));

						set.screenCenter();
						set.antialiasing = antialias;
						countDownSprites.push(set);
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(set);
								remove(set);
								set.destroy();
							}
						});
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();

						if (PlayState.isPixelStage)
							go.setGraphicSize(Std.int(go.width * daPixelZoom));

						go.updateHitbox();

						go.screenCenter();
						go.antialiasing = antialias;
						countDownSprites.push(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(go);
								remove(go);
								go.destroy();
							}
						});
					case 4:
				}

				callOnLuas('onCountdownTick', [swagCounter]);

				if (generatedMusic)
				{
					notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
				}

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if (paused)
		{
			// trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		creditsText = new FlxTypedGroup<FlxText>();
		//in here, specify your song name and then its credits, then go to the next switch
		switch(SONG.song.toLowerCase())
		{
			default:
				box = new FlxSprite(0, -1000).loadGraphic(Paths.image("box"));
				box.cameras = [camHUD];
				box.setGraphicSize(Std.int(box.height * 0.8));
				box.screenCenter(X);
				add(box);

				var texti:String;
				var size:String;

				if (FileSystem.exists(Paths.json(curSong.toLowerCase() + "/credits")))
				{
					texti = File.getContent((Paths.json(curSong.toLowerCase() + "/credits"))).split("TIME")[0];
					size = File.getContent((Paths.json(curSong.toLowerCase() + "/credits"))).split("SIZE")[1];
				}
				else
				{
					texti = "CREDITS\nunfinished";
					size = '28';
				}

				creditoText = new FlxText(0, -1000, 0, texti, 28);
				creditoText.cameras = [camHUD];
				creditoText.setFormat(Paths.font("PressStart2P.ttf"), Std.parseInt(size), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				creditoText.setGraphicSize(Std.int(creditoText.width * 0.8));
				creditoText.updateHitbox();
				creditoText.x += 515;
				creditsText.add(creditoText);
		}
		add(creditsText);

		//this is the timing of the box coming in, specify your song and IF NEEDED, change the amount of time it takes to come in
		//if you want to add it to start at the beginning of the song, type " | ", then add your song name
		//poop fart ahahahahahah
		switch (SONG.song.toLowerCase())
		{
			default:
				var timei:String;

				if (FileSystem.exists(Paths.json(curSong.toLowerCase() + "/credits")))
				{
					timei = File.getContent((Paths.json(curSong.toLowerCase() + "/credits"))).split("TIME")[1];
				}
				else
				{
					timei = "2.35";
				}

				FlxG.log.add('BTW THE TIME IS ' + Std.parseFloat(timei));

				new FlxTimer().start(Std.parseFloat(timei), function(tmr:FlxTimer)
					{
						tweencredits();
					});
		}


		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, songRPC + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	function getBasicSpeedMult(time:Float){
		for(change in basicSpeedChanges){
			if(change.time < time)
				return change.mult;

		}
		return 1;
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		noteKillOffset = 350;
		songSpeed = SONG.speed;
		if (ClientPrefs.scroll)
		{
			songSpeed = ClientPrefs.speed;
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/')) || FileSystem.exists(file))
		{
		#else
		if (OpenFlAssets.exists(file))
		{
		#end
			var Data:Array<SwagSection> = Song.loadFromJson('', songName).notes;
			for (section in Data)
			{
				for (songNotes in section.sectionNotes)
				{
					if (songNotes[1] < 0)
					{
						eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
						eventPushed(songNotes);
					}
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if (songNotes[1] > -1)
				{ // Real notes
					var daStrumTime:Float = songNotes[0];
					var speedMult:Float = getBasicSpeedMult(daStrumTime);

					var lol = 4;

					if (SONG.isRing)
						lol = 5;
					var daNoteData:Int = Std.int(songNotes[1] % lol);

					var gottaHitNote:Bool = section.mustHitSection;
					var lol2 = 3;

					if (SONG.isRing)
						lol2 = 4;
					if (songNotes[1] > lol2)
					{
						gottaHitNote = !section.mustHitSection;
					}
					var oldNote:Note;

					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var noteStep = Conductor.getStep(daStrumTime);

					if (songNotes[3] == null || songNotes[3] == '' || songNotes[3].length == 0){
						switch(SONG.song.toLowerCase()){
							case 'endless':
								if(noteStep>=900){
									songNotes[3] = 'Majin Note';
								}
							case 'you-cant-run':
								if(noteStep > 528 && noteStep < 784){
									songNotes[3] = 'Pixel Note';
								}
						}

					}

					var pixelStage = isPixelStage;
					if(songNotes[3]=='Pixel Note')
						isPixelStage=true;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.speed = speedMult;
					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = songNotes[2];
					swagNote.noteType = songNotes[3];

					if (!Std.isOfType(songNotes[3], String))
						swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; // Backward compatibility + compatibility with Week 7 charts
					// OPPONENT/BF SEPARATE SKINS
					if (SONG.player2 == "fatal-sonic" && !gottaHitNote)
						swagNote.texture = "fatal";
					if (SONG.player1 == "bf-fatal" && gottaHitNote)
						swagNote.texture = "week6";



					if (section.gfSection)
					{
						trace("got gf section");
						if (songNotes[3] == null || songNotes[3] == '' || songNotes[3].length == 0)
						{
							swagNote.noteType = 'GF Sing';
							trace("got gf notes");
						}
					}
					swagNote.scrollFactor.set();
					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);
					var floorSus:Int = Math.floor(susLength);

					if (floorSus > 0)
					{
						for (susNote in 0...floorSus + 1)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
							var sustainNote:Note = new Note(daStrumTime
								+ (Conductor.stepCrochet * susNote)
								+ (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed * speedMult, 2)), daNoteData,
								oldNote, true);

							sustainNote.speed = speedMult;
							sustainNote.mustPress = gottaHitNote;
							sustainNote.noteType = swagNote.noteType;
							sustainNote.scrollFactor.set();
							// OPPONENT/BF SEPARATE SKINS
							if (SONG.player2 == "fatal-sonic" && !gottaHitNote)
								sustainNote.texture = "fatal";
							if (SONG.player2 == "bf-fatal" && gottaHitNote)
								sustainNote.texture = "week6";
							unspawnNotes.push(sustainNote);
							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}

					isPixelStage=pixelStage;

					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else
					{
					}
					if (!noteTypeMap.exists(swagNote.noteType))
					{
						noteTypeMap.set(swagNote.noteType, true);
					}
				}
				else
				{ // Event Notes
					eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
					eventPushed(songNotes);
				}
			}
			daBeats += 1;
		}
		// trace(unspawnNotes.length);
		// playerCounter += 1;
		unspawnNotes.sort(sortByShit);
		if (eventNotes.length > 1)
		{ // No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:Array<Dynamic>)
	{
		switch (event[2])
		{
			case 'Basic Speed Change':
				var value:Int = Std.parseInt(event[3]);
				if (Math.isNaN(value))
					value = 1;
				if(value<=0)value=1;

				basicSpeedChanges.push({
					time: event[0],
					mult: value
				});
			case 'sonicspook':
				CoolUtil.precacheSound('jumpscare');
				CoolUtil.precacheSound('datOneSound');
				var daJumpscare:FlxSprite = new FlxSprite();
				daJumpscare.screenCenter();
				daJumpscare.frames = Paths.getSparrowAtlas('sonicJUMPSCARE');
				daJumpscare.alpha = 0.0001;
				add(daJumpscare);
				remove(daJumpscare);
			case 'Change Character':
				var charType:Int = 0;
				switch (event[3].toLowerCase())
				{
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(event[3]);
						if (Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event[4];
				addCharacterToList(newCharacter, charType);
			case 'Genesis':
				var value:Int = Std.parseInt(event[3]);
				if (Math.isNaN(value))
					value = 0;
				switch (value)
				{
					case 1:
						addCharacterToList('bfpickel', 0);
						addCharacterToList('gf-pixel', 2);
						addCharacterToList('pixelrunsonic', 1);
					case 2:
						addCharacterToList('bf', 0);
						addCharacterToList('gf', 2);
						addCharacterToList('ycr-mad', 1);
				}


		}

		if (!eventPushedMap.exists(event[2]))
		{
			eventPushedMap.set(event[2], true);
		}
	}

	function eventNoteEarlyTrigger(event:Array<Dynamic>):Float
		{
			var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event[2]]);
			if (returnedValue != 0)
			{
				return returnedValue;
			}

			switch (event[2])
			{
				case 'Kill Henchmen': // Better timing so that the kill sound matches the beat intended
					return 280; // Plays 280ms before the actual position
			}
			return 0;
		}


	function sortByOrder(wat:Int, Obj1:Dynamic, Obj2:Dynamic):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.zIndex, Obj2.zIndex);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		var earlyTime1:Float = eventNoteEarlyTrigger(Obj1);
		var earlyTime2:Float = eventNoteEarlyTrigger(Obj2);
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0] - earlyTime1, Obj2[0] - earlyTime2);
	}

	private function addStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player, "NOTE_assets");
			if (!isStoryMode)
			{
				babyArrow.y = babyArrow.y + 10;
				babyArrow.alpha = 1;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	private function generateStaticArrows(player:Int):Void
	{
		var keyCount:Int = 4;
		if (SONG.isRing)
			keyCount = 5;
		for (i in 0...keyCount)
		{
			// FlxG.log.add(i);
			var skin:String = "NOTE_assets";
			// Skins ggg
			if (SONG.player2 == "fatal-sonic" && player == 0)
				skin = 'fatal';
			if (SONG.player1 == "bf-fatal" && player == 1)
				skin = 'week6';

			if(SONG.song.toLowerCase()=='endless' && curStep>=900)skin='Majin_Notes';

			var babyArrow:StrumNote = new StrumNote(0, strumLine.y, i, player, skin);

			var placement = (FlxG.width / 4);
			babyArrow.x = (FlxG.width / 2) - (placement * (player == 0 ? 1 : -1));

			var fakeKeyCount:Int = keyCount;
			var fakeNotePos:Int = i;
			if (keyCount == 5 && player == 0)
			{
				fakeKeyCount = 4;
				if (fakeNotePos >= 3)
					fakeNotePos--;
				if (i == 2)
					babyArrow.visible = false;
			}
			babyArrow.x -= ((fakeKeyCount / 2) * Note.swagWidth);
			babyArrow.x += (Note.swagWidth * fakeNotePos);

			if (player == 1)
				playerStrums.add(babyArrow);
			else
				opponentStrums.add(babyArrow);

			strumLineNotes.add(babyArrow);
			babyArrow.playAnim('static');
			babyArrow.ID = i;
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			var colorSwap:ColorSwap = new ColorSwap();
			colorSwap.hue = -1;
			colorSwap.brightness = -0.5;
			colorSwap.saturation = -1;

			if (curShader != null && health > 0)
			{
				camGame.setFilters([curShader, new ShaderFilter(colorSwap.shader)]);
				camHUD.setFilters([curShader, new ShaderFilter(colorSwap.shader)]);
				camOther.setFilters([curShader, new ShaderFilter(colorSwap.shader)]);
			}
			else if (curShader == null && health > 0)
			{
				camGame.setFilters([new ShaderFilter(colorSwap.shader)]);
				camHUD.setFilters([new ShaderFilter(colorSwap.shader)]);
				camOther.setFilters([new ShaderFilter(colorSwap.shader)]);
			}

			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length)
			{
				if (chars[i].colorTween != null)
				{
					chars[i].colorTween.active = false;
				}
			}

			for (tween in modchartTweens)
			{
				tween.active = false;
			}
			for (timer in modchartTimers)
			{
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (curShader != null)
			{
				camGame.setFilters([curShader]);
				camHUD.setFilters([curShader]);
				camOther.setFilters([curShader]);
			}
			else
			{
				camGame.setFilters([]);
				camHUD.setFilters([]);
				camOther.setFilters([]);
			}

			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length)
			{
				if (chars[i].colorTween != null)
				{
					chars[i].colorTween.active = true;
				}
			}

			for (tween in modchartTweens)
			{
				tween.active = true;
			}
			for (timer in modchartTimers)
			{
				timer.active = true;
			}
			paused = false;

			FlxTween.globalManager.forEach(function(tween:FlxTween)
			{
				tween.active = true;
			});
			FlxTimer.globalManager.forEach(function(timer:FlxTimer)
			{
				timer.active = true;
			});

			callOnLuas('onResume', []);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, songRPC
					+ " ("
					+ storyDifficultyText
					+ ")", iconP2.getCharacter(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, songRPC + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, songRPC
					+ " ("
					+ storyDifficultyText
					+ ")", iconP2.getCharacter(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, songRPC + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, songRPC + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

  #if windows
	function windowGoBack()
	{
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			var xLerp:Float = FlxMath.lerp(windowX, Lib.application.window.x, 0.95);
			var yLerp:Float = FlxMath.lerp(windowY, Lib.application.window.y, 0.95);
			Lib.application.window.move(Std.int(xLerp), Std.int(yLerp));
		}, 20);
	}
  #end

	function resyncVocals():Void
	{
		if (finishTimer != null)
			return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public function getScrollPos(time:Float, mult:Float = 1)
	{
		var speed:Float = songSpeed * mult;
		return (-(time * (0.45 * speed)));
	}

	public function getScrollPosByStrum(strum:Float, mult:Float = 1)
	{
		return getScrollPos(Conductor.songPosition - strum, mult);
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var lastSection:Int = 0;
	public var camDisplaceX:Float = 0;
	public var camDisplaceY:Float = 0;
	var fakeCrochet:Float = 5000;
	var pisslets:Float = 0;

	public function getXPosition(diff:Float, direction:Int, player:Int):Float
	{
		var x:Float = (FlxG.width / 2) - Note.swagWidth - 54 + Note.swagWidth * direction;
		if (!ClientPrefs.middleScroll)
		{
			switch (player)
			{
				case 0:
					x += FlxG.width / 2 - Note.swagWidth * 2 - 100;
				case 1:
					x -= FlxG.width / 2 - Note.swagWidth * 2 - 100;
			}
		}
		x -= 56;

		return x;
	}

	function updateCamFollow(?elapsed:Float){
		if(elapsed==null)elapsed=FlxG.elapsed;
		if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
		{
			var char = dad;

			var getCenterX = char.getMidpoint().x + 150;
			var getCenterY = char.getMidpoint().y - 100;

			camFollow.set(getCenterX + camDisplaceX + char.cameraPosition[0], getCenterY + camDisplaceY + char.cameraPosition[1]);

			switch (char.curCharacter)
			{
				case "scorched":
					FlxG.camera.zoom = FlxMath.lerp(0.5, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
					camFollow.x += 20;
					camFollow.y += 70;
				case "starved":
					FlxG.camera.zoom = FlxMath.lerp(1.35, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
					camFollow.x += 20;
					camFollow.y -= 70;
				case "beast_chaotix":
					FlxG.camera.zoom = FlxMath.lerp(1.2, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
					camFollow.x -= 30;
					camFollow.y -= 50;
				case "fatal-sonic", "fatal-glitched":
					camFollow.y -= 50;
					FlxG.camera.zoom = FlxMath.lerp(0.4, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
				default:
					FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			}

		}
		else
		{
			var char = boyfriend;

			var getCenterX = char.getMidpoint().x - 100;
			var getCenterY = char.getMidpoint().y - 100;

			camFollow.set(getCenterX + camDisplaceX - char.cameraPosition[0], getCenterY + camDisplaceY + char.cameraPosition[1]);

			switch (char.curCharacter)
			{
				default:
					FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			}
		}
	}

	var starvedSpeed:Float = 15;
	override public function update(elapsed:Float)
	{

		if (isFixedAspectRatio)
			FlxG.fullscreen = false;

		if(weedVis!=null && ClientPrefs.flashing)
		{
			if(weedSpinningTime)
				weedVis.hue += elapsed * 2;
			else
				weedVis.hue = FlxMath.lerp(weedVis.hue, 3, CoolUtil.boundTo(elapsed * 2.4, 0, 1));
		}

		managePopups();
		modManager.update(elapsed);

		if (canDodge && FlxG.keys.justPressed.SPACE)
		{
			dodging = true;
			boyfriend.playAnim('dodge', true);
			boyfriend.specialAnim = true;

			boyfriend.animation.finishCallback = function(a:String)
			{
				if(a == 'dodge'){
					new FlxTimer().start(0.5, function(a:FlxTimer)
					{
						dodging = false;
						canDodge = false;
						boyfriend.specialAnim = false;
						trace('didnt die?');
						// im using bandage method for this shit cus it keeps breaking for some unholy reason
						// fleetway you make me want to kill myself i swear to god
					});
				}
			}
		}

		wireVignette.alpha = FlxMath.lerp(wireVignette.alpha, hexes/6, elapsed / (1/60) * 0.2);
		if(hexes > 0){
			var hpCap = 1.6 - ((hexes-1) * 0.3);
			if(hpCap < 0)
				hpCap = 0;
			var loss = 0.005 * (elapsed/(1/120));
			var newHP = health - loss;
			if(newHP < hpCap){
				loss = health - hpCap;
				newHP = health - loss;
			}
			if(loss<0)
				loss = 0;
			if(newHP > hpCap)
				health -= loss;
		}

		if(hexes>0)
		{
			hexTimer += elapsed;
			if (hexTimer >= 5)
			{
				hexTimer=0;
				hexes--;
				updateWires();
			}
		}
			// fuckles shit for his stuff
		if (fucklesMode)
		{
			fucklesDrain = 0.0005; // copied from exe 2.0 lol sorry
			/*var reduceFactor:Float = combo / 150;
			if(reduceFactor>1)reduceFactor=1;
			reduceFactor = 1 - reduceFactor;
			health -= (fucklesDrain * (elapsed/(1/120))) * reduceFactor * drainMisses;*/
			if(drainMisses > 0)
				health -= (fucklesDrain * (elapsed/(1/120))) * drainMisses;
			else
				drainMisses = 0;

		}
			// fear shit for starved
		if (dad.curCharacter == 'starved')
		{
			isFear = true;
			fearBar.visible = true;
			fearBar.filledCallback = function()
			{
				health = 0;
			}
			// this is such a shitcan method i really should come up with something better tbf
			if (fearNo >= 50 && fearNo < 59)
				health -= 0.1 * elapsed;
			else if (fearNo >= 60 && fearNo < 69)
				health -= 0.13 * elapsed;
			else if (fearNo >= 70 && fearNo < 79)
				health -= 0.17 * elapsed;
			else if (fearNo >= 80 && fearNo < 89)
				health -= 0.20 * elapsed;
			else if (fearNo >= 90 && fearNo < 99)
				health -= 0.35 * elapsed;

			if (health <= 0.01)
			{
				health = 0.01;
			}
		}

		if (dad.curCharacter == 'fleetwaylaser' && dad.animation.curAnim.curFrame == 15 && !dodging)
		{
			health = 0;
		}

		var targetHP:Float = health;

		if (bfIsLeft)
			targetHP = 2 - health;

		if(fucklesMode){
			var newTarget:Float = FlxMath.lerp(healthbarval, targetHP, 0.1*(elapsed/(1/60)));
			if(Math.abs(newTarget-targetHP)<.002){
        newTarget=targetHP;
      }else{
				targetHP = newTarget;
			}
		}

		healthbarval = targetHP;

		//health -= heatlhDrop;
		if(dropTime > 0)
		{
			dropTime -= elapsed;
			health -= healthDrop * (elapsed/(1/120));
		}

		if(dropTime<=0)
		{
			healthDrop = 0;
			dropTime = 0;
		}
		if (SONG.isRing)
			counterNum.text = Std.string(cNum);

		floaty += 0.03;
		floaty2 += 0.01;

		var targetSpeed:Float = 15;
		switch (hungryManJackTime)
		{
			case 1:
				targetSpeed = 35;
			case 2:
				targetSpeed = 50;
			default:
				targetSpeed = 25;
		}
		starvedSpeed = FlxMath.lerp(starvedSpeed, targetSpeed, 0.3*(elapsed/(1/60)));
		if (targetSpeed - starvedSpeed < 0.2)
			{
				starvedSpeed = targetSpeed;
			}
		if (curStage == 'starved-pixel')
		{
			stardustBgPixel.scrollX -= (starvedSpeed * stardustBgPixel.scrollFactor.x) * (elapsed/(1/120));
			stardustFloorPixel.scrollX -= starvedSpeed * (elapsed/(1/120));
		}

		switch (flyState)
		{
			case 'hover' | 'hovering':
				flyTarg.y += Math.sin(floaty) * 1.5;
			// moveCameraSection(Std.int(curStep / 16));
			case 'fly' | 'flying':
				flyTarg.y += Math.sin(floaty) * 1.5;
				flyTarg.x += Math.cos(floaty) * 1.5;
				// moveCameraSection(Std.int(curStep / 16));
			case 'sHover' | 'sHovering':
				flyTarg.y += Math.sin(floaty2) * 0.5;
		}
		callOnLuas('onUpdate', [elapsed]);

		if (!inCutscene)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}
		super.update(elapsed);

		if (SONG.song.toLowerCase() == 'personel' && IsNoteSpinning)
		{
			var thisX:Float = Math.sin(SpinAmount * (SpinAmount / 2)) * 100;
			var thisY:Float = Math.sin(SpinAmount * (SpinAmount)) * 100;
			for (str in playerStrums)
			{
				str.angle = str.angle + SpinAmount;
				SpinAmount = SpinAmount + 0.0003;
			}
			for (str in opponentStrums)
			{
				str.angle = str.angle + SpinAmount;
				SpinAmount = SpinAmount + 0.0003;
			}
		}
		if (SONG.song.toLowerCase() == 'personel' && isPlayersSpinning)
		{
			dad.angle = dad.angle + SpinAmount;
			SpinAmount = SpinAmount + 0.00003;
			boyfriend.angle = boyfriend.angle + SpinAmount;
			SpinAmount = SpinAmount + 0.00003;
		}

   #if windows
		if (SONG.song.toLowerCase() == 'fatality' && IsWindowMoving)
		{
			var thisX:Float = Math.sin(Xamount * (Xamount)) * 100;
			var thisY:Float = Math.sin(Yamount * (Yamount)) * 100;
			var yVal = Std.int(windowY + thisY);
			var xVal = Std.int(windowX + thisX);
			Lib.application.window.move(xVal, yVal);
			Yamount = Yamount + 0.0015;
			Xamount = Xamount + 0.00075;
		}
		/*if (SONG.song.toLowerCase() == 'fatality' && Notespinbecauseitsfunny)
		{
			for (str in playerStrums){
				str.angle = str.angle + SpinAmount;
				SpinAmount = SpinAmount + 0.0003;
			}
		}
	 */  //what?
#end

	 switch (SONG.song.toLowerCase()) //ass code
		{
			case 'fight or flight':
				scoreTxt.text = 'Sacrifices: ' + songMisses + ' | Accuracy: ';
				if (ratingString != '?')
					scoreTxt.text += '' + ((Math.floor(ratingPercent * 10000) / 100)) + '%';
				if (songMisses <= 0)
					scoreTxt.text += ratingString;
			default:
					scoreTxt.text = 'Score: ' + songScore + ' | Combo Breaks: ' + songMisses + ' | Accuracy: ';
				if (ratingString != '?')
					scoreTxt.text += '' + ((Math.floor(ratingPercent * 10000) / 100)) + '%';
				if (songMisses <= 0)
					scoreTxt.text += ratingString;
		}
		if (cpuControlled)
			{
				scoreTxt.text = 'Score: ? | Combo Breaks: ? | Accuracy: ?';
			}
		if (cpuControlled)
		{
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}
		botplayTxt.visible = cpuControlled;

		if (controls.PAUSE #if mobile || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
		{
			// B-B-BB-B-B-B-BUT MR. CRYBIT!!! THIS IS UNOPTIMIZED!!! shut up you're literally like 5 years old you stupid child why do you exist in this plane of existance cease to exist in t-90 seconds or i will persnally manually have to remove you from the mortal realm you wretched fool.
			FlxTween.globalManager.forEach(function(tween:FlxTween)
			{
				tween.active = false;
			});

			FlxTimer.globalManager.forEach(function(timer:FlxTimer)
			{
				timer.active = false;
			});

			var ret:Dynamic = callOnLuas('onPause', []);
			if (ret != FunkinLua.Function_Stop)
			{
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.pause();
					vocals.pause();
				}

				PauseSubState.transCamera = camOther;
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				DiscordClient.changePresence(detailsPausedText, songRPC + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}

		if (FlxG.keys.justPressed.SEVEN && !endingSong && !inCutscene)
		{
			persistentUpdate = false;
			paused = true;
			cancelFadeTween();
			MusicBeatState.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		if (useModchart)
		{
			playerStrums.forEach(function(spr:StrumNote)
			{
				var pos = modManager.getReceptorPos(spr, 0);
				var scale = modManager.getReceptorScale(spr, 0);
				modManager.updateReceptor(spr, 0, scale, pos);

				spr.x = pos.x;
				spr.y = pos.y;
				spr.z = pos.z;
				spr.scale.set(scale.x, scale.y);

				scale.put();
			});
			opponentStrums.forEach(function(spr:StrumNote)
			{
				var pos = modManager.getReceptorPos(spr, 1);
				var scale = modManager.getReceptorScale(spr, 1);
				modManager.updateReceptor(spr, 1, scale, pos);

				spr.x = pos.x;
				spr.y = pos.y;
				spr.z = pos.z;
				spr.scale.set(scale.x, scale.y);

				scale.put();
			});
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int;
		switch (curStage)
			{
				case 'starved':
					iconOffset = 270;
				default:
					iconOffset = 26;
			}

		switch (curStage)
		{
			case 'starved':
				iconP1.y = healthBar.y
				+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
				+ (150 * iconP1.scale.x - 150) / 2
				- iconOffset;
					iconP2.y = healthBar.y
				+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
				- (150 * iconP2.scale.x) / 2
				- iconOffset;
			default:
				iconP1.x = healthBar.x
				+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
				+ (150 * iconP1.scale.x - 150) / 2
				- iconOffset;
					iconP2.x = healthBar.x
				+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
				- (150 * iconP2.scale.x) / 2
				- iconOffset * 2;
		}
		//haha code go brrr
		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.justPressed.EIGHT && !endingSong && !inCutscene)
		{
			persistentUpdate = false;
			paused = true;
			cancelFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += elapsed * 1000;
				if (Conductor.songPosition >= 0)
				{
					switch (curSong)
					{
						case 'too-slow':
							startSong();
						case 'endless':
							startSong();
						default:
							startSong();
					}
				}
			}
		}
		else
		{
			Conductor.songPosition += elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if (updateTime)
				{
					var curTime:Float = FlxG.sound.music.time - ClientPrefs.noteOffset;
					if (curTime < 0)
						curTime = 0;
					songPercent = (curTime / songLength);

					var secondsTotal:Int = Math.floor((songLength - curTime) / 1000);
					if (secondsTotal < 0)
						secondsTotal = 0;

					var minutesRemaining:Int = Math.floor(secondsTotal / 60);
					var secondsRemaining:String = '' + secondsTotal % 60;

					if (secondsRemaining.length < 2)
						secondsRemaining = '0' + secondsRemaining; // Dunno how to make it display a zero first in Haxe lol

					if(SONG.song.toLowerCase()=='endless' && curStep>=898){
						songPercent=0;
						timeTxt.text = 'Infinity';
					}else
						timeTxt.text = minutesRemaining + ':' + secondsRemaining;

					var curMS:Float = Math.floor(curTime);
					var curSex:Int = Math.floor(curMS / 1000);
					if (curSex < 0)
						curSex = 0;

		    	var curMins = Math.floor(curSex / 60);
					curMS%=1000;
		    	curSex%=60;

					minNumber.number = curMins;

					var sepSex = Std.string(curSex).split("");
					if(curSex<10){
						secondNumberA.number = 0;
						secondNumberB.number = curSex;
					}else{
						secondNumberA.number = Std.parseInt(sepSex[0]);
						secondNumberB.number = Std.parseInt(sepSex[1]);
					}
					if(millisecondNumberA!=null && millisecondNumberB!=null){
						curMS = Math.round(curMS/10);
						if(curMS<10){
							millisecondNumberA.number = 0;
							millisecondNumberB.number = Math.floor(curMS);
						}else{
							var sepMSex = Std.string(curMS).split("");
							millisecondNumberA.number = Std.parseInt(sepMSex[0]);
							millisecondNumberB.number = Std.parseInt(sepMSex[1]);
						}
					}
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			var curSection = Std.int(curStep / 16);
			if (curSection != lastSection)
			{
				// section reset stuff
				var lastMustHit:Bool = PlayState.SONG.notes[lastSection].mustHitSection;
				if (PlayState.SONG.notes[curSection].mustHitSection != lastMustHit)
				{
					camDisplaceX = 0;
					camDisplaceY = 0;
				}
				lastSection = Std.int(curStep / 16);
			}

			updateCamFollow(elapsed);
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		/*if(trueFatal!=null){
			var scaleW = trueFatal.width / (FlxG.width / FlxG.camera.zoom);
			var scaleH = trueFatal.height / (FlxG.height / FlxG.camera.zoom);

			var scale = scaleW > scaleH ? scaleW : scaleH;

			trueFatal.scale.x = scale;
			trueFatal.scale.y = scale;
		}*/

		camNotes.zoom = camHUD.zoom;
		camNotes.x = camHUD.x;
		camNotes.y = camHUD.y;

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = 1000;
			if (songSpeed < 1)time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				dunceNote.visible = false;
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			// if the song is generated
			if (generatedMusic && startedCountdown)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					// set the notes x and y
					var downscrollMultiplier:Float = 1;
					if (ClientPrefs.downScroll)
						downscrollMultiplier = -1;

					if (useModchart)
						downscrollMultiplier = CoolUtil.scale(modManager.get("reverse").getScrollReversePerc(daNote.noteData, daNote.mustPress == true ? 0 : 1),
							0, 1, 1, -1);

					var receptors:FlxTypedGroup<StrumNote> = (daNote.mustPress ? playerStrums : opponentStrums);

					var receptorPosY:Float = receptors.members[Math.floor(daNote.noteData)].y;
					var psuedoY:Float = getScrollPos(Conductor.songPosition - daNote.strumTime, daNote.speed);
					// var psuedoX = 25;
					if (useModchart)
					{
						var notePos = modManager.getPath(Conductor.songPosition - daNote.strumTime, psuedoY, daNote.noteData, daNote.mustPress == true ? 0 : 1);
						notePos.x += daNote.offsetX;
						notePos.y += daNote.offsetY;

						var scale = modManager.getNoteScale(daNote);
						modManager.updateNote(daNote, daNote.mustPress ? 0 : 1, scale, notePos);

						daNote.x = notePos.x;
						daNote.y = notePos.y;

						daNote.z = notePos.z;

						daNote.scale.copyFrom(scale);
						daNote.updateHitbox();

						if (daNote.isSustainNote)
						{
							var futureSongPos = Conductor.songPosition + 75;

							var diff = futureSongPos - daNote.strumTime;
							var vDiff:Float = (-((futureSongPos - daNote.strumTime) * (0.45 * (songSpeed * daNote.speed))));

							var nextPos = modManager.getPath(diff, vDiff, daNote.noteData, daNote.mustPress == true ? 0 : 1);
							nextPos.x += daNote.offsetX;
							nextPos.y += daNote.offsetY;

							var diffX = (nextPos.x - notePos.x);
							var diffY = (nextPos.y - notePos.y);
							var rad = Math.atan2(diffY, diffX);
							var deg = rad * (180 / Math.PI);
							if (deg != 0)
								daNote.angle = deg + 90;
							else
								daNote.angle = 0;

							if (downscrollMultiplier < 0)
								daNote.angle += 180;
						}

						scale.put();
					}
					else
					{
						daNote.y = receptorPosY + (downscrollMultiplier * psuedoY) + daNote.offsetY;
						// painful math equation
						daNote.x = receptors.members[Math.floor(daNote.noteData)].x + daNote.offsetX;
					}

					// if you're doing fuckin uhh schmovin hold renderer
					// comment out atleast the cliprect stuff
					// idk bout this shit

					// okay nebula zorua fuck you k*ll yourself - yoshubs

					// <3 -nebulazorua

					// shitty note hack I hate it so much

					if(!ClientPrefs.schmovin){
						var center:Float = receptorPosY + Note.swagWidth / 2;
						if (daNote.isSustainNote)
						{
							if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null))
							{
								daNote.y -= ((daNote.prevNote.height / 2) * downscrollMultiplier);
								if (downscrollMultiplier < 0)
								{
									daNote.y += (daNote.height * 2);
									if (daNote.endHoldOffset == Math.NEGATIVE_INFINITY)
									{
										daNote.endHoldOffset = (daNote.prevNote.y - (daNote.y + daNote.height));
									}
									else
										daNote.y += daNote.endHoldOffset;
								}
								else // this system is funny like that
									daNote.y += ((daNote.height / 2) * downscrollMultiplier);
							}

							if (downscrollMultiplier < 0) // goin DOWWWWWNNNNNNNNNNNN
							{
								daNote.flipY = true;
								if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
									&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;
									daNote.clipRect = swagRect;
								}
							}
							else
							{
								daNote.flipY = false;
								if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
									&& daNote.y + daNote.offset.y * daNote.scale.y <= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (center - daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;
									daNote.clipRect = swagRect;
								}
							}
						}
					}

					if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
					{
						if (Paths.formatToSongPath(SONG.song) != 'tutorial')
							camZooming = true;

						if (daNote.noteType == 'Hey!' && dad.animOffsets.exists('hey'))
						{
							dad.playAnim('hey', true);
							dad.specialAnim = true;
							dad.heyTimer = 0.6;
						}
						else if (!daNote.noAnimation)
						{
							var altAnim:String = "";

							if (SONG.notes[Math.floor(curStep / 16)] != null)
							{
								if (SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.noteType == 'Alt Animation')
								{
									altAnim = '-alt';
								}
							}

							if (true && flyState == '')
							{
								// doCamMove(daNote.noteData, false);
							}

							var animToPlay:String = '';
							if (SONG.isRing)
								switch (Math.abs(daNote.noteData))
								{
									case 0:
										animToPlay = 'singLEFT';
									case 1:
										animToPlay = 'singDOWN';
									case 3:
										animToPlay = 'singUP';
									case 4:
										animToPlay = 'singRIGHT';
								}
							else
								switch (Math.abs(daNote.noteData))
								{
									case 0:
										animToPlay = 'singLEFT';
									case 1:
										animToPlay = 'singDOWN';
									case 2:
										animToPlay = 'singUP';
									case 3:
										animToPlay = 'singRIGHT';
								}
							if (daNote.noteType == 'GF Sing')
							{
								gf.playAnim(animToPlay + altAnim, true);
								gf.holdTimer = 0;
							}
							else if (curStage == 'needle')
							{
								dad.playAnim(animToPlay + altAnim, true);
								dad2.playAnim(animToPlay + altAnim, true);

								dad.holdTimer = 0;
								dad2.holdTimer = 0;
							}
							else
							{
								dad.playAnim(animToPlay + altAnim, true);
								dad.holdTimer = 0;
							}
						}

						if (SONG.needsVoices)
							vocals.volume = 1;

						var time:Float = 0.15;
						if (daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end'))
						{
							time += 0.15;
						}
						if (SONG.isRing)
							StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)) % 5, time);
						else
							StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)) % 4, time);
						daNote.hitByOpponent = true;

						if (dad.curCharacter == 'starved' && daNote.hitByOpponent)
						{
							fearNo += 0.15;
							// trace(fearNo);
						}

						callOnLuas('opponentNoteHit', [
							notes.members.indexOf(daNote),
							Math.abs(daNote.noteData),
							daNote.noteType,
							daNote.isSustainNote
						]);

						if (!daNote.isSustainNote)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					}

					// check where the note is and make sure it is either active or inactive
					if (daNote.y > FlxG.height)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}

					// if(daNote.isSustainNote)daNote.visible=false;

					if (!daNote.tooLate && daNote.strumTime < Conductor.songPosition - (Conductor.safeZoneOffset) && !daNote.wasGoodHit)
					{
						if ((!daNote.tooLate) && (daNote.mustPress))
						{
							if (!daNote.isSustainNote)
							{
								daNote.tooLate = true;
								for (note in daNote.childrenNotes)
									note.tooLate = true;

								if (!daNote.ignoreNote || ((SONG.isRing && daNote.noteData == 2)))
									noteMissPress(daNote.noteData);
							}
							else if (daNote.isSustainNote)
							{
								if (daNote.parentNote != null)
								{
									var parentNote = daNote.parentNote;
									if (!parentNote.tooLate)
									{
										var breakFromLate:Bool = false;
										for (note in parentNote.childrenNotes)
										{
											trace('hold amount ${parentNote.childrenNotes.length}, note is late?' + note.tooLate + ', ' + breakFromLate);
											if (note.tooLate && !note.wasGoodHit)
												breakFromLate = true;
										}
										if (!breakFromLate)
										{
											if (!daNote.ignoreNote || ((SONG.isRing && daNote.noteData == 2)))
												noteMissPress(daNote.noteData);
											for (note in parentNote.childrenNotes)
												note.tooLate = true;
										}
										//
									}
								}
							}
						}
					}

					if (daNote.mustPress && cpuControlled)
					{
						if (daNote.isSustainNote)
						{
							if (daNote.canBeHit)
								goodNoteHit(daNote);
						}
						else if (daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress))
							goodNoteHit(daNote);
					}

					// if the note is off screen (above)
					if ((((downscrollMultiplier > 0) && (daNote.y < -daNote.height))
						|| ((downscrollMultiplier < 0) && (daNote.y > (FlxG.height + daNote.height)))
						|| (daNote.isSustainNote && daNote.strumTime - Conductor.songPosition < -noteKillOffset))
						&& (daNote.tooLate || daNote.wasGoodHit))
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}

			FlxG.watch.addQuick("rendered notes", notes.members.length);
			// reset bf's animation
			var up = controls.NOTE_UP;
			var right = controls.NOTE_RIGHT;
			var down = controls.NOTE_DOWN;
			var left = controls.NOTE_LEFT;
			var spaceM = hitbox.buttonDodge.pressed;

			var holdControls:Array<Bool> = [left, down, up, right]; //default keys
			if (SONG.isRing) {
				#if mobile
					holdControls = [left, down, spaceM, up, right];
				#else
					holdControls = [left, down, FlxG.keys.pressed.SPACE, up, right];
				#end
			}
			if (holdControls.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
						&& daNote.isSustainNote
						&& daNote.canBeHit
						&& daNote.mustPress
						&& holdControls[daNote.noteData]
						&& !daNote.tooLate)
						goodNoteHit(daNote);
				});
			}

			if ((boyfriend != null && boyfriend.animation != null)
				&& (boyfriend.holdTimer > Conductor.stepCrochet * (4 / 1000) && (!holdControls.contains(true) || cpuControlled)))
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.dance();
			}
			cameraDisplacement(boyfriend, true);
			cameraDisplacement(dad, false);
		}
		checkEventNote();

		if (!inCutscene)
		{
			if (cpuControlled
				&& boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				bfCamThing = [0, 0];
			}
		}

		#if debug
		if (!endingSong && !startingSong)
		{
			if (FlxG.keys.justPressed.ONE)
			{
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if (FlxG.keys.justPressed.TWO)
			{ // Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime + 800 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length)
				{
					var daNote:Note = unspawnNotes[0];
					if (daNote.strumTime >= Conductor.songPosition)
					{
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', PlayState.cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
		#end
	}

	var isDead:Bool = false;

	function doDeathCheck()
	{
		if (health <= 0 && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if (ret != FunkinLua.Function_Stop)
			{
				boyfriend.stunned = true;
				deathCounter++;

				persistentUpdate = false;
				paused = true;
				if (SONG.song.toLowerCase() != 'fight or flight' && SONG.song.toLowerCase() != 'prey')
					{
						FlxG.camera.zoom = 1.2;
						persistentDraw = true;
					}
				else
					{
						FlxG.camera.zoom = 1;
						persistentDraw = false;
					}

				//crybit please
				camHUD.alpha = 0;
				camOther.alpha = 0;
				boyfriendGroup.alpha = 0;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.x, boyfriend.y, camFollowPos.x, camFollowPos.y, this));
				for (tween in modchartTweens)
				{
					tween.active = true;
				}
				for (timer in modchartTimers)
				{
					timer.active = true;
				}

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, songRPC + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	function doSimpleJump()
	{
		trace('SIMPLE JUMPSCARE');

		var simplejump:FlxSprite;
		simplejump = new FlxSprite(0, 0).loadGraphic(Paths.image("simplejump", 'exe'));
		simplejump.setGraphicSize(FlxG.width, FlxG.height);
		simplejump.screenCenter();
		simplejump.cameras = [camOther];
		FlxG.camera.shake(0.0025, 0.50);

		add(simplejump);

		FlxG.sound.play(Paths.sound('sppok', 'exe'), 1);

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			trace('ended simple jump');
			remove(simplejump);
		});

		// now for static

		var daStatic:FlxSprite;
		daStatic = new FlxSprite(0, 0).loadGraphic(Paths.image("daSTAT", 'exe'));
		daStatic.frames = Paths.getSparrowAtlas('daSTAT');
		daStatic.setGraphicSize(FlxG.width, FlxG.height);
		daStatic.screenCenter();
		daStatic.cameras = [camOther];
		daStatic.animation.addByPrefix('static', 'staticFLASH', 24, false);
		add(daStatic);

		FlxG.sound.play(Paths.sound('staticBUZZ'));

		if (daStatic.alpha != 0)
			daStatic.alpha = FlxG.random.float(0.1, 0.5);

		daStatic.animation.play('static');

		daStatic.animation.finishCallback = function(pog:String)
		{
			trace('ended static');
			remove(daStatic);
		}
	}

	function doStaticSign(lestatic:Int = 0, leopa:Bool = true)
	{
		trace('static MOMENT HAHAHAH ' + lestatic);

		var daStatic:FlxSprite;
		daStatic = new FlxSprite(0, 0).loadGraphic(Paths.image("daSTAT", 'exe'));
		daStatic.frames = Paths.getSparrowAtlas('daSTAT');
		daStatic.setGraphicSize(FlxG.width, FlxG.height);
		daStatic.screenCenter();
		daStatic.cameras = [camHUD];

		switch (lestatic)
		{
			case 0:
				daStatic.animation.addByPrefix('static', 'staticFLASH', 24, false);
		}
		add(daStatic);

		FlxG.sound.play(Paths.sound('staticBUZZ'));

		if (leopa)
		{
			if (daStatic.alpha != 0)
				daStatic.alpha = FlxG.random.float(0.1, 0.5);
		}
		else
			daStatic.alpha = 1;

		daStatic.animation.play('static');

		daStatic.animation.finishCallback = function(pog:String)
		{
			trace('ended static');
			remove(daStatic);
		}
	}

	var strumArray:Array<Int> = [0, 1, 2, 3];

	public function cameraDisplacement(character:Character, mustHit:Bool)
	{
		var camDisplaceExtend:Float = 15;
		if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if ((PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && mustHit)
				|| (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && !mustHit))
			{
				if(character.animation.curAnim!=null){
					camDisplaceX = 0;
					camDisplaceY = 0;
					switch (character.animation.curAnim.name)
					{
						case 'singUP':
							camDisplaceY -= camDisplaceExtend;
						case 'singDOWN':
							camDisplaceY += camDisplaceExtend;
						case 'singLEFT':
							camDisplaceX -= camDisplaceExtend;
						case 'singRIGHT':
							camDisplaceX += camDisplaceExtend;
					}
				}
			}
		}
	}

	public function checkEventNote()
	{
		while (eventNotes.length > 0)
		{
			var early:Float = eventNoteEarlyTrigger(eventNotes[0]);
			var leStrumTime:Float = eventNotes[0][0];
			if (Conductor.songPosition < leStrumTime - early)
			{
				break;
			}

			var value1:String = '';
			if (eventNotes[0][3] != null)
				value1 = eventNotes[0][3];

			var value2:String = '';
			if (eventNotes[0][4] != null)
				value2 = eventNotes[0][4];

			triggerEventNote(eventNotes[0][2], value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String)
	{
		var pressed:Bool = Reflect.getProperty(controls, key);
		// trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String)
	{
		switch (eventName)
		{
			case 'Song Speed Change':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
			case 'Lyrics':
				var split = value1.split("--");
				var text = value1;
				var color = FlxColor.WHITE;
				if(split.length > 1){
					text = split[0];
					color = FlxColor.fromString(split[1]);
				}
				var duration:Float = Std.parseFloat(value2);
				if (Math.isNaN(duration) || duration <= 0)
					duration = text.length * 0.5;

				writeLyrics(text, duration, color);
			case 'Hey!':
				var value:Int = 2;
				switch (value1.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if (Math.isNaN(time) || time <= 0)
					time = 0.6;

				if (value != 0)
				{
					if (dad.curCharacter.startsWith('gf'))
					{ // Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					}
					else
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

				}
				if (value != 1)
				{
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Add Camera Zoom':
				if (ClientPrefs.camZooms && FlxG.camera.zoom < 1.35)
				{
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if (Math.isNaN(camZoom))
						camZoom = 0.015;
					if (Math.isNaN(hudZoom))
						hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				// trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch (value2.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if (Math.isNaN(val2))
							val2 = 0;

						switch (val2)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				switch (value1)
				{
					case 'end':
						char.specialAnim = false;
					case 'laugh':
						if(char.curCharacter=='ycr' || char.curCharacter=='ycr-mad'){
							camGame.zoom += 0.03;
							camHUD.zoom += 0.06;
						}

						char.specialAnim = false;
						char.playAnim(value1, true);
						char.specialAnim = true;
					default:
						char.specialAnim = false;
						char.playAnim(value1, true);
						char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 0;
				if (Math.isNaN(val2))
					val2 = 0;

				isCameraOnForcedPos = false;
				if (!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2)))
				{
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch (value1.toLowerCase())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if (Math.isNaN(val))
							val = 0;

						switch (val)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.idleSuffix = value2;
				char.recalculateDanceIdle();

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length)
				{
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = Std.parseFloat(split[0].trim());
					var intensity:Float = Std.parseFloat(split[1].trim());
					if (Math.isNaN(duration))
						duration = 0;
					if (Math.isNaN(intensity))
						intensity = 0;

					if (duration > 0 && intensity != 0)
					{
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'HUD opaticity':
				var alpha:Float = Std.parseFloat(value1);
				var time:Float = Std.parseFloat(value2);
				FlxTween.tween(camHUD, {alpha: alpha}, time);
			case 'Chroma Video':
				if(ClientPrefs.flashing)chromaVideo(value1);
			case '':
				/*switch (value1)
				{
					case 'Endless':
						{
							switch (value2)
							{
								case "count1":
									inCutscene = true;
									camFollow.set(FlxG.width / 2 + 50, FlxG.height / 4 * 3 + 280);
									FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
									three();
								case "count2":
									FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
									two();
								case "count3":
									FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
									one();
								case "count4":
									inCutscene = false;
									FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.7, {ease: FlxEase.cubeInOut});
									gofun();
								case "strum":
									StrumNote.isMajinNote = true;
									removeStatics();
									generateStaticArrows(0);
									generateStaticArrows(1);
									StrumNote.isMajinNote = false;
								case "spin":
									strumLineNotes.forEach(function(tospin:FlxSprite)
									{
										FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
									});
							}
						}
				}*/ // This Thing can make us and player confused about events

			case 'Genesis':
				var value:Int = Std.parseInt(value1);
				if (Math.isNaN(value))
					value = 0;
				switch (value)
				{
					case 1:
						defaultCamZoom = 0.9;
						// FlxG.camera.flash(FlxColor.WHITE, 0.3);
						// pickle = true;
						// filters.push(ShadersHandler.scanline);
						isPixelStage = true;
						scoreTxt.visible=false;
						timeBar.visible=false;
						timeBarBG.visible=false;
						timeTxt.visible=false;

						removeStatics();
						generateStaticArrows(0);
						generateStaticArrows(1);
						sonicHUD.visible=true;
						pickle.visible = true;
						genesis.visible = false;
						if (boyfriend.curCharacter != 'bfpickel')
						{
							if (!boyfriendMap.exists('bfpickel'))
							{
								addCharacterToList('bfpickel', 0);
							}

							boyfriend.visible = false;
							boyfriend = boyfriendMap.get('bfpickel');
							if (!boyfriend.alreadyLoaded)
							{
								boyfriend.alpha = 1;
								boyfriend.alreadyLoaded = true;
							}
							boyfriend.visible = true;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						if (gf.curCharacter != 'gf-pixel')
						{
							if (!gfMap.exists('gf-pixel'))
							{
								addCharacterToList('gf-pixel', 2);
							}

							gf.visible = false;
							gf = gfMap.get('gf-pixel');
							if (!gf.alreadyLoaded)
							{
								gf.alpha = 1;
								gf.alreadyLoaded = true;
							}
						}

						if (dad.curCharacter != 'pixelrunsonic')
						{
							if (!dadMap.exists('pixelrunsonic'))
							{
								addCharacterToList('pixelrunsonic', 1);
							}

							dad.visible = false;
							dad = dadMap.get('pixelrunsonic');
							if (!dad.alreadyLoaded)
							{
								dad.alpha = 1;
								dad.alreadyLoaded = true;
							}
							dad.visible = true;

							iconP2.changeIcon(dad.healthIcon);
						}
						// dad.x = 100;
						dad.setPosition(70, 350);
						dad.y -= 155;
						boyfriend.setPosition(530 + 100, 170 + 200);
						gf.x = 400;
						gf.y = 130;
						reloadHealthBarColors();

						healthBar.x += 150;
						iconP1.x += 150;
						iconP2.x += 150;
						healthBarBG.x += 150;
						updateCamFollow();
						camFollowPos.setPosition(camFollow.x, camFollow.y);
					case 2:
						scoreTxt.visible=!ClientPrefs.hideHud;
						timeBar.visible=!ClientPrefs.hideTime;
						timeBarBG.visible=!ClientPrefs.hideTime;
						timeTxt.visible=!ClientPrefs.hideTime;
						sonicHUD.visible=false;
						defaultCamZoom = 0.65;
						isPixelStage = false;
						removeStatics();
						generateStaticArrows(0);
						generateStaticArrows(1);
						//	chromOn = false;
						pickle.visible = false;
						//	filters.remove(ShadersHandler.scanline);
						genesis.visible = true;
						if (boyfriend.curCharacter != 'bf')
						{
							if (!boyfriendMap.exists('bf'))
							{
								addCharacterToList('bf', 0);
							}

							boyfriend.visible = false;
							boyfriend = boyfriendMap.get('bf');
							if (!boyfriend.alreadyLoaded)
							{
								boyfriend.alpha = 1;
								boyfriend.alreadyLoaded = true;
							}
							boyfriend.visible = true;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						if (dad.curCharacter != 'ycr-mad')
						{
							if (!dadMap.exists('ycr-mad'))
							{
								addCharacterToList('ycr-mad', 1);
							}

							dad.visible = false;
							dad = dadMap.get('ycr-mad');
							if (!dad.alreadyLoaded)
							{
								dad.alpha = 1;
								dad.alreadyLoaded = true;
							}
							dad.visible = true;
							iconP2.changeIcon(dad.healthIcon);
						}
						if (gf.curCharacter != 'gf')
						{
							if (!gfMap.exists('gf'))
							{
								addCharacterToList('gf', 2);
							}

							gf.visible = false;
							gf = gfMap.get('gf');
							if (!gf.alreadyLoaded)
							{
								gf.alpha = 1;
								gf.alreadyLoaded = true;
							}
						}
						reloadHealthBarColors();
						//	dad.x = 100;
						//	dad.y = 50;
						//	boyfriend.x = 800;
						//	boyfriend.y = 20;
						healthBar.x -= 150;
						iconP1.x -= 150;
						iconP2.x -= 150;
						healthBarBG.x -= 150;
						updateCamFollow();
						camFollowPos.setPosition(camFollow.x, camFollow.y);
				}
			case 'RedVG':
				// ty maliciousbunny, i stole this from you but eh you wrote it in v2 so its fiiiiiiiiiiiine
				var vg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('RedVG', 'exe'));
				vg.alpha = 0;
				vg.cameras = [camHUD];
				add(vg);

				// now that we can pause it, why not just yknow

				FlxTween.tween(vg, {alpha: 1}, 0.85, {type: FlxTweenType.PINGPONG});

			case 'static':
				doStaticSign(0, false);

			case 'TooSlowFlashinShit':
				switch (Std.parseFloat(value1))
				{
					case 1:
						doStaticSign(0);
					case 2:
						doSimpleJump();
				}

			case 'strum swap1':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.x -= 645;
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x += 645;
				});
				bfIsLeft = true;
				iconP1.changeIcon(dad.healthIcon);
				iconP2.changeIcon(boyfriend.healthIcon);
				reloadHealthBarColors();
			case 'strum swap2':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.x += 645;
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x -= 645;
				});
				bfIsLeft = false;
				iconP2.changeIcon(dad.healthIcon);
				iconP1.changeIcon(boyfriend.healthIcon);
				reloadHealthBarColors();
			case 'Character Fly':
				flyState = '';
				FlxTween.tween(dad, {x: DAD_X, y: DAD_Y}, 0.2, {
					onComplete: function(lol:FlxTween)
					{
						dad.setPosition(DAD_X, DAD_Y);
						flyState = value1;
					}
				});

			case 'spingbing':
				var sponge:FlxSprite = new FlxSprite(dad.getGraphicMidpoint().x - 100,
					dad.getGraphicMidpoint().y - 120).loadGraphic(Paths.image('SpingeBinge', 'exe'));

				add(sponge);

				dad.visible = false;

				new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					remove(sponge);
					dad.visible = true;
				});

			case 'sonicspook':
				trace('JUMPSCARE aaaa');

				var daJumpscare:FlxSprite = new FlxSprite();
				daJumpscare.frames = Paths.getSparrowAtlas('sonicJUMPSCARE');
				daJumpscare.animation.addByPrefix('jump', "sonicSPOOK", 24, false);
				daJumpscare.animation.play('jump',true);
				daJumpscare.scale.x = 1.1;
				daJumpscare.scale.y = 1.1;
				daJumpscare.updateHitbox();
				daJumpscare.screenCenter();
				daJumpscare.y += 370;
				daJumpscare.cameras = [camHUD];

				FlxG.sound.play(Paths.sound('jumpscare'), 1);
				FlxG.sound.play(Paths.sound('datOneSound'), 1);

				add(daJumpscare);

				daJumpscare.animation.play('jump');

				daJumpscare.animation.finishCallback = function(pog:String)
				{
					trace('ended jump');
					daJumpscare.visible = false;
				}

			case 'char disappear':
				boyfriend.visible = false;
				flooooor.visible = false;

			case 'char appear':
				boyfriend.visible = true;
				flooooor.visible = true;

			case 'Pnotefade':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.2, {ease: FlxEase.sineOut});
				});
			case 'Pnotein':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 1}, 0.1, {ease: FlxEase.sineIn});
				});
			case 'TDnoteshitdie':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (!FlxG.save.data.midscroll)
						spr.x -= 275;
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x -= 1000;
				});
			case 'TDnoteshitlive':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 1}, 0.4, {ease: FlxEase.circOut});
					if (!FlxG.save.data.midscroll)
						spr.x += 275;
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x += 1000;
				});

			case 'funnystatic':
				trace('p3static XDXDXD');
				var daP3Static:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Phase3Static', 'exe'));
				daP3Static.frames = Paths.getSparrowAtlas('Phase3Static', 'exe');
				daP3Static.animation.addByPrefix('P3Static', 'Phase3Static instance 1', 24, false);
				daP3Static.screenCenter();

				daP3Static.scale.x = 4;
				daP3Static.scale.y = 4;
				daP3Static.alpha = 0.5;

				daP3Static.cameras = [camHUD];
				add(daP3Static);
				daP3Static.animation.play('P3Static');

				daP3Static.animation.finishCallback = function(pog:String)
				{
					trace('ended p3static');
					daP3Static.alpha = 0;

					remove(daP3Static);
				}

			case 'startstatic':
				goofyAhhStatic(1);

			case 'tailsjump':
				spookyJumpscareAAA("tails");
			case 'Clear Popups':
				while(FatalPopup.popups.length>0)
					FatalPopup.popups[0].close();
			case 'Fatality Popup':
				var value:Int = Std.parseInt(value1);
				if (Math.isNaN(value) || value<1)
					value = 1;

				var type:Int = Std.parseInt(value2);
				if (Math.isNaN(type) || type<1)
					type = 1;
				for(idx in 0...value){
					doPopup(type);
				}
			case 'knuxjump':
				spookyJumpscareAAA("knux");
			case 'eggjump':
				spookyJumpscareAAA("egg");

			case 'Change Character':
				var charType:Int = 0;
				switch (value1)
				{
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				switch (charType)
				{
					case 0:
						if (boyfriend.curCharacter != value2)
						{
							if (!boyfriendMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							boyfriend.visible = false;
							boyfriend = boyfriendMap.get(value2);
							if (!boyfriend.alreadyLoaded)
							{
								boyfriend.alpha = 1;
								boyfriend.alreadyLoaded = true;
							}
							boyfriend.visible = true;
							if (!bfIsLeft) iconP1.changeIcon(boyfriend.healthIcon) else iconP1.changeIcon(dad.healthIcon);
						}

					case 1:
						if (dad.curCharacter != value2)
						{
							if (!dadMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							dad.visible = false;
							dad = dadMap.get(value2);
							if (!dad.curCharacter.startsWith('gf'))
							{
								if (wasGf)
								{
									gf.visible = true;
								}
							}
							else
							{
								gf.visible = false;
							}
							if (!dad.alreadyLoaded)
							{
								dad.alpha = 1;
								dad.alreadyLoaded = true;
							}
							dad.visible = true;
							if (!bfIsLeft) iconP2.changeIcon(dad.healthIcon) else iconP2.changeIcon(boyfriend.healthIcon);
						}

					case 2:
						if (gf.curCharacter != value2)
						{
							if (!gfMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							gf.visible = false;
							gf = gfMap.get(value2);
							if (!gf.alreadyLoaded)
							{
								gf.alpha = 1;
								gf.alreadyLoaded = true;
							}
						}
				}
				reloadHealthBarColors();
				//EXE Events
				case 'Majin count':
					switch (Std.parseFloat(value1))
					{
						case 1:
							inCutscene = true;
							camFollow.set(FlxG.width / 2 + 50, FlxG.height / 4 * 3 + 280);
							FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
							majinSaysFuck(4);
						case 2:
							FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
							majinSaysFuck(3);
						case 3:
							FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
							majinSaysFuck(2);
						case 4:
							inCutscene = false;
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.7, {ease: FlxEase.cubeInOut});
							majinSaysFuck(1);
					}
			case 'Majin spin':
				strumLineNotes.forEach(function(tospin:FlxSprite)
					{
						FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
					});
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	var cameraTwn:FlxTween;

	function tweenCamIn()
	{
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
		{
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FlxEase.elasticInOut,
				onComplete: function(twn:FlxTween)
				{
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; // In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if (ClientPrefs.noteOffset <= 0)
		{
			finishCallback();
		}
		else
		{
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer)
			{
				finishCallback();
			});
		}
	}

	var transitioning = false;

	public function endSong():Void
	{
		// Should kill you if you tried to cheat
		if (!startingSong)
		{
			notes.forEach(function(daNote:Note)
			{
				health -= 0.0475;
			});
			for (daNote in unspawnNotes)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.0475;
				}
			}

			if (doDeathCheck())
			{
				return;
			}
		}

		if(SONG.song.toLowerCase() == 'milk'&& aspectRatio)
			{
				ClientPrefs.noteSize == 0.7;
			}
		if(SONG.song.toLowerCase()=='fatality'){
			#if windows
			try{
				Sys.command('${Sys.getCwd()}\\assets\\exe\\FatalError.exe');
			}catch(e:Dynamic){
				trace("A fatal error has ACTUALLY occured: " + e);
			}
			#end
			FlxG.mouse.visible = false;
			FlxG.mouse.unload();
		}
		#if mobile
			if (SONG.isRing && SONG.song.toLowerCase()=='triple-trouble') {
				hitbox.visible = false;
			} else {
				mobileControls.visible = false;
			}
		#end

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;

		deathCounter = 0;
		seenCutscene = false;
		updateTime = false;


		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if (ret != FunkinLua.Function_Stop && !transitioning)
		{
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if (Math.isNaN(percent))
					percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelFadeTween();
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if (!usedPractice)
					{
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						ClientPrefs.beatweek = true;
						ClientPrefs.saveSettings();
						FlxG.save.flush();

					}
					usedPractice = false;
					changedDifficulty = false;
					cpuControlled = false;
				}
				else
				{
					var difficulty:String = '' + CoolUtil.difficultyStuff[storyDifficulty][1];

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);


					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();
					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						new FlxTimer().start(1.5, function(tmr:FlxTimer)
						{
							cancelFadeTween();
							// resetSpriteCache = true;
							LoadingState.loadAndSwitchState(new PlayState());
						});
					}
					else
					{
						cancelFadeTween();
						// resetSpriteCache = true;
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelFadeTween();
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				usedPractice = false;
				changedDifficulty = false;
				cpuControlled = false;
			}
			transitioning = true;
		}
	}

	public function KillNotes()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var ratingIndexArray:Array<String> = ["sick", "good", "bad", "shit"];
	public var returnArray:Array<String> = [" [SFC]", " [GFC]", " [FC]", ""];
	public var smallestRating:String;

	function updateSonicScore(){
		var seperatedScore:Array<String> = Std.string(songScore).split("");
		if(seperatedScore.length<scoreNumbers.length){
			for(idx in seperatedScore.length...scoreNumbers.length){
				if(hudStyle == 'chaotix' || hudStyle == 'sonic3' || hudStyle == 'soniccd'){
					seperatedScore.unshift('');
				}else{
					seperatedScore.unshift('0');
				}
			}
		}
		if(seperatedScore.length>scoreNumbers.length)
			seperatedScore.resize(scoreNumbers.length);

		for(idx in 0...seperatedScore.length){
			if(seperatedScore[idx]!='' || idx==scoreNumbers.length-1){
				var val = Std.parseInt(seperatedScore[idx]);
				if(Math.isNaN(val))val=0;
				scoreNumbers[idx].number = val;
				scoreNumbers[idx].visible=true;
			}else
				scoreNumbers[idx].visible=false;

		}
	}

	function updateSonicMisses(){
		var seperatedScore:Array<String> = Std.string(songMisses).split("");
		if(seperatedScore.length<missNumbers.length){
			for(idx in seperatedScore.length...missNumbers.length){
				if(hudStyle == 'chaotix' || hudStyle == 'sonic3' || hudStyle == 'soniccd'){
					seperatedScore.unshift('');
				}else{
					seperatedScore.unshift('0');
				}
			}
		}
		if(seperatedScore.length>missNumbers.length)
			seperatedScore.resize(missNumbers.length);

		for(idx in 0...seperatedScore.length){
			if(seperatedScore[idx]!='' || idx==missNumbers.length-1){
				var val = Std.parseInt(seperatedScore[idx]);
				if(Math.isNaN(val))val=0;
				missNumbers[idx].number = val;
				missNumbers[idx].visible=true;
			}else
				missNumbers[idx].visible=false;

		}
	}

	function updateSonicRings(){
		var seperatedScore:Array<String> = Std.string(cNum).split("");
		if(seperatedScore.length<ringsNumbers.length){
			for(idx in seperatedScore.length...ringsNumbers.length){
				if(hudStyle == 'chaotix' || hudStyle == 'sonic3' || hudStyle == 'soniccd'){
					seperatedScore.unshift('');
				}else{
					seperatedScore.unshift('0');
				}
			}
		}
		if(seperatedScore.length>ringsNumbers.length)
			seperatedScore.resize(ringsNumbers.length);

		for(idx in 0...seperatedScore.length){
			if(seperatedScore[idx]!='' || idx==ringsNumbers.length-1){
				var val = Std.parseInt(seperatedScore[idx]);
				if(Math.isNaN(val))val=0;
				ringsNumbers[idx].number = val;
				ringsNumbers[idx].visible=true;
			}else
				ringsNumbers[idx].visible=false;

		}
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + 8);

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;
		var diffMultiplier:Float = 1;

		ratingString = '';
		var daRating:String = "sick";
		if (noteDiff > 120)
		{
			daRating = 'shit';
			score = -50;
			diffMultiplier = -1;
			songMisses++;
			if(fucklesMode)drainMisses++;
			updateSonicMisses();
			combo = 0;
		}
		else if (noteDiff > 100)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > 50)
		{
			daRating = 'good';
			score = 200;
			if(fucklesMode)drainMisses -= 1/100;
			diffMultiplier = 0.5;
		}else{
			if(fucklesMode)drainMisses -= 1/50;
		}

		/*if (!fucklesMode)
			health += note.hitHealth * healthMultiplier * diffMultiplier;
		else
			health += 0.0000001;*/

		if (curSong == "cycles")
		{
			fileHealth = health;
		}

		if (daRating == 'sick' && !note.noteSplashDisabled){
			var splashSkin = spawnNoteSplashOnNote(note);
			if(splashSkin == 'hitmarker'){
				FlxG.sound.play(Paths.sound("hitmarker"));
			}
		}

		if (songMisses <= 0)
		{
			if (ratingIndexArray.indexOf(daRating) > ratingIndexArray.indexOf(smallestRating))
				smallestRating = daRating;
			ratingString = returnArray[ratingIndexArray.indexOf(smallestRating)];
		}

		if (!practiceMode && !cpuControlled)
		{
			songScore += score;
			updateSonicScore();
			songHits++;
			RecalculateRating();
			if (scoreTxtTween != null)
			{
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.1;
			scoreTxt.scale.y = 1.1;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween)
				{
					scoreTxtTween = null;
				}
			});
		}

		/* if (combo > 60)
			daRating = 'sick';
		else if (combo > 12)
			daRating = 'good'
		else if (combo > 4)
			daRating = 'bad';
	 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = !ClientPrefs.hideHud;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = !ClientPrefs.hideHud;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if (combo >= 1000)
		{
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/*
		trace(combo);
		trace(seperatedScore);
	 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	function ghostMiss(statement:Bool = false, direction:Int = 0, ?ghostMiss:Bool = false)
	{
		if (statement && ((SONG.isRing && direction != 2) || !SONG.isRing))
		{
			noteMissPress(direction, ghostMiss);
			callOnLuas('noteMissPress', [direction]);
		}
	}

	function noteMiss(daNote:Note):Void
	{ // You didn't hit the key and let it go offscreen, also used by Hurt Notes
		// Dupe note remove
		notes.forEachAlive(function(note:Note)
		{
			if (daNote != note
				&& daNote.mustPress
				&& daNote.noteData == note.noteData
				&& daNote.isSustainNote == note.isSustainNote
				&& Math.abs(daNote.strumTime - note.strumTime) < 10)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		var cHealth:Float = health;
		switch (daNote.noteType)
		{
			case "Static Note":
				trace('lol you missed the static note!');
				daNoteStatic = new FlxSprite(0, 0).loadGraphic(Paths.image("hitStatic", 'exe'));
				daNoteStatic.frames = Paths.getSparrowAtlas('hitStatic');
				daNoteStatic.animation.addByPrefix('static', "staticANIMATION", 24, false);
				daNoteStatic.animation.play('static');
				daNoteStatic.cameras = [camHUD];
				add(daNoteStatic);

				FlxG.camera.shake(0.005, 0.005);

				FlxG.sound.play(Paths.sound("hitStatic1"));

				add(daNoteStatic);

				new FlxTimer().start(.38, function(trol:FlxTimer) // fixed lmao
				{
					daNoteStatic.alpha = 0;
					trace('ended HITSTATICLAWL');
					remove(daNoteStatic);
				});

			//	case 'Phantom Note':
			//	health -= 0;

			default:

				if (cNum<=0 && !fucklesMode)
					health -= daNote.missHealth;
				fearNo += 5;
				songMisses++;
				if(fucklesMode)drainMisses++;
				updateSonicMisses();
			if (curSong == "cycles")
			{
				fileHealth = health;
			}
		}
		vocals.volume = 0;
		RecalculateRating();

		var animToPlay:String = '';
		if (SONG.isRing)
			switch (Math.abs(daNote.noteData) % 5)
			{
				case 0:
					animToPlay = 'singLEFTmiss';
				case 1:
					animToPlay = 'singDOWNmiss';
				case 2:
					animToPlay = '';
				case 3:
					animToPlay = 'singUPmiss';
				case 4:
					animToPlay = 'singRIGHTmiss';
			}
		else
			switch (Math.abs(daNote.noteData) % 4)
			{
				case 0:
					animToPlay = 'singLEFTmiss';
				case 1:
					animToPlay = 'singDOWNmiss';
				case 2:
					animToPlay = 'singUPmiss';
				case 3:
					animToPlay = 'singRIGHTmiss';
			}

		if (daNote.noteType == 'GF Sing')
		{
			gf.playAnim(animToPlay, true);
		}
		else
		{
			var daAlt = '';
			if (daNote.noteType == 'Alt Animation')
				daAlt = '-alt';

			boyfriend.playAnim(animToPlay + daAlt, true);
		}
		if(cNum>0){
			cNum--;
			updateSonicRings();
			health = cHealth;
		}


		callOnLuas('noteMiss', [
			notes.members.indexOf(daNote),
			daNote.noteData,
			daNote.noteType,
			daNote.isSustainNote
		]);
	}

	function noteMissPress(direction:Int = 1, ?ghostMiss:Bool = false):Void // You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned && !(SONG.isRing && direction == 2))
		{
			var cHealth:Float = health;
			if (isFear && cNum==0)
				health -= 0.15;
			fearNo += 5;
			if (cNum==0)
				health -= 0.15;
			if (curSong == "cycles")
			{
				fileHealth = health;
			}
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if (!practiceMode){
				songScore -= 10;
				updateSonicScore();
			}
			if (!endingSong)
			{
				if (ghostMiss)
					ghostMisses++;
					songMisses++;
				if (fucklesMode)
					drainMisses++;
				updateSonicMisses();
			}
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
		});*/

			var animToPlay:String = '';

			if (PlayState.SONG.isRing)
				switch (Math.abs(direction) % 5)
				{
					case 0:
						animToPlay = 'singLEFTmiss';
					case 1:
						animToPlay = 'singDOWNmiss';
					case 2:
						animToPlay = '';
					case 3:
						animToPlay = 'singUPmiss';
					case 4:
						animToPlay = 'singRIGHTmiss';
				}
			else
				switch (Math.abs(direction) % 4)
				{
					case 0:
						animToPlay = 'singLEFTmiss';
					case 1:
						animToPlay = 'singDOWNmiss';
					case 2:
						animToPlay = 'singUPmiss';
					case 3:
						animToPlay = 'singRIGHTmiss';
				}
			boyfriend.playAnim(animToPlay, true);

			vocals.volume = 0;

			if(cNum>0){
				cNum--;
				updateSonicRings();
				health = cHealth;
			}

		}
	}
	function updateWires(){
		for(wireIdx in 0...barbedWires.members.length){
			var wire = barbedWires.members[wireIdx];
			wire.screenCenter();
			var flag:Bool = wire.extraInfo.get("inUse");
			if((wireIdx+1) <= hexes){
				if(!flag){
					if(wire.tweens.exists("disappear")){wire.tweens.get("disappear").cancel();wire.tweens.remove("disappear");}
					wire.alpha=1;
					wire.shake(0.01,0.05);
					wire.extraInfo.set("inUse",true);
				}
			}else{
				if(wire.tweens.exists("disappear")){wire.tweens.get("disappear").cancel();wire.tweens.remove("disappear");}
				if(flag){
					wire.extraInfo.set("inUse",false);
					wire.tweens.set("disappear", FlxTween.tween(wire, {
						alpha: 0,
						y: ((FlxG.height - wire.height)/2) + 75
					},0.2,{
						ease: FlxEase.quadIn,
						onComplete:function(tw:FlxTween){
							if(wire.tweens.get("disappear")==tw){
								wire.tweens.remove("disappear");
								wire.alpha=0;
							}
						}
					}));
				}

			}
		}
	}

	var fuckyou:Int = 0;

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (cpuControlled && (note.ignoreNote || note.hitCausesMiss))
				return;

			if (cpuControlled)
			{
				var time:Float = 0.15;
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					time += 0.15;
				}
				if (SONG.isRing)
					StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 5, time);
				else
					StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			}
			else
			{
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}

			if (note.hitCausesMiss)
			{
				noteMiss(note);
				if (!note.noteSplashDisabled && !note.isSustainNote)
				{
					spawnNoteSplashOnNote(note);
				}

				trace("The fuck is that a: " + note.noteType);

				switch (note.noteType)
				{
					case 'Hex Note':
						hexes++;
						FlxG.sound.play(Paths.sound("hitWire"));
						camOther.flash(0xFFAA0000, 0.35, null, true);
						hexTimer=0;
						updateWires();
						if(hexes > barbedWires.members.length){
							trace("die.");
							health = -10000; // you are dead
						}
					case 'Phantom Note':
						trace("xdeez nuts lmao");
						healthDrop += 0.00025;
						dropTime = 10;

					case 'Hurt Note': // Hurt note
						if (boyfriend.animation.getByName('hurt') != null)
						{
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
					case 'Static Note': // what do you fucking think dawg
						health += 0;
					case 'Majin Note': // HOLY SHIT MAJIN!!!!!!!!
						health += 0;
					case 'Pixel Note':
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote && ((SONG.isRing && note.noteData != 2) || !SONG.isRing))
			{
				combo += 1;
				popUpScore(note);
			}
			else if (note.isSustainNote)
			{
				// call updated accuracy stuffs
				if (note.parentNote != null)
				{
					// Timings.updateAccuracy(100, true, coolNote.parentNote.childrenNotes.length);
					if (!fucklesMode)
						health += note.hitHealth;
					if (curSong == "cycles")
					{
						fileHealth = health;
					}
				}
			}

			if (SONG.isRing && note.noteData == 2)
			{
				cNum += 1;
				updateSonicRings();
				FlxG.sound.play(Paths.sound('Ring', 'exe'));
			}
			if (!note.isSustainNote){
				if (!fucklesMode)
					health += note.hitHealth;
			}
			if (curSong == "cycles")
			{
				fileHealth = health;
			}

			if (isFear)
			{
				fearNo -= 0.1;
				//trace(fearNo);
			}

			if (!note.noAnimation)
			{
				var daAlt = '';
				if (note.noteType == 'Alt Animation')
					daAlt = '-alt';

				var animToPlay:String = '';
				if (PlayState.SONG.isRing)
					switch (Math.abs(note.noteData) % 5)
					{
						case 0:
							animToPlay = 'singLEFT';
						case 1:
							animToPlay = 'singDOWN';
						case 2:
							animToPlay = '';
						case 3:
							animToPlay = 'singUP';
						case 4:
							animToPlay = 'singRIGHT';
					}
				else
					switch (Math.abs(note.noteData) % 4)
					{
						case 0:
							animToPlay = 'singLEFT';
						case 1:
							animToPlay = 'singDOWN';
						case 2:
							animToPlay = 'singUP';
						case 3:
							animToPlay = 'singRIGHT';
					}
				if (note.noteType == 'GF Sing')
				{
					gf.playAnim(animToPlay + daAlt, true);
					gf.holdTimer = 0;
				}
				else
				{
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
				}

				if (note.noteType == 'Hey!')
				{
					if (boyfriend.animOffsets.exists('hey'))
					{
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if (gf.animOffsets.exists('cheer'))
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; // GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note)
	{
		if (ClientPrefs.noteSplashes && note != null)
		{
			var strum:StrumNote = playerStrums.members[note.noteData];
			if (strum != null)
			{
				return spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
		return '';
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null)
	{
		var skin:String = 'BloodSplash';
		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;


		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if (note != null)
		{
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		if(weedSpinningTime && (skin == 'BloodSplash' || skin == null))
			skin = 'hitmarker';
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
		return skin;
	}


	function fucklesDeluxe()
	{
		health = 2;
		//songMisses = 0;
		fucklesMode = true;

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		scoreTxt.visible = false;

		opponentStrums.forEach(function(spr:FlxSprite)
		{
			spr.x += 10000;
		});
	}

	// ok might not do this lmao

	var fuckedMode:Bool = false;

	function fucklesFinale()
	{
		if (fucklesMode)
			fuckedMode = true;
		if (fuckedMode)
		{
			health -= 0.1;
			if (health <= 0.01)
			{
				health = 0.01;
				fuckedMode = false;
			}
		}
		trace('dont die lol');
	}

	function fucklesHealthRandomize()
	{
		if (fucklesMode)
			health = FlxG.random.float(0.5, 2);
		trace('fuck your health!');
		// randomly sets health between max and 0.5,
		// this im gonna use for stephits and basically
		// have it go fucking insane in some parts and disable the drain and reenable when needed
	}

  #if VIDEOS_ALLOWED
	function chromaVideo(name:String){
		var video:VideoSprite = new VideoSprite(0,0);
		video.scrollFactor.set();
		video.cameras = [camHUD];
		video.shader = new GreenScreenShader();
		video.visible=false;
		video.finishCallback = function(){
			trace("video gone");
			remove(video);
			video.destroy();
		}
		video.playVideo(Paths.video(name));
		video.openingCallback = function(){
			video.visible=true;
		}
		add(video);
	}
  #end

	function majinSaysFuck(numb:Int):Void
		{
			switch(numb)
			{
				case 4:
					var three:FlxSprite = new FlxSprite().loadGraphic(Paths.image('three', 'exe'));
					three.scrollFactor.set();
					three.updateHitbox();
					three.screenCenter();
					three.y -= 100;
					three.alpha = 0.5;
					three.cameras = [camOther];
					add(three);
					FlxTween.tween(three, {y: three.y + 100, alpha: 0, "scale.x": 1.05, "scale.y": 1.05}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeOut,
						onComplete: function(twn:FlxTween)
						{
							three.destroy();
						}
					});
				case 3:
					var two:FlxSprite = new FlxSprite().loadGraphic(Paths.image('two', 'exe'));
					two.scrollFactor.set();
					two.screenCenter();
					two.y -= 100;
					two.alpha = 0.5;
					two.cameras = [camOther];
					add(two);
					FlxTween.tween(two, {y: two.y + 100, alpha: 0, "scale.x": 1.05, "scale.y": 1.05}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeOut,
						onComplete: function(twn:FlxTween)
						{
							two.destroy();
						}
					});
				case 2:
					var one:FlxSprite = new FlxSprite().loadGraphic(Paths.image('one', 'exe'));
					one.scrollFactor.set();
					one.screenCenter();
					one.y -= 100;
					one.alpha = 0.5;
					one.cameras = [camOther];

					add(one);
					FlxTween.tween(one, {y: one.y + 100, alpha: 0, "scale.x": 1.05, "scale.y": 1.05}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeOut,
						onComplete: function(twn:FlxTween)
						{
							one.destroy();
						}
					});
				case 1:
					var gofun:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gofun', 'shared'));
					gofun.scrollFactor.set();

					gofun.updateHitbox();

					gofun.screenCenter();
					gofun.y -= 100;
					gofun.alpha = 0.5;

					add(gofun);
					FlxTween.tween(gofun, {y: gofun.y + 100, alpha: 0, "scale.x": 1.05, "scale.y": 1.05}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							gofun.destroy();
						}
					});
			}

		}

	private var preventLuaRemove:Bool = false;

	override function destroy()
	{
	    if(!ClientPrefs.mariomaster){
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		// holdRenderer.Destroy();

		preventLuaRemove = true;
		for (i in 0...luaArray.length)
		{
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];
		super.destroy();
	}

	public function cancelFadeTween()
	{
		if (FlxG.sound.music.fadeTween != null)
		{
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua)
	{
		if (luaArray != null && !preventLuaRemove)
		{
			luaArray.remove(lua);
		}
	}

	function sponglebobble()
	{
		var sponge:FlxSprite = new FlxSprite(dad.getGraphicMidpoint().x - 100, dad.getGraphicMidpoint().y - 120).loadGraphic(Paths.image('SpingeBinge', 'exe'));

		add(sponge);

		dad.visible = false;

		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			remove(sponge);
			dad.visible = true;
		});
	}

	var lastStepHit:Int = -1;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (curStep == lastStepHit)
		{
			return;
		}

		lastStepHit = curStep;
		if (curSong == 'chaos')
		{
			if (curStep == 16)
			{
				dad.playAnim('fastanim', true);
				dad.specialAnim = true;
				//	dad.nonanimated = true;

				FlxTween.tween(dad, {x: 61.15, y: -94.75}, 2, {ease: FlxEase.cubeOut});
			}
			else if (curStep == 1)
			{
				boyfriendGroup.add(boyfriend);
				//https://twitter.com/averyavary/status/1515991304286707712

				// wow this is inefficent but change character fucks everything up royally
			}
			else if (curStep == 9)
			{
				dad.visible = true;
				FlxTween.tween(dad, {y: dad.y - 500}, 0.5, {ease: FlxEase.cubeOut});
			}
			else if (curStep == 64)
			{
				//	dad.nonanimated = false;
				dad.specialAnim = false;
				boyfriend.visible = true;
				tailscircle = 'hovering';
				camHUD.visible = true;
				camHUD.alpha = 0;
				cinematicBars(false);
				FlxTween.tween(camHUD, {alpha: 1}, 0.2, {ease: FlxEase.cubeOut});
			}

			switch (curStep)
			{ // silencing the unused pattern thing
				case 380, 509, 637, 773, 1033, 1149, 1261, 1543, 1672, 1792, 1936:
					tailscircle = '';
					FlxTween.tween(dad, {x: 61.15, y: -94.75}, 0.2);
					dad.setPosition(61.15, -94.75);
			}
			switch (curStep)
			{
				case 256:
					laserThingy(true);
					canDodge = true;
				case 272:
					dodgething.visible = false;
				case 398, 527, 655, 783, 1039, 1167, 1295, 1551, 1679, 1807, 1951:
					/*dadGroup.remove(dad);*/
					/*var olddx = dad.x;
					var olddy = dad.y;
					dad = new Character(olddx, olddy, 'fleetway');
					dadGroup.add(dad);*/
					dad.specialAnim = false;
					tailscircle = 'hovering';

				case 1008:
					boyfriendGroup.remove(boyfriend);
					var oldbfx = boyfriend.x - 10;
					var oldbfy = boyfriend.y - 225;
					boyfriend = new Boyfriend(oldbfx, oldbfy, 'bf-super');
					boyfriendGroup.add(boyfriend);

					FlxG.camera.shake(0.02, 0.2);
					FlxG.camera.flash(FlxColor.YELLOW, 0.2);

					FlxG.sound.play(Paths.sound('SUPERBF', 'exe'));

					boyfriend.scrollFactor.set(1.1, 1);

				case 1260, 1543, 1672, 1792, 1936:
					/*dadGroup.remove(dad);
					var olddx = dad.x;
					var olddy = dad.y;
					dad = new Character(olddx, olddy, 'fleetway-anims2');
					dadGroup.add(dad);*/
					switch (curStep)
					{
						case 1260:
							dad.playAnim('Ill show you', true);
							dad.specialAnim = true;

						case 1543:
							dad.playAnim('AAAA', true);
							dad.specialAnim = true;

						case 1672:
							dad.playAnim('Growl', true);
							dad.specialAnim = true;

						case 1792:
							dad.playAnim('Shut up', true);
							dad.specialAnim = true;

						case 1936:
							dad.playAnim('Right Alt', true);
							dad.specialAnim = true;
					}
				case 383, 512, 640, 776, 1036, 1152:
					/*dadGroup.remove(dad);
					var olddx = dad.x;
					var olddy = dad.y;
					dad = new Character(olddx, olddy, 'fleetway-anims3');
					dadGroup.add(dad);*/
					switch (curStep)
					{
						case 383:
							dad.playAnim('Step it up', true);
							dad.specialAnim = true;

						case 512:
							dad.playAnim('lmao', true);
							dad.specialAnim = true;

						case 640:
							dad.playAnim('fatphobia', true);
							dad.specialAnim = true;

						case 776:
							dad.playAnim('Finished', true);
							dad.specialAnim = true;

						case 1036:
							dad.playAnim('WHAT', true);
							dad.specialAnim = true;

						case 1152:
							dad.playAnim('Grrr', true);
							dad.specialAnim = true;
					}
			}
		}

		if(curSong == 'endless'){
			switch(curStep){
				case 1:
					timeBar.createFilledBar(0xFF000000, 0xFF5f41a1);
					timeBar.updateBar();
				case 886:
					FlxTween.tween(camHUD, {alpha: 0}, 0.5);

				case 900:
					removeStatics();
					generateStaticArrows(0);
					generateStaticArrows(1);
					FlxTween.tween(camHUD, {alpha: 1}, 0.5);
			}
		}
		if (curStage == 'needle' && SONG.song.toLowerCase() == 'round-a-bout')
		{
			switch (curStep)
			{
				case 765:
					FlxTween.tween(dad2, {alpha: 1}, 0.3, {ease: FlxEase.quadInOut});
				// funnyLargeTween();

				case 770:
					var oki:Float = -0.1;
					new FlxTimer().start(0.1, function(ok:FlxTimer)
					{
						if (dad2.alpha <= 0.5)
						{
							oki = 0.01;
						}
						if (dad2.alpha >= 1)
						{
							oki = -0.01;
						}
						dad2.alpha += oki;

						ok.reset();
					});
			}
		}
		if (SONG.song.toLowerCase() == 'fight or flight')
		{
			switch (curStep)
			{
				case 1:
					timeBar.createFilledBar(FlxColor.RED, 0xFF000000);
					timeBar.updateBar();
				case 1184, 1471:
					starvedLights();
				case 1439, 1728:
					starvedLightsFinale();
			}
		}
		if (curStage == 'trioStage' && SONG.song.toLowerCase()=='triple-trouble')
		{
			switch (curStep)
			{
				/*
				this shit is goin unused since all the dash sound effects are on ring note hits lol
				case 1431, 1496, 1560, 1624, 1687, 1816, 1879, 1928, 1932, 1944, 2008, 2072, 2136, 2200, 2264:
					strumLineNotes.forEach(function(tospin:FlxSprite)
						{
							FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
						});
				*/
				case 1:
					timeBar.createFilledBar(0x007F7E7E, 0xFF7F7E7E);
					timeBar.updateBar();

					//goofyAhhStatic(1);

					FlxTween.tween(FlxG.camera, {zoom: 1.3}, 2.5, {ease: FlxEase.quadInOut});
				case 16:
					FlxTween.cancelTweensOf(FlxG.camera);
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 1, {ease: FlxEase.elasticOut});
				//case 144, 272, 656:
				//	spookyJumpscareAAA("tails");
				case 399:
					superZoomShit = true;
				case 400:
					defaultCamZoom = 0.75;
				case 416:
					defaultCamZoom = 0.80;
				case 432:
					defaultCamZoom = 0.85;
				case 448:
					defaultCamZoom = 0.9;
				case 464:
					defaultCamZoom = 0.95;
				case 480:
					defaultCamZoom = 1;
				case 496:
					defaultCamZoom = 1.05;
				case 512:
					defaultCamZoom = 1.1;
				case 527:
					supersuperZoomShit = true;
					superZoomShit = false;
				case 528:
					defaultCamZoom = 0.7;
				case 783:
					supersuperZoomShit = false;
				case 1024:
					//goofyAhhStatic(1);
				case 1040:
					timeBar.createFilledBar(0x00D416E3, 0xFFD416E3);
					timeBar.updateBar();

					defaultCamZoom = 0.9;

					fgTree1.alpha = 0;
					fgTree2.alpha = 0;

					backtreesXeno.visible = true;
					grassXeno.visible = true;
					p3staticbg.visible = true;

				case 1072:
					vg = new FlxSprite().loadGraphic(Paths.image('RedVG', 'exe'));
					vg.alpha = 0;
					vg.cameras = [camHUD];
					add(vg);

					FlxTween.tween(vg, {alpha: 0.90}, 2.5, {ease: FlxEase.quadInOut});
				case 1104:
					FlxTween.cancelTweensOf(vg);
					FlxTween.tween(vg, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut});
				case 1136:
					vg = new FlxSprite().loadGraphic(Paths.image('RedVG', 'exe'));
					vg.alpha = 0;
					vg.cameras = [camHUD];
					add(vg);

					FlxTween.tween(vg, {alpha: 0.90}, 2.5, {ease: FlxEase.quadInOut});
				case 1168:
					FlxTween.cancelTweensOf(vg);
					FlxTween.tween(vg, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut});
				case 1216:
					//goofyAhhStatic(1);
				case 1264:
					vg = new FlxSprite().loadGraphic(Paths.image('RedVG', 'exe'));
					vg.alpha = 0;
					vg.cameras = [camHUD];
					add(vg);

					FlxTween.tween(vg, {alpha: 0.90}, 2.5, {ease: FlxEase.quadInOut});
				case 1280:
					//goofyAhhStatic(1);
				case 1296:
					timeBar.createFilledBar(0x00AD0E0E, 0xFFAD0E0E);
					timeBar.updateBar();

					FlxTween.cancelTweensOf(vg);
					FlxTween.tween(vg, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut});

					fgTree1.alpha = 1;
					fgTree2.alpha = 1;

					backtreesXeno.visible = false;
					grassXeno.visible = false;
					p3staticbg.visible = false;

					defaultCamZoom = 0.7;
					//spookyJumpscareAAA("knux");
				case 1424:
					superZoomShit = true;
				case 1663:
					superZoomShit = false;
				case 1664:
					supersuperZoomShit = true;
				case 1679:
					supersuperZoomShit = false;
					//spookyJumpscareAAA("knux");
				case 1920:
					defaultCamZoom = 0.8;
				case 1924:
					defaultCamZoom = 0.9;
				case 1928:
					defaultCamZoom = 1.2;
				case 1932:
					defaultCamZoom = 1.4;
				case 1935:
					supersuperZoomShit = true;
				case 1936:
					defaultCamZoom = 0.7;
				case 2304:
					//goofyAhhStatic(1);
				case 2320:
					dad.x += 100;
					supersuperZoomShit = false;
					superZoomShit = false;
					timeBar.createFilledBar(0x00D416E3, 0xFFD416E3);
					timeBar.updateBar();

					defaultCamZoom = 0.9;

					fgTree1.alpha = 0;
					fgTree2.alpha = 0;

					grassXeno.angle = -30;
					backtreesXeno.y += 70;

					backtreesXeno.visible = true;
					grassXeno.visible = true;
					p3staticbg.visible = true;
				case 2816:
					//goofyAhhStatic(1);
				case 2832:
					timeBar.createFilledBar(0x00A87608, 0xFFA87608);
					timeBar.updateBar();

					superZoomShit = true;

					FlxTween.cancelTweensOf(vg);
					FlxTween.tween(vg, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut});

					fgTree1.alpha = 1;
					fgTree2.alpha = 1;

					fgTree1.x += -50;

					backtreesXeno.visible = false;
					grassXeno.visible = false;
					p3staticbg.visible = false;

					defaultCamZoom = 0.7;

					//spookyJumpscareAAA("egg");
				case 4111:
					timeBar.createFilledBar(0x00D416E3, 0xFFD416E3);
					timeBar.updateBar();

					defaultCamZoom = 0.9;

					fgTree1.alpha = 0;
					fgTree2.alpha = 0;

					backtreesXeno.visible = true;
					grassXeno.visible = true;
					p3staticbg.visible = true;
			}
		}
		if (SONG.song.toLowerCase()=='personel')
		{
			switch (curStep)
			{
				case 32:
					camGame.alpha = 1;
				case 288:
					defaultCamZoom = 1.2;
					FlxTween.tween(FlxG.camera, {zoom: 1.2}, 0.3);
				case 416:
					defaultCamZoom = 1.6;
					FlxTween.tween(FlxG.camera, {zoom: 1.6}, 0.3);
				case 543:
					defaultCamZoom = 1.0;
					FlxTween.tween(FlxG.camera, {zoom: 1.0}, 0.3);
				case 799:
					defaultCamZoom = 0.9;
					FlxTween.tween(FlxG.camera, {zoom: 0.9}, 0.3);
				case 1069:
					for (str in playerStrums)
					{
						str.angle = str.angle + 35;
					}
					for (str in opponentStrums)
					{
						str.angle = str.angle + 35;
					}
				case 1087:
					for (str in playerStrums)
					{
						str.angle = str.angle + 35;
					}
					for (str in opponentStrums)
					{
						str.angle = str.angle + 35;
					}
				case 1098:
					for (str in playerStrums)
					{
						str.angle = str.angle + 35;
					}
					for (str in opponentStrums)
					{
						str.angle = str.angle + 35;
					}
				case 1101:
					for (str in playerStrums)
					{
						str.angle = str.angle + 35;
					}
					for (str in opponentStrums)
					{
						str.angle = str.angle + 35;
					}
				case 1134:
					for (str in playerStrums)
					{
						str.angle = str.angle + 35;
					}
					for (str in opponentStrums)
					{
						str.angle = str.angle + 35;
					}
				case 1151:
					for (str in playerStrums)
					{
						str.angle = str.angle + 35;
					}
					for (str in opponentStrums)
					{
						str.angle = str.angle + 35;
					}
				case 1163:
					for (str in playerStrums)
					{
						str.angle = str.angle + 35;
					}
					for (str in opponentStrums)
					{
						str.angle = str.angle + 35;
					}
				case 1167:
					for (str in playerStrums)
					{
						str.angle = str.angle + 35;
					}
					for (str in opponentStrums)
					{
						str.angle = str.angle + 35;
					}
				case 1199:
					IsNoteSpinning = true;
					FlxTween.tween(FlxG.camera, {zoom: 1.6}, 0.3);
					defaultCamZoom = 1.6;
				case 1263:
					IsNoteSpinning = false;
				case 1311:
					IsNoteSpinning = true;
					isPlayersSpinning = true;
					FlxTween.tween(FlxG.camera, {zoom: 1.2}, 0.3);
					defaultCamZoom = 1.2;
				case 1401:
					IsNoteSpinning = false;
					FlxTween.tween(FlxG.camera, {zoom: 1.8}, 0.3);
					defaultCamZoom = 1.8;
				case 1403:
					defaultCamZoom = 0.9;
					FlxTween.tween(FlxG.camera, {zoom: 0.9}, 21.2);
					isPlayersSpinning = false;
					dad.angle = 0;
					boyfriend.angle = 0;
					for (str in playerStrums)
					{
						FlxTween.tween(str, {angle: 0}, 0.5, {ease: FlxEase.circOut});
					}
					for (str in opponentStrums)
					{
						FlxTween.tween(str, {angle: 0}, 0.5, {ease: FlxEase.circOut});
					}
				case 1695:
					superZoomShit = true;
				case 1872:
					superZoomShit = false;
					supersuperZoomShit = true;
				case 1888:
					superZoomShit = true;
					supersuperZoomShit = false;
				case 1936:
					supersuperZoomShit = true;
					superZoomShit = false;
				case 1975:
					superZoomShit = false;
					supersuperZoomShit = false;
			}
		}
		if (curStage == 'TDP2')
		{
			switch (curStep)
			{
				case 1:
					FlxTween.tween(camGame, {alpha: 1}, 12);
						opponentStrums.forEach(function(spr:FlxSprite)
						{
							spr.x += 10000;
						});
				case 64:
					FlxTween.tween(camHUD, {alpha: 1}, 12);
				case 127:
					defaultCamZoom = 0.8;
			}
		}
		if(SONG.song.toLowerCase()=='too-slow'){
			switch(curStep){
				case 765:
					FlxG.camera.flash(FlxColor.RED, 3);
				case 1305:

			}
		}
		if (SONG.song.toLowerCase() == 'too-slow-encore')
			{
				switch (curStep)
				{
					case 384:
						camGame.alpha = 0;
					case 400:
						camGame.alpha = 1;
						defaultCamZoom = 0.9;
					case 415:
						supersuperZoomShit = true;
					case 416:
						defaultCamZoom = 0.65;
					case 675:
						supersuperZoomShit = false;
					case 687:
						supersuperZoomShit = true;
					case 736:
						supersuperZoomShit = false;
					case 751:
						supersuperZoomShit = true;
					case 928:
						FlxTween.tween(FlxG.camera, {zoom: 1.0}, 0.7);
						cinematicBars(true);
						defaultCamZoom = 1.0;
						supersuperZoomShit = false;
						FlxTween.tween(camHUD, {alpha: 0}, 0.7);
					case 1039:
						cinematicBars(false);
						FlxTween.tween(FlxG.camera, {zoom: 0.6}, 1.4);
						defaultCamZoom = 0.6;
						FlxTween.tween(camHUD, {alpha: 1}, 1.4);
					case 1055:
						supersuperZoomShit = true;
					case 1664:
						camFollow.x = gf.x;
						camFollow.y = gf.y;
						isCameraOnForcedPos = true;
				}
			}
		if (curStage == 'fatality' && SONG.song.toLowerCase()=='fatality')
		{
			switch (curStep)
			{
				case 255, 1983:
					fatalTransitionStatic();
				case 256:
					fatalTransistionThing();
				case 1151:
					dadGroup.remove(dad);
					var olddx = dad.x;
					var olddy = dad.y;
					dad = new Character(olddx, olddy, 'fatal-glitched');
					dadGroup.add(dad);
       #if !windows
        case 1984:
        fatalTransistionThingDos();
       #else
				case 1984:
					Xamount += 2;
					Yamount += 2;
					fatalTransistionThingDos();
					windowX = Lib.application.window.x;
					windowY = Lib.application.window.y;
					IsWindowMoving2 = true;
				case 2208:
					IsWindowMoving = false;
					IsWindowMoving2 = false;
				case 2230:
					shakescreen();
					camGame.shake(0.02, 0.8);
					camHUD.shake(0.02, 0.8);
				case 2240:
					IsWindowMoving = true;
					IsWindowMoving2 = false;
				case 2528:
					shakescreen();
					IsWindowMoving = true;
					IsWindowMoving2 = true;
					Yamount += 3;
					Xamount += 3;
					camGame.shake(0.02, 2);
					camHUD.shake(0.02, 2);
				case 2530:
					shakescreen();
				case 2535:
					shakescreen();
				case 2540:
					shakescreen();
				case 2545:
					shakescreen();
				case 2550:
					shakescreen();
				case 2555:
					shakescreen();
				case 2560:
					IsWindowMoving = false;
					IsWindowMoving2 = false;
					 windowGoBack();
        #end
			}
		}
		if (curStage == 'sunkStage' && SONG.song.toLowerCase()=='milk')
		{
			switch (curStep)
			{
				case 64:
					FlxG.camera.zoom += 0.06;
					camHUD.zoom += 0.08;
				case 80:
					FlxG.camera.zoom += 0.06;
					camHUD.zoom += 0.08;
				case 96:
					supersuperZoomShit = true;
					FlxTween.tween(FlxG.camera, {zoom: 1.5}, 6.5);
				case 119:
					supersuperZoomShit = false;
					FlxTween.cancelTweensOf(FlxG.camera);
					FlxTween.tween(FlxG.camera, {zoom: 0.77}, 0.5);
				case 132:
					FlxTween.tween(FlxG.camera, {zoom: 1.9}, 2.5);
					camGame.shake(0.2, 0.85);
					camHUD.shake(0.2, 0.85);

					sunker.visible = true;
					sunker.alpha = 0;
					FlxTween.tween(sunker, {alpha: 1}, 1.5);
				case 144:
					FlxTween.cancelTweensOf(FlxG.camera);

					FlxTween.cancelTweensOf(sunker);
					sunker.alpha = 0;
					sunker.visible = false;

					FlxTween.tween(FlxG.camera, {zoom: 0.77}, 0.5);
					superZoomShit = true;
				case 352:
					FlxTween.tween(FlxG.camera, {zoom: 1.9}, 1.9);
					superZoomShit = false;
				case 367:
					FlxTween.cancelTweensOf(FlxG.camera);
					FlxTween.tween(FlxG.camera, {zoom: 0.77}, 0.5);
				case 404:
					superZoomShit = true;
				case 528:
					switch(FlxG.random.int(1, 3)){
						case 1:
							FlxTween.tween(cereal, {x: 1350}, 12.5);
						case 2:
							FlxTween.tween(munch, {x: 1350}, 12.5);
						case 3:
							FlxTween.tween(pose, {x: 1350}, 12.5);
					}
				case 639:
					superZoomShit = false;
					FlxTween.tween(FlxG.camera, {zoom: 1.3}, 0.5);
					defaultCamZoom = 1.3;
				case 651:
					FlxTween.tween(FlxG.camera, {zoom: 1.9}, 0.5);
					defaultCamZoom = 1.9;
				case 656:
					FlxTween.tween(FlxG.camera, {zoom: 0.77}, 0.5);
					defaultCamZoom = 0.9;
					superZoomShit = true;
				case 752:
					cereal.y = -1000;
					cereal.x = 500;
					munch.y = -1000;
					munch.x = 500;
					pose.y = -1000;
					pose.x = 500;
				case 784:
					switch(FlxG.random.int(1, 3)){
						case 1:
							FlxTween.tween(cereal, {y: 1150}, 9.8);
						case 2:
							FlxTween.tween(munch, {y: 1150}, 9.8);
						case 3:
							FlxTween.tween(pose, {y: 1150}, 9.8);
					}
				case 879:
					FlxTween.cancelTweensOf(cereal);
					FlxTween.cancelTweensOf(munch);
					FlxTween.cancelTweensOf(pose);
					cereal.y = -1000;
					cereal.x = 500;
				case 911:
					cereal.y = -1000;
					cereal.x = -700;
					munch.y = -1000;
					munch.x = -700;
					pose.y = -1000;
					pose.x = -700;
					switch(FlxG.random.int(1, 3)){
						case 1:
							FlxTween.tween(cereal, {y: 1050}, 10.8);
							FlxTween.tween(cereal, {x: 1350}, 10.8);
						case 2:
							FlxTween.tween(munch, {y: 1050}, 9.8);
							FlxTween.tween(munch, {x: 1350}, 10.8);
						case 3:
							FlxTween.tween(pose, {y: 1050}, 9.8);
							FlxTween.tween(pose, {x: 1350}, 10.8);
					}
				case 1423:
					camGame.alpha = 0;
				case 1439:
					spoOoOoOky.x -= 100;
					spoOoOoOky.visible = true;
					spoOoOoOky.alpha = 0;
					FlxTween.tween(spoOoOoOky, {alpha: 1}, 1.5);
				case 1455:
					FlxTween.cancelTweensOf(spoOoOoOky);
					spoOoOoOky.alpha = 0;
					camGame.alpha = 1;
			}
		}

		if (SONG.song.toLowerCase() == 'my-horizon')
		{
			switch (curStep)
			{
				case 896:
					FlxTween.tween(camHUD, {alpha: 0}, 2.2);
				case 908:
					dad.playAnim('transformation', true);
					dad.specialAnim = true;
					camZooming = false;
					cinematicBars(true);
				case 924:

					FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.5}, 12, {ease: FlxEase.cubeInOut});
					FlxTween.tween(whiteFuck, {alpha: 1}, 6, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
						{
							remove(fucklesFGPixel);
							remove(fucklesBGPixel);
							fucklesBGPixel.destroy();
							fucklesFGPixel.destroy();
							fucklesFuckedUpBg.visible = true;
							fucklesFuckedUpFg.visible = true;
						}
					});
				case 975:
					cinematicBars(false);
				case 992:
					literallyMyHorizon();
				case 1120, 1248, 1376, 1632, 1888, 1952, 2048, 2054, 2060:
					fucklesHealthRandomize();
					camHUD.shake(0.005, 1);
				case 1121, 1760:
					superZoomShit = true;
				case 1503, 2015:
					superZoomShit = false;
				case 1504, 2080:
					supersuperZoomShit = true;
				case 1759, 2336:
					supersuperZoomShit = false;
				case 2208, 2222, 2240, 2254, 2320, 2324, 2328:
					fucklesFinale();
					camHUD.shake(0.003, 1);
				case 2337:
					camZooming = false;
			}
		}

		if (SONG.song.toLowerCase() == 'b4cksl4sh')
			{
				switch (curStep)
					{
						case 1823:
							doStaticSign();
							slashChangingShit();
							dadGroup.remove(dad);
							boyfriend.visible = false;
							var olddx = dad.x + 190;
							var olddy = dad.y + 20;
							dad = new Character(olddx, olddy, 'FrontViewSl4sh');
							boyfriend.x += 50;
							boyfriend.y -= 165;
							iconP2.changeIcon(dad.healthIcon);
							dadGroup.add(dad);

						case 1824:
							var warning:FlxSprite = new FlxSprite();
							warning.frames = Paths.getSparrowAtlas("slash_warning_sheet");
							warning.animation.addByPrefix('warn', 'slash warning');
							warning.setGraphicSize(Std.int(warning.width * 2.5));
							warning.screenCenter();
							warning.cameras = [camHUD];

							new FlxTimer().start(0, function(ok:FlxTimer){
								var youhavebeenwarned:Bool = false;
								var slashframe:Float = curBeat + (4 * FlxG.random.int(5, 10)); // every second in fnf is 4 beats
								trace("setting new thing, slash frame is: " + slashframe + " current frame is: " + FlxG.sound.music.time);

								new FlxTimer().start(0, function(lol:FlxTimer) // xd lmafo never thought i would use while loops but here we go, EDIT: PLEASE DO NOT, IT WILL MAKE YOUR GAME FUCKING FREEZE
								{
									if (curBeat >= slashframe)
									{
										remove(warning);
										dad.playAnim("attack", true);
										FlxG.sound.play(Paths.sound('slashslash'));
										dad.animation.finishCallback = function(slash:String)
										{
											if (dad.animation.curAnim.name == "attack")
											{
												trace("finished slash animation");
												dad.specialAnim = false;
												canDodge = false;
											}
										}
										dad.specialAnim = true;
										new FlxTimer().start(0, function(yes:FlxTimer)
										{
											if (dad.animation.curAnim.curFrame >= 7 && !dodging)
											{
												FlxG.sound.play(Paths.sound('slashhit'));
												health -= 0.4;
												healthMultiplier -= 0.1;
											}
											if (dad.animation.curAnim.curFrame < 7) yes.reset();
										});
										trace("woah slash");
										if (FlxG.sound.music.time <= FlxG.sound.music.length - 8000) ok.reset();
									}
									else if (curBeat >= slashframe - 4 && !youhavebeenwarned)
									{
										FlxG.sound.play(Paths.sound('slashwarning'), 0.3);
										add(warning);
										warning.animation.play("warn");
										canDodge = true;
										youhavebeenwarned = true;
									}
									if (curBeat < slashframe)
									{
										lol.reset();
									}
								});
							});

					}
			}

			if (SONG.song.toLowerCase() == 'hedge')
				{
					switch (curStep)
						{
							case 1264:
								var warning:FlxSprite = new FlxSprite(boyfriend.x - 25, boyfriend.y - 30);
								warning.frames = Paths.getSparrowAtlas("hog/TargetLock");
								warning.animation.addByPrefix('warn', 'TargetLock', 24, false);
								warning.alpha = 0;
								add(warning);
								//warning.setGraphicSize(Std.int(warning.width * 2.5));

								new FlxTimer().start(0.8, function(lol:FlxTimer)
									{
										FlxTween.tween(warning, {alpha: 1}, 0.5);
										warning.animation.play("warn", true);
										warning.animation.finishCallback = function(warn:String)
											{
												remove(warning);
												warning.destroy();
											}

									});

								canDodge = true;
								dad.playAnim("getfuckedlol", true);
								dad.specialAnim = true;
								dad.animation.finishCallback = function(getfuckedlol:String)
								{
									dad.specialAnim = false;
								}
								new FlxTimer().start(0, function(lol:FlxTimer)
								{
									if (dad.animation.curAnim.curFrame == 38 && !dodging) health = 0;
									boyfriend.animation.finishCallback=null;
								});
						}
				}

			if (SONG.song.toLowerCase() == 'too-fest')
				{
					switch (curStep)
						{
							case 5, 9, 12, 634, 639, 642, 646, 650, 654, 710, 716, 774, 780, 838, 845, 895, 900, 905, 910, 1472, 1476, 1480, 1484:
								festSpinFull();
							case 64, 69, 73, 77, 383, 389, 393, 397, 448, 452, 456, 460, 512, 516, 520, 524, 576, 580, 584, 588, 664, 698, 729, 760, 790, 857:
								festSpinOppenet();
							case 408, 410, 412, 472, 474, 476, 536, 538, 540, 600, 602, 604, 682, 710, 745, 808, 825, 872, 888:
								festSpinPlayer();
							case 912:
								if(ClientPrefs.flashing && weedVis!=null){
									curShader = new ShaderFilter(weedVis);
									camGame.setFilters([curShader]);
									camHUD.setFilters([curShader]);
									camOther.setFilters([curShader]);
								}
								weedSpinningTime = true;
							case 1167:
								weedSpinningTime = false;
						}
				}
			if (SONG.song.toLowerCase() == 'prey')
			{
				switch (curStep)
					{
						case 1:
							boyfriend.alpha = 0;
							camHUD.alpha = 0;
							FlxTween.tween(boyfriend, {alpha: 1}, 6);

						case 128:
							FlxG.camera.flash(FlxColor.WHITE, 2);
							FlxG.camera.zoom = 2;
							stardustBgPixel.visible = true;
							stardustFloorPixel.visible = true;

						case 246:
							FlxTween.tween(dad, {x: 580}, 1, {ease: FlxEase.cubeInOut});
							FlxTween.tween(camHUD, {alpha: 1}, 1.2,{ease: FlxEase.cubeInOut});
							camZooming = true;
						case 1530:
							FlxTween.tween(camHUD, {alpha: 0}, 0.75,{ease: FlxEase.cubeInOut});
						case 1505:
							FlxTween.tween(dad, {x: -1500}, 5, {ease: FlxEase.cubeInOut});
							FlxTween.angle(dad, 0, -180, 5, {ease: FlxEase.cubeInOut});
						case 1542:
							dadGroup.visible = false;
						case 1545:
								cinematicBars(true);
								dad.x -= 500;
								dad.y += 100;
						case 1548:
							dadGroup.visible = true;
						case 1547:
							health = 1;
							boyfriend.playAnim("first dialogue");
							boyfriend.animation.finishCallback = function(slash:String)
							{
								hungryManJackTime = 2;
								if (dad.animation.curAnim.name == "first dialogue")
								{
									boyfriend.specialAnim = false;
								}
							}
							dad.playAnim("dialogue", true);
							dad.specialAnim = true;
							dad.animation.finishCallback = function(slash:String)
							{
								if (dad.animation.curAnim.name == "dialogue")
								{
									hungryManJackTime = 1;
									cinematicBars(false);
									dad.specialAnim = false;
								}
							}
						case 1570:
							FlxTween.tween(dad, {x: 1300}, 2.5,{ease: FlxEase.cubeInOut});
						case 1780:
							FlxTween.tween(camHUD, {alpha: 1}, 1.0);
						case 2432:
							FlxTween.tween(stardustFurnace, {x: 3000}, 7);
						case 3328:
							FlxTween.tween(camHUD, {alpha: 0}, 1,{ease: FlxEase.cubeInOut});
							FlxTween.tween(dad, {x: -300}, 4,{ease: FlxEase.cubeInOut});
						case 3335:
							boyfriend.playAnim("dialogue peel");
							boyfriend.specialAnim = true;
						case 3367:
							FlxG.camera.flash(FlxColor.RED, 2);
							boyfriendGroup.visible = false;
							dadGroup.visible = false;
							stardustFurnace.visible = false;
							stardustBgPixel.visible = false;
							stardustFloorPixel.visible = false;
						case 3364:
							cinematicBars(true);
							var gotcha:FlxSprite = new FlxSprite(boyfriend.x + 1500, boyfriend.y + 505).loadGraphic(Paths.image('furnace_gotcha'));
							gotcha.setGraphicSize(Std.int(gotcha.width * 5));
							gotcha.antialiasing = false;
							gotcha.flipX = true;
							add(gotcha);
							FlxTween.tween(gotcha, {x: boyfriend.x + 500}, 0.2, {onComplete: function(yes:FlxTween)
							{
								remove(gotcha);
							}});
					}
			}
			/**hungryManJackTime = true;
				boyfriendGroup.remove(boyfriend);
				**/
			if (SONG.song.toLowerCase() == 'malediction')
			{
				switch (curStep)
					{
						case 528, 725:
							FlxTween.tween(camHUD, {alpha: 0.5}, 0.3,{ease: FlxEase.cubeInOut});
						case 558, 735:
							FlxTween.tween(camHUD, {alpha: 1}, 0.3,{ease: FlxEase.cubeInOut});
						case 736:
							FlxG.camera.flash(FlxColor.PURPLE, 0.5);
							if(curseStatic!=null)curseStatic.visible = true;
						case 991:
							if(curseStatic!=null){
								FlxTween.tween(curseStatic, {alpha: 0}, 1, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
									{
										curseStatic.visible=false;
									}
								});
							}
						case 1184:
							FlxTween.tween(camHUD, {alpha: 0}, 1,{ease: FlxEase.cubeInOut});
					}
			}

		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	function shakescreen()
	{
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			Lib.application.window.move(Lib.application.window.x + FlxG.random.int(-10, 10), Lib.application.window.y + FlxG.random.int(-8, 8));
		}, 50);
	}

	function literallyMyHorizon()
		{
			dad.specialAnim = false;
			FlxG.camera.flash(FlxColor.BLACK, 1);
			dadGroup.remove(dad);
			var olddx = dad.x - 230;
			var olddy = dad.y - 170;
			dad = new Character(olddx, olddy, 'beast_chaotix');
			iconP2.changeIcon(dad.healthIcon);
			dadGroup.add(dad);
			camZooming = true;
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 1.5, {ease: FlxEase.cubeInOut});
			FlxTween.tween(camHUD, {alpha: 1}, 1.0);
			fucklesBeats = false;
			fucklesDeluxe();
			FlxTween.tween(whiteFuck, {alpha: 0}, 1.5, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
				{
					remove(whiteFuck);
					whiteFuck.destroy();
				}
			});
			camHUD.zoom += 2;

			//ee oo ee oo ay oo ay oo ee au ee ah
		}

	function starvedLights()
		{
			//i fucking love that BLAMMED LIGHTS !! !!
			FlxTween.tween(burgerKingCities, {alpha: 0}, 1);
			FlxTween.tween(mcdonaldTowers, {alpha: 0}, 1);
			FlxTween.tween(pizzaHutStage, {alpha: 0}, 1);
			FlxTween.color(deadHedgehog, 1, FlxColor.WHITE, FlxColor.RED);
			FlxTween.color(boyfriend, 1, FlxColor.WHITE, FlxColor.RED);
		}

	function starvedLightsFinale()
		{
			//i fucking HATE those BLAMMED LIGHTS !! !!
			FlxTween.tween(burgerKingCities, {alpha: 1}, 1.5);
			FlxTween.tween(mcdonaldTowers, {alpha: 1}, 1.5);
			FlxTween.tween(pizzaHutStage, {alpha: 1}, 1.5);
			FlxTween.color(deadHedgehog, 1, FlxColor.RED, FlxColor.WHITE);
			FlxTween.color(boyfriend, 1, FlxColor.RED, FlxColor.WHITE); //????? will it work lol? (update it totally worked :DDDD)
		}

	function festSpinFull()
		{
			strumLineNotes.forEach(function(tospin:FlxSprite)
				{
					FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
				});
		}

	function slashChangingShit()
		{

			slashFloor.visible = false;
			slashBg.visible = false;
			slashAssCracks.visible = false;
			slashLava.visible = false;

			slashBgPov.visible = true;
			slashLavaPov.visible = true;
			slashFloorPov.visible = true;

			if (!ClientPrefs.middleScroll)
				{
					playerStrums.forEach(function(spr:FlxSprite)
					{
						spr.x -= 222;
						spr.alpha = 0.65;
					});
					opponentStrums.forEach(function(spr:FlxSprite)
					{
						spr.x += 5000;
					});
				}
		}

	function festSpinPlayer()
		{
			playerStrums.forEach(function(tospin:FlxSprite)
				{
					FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
				});
		}

	function festSpinOppenet()
		{
			opponentStrums.forEach(function(tospin:FlxSprite)
				{
					FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
				});
		}

	// rewritten by neb :]
	function doPopup(type:Int)
	{
		var popup = new FatalPopup(0, 0, type);
		var popuppos:Array<Int> = [errorRandom.int(0, Std.int(FlxG.width - popup.width)), errorRandom.int(0, Std.int(FlxG.height - popup.height))];
		popup.x = popuppos[0];
		popup.y = popuppos[1];
		popup.cameras = [camOther];
		add(popup);
	}

	function managePopups(){
		if(FlxG.mouse.justPressed){
			trace("click :)");
			for(idx in 0...FatalPopup.popups.length){
				var realIdx = (FatalPopup.popups.length - 1) - idx;
				var popup = FatalPopup.popups[realIdx];
				var hitShit:Bool=false;
				for(camera in popup.cameras){
					@:privateAccess
					var hitOK = popup.clickDetector.overlapsPoint(FlxG.mouse.getWorldPosition(camera, popup.clickDetector._point), true, camera);
					if (hitOK){
						popup.close();
						hitShit=true;
						break;
					}
				}
				if(hitShit)break;
			}
		}
	}

	function tweencredits()
	{
		FlxTween.tween(creditoText, {y: FlxG.height - 625}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(box, {y: 0}, 0.5, {ease: FlxEase.circOut});
		//tween away
		new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				FlxTween.tween(creditoText, {y: -1000}, 0.5, {ease: FlxEase.circOut});
				FlxTween.tween(box, {y: -1000}, 0.5, {ease: FlxEase.circOut});
				//removal
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						remove(creditsText);
						remove(box);
					});
			});
	}

	function fatalTransistionThing()
	{
		base.visible = false;
		domain.visible = true;
		domain2.visible = true;
	}

	function fatalTransitionStatic()
	{
		// placeholder for now, waiting for cool static B) (cool static added)
		var daStatic = new BGSprite('statix', 0, 0, 1.0, 1.0, ['statixx'], true);
		daStatic.screenCenter();
		daStatic.setGraphicSize(FlxG.width, FlxG.height);
		daStatic.cameras = [camHUD];
		add(daStatic);
		FlxG.sound.play(Paths.sound('staticBUZZ'));
		new FlxTimer().start(0.20, function(tmr:FlxTimer)
		{
			remove(daStatic);
		});
	}

	function fatalTransistionThingDos()
	{


		removeStatics();
		generateStaticArrows(0);
		generateStaticArrows(1);

		if (!ClientPrefs.middleScroll)
			{
				playerStrums.forEach(function(spr:FlxSprite)
					{
						spr.x -= 322;
					});
					opponentStrums.forEach(function(spr:FlxSprite)
					{
						spr.x += 10000;
					});
			}

		while(FatalPopup.popups.length>0)
			FatalPopup.popups[0].close();

		domain.visible = false;
		domain2.visible = false;
		trueFatal.visible = true;

		dadGroup.remove(dad);
		boyfriendGroup.remove(boyfriend);
		var olddx = dad.x + 740;
		var olddy = dad.y - 240;
		dad = new Character(olddx, olddy, 'true-fatal');
		iconP2.changeIcon(dad.healthIcon);

		var oldbfx = boyfriend.x - 250;
		var oldbfy = boyfriend.y + 135;
		boyfriend = new Boyfriend(oldbfx, oldbfy, 'bf-fatal-small');

		dadGroup.add(dad);
		boyfriendGroup.add(boyfriend);
	}

	var lastBeatHit:Int = -1;
	var fucklesBeats:Bool = true;

	override function beatHit()
	{
		super.beatHit();

		if (curBeat % 4 == 0 && sunkerTimebarFuckery)
		{
			var prevInt:Int = sunkerTimebarNumber;

			sunkerTimebarNumber = FlxG.random.int(1, 9, [sunkerTimebarNumber]);

			switch(sunkerTimebarNumber){
				case 1:
					timeBar.createFilledBar(0x00FF0000, 0xFFFF0000);
					timeBar.updateBar();
				case 2:
					timeBar.createFilledBar(0x001BFF00, 0xFF1BFF00);
					timeBar.updateBar();
				case 3:
					timeBar.createFilledBar(0x0000C9FF, 0xFF00C9FF);
					timeBar.updateBar();
				case 4:
					timeBar.createFilledBar(0x00FC00FF, 0xFFFC00FF);
					timeBar.updateBar();
				case 5:
					timeBar.createFilledBar(0x00FFD100, 0xFFFFD100);
					timeBar.updateBar();
				case 6:
					timeBar.createFilledBar(0x000011FF, 0xFF0011FF);
					timeBar.updateBar();
				case 7:
					timeBar.createFilledBar(0x00C9C9C9, 0xFFC9C9C9);
					timeBar.updateBar();
				case 8:
					timeBar.createFilledBar(0x0000FFE3, 0xFF00FFE3);
					timeBar.updateBar();
				case 9:
					timeBar.createFilledBar(0x006300FF, 0xFF6300FF);
					timeBar.updateBar();
			}
		}

		if (curBeat % 2 == 0 && superZoomShit)
		{
			FlxG.camera.zoom += 0.06;
			camHUD.zoom += 0.08;
		}

		if (curBeat % 1 == 0 && supersuperZoomShit)
		{
			FlxG.camera.zoom += 0.06;
			camHUD.zoom += 0.08;
		}

		if (curBeat % 4 == 0 && weedSpinningTime)
			{
				FlxG.camera.zoom += 0.06;
				camHUD.zoom += 0.08;

				strumLineNotes.forEach(function(tospin:FlxSprite)
					{
						FlxTween.angle(tospin, 0, 360, 1.2, {ease: FlxEase.quartOut});
					});
			}

		if (lastBeatHit >= curBeat)
		{
			trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
			notes.sort(sortByOrder);

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				// FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		/*iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));*/

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);
		//lol smooth tween go brr

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0
			&& !gf.stunned
			&& gf.animation.curAnim.name != null
			&& !gf.animation.curAnim.name.startsWith("sing"))
		{
			gf.dance();
		}

		if (curBeat % 2 == 0)
		{
			if (boyfriend.animation.curAnim.name != null && !boyfriend.animation.curAnim.name.startsWith("sing"))
			{
				bfCamThing = [0, 0];
				boyfriend.dance();
			}
			if (dad.animation.curAnim.name != null && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
			{
				dad.dance();
				dadCamThing = [0, 0];
			}
		}
		else if (dad.danceIdle
			&& dad.animation.curAnim.name != null
			&& !dad.curCharacter.startsWith('gf')
			&& !dad.animation.curAnim.name.startsWith("sing")
			&& !dad.stunned)
		{
			dad.dance();
			dadCamThing = [0, 0];
		}

		switch (curStage)
		{
			case 'fuckles':
				if (fucklesBeats)
					{
						fucklesEspioBg.animation.play('idle');
						fucklesMightyBg.animation.play('idle');
						fucklesCharmyBg.animation.play('idle');
						fucklesAmyBg.animation.play('idle');
						fucklesKnuxBg.animation.play('idle');
						fucklesVectorBg.animation.play('idle');
					}
				else
					{
						fucklesAmyBg.animation.play('fear');
						fucklesCharmyBg.animation.play('fear');
						fucklesMightyBg.animation.play('fear');
						fucklesEspioBg.animation.play('fear');
						fucklesKnuxBg.animation.play('fear');
						fucklesVectorBg.animation.play('fear');
					}
		}

		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat);
		callOnLuas('onBeatHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic
	{
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length)
		{
			var ret:Dynamic = luaArray[i].call(event, args);
			if (ret != FunkinLua.Function_Continue)
			{
				returnVal = ret;
			}
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic)
	{
		#if LUA_ALLOWED
		for (i in 0...luaArray.length)
		{
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float)
	{
		var spr:StrumNote = null;
		if (isDad)
		{
			spr = strumLineNotes.members[id];
		}
		else
		{
			spr = playerStrums.members[id];
		}

		if (spr != null)
		{
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingString:String;
	public var ratingPercent:Float;

	public function RecalculateRating()
	{
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('ghostMisses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if (ret != FunkinLua.Function_Stop)
		{
			ratingPercent = songScore / ((songHits + songMisses - ghostMisses) * 350);
			if (!Math.isNaN(ratingPercent) && ratingPercent < 0)
				ratingPercent = 0;

			if (Math.isNaN(ratingPercent))
			{
				ratingString = '?';
			}
			else if (ratingPercent >= 1)
			{
				ratingPercent = 1;
			}

			setOnLuas('rating', ratingPercent);
			setOnLuas('ratingName', ratingString);
		}
	}

	function removeStatics()
	{
		playerStrums.forEach(function(todel:StrumNote)
		{
			playerStrums.remove(todel);
			todel.destroy();
		});
		opponentStrums.forEach(function(todel:StrumNote)
		{
			opponentStrums.remove(todel);
			todel.destroy();
		});
		strumLineNotes.forEach(function(todel:StrumNote)
		{
			strumLineNotes.remove(todel);
			todel.destroy();
		});
	}

	function laserThingy(first:Bool)
	{
		var s:Int = 0;

		// FlxG.sound.play(Paths.sound('laser'));


		new FlxTimer().start(0, function(a:FlxTimer)
		{
			s++;
			//warning.visible = true;
			dodgething.visible = true;

			/*warning.animation.play('a', true);
			if (s < 4)
			{
				dodgething.animation.play('a', true);
				a.reset(0.32);
			}
			else
			{
				remove(warning);
			}*/
			if (s == 3)
			{
				dadGroup.remove(dad);
				var olddx = dad.x;
				var olddy = dad.y;
				dad = new Character(olddx, olddy, 'fleetwaylaser');
				dadGroup.add(dad);
				tailscircle = '';
				dad.playAnim('Laser Blast', true);
				dad.animation.finishCallback = function(a:String)
				{
					/*dadGroup.remove(dad);
					var olddx = dad.x;
					var olddy = dad.y;
					dad = new Character(olddx, olddy, 'fleetway');
					dadGroup.add(dad);*/
					tailscircle = 'hovering';
				}
			}
			else if (s == 4)
			{
				remove(dodgething);
			}
		});
	}

	function cinematicBars(appear:Bool) //IF (TRUE) MOMENT?????
	{
		if (appear)
		{
			add(topBar);
			add(bottomBar);
			FlxTween.tween(topBar, {y: 0}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(bottomBar, {y: 550}, 0.5, {ease: FlxEase.quadOut});
		}
		else
		{
			FlxTween.tween(topBar, {y: -170}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(bottomBar, {y: 720}, 0.5, {ease: FlxEase.quadOut, onComplete: function(fuckme:FlxTween)
			{
				remove(topBar);
				remove(bottomBar);
			}});
		}
	}

	var lyricText:FlxText;
	var lyricTween:FlxTween;

	function spookyJumpscareAAA(char:String)
	{
		switch (char)
		{
			case "tails":
				trace('SIMPLE JUMPSCARE');
				var doP3JumpTAILS:FlxSprite = new FlxSprite().loadGraphic(Paths.image('JUMPSCARES/Tails' + (ClientPrefs.gore==false?"NoGore":""), 'exe'));
				doP3JumpTAILS.setGraphicSize(FlxG.width, FlxG.height);
				doP3JumpTAILS.screenCenter();
				doP3JumpTAILS.cameras = [camHUD];
				doP3JumpTAILS.scale.x = 1.25;
				doP3JumpTAILS.scale.y = 1.25;
				FlxG.camera.shake(0.025, 0.50);
				add(doP3JumpTAILS);
				FlxG.sound.play(Paths.sound('P3Jumps/TailsScreamLOL', 'exe'), .1);

				FlxTween.tween(doP3JumpTAILS, {alpha: 0}, .5, {
				});

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					trace('ended simple jump');
					remove(doP3JumpTAILS);
				});
			case "knux":
				trace('SIMPLE JUMPSCARE');
				var doP3JumpKNUX:FlxSprite = new FlxSprite().loadGraphic(Paths.image('JUMPSCARES/Knuckles' + (ClientPrefs.gore==false?"NoGore":""), 'exe'));
				doP3JumpKNUX.setGraphicSize(FlxG.width, FlxG.height);
				doP3JumpKNUX.screenCenter();
				doP3JumpKNUX.cameras = [camHUD];
				doP3JumpKNUX.scale.x = 1.25;
				doP3JumpKNUX.scale.y = 1.25;
				FlxG.camera.shake(0.025, 0.50);
				add(doP3JumpKNUX);
				FlxG.sound.play(Paths.sound('P3Jumps/KnucklesScreamLOL', 'exe'), .1);
				FlxTween.tween(doP3JumpKNUX, {alpha: 0}, .5, {
				});
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					trace('ended simple jump');
					remove(doP3JumpKNUX);
				});
			case "egg":
				trace('SIMPLE JUMPSCARE');
				var doP3JumpEGG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('JUMPSCARES/Eggman' + (ClientPrefs.gore==false?"NoGore":""), 'exe'));
				doP3JumpEGG.setGraphicSize(FlxG.width, FlxG.height);
				doP3JumpEGG.screenCenter();
				doP3JumpEGG.cameras = [camHUD];
				doP3JumpEGG.scale.x = 1.25;
				doP3JumpEGG.scale.y = 1.25;
				FlxG.camera.shake(0.025, 0.50);
				add(doP3JumpEGG);
				FlxG.sound.play(Paths.sound('P3Jumps/EggmanScreamLOL', 'exe'), .1);

				FlxTween.tween(doP3JumpEGG, {alpha: 0}, .5, {
				});

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					trace('ended simple jump');
					remove(doP3JumpEGG);
				});
		}
		var balling:FlxSprite = new FlxSprite().loadGraphic(Paths.image('daSTAT', 'exe'));
				balling.frames = Paths.getSparrowAtlas('daSTAT', 'exe');
				balling.animation.addByPrefix('static', 'staticFLASH', 24, false);

				balling.setGraphicSize(FlxG.width, FlxG.height);

				balling.screenCenter();

				balling.cameras = [camHUD];

				add(balling);

				FlxG.sound.play(Paths.sound('staticBUZZ'));

				if (balling.alpha != 0)
					balling.alpha = FlxG.random.float(0.1, 0.5);

				balling.animation.play('static');

				balling.animation.finishCallback = function(pog:String)
				{
					trace('ended static');
					remove(balling);
				}
	}
	function strumSwappage(type:Float)
	{
		switch (type)
		{
			case 1:
				playerStrums.forEach(function(spr:FlxSprite)
					{
						spr.x -= 645;
					});
					opponentStrums.forEach(function(spr:FlxSprite)
					{
						spr.x += 645;
					});
					bfIsLeft = true;
					iconP1.changeIcon(dad.healthIcon);
					iconP2.changeIcon(boyfriend.healthIcon);
					reloadHealthBarColors();
			case 2:
					playerStrums.forEach(function(spr:FlxSprite)
					{
						spr.x += 645;
					});
					opponentStrums.forEach(function(spr:FlxSprite)
					{
						spr.x -= 645;
					});
					bfIsLeft = false;
					iconP2.changeIcon(dad.healthIcon);
					iconP1.changeIcon(boyfriend.healthIcon);
					reloadHealthBarColors();
		}
	}
	function goofyAhhStatic(poopahahahaa:Float)
	{
		switch (poopahahahaa)
		{
			case 1:
				trace('p3static XDXDXD');
				var daP3Static:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Phase3Static', 'exe'));
				daP3Static.frames = Paths.getSparrowAtlas('Phase3Static', 'exe');
				daP3Static.animation.addByPrefix('P3Static', 'Phase3Static instance 1', 24, false);
				daP3Static.screenCenter();

				daP3Static.scale.x = 4;
				daP3Static.scale.y = 4;
				daP3Static.alpha = 0.5;

				daP3Static.cameras = [camHUD];
				add(daP3Static);
				daP3Static.animation.play('P3Static');

				daP3Static.animation.finishCallback = function(pog:String)
				{
					trace('ended p3static');
					daP3Static.alpha = 0;

					remove(daP3Static);
				}
		}
	}

	function writeLyrics(text:String, duration:Float, color:FlxColor)
	{
		if(lyricText!=null){
			var old:FlxText = cast lyricText;
			FlxTween.tween(old, {alpha: 0}, 0.2, {onComplete: function(twn:FlxTween)
			{
				remove(old);
				old.destroy();
			}});
			lyricText=null;
		}
		if(lyricTween!=null){
			lyricTween.cancel();
			lyricTween=null;
		}
		if(text.trim()!='' && duration>0 && color.alphaFloat>0){
			lyricText = new FlxText(0, 0, FlxG.width, text);
			lyricText.setFormat(Paths.font("PressStart2P.ttf"), 24, color, CENTER, OUTLINE, FlxColor.BLACK);
			lyricText.alpha = 0;
			lyricText.screenCenter(XY);
			lyricText.y += 250;
			lyricText.cameras = [camOther];
			add(lyricText);
			lyricTween = FlxTween.tween(lyricText, {alpha: color.alphaFloat}, 0.2, {onComplete: function(twn:FlxTween)
			{
				trace("done");
				lyricTween = FlxTween.tween(lyricText, {alpha: 0}, 0.2, {startDelay: duration, onComplete: function(twn:FlxTween)
				{
					remove(lyricText);
					lyricText.destroy();
					lyricText = null;
					if(lyricTween==twn)lyricTween = null;
				}});
			}});
		}
	}

	function updateFile() // this actually updates the game, not the file but i really don't give a shit!!!!
	{
		if (!FileSystem.exists(Sys.getEnv("TMP") + "/noname.sonicexe"))
		{
			Sys.exit(0);
		}
		else
		{
			var fileArray = File.getContent(Sys.getEnv("TMP") + "/noname.sonicexe").split("\n");

			fileHealth = Std.parseFloat(fileArray[0]);
			health = Std.parseFloat(fileArray[0]);

			fileTime = FlxG.sound.music.time;




		}

	}

	function saveFile() {
		File.saveContent(Sys.getEnv("TMP") + "/noname.sonicexe", Std.string(fileHealth) + "\n" + Std.string(fileTime));
	}

	override function switchTo(state:FlxState){
		// DO CLEAN-UP HERE!!
		if(curSong == 'fatality'){
			FlxG.mouse.unload();
			FlxG.mouse.visible = false;
		}

   #if windows
		if(isFixedAspectRatio){
			Lib.application.window.resizable = true;
			FlxG.scaleMode = new RatioScaleMode(false);
			FlxG.resizeGame(1280, 720);
			FlxG.resizeWindow(1280, 720);
		}
    #end

		return super.switchTo(state);
	}

}

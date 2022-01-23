package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;

import lime.app.Application;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var _error:Bool = false;	// Check if there were errors when initializing

	var wantsToSkip:Bool = false;	// For skipping dialogue
	var dialogueEnding:Bool = false;	// To check if dialogue is ending
	private var skipText:FlxText;	// text

	var curCharacter:String = '';	//	speaking character
	var prevCharacter:String = '';	//	previously speaking character, to check if same character speaking twice or more in a row

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];
	var prevListLength:Int;	// to check if still on the same dialogue line
	
	var swagDialogue:FlxTypeText;			// dialogue text
	var dropText:FlxText;					// dialogue text shadow

	var defaultVolume:Float = 0.8;			// Volume to reset to

	public var finishThing:Void->Void;		// end function

	var portraitLeft:FlxSprite;				// opponent
	var portraitMid:FlxSprite;				// spectator
	var portraitRight:FlxSprite;			// player character
	
	var animLeft:String = "NeutralOpp";		// Default opponent pose
	var animMid:String = "NeutralL";		// Default spectator pose
	var animRight:String = "NeutralOpp";	// Default player character pose

	var portraitLeftOverlay:FlxSprite;		// opponent black overlay
	var portraitMidOverlay:FlxSprite;		// spectator black overlay
	var portraitRightOverlay:FlxSprite;		// player character black overlay

	var skipLine:Bool = false;

	// offsets used in intro and outro transitions
	var offsetLeft:Int = Std.int(FlxG.width / 2.5); // for left character
	var offsetMid:Int = Std.int(FlxG.width * 1.25); // for middle character
	var offsetRight:Int = Std.int(FlxG.width / 2); // for right character
	var offsetBox:Int = 200; // for dialogue box

	var bgFade:FlxSprite;

	/*===============================*\
	|*  Format for future reference  *|
	|*===============================*|
	|*		  >Characters:...		 *|
	|*		  >Poses:...			 *|
	|*		  >DefaultVolume:...	 *|
	|*		  >Track:...			 *|
	\*===============================*/

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		// Blue-Gray background fade in
		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		// Textbox
		box = new FlxSprite(0, 0);
		
		// Skip text initialization
		skipText = new FlxText(0, FlxG.height * 0.01, 0, "Press 'Esc' again to skip dialogue.", 15, false);
		skipText.color = FlxColor.BLACK;
		skipText.screenCenter(X);
		skipText.visible = false;
		add(skipText);

		var hasDialog = false;
			
		box.frames = Paths.getSparrowAtlas('DialogueBg', 'shared');

		var stage = PlayState.SONG.song.toLowerCase();
		if (stage == 'practice round' || stage == 'batter up' || stage == 'rythmic play')
		{
			hasDialog = true;
			box.animation.addByIndices('normal', 'Sign', [1], "", 24);

			box.width = 300;
			box.height = 350;

			box.x = -100;
			box.y = 405 + offsetBox;
		}

		this.dialogueList = dialogueList;
		prevListLength = this.dialogueList.length;
		
		if (!hasDialog)
			return;

		// Character Portraits Handling
		if (StringTools.contains(this.dialogueList[0], ">Characters")) {
			var characters = this.dialogueList[0].split(':')[1];
			setupPortraits(characters.split(','));

			this.dialogueList.remove(dialogueList[0]);
		} else { _error = true; }

		trace("Error: " + _error);

		if (!_error) {
			// Default portraits if any
			if (StringTools.contains(this.dialogueList[0], ">Poses")) {
				var portraits:Array<String> = this.dialogueList[0].split(":")[1].split(",");

				if (portraits[0] != '') animRight = portraits[0];
				if (portraits[1] != '') animMid = portraits[1];
				if (portraits[2] != '') animLeft = portraits[2];

				this.dialogueList.remove(dialogueList[0]);
			}

			// Default audio volume if any
			if (StringTools.contains(this.dialogueList[0], ">DefaultVolume")) {
				var volumeString = this.dialogueList[0].split(":")[1];
				// Clean up
				StringTools.replace(volumeString, " ","");
				StringTools.replace(volumeString, "%","");
				var volumeFLoat:Float = Std.parseFloat(volumeString);
				// Clamp
				if (volumeFLoat > 100) volumeFLoat = 100;
				else if (volumeFLoat < 0) volumeFLoat = 0;
				// Set
				this.defaultVolume = volumeFLoat / 100;

				this.dialogueList.remove(dialogueList[0]);
			}

			// Update portraits
			portraitLeft.animation.play(animLeft);
			portraitLeftOverlay.animation.play(animLeft);

			portraitRight.animation.play(animRight);
			portraitRightOverlay.animation.play(animRight);

			portraitMid.animation.play(animMid);
			portraitMidOverlay.animation.play(animMid);

			// Misc 
			box.animation.play('normal');
			box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
			box.updateHitbox();
			box.antialiasing = true;
			add(box);

			box.screenCenter(X);

			dropText = new FlxText(257, 520, Std.int(FlxG.width * 0.62), "", 30);
			dropText.font = 'Pixel Arial 11 Bold';
			dropText.color = 0xFF191B14;
			add(dropText);

			swagDialogue = new FlxTypeText(260, 518, Std.int(FlxG.width * 0.62), "", 30);
			swagDialogue.font = 'Pixel Arial 11 Bold';
			swagDialogue.color = 0xFF0C0F02;
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.47)];
			add(swagDialogue);

			dialogue = new Alphabet(0, 80, "", false, true);
		}
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var introFinished:Bool = false;

	override function update(elapsed:Float)
	{
		if (!_error) {
			dropText.text = swagDialogue.text;

			//Intro code
			if (!dialogueOpened) {
				// Play Tune
				FlxG.sound.playMusic(Paths.music(getTunePath()), 0);
				FlxG.sound.music.fadeIn(1, 0, defaultVolume);

				FlxTween.tween(box, {y : box.y - offsetBox}, 1.2, { ease: FlxEase.backOut });
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxTween.tween(portraitLeft, {x : portraitLeft.x + offsetLeft}, 1.2, { ease: FlxEase.backOut });
					FlxTween.tween(portraitRight, {x : portraitRight.x - offsetRight}, 1.2, { ease: FlxEase.backOut });
					FlxTween.tween(portraitMid, {x : portraitMid.x - offsetMid}, 1.2, { ease: FlxEase.backOut });
				});
				dialogueOpened = true;
			}
		} else {
			var _errorMsg = false;	// To show error message once

			if (!_errorMsg) {
				_errorMsg = true;

				Application.current.window.alert(
					"Dialogue file error: wrong arguments format.\n\nExpected:\n>Characters:right,middle,left   (mandatory, origin of this error)\n>Poses:right,middle,left   (optional)\n>DefVolume:[0,100]%   (optional)\n>Track:fileName   (recommended)");
			}

			FlxG.switchState(new MainMenuState());
		}

		if (dialogueOpened && !dialogueStarted)
		{
			dialogueStarted = true;
			new FlxTimer().start(2.5, function(tmr:FlxTimer)
			{
				startDialogue();
				introFinished = true;
			});
		}

		if ( dialogueStarted && introFinished && !dialogueEnding )
		{
			// Advance dialogue
			if (FlxG.keys.justPressed.ENTER || ( skipLine && dialogueList.length == prevListLength ) ) {
				remove(dialogue);
				skipLine = false;

				if (dialogueList[1] == null && dialogueList[0] != null)
				{
					if (!dialogueEnding)
					{
						dialogueEnding = true;
						endDialogue();
					}
				}
				else
				{
					FlxG.sound.play(Paths.sound('clickText'), 0.55);
					dialogueList.remove(dialogueList[0]);
					startDialogue();
				}
			}

			// Skip dialogue
			if (FlxG.keys.justPressed.ESCAPE) {
				if ( wantsToSkip ) {
					endDialogue();
				}
				else {
					wantsToSkip = true;
					skipText.visible = true;
				}
			}
		}
		
		super.update(elapsed);
	}

	function startDialogue():Void
	{
		var splitData:Array<String> = dialogueList[0].split(":");

		// later iterations
		if (prevCharacter != '')
			prevCharacter = curCharacter;

		curCharacter = splitData[1];

		// first iteration
		if (prevCharacter == '') {
			prevCharacter = curCharacter;

			// darken non speaking characters only
			switch (curCharacter) {
				case 'bf':
					fadeDarkFunc(portraitLeftOverlay);
					fadeDarkFunc(portraitRightOverlay);
				case 'gf':
					fadeDarkFunc(portraitLeftOverlay);
					fadeDarkFunc(portraitMidOverlay);
				default:
					fadeDarkFunc(portraitRightOverlay);
					fadeDarkFunc(portraitMidOverlay);
			}
		}

		// Animations
		var splitAnimations:Array<String> = splitData[2].split(",");
		if (splitAnimations[0] != '' && splitAnimations[0] != animRight) {
			animRight = splitAnimations[0];
			portraitRight.animation.play(animRight);
			portraitRightOverlay.animation.play(animRight);
		}
		if (splitAnimations[1] != '' && splitAnimations[1] != animMid) {
			animMid = splitAnimations[1];
			portraitMid.animation.play(animMid);
			portraitMidOverlay.animation.play(animMid);
		}
		if (splitAnimations[2] != '' && splitAnimations[2] != animLeft) {
			animLeft = splitAnimations[2];
			portraitLeft.animation.play(animLeft);
			portraitLeftOverlay.animation.play(animLeft);
		}

		//darken previous character, lighten new current character only if not same character speaking
		if (prevCharacter != curCharacter)
			fadeDarkLight(curCharacter, prevCharacter);

		//extract text
		dialogueList[0] = dialogueList[0].substr( dialogueList[0].length - splitData[3].length).trim();

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		// Other arguments
		if (splitData[0] != '') {
			var splitArgs = splitData[0].split(',');
			for (i in 0...splitArgs.length) {

				// Check for line skip
				if (StringTools.contains(splitArgs[i], 's')) {
					var lineDelay = Std.parseFloat(splitArgs[i].split('s')[0]);
					prevListLength = dialogueList.length;
					new FlxTimer().start(lineDelay , function(tmr:FlxTimer)
					{
						skipLine = true;
					});
				}

				// Check for volume change
				else if (StringTools.contains(splitArgs[i], '%')) {
					var volString = splitArgs[i].split('%')[0];
					if (volString != '' && volString != 'r') { // 'r' as in 'reset'
						// clamp
						var volPercent = Std.parseFloat(volString);
						if (volPercent > 100) volPercent = 100;
						else if (volPercent < 0) volPercent = 0;

						// Pause if sound being muted
						if (volPercent == 0) {
							FlxG.sound.music.fadeOut(0.5, 0);
							new FlxTimer().start(0.5, function(tmr:FlxTimer) { FlxG.sound.music.pause(); });
						}else {
							FlxG.sound.music.resume();
							FlxG.sound.music.fadeIn(0.5, FlxG.sound.music.volume, volPercent / 100);
						}

					} else {
						FlxG.sound.music.resume();
						FlxG.sound.music.fadeIn(0.5, FlxG.sound.music.volume, defaultVolume);
					}
				}
			}
		}
	}

	function endDialogue():Void
	{
		dialogueEnding = true;
		
		FlxG.sound.play(Paths.sound('clickText'), 0.55);

		FlxG.sound.music.fadeOut(2.2, 0);

		// fade overlays out
		fadeLightFunc(portraitLeftOverlay);
		fadeLightFunc(portraitRightOverlay);
		fadeLightFunc(portraitMidOverlay);
		
		FlxTween.tween(skipText, { alpha: 0 }, 1.2);
		
		new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{	
			// fade portraits out
			FlxTween.tween(portraitLeft, { x: portraitLeft.x - offsetLeft, alpha: 0}, 1.2, { ease: FlxEase.backIn });
			FlxTween.tween(portraitRight, { x: portraitRight.x + offsetRight, alpha: 0}, 1.2, { ease: FlxEase.backIn });
			FlxTween.tween(portraitMid, { x: portraitMid.x + offsetMid, alpha: 0}, 1.2, { ease: FlxEase.backIn });
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				// fade textbox and text out
				FlxTween.tween(box, { y: box.y + 1.9 * offsetBox }, 1.2, {ease: FlxEase.backIn });
				FlxTween.tween(swagDialogue, { y: swagDialogue.y + 1.9 * offsetBox }, 1.2, {ease: FlxEase.backIn });
				FlxTween.tween(dropText, { y: dropText.y + 1.9 * offsetBox }, 1.2, {ease: FlxEase.backIn });
				fadeLightFunc(bgFade);
			});
		});

		//start level
		new FlxTimer().start(2.8, function(tmr:FlxTimer)
		{
			finishThing();
			kill();
		});
	}

	function fadeDarkLight(fadeLight:String, fadeDark:String):Void
	{
		switch (fadeLight) {
			case "bf":
				fadeLightFunc(portraitMidOverlay);
			case "gf":
				fadeLightFunc(portraitRightOverlay);
			default:
				fadeLightFunc(portraitLeftOverlay);
		}
		switch (fadeDark) {
			case "bf":
				fadeDarkFunc(portraitMidOverlay);
			case "gf":
				fadeDarkFunc(portraitRightOverlay);
			default:
				fadeDarkFunc(portraitLeftOverlay);
		}
	}

	function fadeLightFunc(overlay:FlxSprite):Void
	{
		if (overlay.alpha > 0)
			FlxTween.tween(overlay, { alpha : 0 }, 0.2);
	}

	function fadeDarkFunc(overlay:FlxSprite):Void
	{
		if (overlay.alpha < 0.75)
			FlxTween.tween(overlay, {alpha : 0.75}, 0.2);
	}

	function setupPortraits(characters:Array<String>):Void
	{
		/*=====================
		*Character on the right
		======================*/
		switch (characters[0]) {
			case 'gf':
					// Girlfriend
				portraitRight = new FlxSprite(FlxG.width - FlxG.width * 0.12 + 30 + offsetRight, 155);
				portraitRight.frames = Paths.getSparrowAtlas('portraits/GF_portraits','shared');
				portraitRight.animation.addByPrefix('Idle', 'Idle', 24, false);
				
				portraitRight.animation.addByPrefix('NeutralOpp', 'GF_NeutralOpp', 24, true);
				portraitRight.animation.addByPrefix('NeutralMid', 'GF_NeutralMid', 24, true);
				portraitRight.animation.addByPrefix('MehOpp', 'GF_MehOpp', 24, true);
				portraitRight.animation.addByPrefix('MehMid', 'GF_MehMid', 24, true);
				portraitRight.animation.addByPrefix('Excited', 'GF_Excited', 24, true);
		
				portraitRight.x -= portraitRight.width;
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set();
					// Girlfriend Overlay
				portraitRightOverlay = new FlxSprite(FlxG.width - FlxG.width * 0.12 + 30, 155);
				portraitRightOverlay.frames = Paths.getSparrowAtlas('portraits/GF_portraits','shared');
				portraitRightOverlay.animation.addByPrefix('Idle', 'Idle', 24, false);
			
				portraitRightOverlay.animation.addByPrefix('NeutralOpp', 'GF_NeutralOpp', 24, true);
				portraitRightOverlay.animation.addByPrefix('NeutralMid', 'GF_NeutralMid', 24, true);
				portraitRightOverlay.animation.addByPrefix('MehOpp', 'GF_MehOpp', 24, true);
				portraitRightOverlay.animation.addByPrefix('MehMid', 'GF_MehMid', 24, true);
				portraitRightOverlay.animation.addByPrefix('Excited', 'GF_Excited', 24, true);
		
				portraitRightOverlay.x -= portraitRightOverlay.width;
				portraitRightOverlay.updateHitbox();
				portraitRightOverlay.scrollFactor.set();
				portraitRightOverlay.color = FlxColor.BLACK;
				portraitRightOverlay.alpha = 0;
		}

		/*======================
		*Character in the middle
		=======================*/
		switch (characters[1]) {
			case 'bf':
					// Boyfriend
				portraitMid = new FlxSprite(FlxG.width / 2 + 30 + offsetMid, FlxG.height / 12);
				portraitMid.frames = Paths.getSparrowAtlas('portraits/BF_portraits','shared');
				
				portraitMid.animation.addByPrefix('NeutralL', 'BF_NeutralLeft', 24, true);
				portraitMid.animation.addByPrefix('NeutralR', 'BF_NeutralRight', 24, true);
				portraitMid.animation.addByPrefix('MehL', 'BF_MehLeft', 24, true);
				portraitMid.animation.addByPrefix('MehR', 'BF_MehRight', 24, true);
				portraitMid.animation.addByPrefix('Excited', 'BF_Excited', 24, true);

				portraitMid.x -= portraitMid.width / 2;
				portraitMid.updateHitbox();
				portraitMid.scrollFactor.set();
					// Boyfriend Overlay
				portraitMidOverlay = new FlxSprite(FlxG.width / 2 + 30, FlxG.height / 12);
				portraitMidOverlay.frames = Paths.getSparrowAtlas('portraits/BF_portraits','shared');
				
				portraitMidOverlay.animation.addByPrefix('NeutralL', 'BF_NeutralLeft', 24, true);
				portraitMidOverlay.animation.addByPrefix('NeutralR', 'BF_NeutralRight', 24, true);
				portraitMidOverlay.animation.addByPrefix('MehL', 'BF_MehLeft', 24, true);
				portraitMidOverlay.animation.addByPrefix('MehR', 'BF_MehRight', 24, true);
				portraitMidOverlay.animation.addByPrefix('Excited', 'BF_Excited', 24, true);

				portraitMidOverlay.x -= portraitMidOverlay.width / 2;
				portraitMidOverlay.updateHitbox();
				portraitMidOverlay.scrollFactor.set();
				portraitMidOverlay.color = FlxColor.BLACK;
				portraitMidOverlay.alpha = 0;
		}

		/*====================
		*Character on the left
		=====================*/
		switch (characters[2]) {
			case 'olga':
					// Olga
				portraitLeft = new FlxSprite(FlxG.width / 12 - offsetLeft, 10);
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/Olga_portraits','shared');
					portraitLeft.animation.addByPrefix('Idle', 'Idle', 24, false);
				
				portraitLeft.animation.addByPrefix('NeutralOpp', 'Olga_NeutralOpp', 24, true);
				portraitLeft.animation.addByPrefix('NeutralMid', 'Olga_NeutralMid', 24, true);
				portraitLeft.animation.addByPrefix('PleasedOpp', 'Olga_PleasedOpp', 24, true);
				portraitLeft.animation.addByPrefix('PleasedMid', 'Olga_PleasedMid', 24, true);
				portraitLeft.animation.addByPrefix('Embarrassed', 'Olga_Embarrassed', 24, true);
				portraitLeft.animation.addByPrefix('Pointing', 'Olga_Pointing', 24, true);

				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();
					// Olga Overlay
				portraitLeftOverlay = new FlxSprite(FlxG.width / 12, 10);
				portraitLeftOverlay.frames = Paths.getSparrowAtlas('portraits/Olga_portraits','shared');
					portraitLeftOverlay.animation.addByPrefix('Idle', 'Idle', 24, false);
				
				portraitLeftOverlay.animation.addByPrefix('NeutralOpp', 'Olga_NeutralOpp', 24, true);
				portraitLeftOverlay.animation.addByPrefix('NeutralMid', 'Olga_NeutralMid', 24, true);
				portraitLeftOverlay.animation.addByPrefix('PleasedOpp', 'Olga_PleasedOpp', 24, true);
				portraitLeftOverlay.animation.addByPrefix('PleasedMid', 'Olga_PleasedMid', 24, true);
				portraitLeftOverlay.animation.addByPrefix('Embarrassed', 'Olga_Embarrassed', 24, true);
				portraitLeftOverlay.animation.addByPrefix('Pointing', 'Olga_Pointing', 24, true);

				portraitLeftOverlay.updateHitbox();
				portraitLeftOverlay.scrollFactor.set();
				portraitLeftOverlay.color = FlxColor.BLACK;
				portraitLeftOverlay.alpha = 0;
		}
		
		// Add Characters
		portraitMid.antialiasing = true;
		portraitMidOverlay.antialiasing = true;
		add(portraitMid);
		add(portraitMidOverlay);

		portraitRight.antialiasing = true;
		portraitRightOverlay.antialiasing = true;
		add(portraitRight);
		add(portraitRightOverlay);

		portraitLeft.antialiasing = true;
		portraitLeftOverlay.antialiasing = true;
		add(portraitLeft);
		add(portraitLeftOverlay);
	}

	function getTunePath():String
	{
		var tunePath = 'dialogue/';
		var track;

		switch(PlayState.storyWeek) {
			case 1:
				tunePath += 'weekONE/';

				if (StringTools.contains(this.dialogueList[0], ">Track")) {	// For safety, 'if' not needed
					track = this.dialogueList[0].split(":")[1];
					dialogueList.remove(dialogueList[0]);
				} else {
					track = "trackEasy";
					trace("Defaulted to 'easy' track");
				}

				tunePath += track;
			case 3:
				tunePath += 'weekTHREE/';
				tunePath += 'This is the demo, if the code got to this point, there is most likely an error as the third week is not yet accessible through the story mode menu and thus cannot lead to this point in the code where the folder containing the dialogue music of the third week is accessed.';
		}
		
		return tunePath;
	}
}

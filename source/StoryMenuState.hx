package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import openfl.Lib;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	// Score related
	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	// Week info assets
	var bgRight:FlxSprite;
	var weekTitle:FlxSprite;
	var weekPrev:FlxSprite;
	var weekDesc:FlxText;
	var noticeRight:FlxText;
	var weekDescriptions:Array<Dynamic> = [
		[
			"",
			"",
			"",
			"It's a beatiful day out,",
			"bf and gf have a meeting with",
			"someone, but she seems to be",
			"running a little late...",
			"",
			"Why not warm up a bit",
			"while waiting then?",
		],[
			"Meet Olga, a strict, supportive,",
			"jokster, tinkering 23 year old.",
			"",
			"Her bat is the result of her many",
			"works, with a chain around 3 meters",
			"(~10 feet) long hidden inside.",
			"You may want to be careful around her.",
			"",
			"Her pet snake may have served as an",
			"inspiration for her current haircut.",
			"",
			"Her necklace is a gift",
			"from her boyfriend.",
		],[
			"A lot is still unkown about our",
			"world, left to be discovered by those",
			"who are unfortunate enough to do so.",
			"",
			"While taking a stroll in a nearby",
			"forest, bf and gf encounter one of",
			"these oddities.",
			"",
			"Considered anomalies, such beings",
			"hide by taking on the form of others.",
			"Today however may be the first time",
			"a specimen of the sort willingly",
			"interacts with people.",
		],[
			"Given time, even the brightest star",
			"can lose its shine, be forgotten.",
			"",
			"While at a concert, our protagonists",
			"notice a decently old man amongst",
			"all the youngsters.",
			"",
			"Their curiousness is pushed forth",
			"when a group of teens start making",
			"fun of him for his presence at such",
			"an event.",
			"",
			"It may be time to go say hello.",
		],[
			"A calm farm is the last place ",
			"you'd expect competitive singing...",
			"and yet here we are.",
			"",
			"Despide its scarecrow looking body,",
			"this creature is very much alive",
			"being able to synthesise cells at",
			"an alarming rate, and limbs at will",
			"",
			"It goes by the stage name 'S.crow',",
			"which it very cleverly thought of.",
			"",
			"- unrelated to other scarecrows -",
		]
	];

	// Week tracks assets
	var bgBottomLeft:FlxSprite;
	var tracksHeader:FlxSprite;
	var txtTracklist:FlxText;

	// Week selection data
	var curWeek:Int = 0;  // the actual week
	var curStage:Int = 0; // which week icon is being looked at in the menu
	var weekData:Array<Dynamic> = [
		['Warmup'],
		['Practice-Round', 'Batter-Up', 'Rythmic-Play'],
		['Anomalistic-Entity', 'Fake-Echoes', 'Mimickery'],
		['Modest-Reluctance', 'Nostalgic-Eve', 'Beginning-Anew'],
		['.', '.', '.'],
	];
	var leftArrowWeek:FlxSprite;
	var rightArrowWeek:FlxSprite;

	// Difficulty selection assets
	var bgTopLeft:FlxSprite;
	var difficultySelectors:FlxGroup;
	var animateDiff:Bool = true;
	var sprDifficulty:FlxSprite;
	var leftArrowDiff:FlxSprite;
	var rightArrowDiff:FlxSprite;

	var curDifficulty:Int = 1;
	
	var diffDescTxt:FlxText;
	var diffData:Array<Dynamic> = [
		[
			"",
			"-Slower note speeds",
			"-Easier charts",
			"",
			"",
			"Similar to normal but with",
			"easier patterns and some",
			"missing notes."
		],[
			"",
			"-Average note speeds",
			"-Full charts",
			"",
			"",
			"Equivalent to 'hard' mode",
			" in other friday night",
			"funkin mods."
		],[
			"",
			"-Fast note speeds",
			"-Charts to both characters",
			"-Charts to the instrumental",
			"",
			"For the 'hard' mode you",
			"may be used to, play",
			"on normal."
		],[
			"",
			"Available in the",
			"final release.",
		]
	];

	// Map visual assets
	var weekIcons:Array<FlxSprite>;
	var iconsHeights:Array<Float> = [0, 400, 100, 320, 230];

	// Misc
	var groupRight:FlxGroup;
	var groupLeft:FlxGroup;

	var exitingState:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	var borderL:FlxSprite; 
	var borderR:FlxSprite;

	var isDemo:Bool = true;

	// States
	var curState:String = 'weekSelect'; // Values: 'weekSelect', 'diffSelect'
	var inTransition:Bool = false;

	// Cameras
	private var camMAP:FlxCamera;
	private var camHUD:FlxCamera;
	private var camFollow:FlxObject;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		FlxG.cameras.bgColor = FlxColor.fromRGB(253, 232, 113);

		initializeElements();
		updateText();

		super.create();
	}

	override function update(elapsed:Float)
	{
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));
		scoreText.text = "WEEK SCORE: " + lerpScore;

		if (!exitingState && !inTransition) {
			
			if (FlxG.keys.justPressed.TAB && curState == 'weekSelect') {
				groupRight.visible = !groupRight.visible;
			}

			if (controls.ACCEPT) {
				switch (curState) {
					case 'weekSelect':
						curState = 'diffSelect';
						curDifficulty = 1;

						groupRight.visible = true;
						groupLeft.visible = true;
						noticeRight.visible = false;
						changeDifficulty(0);
						updateUI();

					case 'diffSelect':
						if (isDemo && curWeek < 2) {
							exitingState = true;
							// play menu character animation
							selectWeek();
						} else {
							FlxG.sound.play(Paths.sound("errorSound"));
						}
				}
			}

			if (controls.BACK) {
				switch (curState) {
					case 'weekSelect':
						if (!selectedWeek) {
							exitingState = true;
							FlxG.sound.play(Paths.sound('cancelMenu'));
							FlxG.switchState(new MainMenuState());
						}
					case 'diffSelect':
						curState = 'weekSelect';
						updateUI();
				}
			}

			// Left
				// Released
			if (controls.LEFT_R) {
				switch (curState) {
					case 'weekSelect':
						changeWeek(-1);

					case 'diffSelect':
						changeDifficulty(-1);
				}
			}

				// Held down
			if (controls.LEFT) {
				switch (curState) {
					case 'weekSelect':
						leftArrowWeek.animation.play('press');
					case 'diffSelect':
						leftArrowDiff.animation.play('press');
				}
			} else {
				leftArrowWeek.animation.play('idle');
				leftArrowDiff.animation.play('idle');
			}

			// Right
				// Released
			if (controls.RIGHT_R) {
				switch (curState) {
					case 'weekSelect':
						changeWeek(1);
						
					case 'diffSelect':
						changeDifficulty(1);
				}					
			}

				// Held Down
			if (controls.RIGHT) {
				switch (curState) {
					case 'weekSelect':
						rightArrowWeek.animation.play('press');
					case 'diffSelect':
						rightArrowDiff.animation.play('press');
				}			
			} else {
				rightArrowWeek.animation.play('idle');
				rightArrowDiff.animation.play('idle');
			}
		}

		// For reference, these override any other position (except the flxTween in the changeDifficulty() function)
		// The positions the below objects are instantiated at are cosmetic
		if (inTransition) {
			//Top Left
			sprDifficulty.x = bgTopLeft.x + 80;
			sprDifficulty.y = bgTopLeft.y + 75;

			leftArrowDiff.x = sprDifficulty.x - 66;
			leftArrowDiff.y = sprDifficulty.y - 9;

			rightArrowDiff.x = sprDifficulty.x + sprDifficulty.width + 12;
			rightArrowDiff.y = sprDifficulty.y - 9;

			diffDescTxt.x = bgTopLeft.x - 54;
			diffDescTxt.y = bgTopLeft.y + 164;
			
			// Bottom Left
			tracksHeader.x = bgBottomLeft.x + 68;
			tracksHeader.y = bgBottomLeft.y + 30;
			
			txtTracklist.x = bgBottomLeft.x + 37;
			txtTracklist.y = bgBottomLeft.y + 68;
		}

		super.update(elapsed);
	}

	private function selectWeek()
	{
		if (stopspamming == false)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));

			stopspamming = true;
		}

		PlayState.storyPlaylist = weekData[curWeek];
		PlayState.isStoryMode = true;
		selectedWeek = true;

		var diffic = "";

		switch (curDifficulty)
		{
			case 0:
				diffic = '-easy';
			case 2:
				diffic = '-hard';
		}

		PlayState.storyDifficulty = curDifficulty;

		PlayState.SONG = Song.loadFromJson(StringTools.replace(PlayState.storyPlaylist[0]," ", "-").toLowerCase() + diffic, StringTools.replace(PlayState.storyPlaylist[0]," ", "-").toLowerCase());
		PlayState.storyWeek = curWeek;
		PlayState.campaignScore = 0;
		PlayState.weekRating = 0;
		PlayState.oppOpinion = 0;
			
		var hasMovie = CutsceneState.checkForCutscene(PlayState.isStoryMode, PlayState.storyPlaylist[0]);

		// Decide next state
		if (hasMovie && FlxG.save.data.playCutscene == true) {
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new CutsceneState(), true);
			});
		} else {
			new FlxTimer().start(1.5, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	private function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (isDemo && curWeek > 1) {
			diffDescTxt.text = "";
			diffDescTxt.text += "                                        \n";

			var infoData = diffData[3];
			for (i in 0...infoData.length)
				diffDescTxt.text += infoData[i] + "\n";
		} else {
			if (curDifficulty < 0) {
				animateDiff = false;
				curDifficulty = 0;
			} else if (curDifficulty > 2) {
				animateDiff = false;
				curDifficulty = 2;
			} else animateDiff = true;

			switch (curDifficulty)
			{
				case 0:
					sprDifficulty.animation.play('easy');
				case 1:
					sprDifficulty.animation.play('normal');
				case 2:
					sprDifficulty.animation.play('hard');
			}

			// animated difficulty text
			if (animateDiff) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				sprDifficulty.y =  bgTopLeft.y + 50;
				sprDifficulty.alpha = 0;
				FlxTween.tween(sprDifficulty, {y: bgTopLeft.y + 75, alpha: 1}, 0.07);
			}

			updateText(curState);
		}

		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}

	private function changeWeek(change:Int = 0):Void
	{
		// Change week value
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = weekData.length - 1;
		else if (curWeek < 0)
			curWeek = 0;
		else FlxG.sound.play(Paths.sound('scrollMenu'));

		curStage = curWeek - 1;
		if (curStage < 0) curStage = 0;

		// Update UI
		updateText(curState);
		weekPrev.animation.play('week' + curWeek);
		weekTitle.animation.play('week' + curWeek);

		updateCamFollow();
		if (curWeek == 0)
			leftArrowWeek.visible = false;
		else {
			leftArrowWeek.visible = true;
			leftArrowWeek.x = weekIcons[curStage].x - 60;
			leftArrowWeek.y = weekIcons[curStage].y + 80;
		}
		if (curWeek == weekData.length - 1)
			rightArrowWeek.visible = false;
		else {
			rightArrowWeek.visible = true;
			rightArrowWeek.x = weekIcons[curStage].x + weekIcons[0].width + 60;
			rightArrowWeek.y = weekIcons[curStage].y + 80;
		}

		if (isDemo && curWeek > 1) {
			difficultySelectors.visible = false;
			sprDifficulty.visible = false;
		} else {
			difficultySelectors.visible = true;
			sprDifficulty.visible = true;
		}
	}

	private function updateText(state:String = 'weekSelect')
	{
		// Any line where an amount of spaces is added onto the text
		// of a FlxText object is for centering the text of that object.
		switch (state) {
			case 'weekSelect':
				// Tracks
				var tracklistData:Array<String> = weekData[curWeek];

				txtTracklist.text = "";
				txtTracklist.text += "                    \n";
				if (curWeek == 0) txtTracklist.text += "\n";

				for (i in tracklistData)
					txtTracklist.text += "\n" + StringTools.replace(i, "-", " ");

				txtTracklist.text += "\n";
				
				// Description
				var curDesc:Array<String> = weekDescriptions[curWeek];

				weekDesc.text = "";
				weekDesc.text += "                                      \n";
				
				for (i in 0...curDesc.length)
					weekDesc.text += "\n" + curDesc[i];

				weekDesc.text += "\n";

			case 'diffSelect':
				diffDescTxt.text = "";
				
				diffDescTxt.text += "                                        \n";

				var infoData = diffData[curDifficulty];
				for (i in 0...infoData.length)
					diffDescTxt.text += infoData[i] + "\n";
		}

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}

	private function initializeElements()
	{
		var ui_tex = Paths.getSparrowAtlas('storymenu/StoryMenuAssets');

		// Camera related
		camFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2, 1, 1);

		camMAP = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camMAP);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camMAP];
		FlxG.camera.follow(camFollow, LOCKON, 0.13 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));

		// Map assets
		var map = new FlxSprite(940, 0);
		map.loadGraphic(Paths.image('storymenu/map'));
		add(map);

		weekIcons = new Array<FlxSprite>();
		for (i in 1...weekData.length) {
			var lvlIcon = new FlxSprite(140 + 1200 * i, iconsHeights[i]);
			lvlIcon.frames = ui_tex;
			lvlIcon.animation.addByPrefix('idle', 'Week' + i + 'Icon');
			lvlIcon.animation.play('idle');
			weekIcons.push(lvlIcon);
			
			add(lvlIcon);
		}

		leftArrowWeek = new FlxSprite(weekIcons[0].x - 60, weekIcons[0].y + 80);
		leftArrowWeek.frames = ui_tex;
		leftArrowWeek.animation.addByPrefix('idle', 'ArrowWeekL');
		leftArrowWeek.animation.addByPrefix('press', 'ArrowWeekPushL');
		leftArrowWeek.animation.play('idle');
		leftArrowWeek.visible = false;
		add(leftArrowWeek);

		rightArrowWeek = new FlxSprite(weekIcons[0].x + weekIcons[0].width + 60, weekIcons[0].y + 80);
		rightArrowWeek.frames = ui_tex;
		rightArrowWeek.animation.addByPrefix('idle', 'ArrowWeekR');
		rightArrowWeek.animation.addByPrefix('press', 'ArrowWeekPushR');
		rightArrowWeek.animation.play('idle');
		add(rightArrowWeek);

		updateCamFollow();

		// Groups
		groupRight = new FlxGroup();
		groupRight.cameras = [camHUD];
		add(groupRight);

		groupLeft = new FlxGroup();
		groupLeft.cameras = [camHUD];
		add(groupLeft);
		
		// Right Section
		bgRight = new FlxSprite(FlxG.width * 0.481, 0);
		bgRight.loadGraphic(Paths.image("storymenu/bg_01"));
		bgRight.cameras = [camHUD];
		groupRight.add(bgRight);
		
		weekTitle = new FlxSprite(bgRight.x + 26, bgRight.y);
		weekTitle.frames = ui_tex;
		for (i in 0...weekData.length)
			weekTitle.animation.addByPrefix('week' + i, 'Week' + i + 'Title');
		weekTitle.animation.play('week0');
		weekTitle.cameras = [camHUD];
		groupRight.add(weekTitle);

		weekPrev = new FlxSprite(bgRight.x + 74, bgRight.y + 93);
		weekPrev.frames = ui_tex;
		weekPrev.animation.addByPrefix('week0', 'Week0Prev');
		weekPrev.animation.addByPrefix('week1', 'Week1Prev');
		weekPrev.animation.addByPrefix('week2', 'Week2Prev');
		weekPrev.animation.addByPrefix('week3', 'Week3Prev');
		weekPrev.animation.addByPrefix('week4', 'Week4Prev');
		weekPrev.animation.play('week0');
		weekPrev.cameras = [camHUD];
		groupRight.add(weekPrev);

		scoreText = new FlxText(weekPrev.x + 50, weekPrev.y + 293, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 24);
		scoreText.color = FlxColor.fromRGB(125, 125, 125);
		scoreText.alignment = CENTER;
		scoreText.cameras = [camHUD];
		groupRight.add(scoreText);

		noticeRight = new FlxText(scoreText.x + weekPrev.width - 18, scoreText.y + 3, 0, "[press TAB to\nhide this]\n", 16);
		noticeRight.setFormat("VCR OSD Mono", 13);
		noticeRight.color = FlxColor.fromRGB(125, 125, 125);
		noticeRight.alignment = CENTER;
		noticeRight.cameras = [camHUD];
		groupRight.add(noticeRight);

		weekDesc = new FlxText(bgRight.x + 34, bgRight.y + 372);
		weekDesc.setFormat("VCR OSD Mono", 24);
		weekDesc.alignment = CENTER;
		weekDesc.cameras = [camHUD];
		groupRight.add(weekDesc);

		// Difficulty assets (Top left section)
		bgTopLeft = new FlxSprite(FlxG.width * 0.072, FlxG.height * -0.675);
		bgTopLeft.loadGraphic(Paths.image("storymenu/bg_02"));
		bgTopLeft.cameras = [camHUD];
		groupLeft.add(bgTopLeft);

		difficultySelectors = new FlxGroup();
		difficultySelectors.cameras = [camHUD];
		groupLeft.add(difficultySelectors);
		
		sprDifficulty = new FlxSprite(bgTopLeft.x + 10, bgTopLeft.y + 60);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'Easy');
		sprDifficulty.animation.addByPrefix('normal', 'Normal');
		sprDifficulty.animation.addByPrefix('hard', 'Hard');
		sprDifficulty.animation.play('easy');

		difficultySelectors.add(sprDifficulty);

		leftArrowDiff = new FlxSprite(sprDifficulty.x - sprDifficulty.width + 60, sprDifficulty.y);
		leftArrowDiff.frames = ui_tex;
		leftArrowDiff.animation.addByPrefix('idle', "ArrowDiffL");
		leftArrowDiff.animation.addByPrefix('press', "ArrowDiffPushL");
		leftArrowDiff.animation.play('idle');
		difficultySelectors.add(leftArrowDiff);

		rightArrowDiff = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 55, sprDifficulty.y + 15);
		rightArrowDiff.frames = ui_tex;
		rightArrowDiff.animation.addByPrefix('idle', "ArrowDiffR");
		rightArrowDiff.animation.addByPrefix('press', "ArrowDiffPushR");
		rightArrowDiff.animation.play('idle');
		difficultySelectors.add(rightArrowDiff);

		diffDescTxt = new FlxText(bgTopLeft.x - 20, bgTopLeft.y - 15, 0, "difficulty", 16);
		diffDescTxt.alignment = CENTER;
		diffDescTxt.setFormat(Paths.font("vcr.ttf"), 24);
		diffDescTxt.color = FlxColor.WHITE;
		diffDescTxt.cameras = [camHUD];
		groupLeft.add(diffDescTxt);

		// Tracks section (Bottom left section)
		bgBottomLeft = new FlxSprite(FlxG.width * 0.072, FlxG.height * 1.4);
		bgBottomLeft.loadGraphic(Paths.image("storymenu/bg_03"));
		bgBottomLeft.cameras = [camHUD];
		groupLeft.add(bgBottomLeft);

		tracksHeader = new FlxSprite(bgBottomLeft.x + 68, bgBottomLeft.y + 30);
		tracksHeader.frames = ui_tex;
		tracksHeader.animation.addByPrefix('idle', 'Tracks');
		tracksHeader.animation.play('idle');
		tracksHeader.cameras = [camHUD];
		groupLeft.add(tracksHeader);
		
		txtTracklist = new FlxText(bgBottomLeft.x + 37, bgBottomLeft.y + 68, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.setFormat(Paths.font("vcr.ttf"), 32);
		txtTracklist.color = FlxColor.fromRGB(253, 232, 113);
		txtTracklist.cameras = [camHUD];
		groupLeft.add(txtTracklist);

		// Misc
		curState = 'weekSelect';
		
		borderL = new FlxSprite(FlxG.width * -0.055, -10);
		borderL.loadGraphic(Paths.image("storymenu/border_L"));
		borderL.cameras = [camHUD];
		add(borderL);
		
		borderR = new FlxSprite(FlxG.width * 0.968, -10);
		borderR.loadGraphic(Paths.image("storymenu/border_R"));
		borderR.cameras = [camHUD];
		add(borderR);

		changeDifficulty();
		updateText('diffSelect');
	}

	private function updateUI() {
		inTransition = true;

		// Code for transition
		switch (curState) {
			case 'weekSelect':
				FlxTween.tween(bgTopLeft, { y: FlxG.height * -0.675}, 0.66, { ease: FlxEase.cubeIn });
				new FlxTimer().start(0.22, function(tmr:FlxTimer) {
					FlxTween.tween(bgBottomLeft, { y: FlxG.height * 1.4 }, 0.44, { ease: FlxEase.cubeIn });
				});
				new FlxTimer().start(0.67, function(tmr:FlxTimer) {	noticeRight.visible = true;	});
			case 'diffSelect':
				FlxTween.tween(bgTopLeft, { y: -5}, 0.66, { ease: FlxEase.cubeIn });
				FlxTween.tween(bgBottomLeft, { y: FlxG.height * 0.64 }, 0.66, { ease: FlxEase.cubeOut });
		}
		
		new FlxTimer().start(0.67, function(tmr:FlxTimer) {
			inTransition = false;
		});
	}

	private function updateCamFollow() {
		camFollow.x = Math.max(weekIcons[curStage].x + weekIcons[curStage].width * 1.62, FlxG.width / 2);
	}
}

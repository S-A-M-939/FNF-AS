package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'gf';
	private var curIcon:HealthIcon;

	public var holdTimer:Float = 0;
	public var opinion:Int = 0;	// Only used if character is opponent

	public function new(x:Float, y:Float, ?character:String = 'gf', ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		var tex1:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'gf':
				var tex = Paths.getSparrowAtlas('characters/GIRLFRIEND', 'shared');
				frames = tex;

				trace(tex.frames.length);

				animation.addByPrefix('idle', 'GF idle dance', 24, false);
				animation.addByPrefix('singUP', 'GF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'GF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'GF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'GF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'GF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'GF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'GF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'GF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'GF HEY', 24, false);

				animation.addByPrefix('firstDeath', "GF dies", 24, false);
				animation.addByPrefix('deathLoop', "GF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "GF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'GF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;
				
			case 'bf':
				tex = Paths.getSparrowAtlas('characters/BF_assets');
				frames = tex;

				animation.addByPrefix('cheer', 'BF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'BF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'BF Right Note', 24, false);
				animation.addByPrefix('singUP', 'BF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'BF Down Note', 24, false);
				animation.addByIndices('sad', 'bf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'BF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'BF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

			case 'olga':
				tex = Paths.getSparrowAtlas('characters/Olga_assets', 'shared');
				frames = tex;

				animation.addByPrefix('idle', 'Olga Idle', 24);
				animation.addByPrefix('singUP', 'Olga Up', 24);
				animation.addByPrefix('singRIGHT', 'Olga Right', 24);
				animation.addByPrefix('singDOWN', 'Olga Down', 24);
				animation.addByPrefix('singLEFT', 'Olga Left', 24);

				addOffset('idle');

				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				playAnim('idle');

			case 'olga-swing':
				tex = Paths.getSparrowAtlas('characters/Olga_swing', 'shared');
				frames = tex;

				animation.addByPrefix('swing', 'Olga Swing', 24, false);

				addOffset('swing');

				playAnim('swing');
		}

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				default:
					playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function setIcon(icon:HealthIcon)
	{
		this.curIcon = icon;
	}
}

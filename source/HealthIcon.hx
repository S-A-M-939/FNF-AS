package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	var isDystopian:Bool;

	public function new(char:String = 'bf', isPlayer:Bool = false, opinion:Int = 0, dystopian:Bool = false)
	{
		super();

		// To note, bf represents the player (so gf in this case).
		// And gf represents the character on the speakers (so bf).
		// Hence why their file names are swapped
		// Why in the world are their names not abstracted, do you know how confusing it is?
		
		loadGraphic(Paths.image('healthIcons/$char'), true, 150, 150);
		this.isDystopian = dystopian;
		antialiasing = true;

		// Determines which row from the character's icons texture is used
		// Centered on mid row of texture for opponent
		// Hand picked for player
		var row:Int;

		if (!isDystopian) {
			if (isPlayer) {
				switch (PlayState.SONG.player2) {
					case 'No spoilers':
						row = 1;
					default:
						row = 0;
				}			
				animation.add(char, [3 * row, 3 * row + 1, 3 * row + 2], 0, false, isPlayer);
			}
			else {
				if (char != 'gf') { // Again, gf here refers to bf, so don't say it's confusing, because it totally isn't
					row = opinion + 1; // Top row if opinion negative, mid if neutral, bottom if positive
					animation.add(char, [3 * row + 2, 3 * row + 1, 3 * row + 0], 0, false, isPlayer);
				} else animation.add(char, [2, 1, 0], 0, false, isPlayer); // bf only has 3 icons, default to them, otherwise game crashes.
			}
		} else animation.add(char, [0], 0, false, isPlayer); // dystopian characters have 1 icon, default to it, otherwise game crashes.
		animation.play(char);

		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function setIcon(index:Int):Void
	{
		if (!isDystopian) animation.curAnim.curFrame = index;
		else { 
			animation.curAnim.curFrame = 0;
			alpha = 0;
		}
	}
}

package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class CharacterSetting
{
	public var x(default, null):Int;
	public var y(default, null):Int;
	public var scale(default, null):Float;
	public var flipped(default, null):Bool;

	public function new(x:Int = 0, y:Int = 0, scale:Float = 1.0, flipped:Bool = false)
	{
		this.x = x;
		this.y = y;
		this.scale = scale;
		this.flipped = flipped;
	}
}

class MenuCharacter extends FlxSprite
{
	private static var settings:Map<String, CharacterSetting> = [
		'bf' => new CharacterSetting(35, 0, 1.0, true),
		'gf' => new CharacterSetting(25, -60, 1.0, true),
		'olga' => new CharacterSetting(40, 77, 0.9),
		'j' => new CharacterSetting(40, 77, 0.9),
		'oliver' => new CharacterSetting(40, 77, 0.9),
		'scrow' => new CharacterSetting(40, 77, 0.9),
	];

	private var flipped:Bool = false;

	public function new(x:Int, y:Int, scale:Float, flipped:Bool)
	{
		super(x, y);
		this.flipped = flipped;

		antialiasing = true;

		frames = Paths.getSparrowAtlas('campaign_menu_UI_characters');

		//Girlfriend
		animation.addByPrefix('bf', "GF idle", 24);
		animation.addByPrefix('bfConfirm', "GF HEY!!", 24, false);
		//Boyfriend
		animation.addByPrefix('gf', "BF idle", 24);
		animation.addByPrefix('gfConfirm', 'BF HEY!!', 24, false);
		
		//Opponents
		animation.addByPrefix('olga', "Olga idle", 24);
		animation.addByPrefix('j', "Olga idle", 24);
		animation.addByPrefix('oliver', "Olga idle", 24);
		animation.addByPrefix('scrow', "Olga idle", 24);

		setGraphicSize(Std.int(width * scale));
		updateHitbox();
	}

	public function setCharacter(character:String):Void
	{
		if (character == '')
		{
			visible = false;
			return;
		}
		else
		{
			visible = true;
		}

		animation.play(character);

		var setting:CharacterSetting = settings[character];
		offset.set(setting.x, setting.y);
		setGraphicSize(Std.int(width * setting.scale));
		flipX = setting.flipped != flipped;
	}
}

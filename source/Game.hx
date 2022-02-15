package;

import flixel.FlxG;

class Game
{
	public static inline final NUMLEVELS = 8;
	public static var gameTime:Float = 0;

	public static function playSound(sound:String)
	{
		#if desktop
		var prefix = '.ogg';
		#else
		var prefix = '.mp3';
		#end
		FlxG.sound.play(sound + prefix);
	}
}

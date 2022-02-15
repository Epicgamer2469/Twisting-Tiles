package objects;

import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;

class Powerup extends FlxSprite
{
	var emitter:FlxEmitter;

	public var reverse:Bool = false;

	public function new(x, y, emitter, reverse = false)
	{
		super(x, y);

		this.emitter = emitter;
		this.reverse = reverse;

		if (!reverse)
		{
			loadGraphic('assets/images/powerup.png');
			flipX = true;
		}
		else
		{
			loadGraphic('assets/images/powerupR.png');
		}
	}

	override function kill()
	{
		emitter.visible = true;
		emitter.start(true);
		super.kill();
	}
}

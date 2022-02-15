package objects;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using echo.FlxEcho;

class JumpPad extends FlxSprite
{
	var bounceTween:FlxTween;
	var dir:String = 'up';
	var mult:Float = 1;

	public function new(x, y, width, height, direction, mult)
	{
		super(x, y);

		makeGraphic(width, height, FlxColor.CYAN);
		immovable = true;

		dir = direction;
		this.mult = mult;

		switch (dir)
		{
			case 'up':
				origin.y = height;
			case 'left':
				origin.x = width;
			case 'down':
				origin.y = 0;
			case 'right':
				origin.x = 0;
		}
	}

	public function bounce(player:Player, pad:JumpPad)
	{
		switch (dir)
		{
			case 'up':
				player.get_body().velocity.y = -456 * mult;
			case 'left':
				player.get_body().velocity.x = -456 * mult;
			case 'down':
				player.get_body().velocity.y = 456 * mult;
			case 'right':
				player.get_body().velocity.x = 456 * mult;
		}
		if (bounceTween != null)
			bounceTween.cancel();
		this.scale.x = 1.25;
		this.scale.y = .75;
		bounceTween = FlxTween.tween(this.scale, {x: 1, y: 1}, 0.65, {ease: FlxEase.elasticOut});
	}
}

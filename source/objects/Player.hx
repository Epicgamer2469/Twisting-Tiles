package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;

using Math;
using echo.FlxEcho;
using flixel.util.FlxArrayUtil;
using flixel.util.FlxSpriteUtil;
using hxmath.math.Vector2;

class Player extends FlxSprite
{
	var emitter:FlxEmitter;

	public function new(x:Float, y:Float, emitter:FlxEmitter)
	{
		super(x, y);
		loadGraphic('assets/images/player.png');
		this.add_body({
			shape: {type: CIRCLE, radius: 7},
			drag_x: 64
		});
		this.emitter = emitter;
	}

	override function update(elapsed:Float)
	{
		controls();

		super.update(elapsed);
	}

	function controls()
	{
		var body = this.get_body();
		switch (PlayState.instance.curAngle)
		{
			case 0 | 360:
				if (FlxG.keys.pressed.LEFT)
				{
					body.velocity.x -= 10;
				}
				if (FlxG.keys.pressed.RIGHT)
				{
					body.velocity.x += 10;
				}
				if (FlxG.keys.justPressed.UP && isTouching(DOWN))
				{
					body.velocity.y -= 275;
					Game.playSound('assets/sounds/jump');
				}
				body.rotational_velocity = body.velocity.x * 4;
			case 270:
				if (FlxG.keys.pressed.LEFT)
				{
					body.velocity.y -= 10;
				}
				if (FlxG.keys.pressed.RIGHT)
				{
					body.velocity.y += 10;
				}
				if (FlxG.keys.justPressed.UP && isTouching(LEFT))
				{
					Game.playSound('assets/sounds/jump');
					body.velocity.x += 275;
				}
				body.rotational_velocity = body.velocity.y * 4;
			case 90:
				if (FlxG.keys.pressed.LEFT)
				{
					body.velocity.y += 10;
				}
				if (FlxG.keys.pressed.RIGHT)
				{
					body.velocity.y -= 10;
				}
				if (FlxG.keys.justPressed.UP && isTouching(LEFT))
				{
					Game.playSound('assets/sounds/jump');
					body.velocity.x -= 275;
				}
				body.rotational_velocity = -body.velocity.y * 4;
			case 180:
				if (FlxG.keys.pressed.LEFT)
				{
					body.velocity.x += 10;
				}
				if (FlxG.keys.pressed.RIGHT)
				{
					body.velocity.x -= 10;
				}
				if (FlxG.keys.justPressed.UP && isTouching(UP))
				{
					Game.playSound('assets/sounds/jump');
					body.velocity.y += 275;
				}
				body.rotational_velocity = -body.velocity.x * 4;
		}
	}

	override function kill()
	{
		if (!alive)
			return;
		emitter.setPosition(this.x, this.y);
		emitter.visible = true;
		emitter.start(true);
		super.kill();
	}
}

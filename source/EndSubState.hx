package;

import echo.FlxEcho;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

class EndSubState extends FlxSubState
{
	var curSelected:Int = 0;
	var emitter:CustomColorEmitter;

	public function new()
	{
		super();

		Game.playSound('assets/sounds/confetti');

		cameras = [PlayState.instance.hudCam];

		if (PlayState.instance.rotateTwn != null)
			PlayState.instance.rotateTwn.active = false;

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x80000000);

		bg.cameras = [PlayState.instance.hudCam];

		var timeTxt = new FlxText(0, 0, 0, 'Thanks for\nplaying!\n\n' + FlxStringUtil.formatTime(Game.gameTime, true), 60);
		timeTxt.alignment = CENTER;
		timeTxt.screenCenter();
		timeTxt.setBorderStyle(OUTLINE, 0xFF000000, 3);
		timeTxt.alpha = 0;
		timeTxt.y -= 175;
		timeTxt.scale.set(.8, .8);
		FlxTween.tween(timeTxt, {
			y: timeTxt.y + 50,
			alpha: 1,
			'scale.x': 1,
			'scale.y': 1
		}, 1.5, {ease: FlxEase.cubeOut});

		var txt = new FlxText(0, 0, 0, 'Press ENTER to return\nto main menu', 35);
		txt.alignment = CENTER;
		txt.color = FlxColor.GRAY;
		txt.screenCenter();
		txt.y = timeTxt.y + timeTxt.height + 200;
		txt.alpha = 0;
		FlxTween.tween(txt, {
			y: txt.y - 75,
			alpha: 1
		}, 1.5, {ease: FlxEase.cubeOut, startDelay: .5});

		add(bg);
		add(timeTxt);
		add(txt);

		emitter = new CustomColorEmitter(FlxG.width / 2, -60, 200);
		emitter.makeParticles(5, 5, 200);
		emitter.lifespan.set(10);
		add(emitter);
		emitter.acceleration.start.min.x = -50;
		emitter.acceleration.start.max.x = 50;
		emitter.acceleration.start.min.y = 150;
		emitter.acceleration.start.max.y = 200;
		emitter.start();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER)
		{
			Game.playSound('assets/sounds/confirm');
			PlayState.instance.remove(PlayState.instance.transition);
			add(PlayState.instance.transition);
			PlayState.instance.transition.close(() ->
			{
				FlxG.switchState(new MenuState());
			});
		}
	}
}

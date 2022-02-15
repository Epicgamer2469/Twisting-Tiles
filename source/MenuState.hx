package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import objects.Player;

class MenuState extends FlxState
{
	var transition:Transition;

	override function create()
	{
		super.create();

		FlxG.mouse.visible = false;

		Game.gameTime = 0;
		PlayState.levelNum = 1;

		FlxMouseEventManager.init();

		var bg = new FlxSprite().loadGraphic('assets/images/menu.png');

		var title = new FlxSprite(0, 50).loadGraphic('assets/images/title.png');
		title.alpha = 0;
		title.screenCenter(X);

		var txt = new FlxText(0, 0, 0, 'Press ENTER to start!', 32);
		txt.screenCenter(X);
		txt.y = title.y + title.height + 115;
		txt.alpha = 1;

		FlxTween.tween(title, {y: title.y + 50, alpha: 1}, 1.5, {ease: FlxEase.cubeOut});
		FlxTween.tween(txt, {y: txt.y + 35}, 1.75, {ease: FlxEase.sineInOut, type: PINGPONG});

		transition = new Transition();
		transition.open(() -> {});

		add(bg);
		add(title);
		add(txt);
		add(transition);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER)
		{
			transition.close(() ->
			{
				PlayState.fromLevelSel = true;
				FlxG.switchState(new LevelSelect());
			});
		}
	}
}

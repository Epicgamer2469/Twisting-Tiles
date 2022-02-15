package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import objects.Player;

class LevelSelect extends FlxState
{
	var transition:Transition;

	var levels = new FlxTypedGroup<FlxSprite>();
	var colorTwn:Array<FlxTween> = [];

	override function create()
	{
		super.create();

		Game.gameTime = 0;

		FlxG.mouse.visible = true;

		var bg = new FlxSprite().loadGraphic('assets/images/menu.png');

		var txt = new FlxText(0, 12, 0, 'Click on a level to play it!', 32);
		txt.screenCenter(X);

		var xLevel:Int = 0;
		var yLevel:Int = 0;
		for (i in 0...Game.NUMLEVELS)
		{
			if (i % 4 == 0 && i != 0)
			{
				yLevel++;
				xLevel = 0;
			}
			var level = new FlxSprite(24 + ((128 + 28) * xLevel), 70 + ((128 + 28) * yLevel)).loadGraphic('assets/images/levelSelect/level_${i + 1}.png');
			level.color = 0xFF9c9c9c;
			level.ID = i + 1;
			FlxMouseEventManager.add(level, buttonClick, null, buttonOver, buttonOut);
			levels.add(level);
			xLevel++;
		}

		transition = new Transition();
		transition.open(() -> {});

		add(bg);
		add(txt);
		add(levels);
		add(transition);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function buttonClick(level:FlxSprite)
	{
		PlayState.levelNum = level.ID;
		PlayState.fromLevelSel = true;
		transition.close(() ->
		{
			FlxG.switchState(new PlayState());
		});
	}

	function buttonOver(level:FlxSprite)
	{
		Game.playSound('assets/sounds/pause');
		if (colorTwn[level.ID - 1] != null)
			colorTwn[level.ID - 1].cancel();
		colorTwn[level.ID - 1] = FlxTween.color(level, .15, level.color, 0xFFffffff);
	}

	function buttonOut(level:FlxSprite)
	{
		if (colorTwn[level.ID - 1] != null)
			colorTwn[level.ID - 1].cancel();
		colorTwn[level.ID - 1] = FlxTween.color(level, .15, level.color, 0xFF9c9c9c);
	}
}

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
import flixel.util.FlxColor;

class PauseSubState extends FlxSubState
{
	var selections = ['Resume', 'Restart Level', 'Main Menu'];
	var selectionG = new FlxTypedGroup<FlxText>();

	var curSelected:Int = 0;

	public function new()
	{
		super();

		FlxG.mouse.visible = true;

		cameras = [PlayState.instance.hudCam];

		if (PlayState.instance.rotateTwn != null)
			PlayState.instance.rotateTwn.active = false;

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x80000000);

		bg.cameras = [PlayState.instance.hudCam];

		for (s in 0...selections.length)
		{
			var text = new FlxText(0, 0, 0, selections[s], 32);
			text.screenCenter(X);
			text.y = FlxG.height / selections.length + (50 * s);
			text.ID = s;
			text.cameras = [PlayState.instance.hudCam];
			FlxMouseEventManager.add(text, buttonClick, null, buttonOver, buttonOut);
			selectionG.add(text);
		}

		add(bg);
		add(selectionG);
		changeSel();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			close();
			Game.playSound('assets/sounds/pause');
		}

		if (FlxG.keys.justPressed.UP)
		{
			curSelected--;
			changeSel();
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			curSelected++;
			changeSel();
		}
		if (FlxG.keys.anyJustPressed([SPACE, ENTER]))
		{
			switch (curSelected)
			{
				case 0:
					Game.playSound('assets/sounds/pause');
					close();
				case 1:
					Game.playSound('assets/sounds/confirm');
					PlayState.instance.remove(PlayState.instance.transition);
					add(PlayState.instance.transition);
					PlayState.instance.transition.close(() ->
					{
						FlxG.switchState(new PlayState());
					});
				case 2:
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

	function changeSel()
	{
		Game.playSound('assets/sounds/pause');
		curSelected = FlxMath.wrap(curSelected, 0, selections.length - 1);
		for (text in selectionG)
		{
			if (text.ID == curSelected)
				text.color = 0xfcd31c;
			else
				text.color = 0xffffff;
		}
	}

	function buttonClick(text:FlxText)
	{
		switch (text.ID)
		{
			case 0:
				Game.playSound('assets/sounds/pause');
				close();
			case 1:
				Game.playSound('assets/sounds/confirm');
				PlayState.instance.remove(PlayState.instance.transition);
				add(PlayState.instance.transition);
				PlayState.instance.transition.close(() ->
				{
					FlxG.switchState(new PlayState());
				});
			case 2:
				Game.playSound('assets/sounds/confirm');
				PlayState.instance.remove(PlayState.instance.transition);
				add(PlayState.instance.transition);
				PlayState.instance.transition.close(() ->
				{
					FlxG.switchState(new MenuState());
				});
		}
	}

	override function close()
	{
		FlxG.mouse.visible = false;
		if (PlayState.instance.rotateTwn != null)
			PlayState.instance.rotateTwn.active = true;
		FlxMouseEventManager.removeAll();
		FlxEcho.instance.active = true;
		super.close();
	}

	function buttonOver(text:FlxText)
	{
		text.color = 0xfcd31c;
	}

	function buttonOut(text:FlxText)
	{
		text.color = 0xffffff;
	}
}

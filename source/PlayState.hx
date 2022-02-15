package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject.*;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import objects.JumpPad;
import objects.Player;
import objects.Powerup;

using Math;
using echo.FlxEcho;
using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	public var rotateTwn:FlxTween;

	public static var instance:PlayState;

	public static var fromLevelSel:Bool = false;

	public var curAngle:Float = 0;
	public var map:FlxOgmo3Loader;
	public var tilemap:FlxTilemap;

	public var gameCam:FlxCamera;
	public var hudCam:FlxCamera;

	var level:FlxGroup = new FlxGroup();
	var spikeGroup:FlxGroup = new FlxGroup();
	var powerGroup = new FlxTypedGroup<Powerup>();
	var jumpGroup = new FlxTypedGroup<JumpPad>();
	var emitG = new FlxTypedGroup<FlxEmitter>();

	var leaving:Bool = false;

	public static var levelNum:Int = 1;

	var canRotate:Bool = true;

	public var transition:Transition;

	var player:Player;
	var door:FlxSprite;

	var timeTxt:FlxText;

	var transSound:FlxSound;

	override function create()
	{
		instance = this;

		#if desktop
		transSound = new FlxSound().loadEmbedded('assets/sounds/transition.ogg');
		#else
		transSound = new FlxSound().loadEmbedded('assets/sounds/transition.mp3');
		#end
		transSound.persist = true;

		FlxG.watch.add(Game, 'gameTime');

		gameCam = new FlxCamera();
		hudCam = new FlxCamera();

		FlxG.cameras.add(gameCam);
		FlxG.cameras.add(hudCam);
		hudCam.bgColor.alpha = 0;

		FlxCamera.defaultCameras = [gameCam];

		timeTxt = new FlxText(3, 3, 0, '0:0.00', 16);
		timeTxt.setBorderStyle(OUTLINE, 0xFF000000, 1.5);
		timeTxt.cameras = [hudCam];
		add(timeTxt);

		transition = new Transition();
		transition.cameras = [hudCam];
		transition.open(() -> {});
		add(transition);

		map = new FlxOgmo3Loader('assets/data/twisting.ogmo', 'assets/data/levels/l$levelNum.json');
		tilemap = map.loadTilemap('assets/images/tiles.png', 'stage');

		gameCam.angle = 0;
		FlxEcho.init({
			width: tilemap.width,
			height: tilemap.height,
			gravity_y: 700
		}, true);

		for (x in 0...tilemap.widthInTiles)
		{
			for (y in 0...tilemap.heightInTiles)
			{
				if (tilemap.getTile(x, y) != 0)
				{
					var spr = tilemap.tileToSprite(x, y);
					spr.add_body({mass: 0});
					spr.add_to_group(level);
				}
			}
		}

		var spikes = map.loadTilemap('assets/images/halftiles.png', 'halfstage');
		for (x in 0...spikes.widthInTiles)
		{
			for (y in 0...spikes.heightInTiles)
			{
				var tile = spikes.getTile(x, y);
				if (tile != 0)
				{
					var ang:Int = 0;
					var offX:Int = 0;
					var offY:Int = 0;
					switch (tile)
					{
						case 1:
							offY = 4;
						case 2:
							ang = 270;
							offX = 4;
						case 3:
							ang = 180;
							offY = -4;
						case 4:
							ang = 90;
							offX = -4;
					}
					var spr = spikes.tileToSprite(x, y);
					spr.add_body({
						mass: 0,
						shape: {
							type: RECT,
							width: 16,
							height: 9,
							offset_y: offY,
							offset_x: offX,
							rotation: ang
						}
					});
					spr.add_to_group(spikeGroup);
				}
			}
		}

		var decals = map.loadDecals('decals', 'assets/images/decals');

		tilemap.destroy();
		spikes.destroy();
		var bg = new FlxSprite().loadGraphic('assets/images/bg.png');
		var v = new FlxSprite().loadGraphic('assets/images/vignette.png');
		var deathEmitter = new FlxEmitter();
		deathEmitter.makeParticles(2, 2, 0xFF584cb3, 25);
		deathEmitter.scale.set(.75, .75, 1.5, 1.5);
		deathEmitter.lifespan.set(1, 1.25);
		deathEmitter.alpha.set(1, 1, 0, 0);
		deathEmitter.angularVelocity.set(50, 60, 70, 80);
		deathEmitter.visible = false;
		player = new Player(36, 164, deathEmitter);
		player.listen(level);
		player.listen(spikeGroup, {
			stay: (a, b, c) ->
			{
				for (col in c)
				{
					if (player.alive)
					{
						player.kill();
						Game.playSound('assets/sounds/die');
						if (fromLevelSel)
							Game.gameTime = 0;
						new FlxTimer().start(.15, tmr -> transition.close(() ->
						{
							FlxG.switchState(new PlayState());
						}));
					}
				}
			}
		});
		map.loadEntities(placeEntities);
		add(bg);
		add(level);
		add(decals);
		add(spikeGroup);
		add(powerGroup);
		add(emitG);
		add(jumpGroup);
		add(door);
		add(deathEmitter);
		add(player);
		add(v);
		gameCam.zoom = 2;
		gameCam.scroll.set(-FlxG.width / 4, -FlxG.height / 4);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		Game.gameTime += elapsed;
		timeTxt.text = FlxStringUtil.formatTime(Game.gameTime, true);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxEcho.instance.active = false;
			openSubState(new PauseSubState());
		}

		if (canRotate && FlxG.keys.justPressed.R)
		{
			Game.playSound('assets/sounds/power1');
			rotateLevel();
		}

		if (!fromLevelSel)
		{
			if (player.alive && !leaving && player.overlaps(door) && levelNum < Game.NUMLEVELS)
			{
				transSound.play(true);
				leaving = true;
				transition.close(() ->
				{
					levelNum++;
					FlxG.switchState(new PlayState());
				});
			}

			if (player.alive && !leaving && player.overlaps(door) && levelNum == Game.NUMLEVELS)
			{
				leaving = true;
				FlxEcho.instance.active = false;
				openSubState(new EndSubState());
			}
		}
		else
		{
			if (player.alive && !leaving && player.overlaps(door))
			{
				transSound.play(true);
				leaving = true;
				transition.close(() ->
				{
					FlxG.switchState(new LevelSelect());
				});
			}
		}

		for (power in powerGroup)
		{
			if (power.alive && player.overlaps(power))
			{
				power.kill();
				if (power.reverse)
					Game.playSound('assets/sounds/power2');
				else
					Game.playSound('assets/sounds/power1');
				rotateLevel(power.reverse);
			}
		}

		if (FlxG.keys.justPressed.Y)
		{
			transition.close(() ->
			{
				FlxG.switchState(new PlayState());
			});
		}

		for (pad in jumpGroup)
		{
			FlxG.overlap(player, pad, pad.bounce);
		}
	}

	function placeEntities(entity:EntityData)
	{
		switch (entity.name)
		{
			case 'player':
				player.get_body().set_position(entity.x, entity.y);
			case 'door':
				door = new FlxSprite(entity.x, entity.y).makeGraphic(entity.width, entity.height, 0xFF151c26);
			case 'rotate':
				var emitter = new FlxEmitter(entity.x, entity.y);
				emitter.makeParticles(2, 2, 0xFF93b2f4, 25);
				emitter.scale.set(.75, .75, 1.5, 1.5);
				emitter.lifespan.set(.75, 1);
				emitter.alpha.set(1, 1, 0, 0);
				emitter.angularVelocity.set(20, 40, 25, 45);
				emitter.visible = false;
				var power = new Powerup(entity.x, entity.y, emitter);
				powerGroup.add(power);
				emitG.add(emitter);
			case 'rotateR':
				var emitter = new FlxEmitter(entity.x, entity.y);
				emitter.makeParticles(2, 2, 0xFFf49393, 25);
				emitter.scale.set(.75, .75, 1.5, 1.5);
				emitter.lifespan.set(.75, 1);
				emitter.alpha.set(1, 1, 0, 0);
				emitter.angularVelocity.set(20, 40, 25, 45);
				emitter.visible = false;
				var power = new Powerup(entity.x, entity.y, emitter, true);
				powerGroup.add(power);
				emitG.add(emitter);
			case 'jumpPad':
				var pad = new JumpPad(entity.x, entity.y, entity.width, entity.height, entity.values.direction, entity.values.mult);
				jumpGroup.add(pad);
			default:
				FlxG.log.add('Unrecognized actor type ${entity.name}');
		}
	}

	function rotateLevel(reverse:Bool = false)
	{
		player.get_body().velocity.x = 0;
		player.get_body().velocity.y = 0;
		canRotate = false;
		if (reverse)
			curAngle -= 90;
		else
			curAngle += 90;
		switch (curAngle)
		{
			case 90 | -270:
				FlxEcho.instance.world.gravity.y = 0;
				FlxEcho.instance.world.gravity.x = 700;
				player.get_body().drag.y = 256;
				player.get_body().max_velocity.y = 256;
				player.get_body().max_velocity.x = 0;
			case 180 | -180:
				FlxEcho.instance.world.gravity.y = -700;
				FlxEcho.instance.world.gravity.x = 0;
				player.get_body().drag.x = 256;
				player.get_body().max_velocity.x = 256;
				player.get_body().max_velocity.y = 0;
			case 270 | -90:
				FlxEcho.instance.world.gravity.y = 0;
				FlxEcho.instance.world.gravity.x = -700;
				player.get_body().drag.y = 256;
				player.get_body().max_velocity.y = 256;
				player.get_body().max_velocity.x = 0;
			case 360 | 0 | -360:
				FlxEcho.instance.world.gravity.y = 700;
				FlxEcho.instance.world.gravity.x = 0;
				player.get_body().drag.x = 256;
				player.get_body().max_velocity.x = 256;
				player.get_body().max_velocity.y = 0;
		}
		if (rotateTwn != null)
			rotateTwn.cancel();
		if (curAngle == 360 || curAngle == -360)
			rotateTwn = FlxTween.tween(gameCam, {angle: curAngle}, .5, {
				ease: FlxEase.cubeOut,
				onComplete: twn ->
				{
					canRotate = true;
					curAngle = 0;
					gameCam.angle = 0;
				}
			});
		else
			rotateTwn = FlxTween.tween(gameCam, {angle: curAngle}, .5, {
				ease: FlxEase.cubeOut,
				onComplete: twn ->
				{
					canRotate = true;
				}
			});
	}
}

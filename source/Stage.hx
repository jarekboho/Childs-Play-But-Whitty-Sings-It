package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Stage extends MusicBeatState
{
	public var curStage:String = '';
	public var camZoom:Float;
	public var hideLastBG:Bool = false;
	public var tweenDuration:Float = 2;
	public var toAdd:Array<Dynamic> = [];
	public var swagBacks:Map<String,
		Dynamic> = [];
	public var swagGroup:Map<String, FlxTypedGroup<Dynamic>> = [];
	public var animatedBacks:Array<FlxSprite> = [];
	public var layInFront:Array<Array<FlxSprite>> = [[], [], []];
	public var slowBacks:Map<Int,
		Array<FlxSprite>> = [];

	var wBg:FlxSprite;
	var nwBg:FlxSprite;
	var wstageFront:FlxSprite;

	public function new(daStage:String)
	{
		super();
		camZoom = 1.05;
		if (PlayStateChangeables.Optimize)
			return;

          	camZoom = 0.9;
            curStage = 'whitty';
            wBg = new FlxSprite(-500, -300).loadGraphic(Paths.image('whittyBack', 'bonusWeek'));
              wBg.antialiasing = true;
              wBg.scrollFactor.set(0.9, 0.9);
              wBg.active = false;

              wstageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('whittyFront', 'bonusWeek'));
              wstageFront.setGraphicSize(Std.int(wstageFront.width * 1.1));
              wstageFront.updateHitbox();
              wstageFront.antialiasing = true;
              wstageFront.scrollFactor.set(0.9, 0.9);
              wstageFront.active = false;

					swagBacks['wBg'] = wBg;
					toAdd.push(wBg);
					swagBacks['wstageFront'] = wstageFront;
					toAdd.push(wstageFront);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function stepHit()
	{
		super.stepHit();

		if (!PlayStateChangeables.Optimize)
		{
			var array = slowBacks[curStep];
			if (array != null && array.length > 0)
			{
				if (hideLastBG)
				{
					for (bg in swagBacks)
					{
						if (!array.contains(bg))
						{
							var tween = FlxTween.tween(bg, {alpha: 0}, tweenDuration, {
								onComplete: function(tween:FlxTween):Void
								{
									bg.visible = false;
								}
							});
						}
					}
					for (bg in array)
					{
						bg.visible = true;
						FlxTween.tween(bg, {alpha: 1}, tweenDuration);
					}
				}
				else
				{
					for (bg in array)
						bg.visible = !bg.visible;
				}
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (FlxG.save.data.distractions && animatedBacks.length > 0)
		{
			for (bg in animatedBacks)
				bg.animation.play('idle', true);
		}
	}
}
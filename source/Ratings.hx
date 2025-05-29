import flixel.FlxG;

class Ratings
{
	public static function GenerateLetterRank(accuracy:Float)
	{
		var ranking:String = "N/A";
		if (FlxG.save.data.botplay && !PlayState.loadRep)
			ranking = "BotPlay";

		if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods == 0)
			ranking = "(MFC)";
		else if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods >= 1)
			ranking = "(GFC)";
		else if (PlayState.misses == 0)
			ranking = "(FC)";
		else if (PlayState.misses < 10)
			ranking = "(SDCB)";
		else
			ranking = "(Clear)";

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935,
			accuracy >= 99.980,
			accuracy >= 99.970,
			accuracy >= 99.955,
			accuracy >= 99.90,
			accuracy >= 99.80,
			accuracy >= 99.70,
			accuracy >= 99,
			accuracy >= 96.50,
			accuracy >= 93,
			accuracy >= 90,
			accuracy >= 85,
			accuracy >= 80,
			accuracy >= 70,
			accuracy >= 60,
			accuracy < 60
		];

		for (i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch (i)
				{
					case 0:
						ranking += " AAAAA";
					case 1:
						ranking += " AAAA:";
					case 2:
						ranking += " AAAA.";
					case 3:
						ranking += " AAAA";
					case 4:
						ranking += " AAA:";
					case 5:
						ranking += " AAA.";
					case 6:
						ranking += " AAA";
					case 7:
						ranking += " AA:";
					case 8:
						ranking += " AA.";
					case 9:
						ranking += " AA";
					case 10:
						ranking += " A:";
					case 11:
						ranking += " A.";
					case 12:
						ranking += " A";
					case 13:
						ranking += " B";
					case 14:
						ranking += " C";
					case 15:
						ranking += " D";
				}
				break;
			}
		}

		if (accuracy == 0)
			ranking = "N/A";
		else if (FlxG.save.data.botplay && !PlayState.loadRep)
			ranking = "BotPlay";

		return ranking;
	}

	public static var timingWindows = [];

	public static function judgeNote(noteDiff:Float)
	{
		var diff = Math.abs(noteDiff);
		for (index in 0...timingWindows.length)
		{
			var time = timingWindows[index];
			var nextTime = index + 1 > timingWindows.length - 1 ? 0 : timingWindows[index + 1];
			if (diff < time && diff >= nextTime)
			{
				switch (index)
				{
					case 0:
						return "shit";
					case 1:
						return "bad";
					case 2:
						return "good";
					case 3:
						return "sick";
				}
			}
		}
		return "good";
	}

	public static function CalculateRanking(score:Int, scoreDef:Int, nps:Int, maxNPS:Int, accuracy:Float):String
	{
		return (FlxG.save.data.npsDisplay ?
			"NPS: "
			+ nps
			+ " (Max "
			+ maxNPS
			+ ")"
			+ (!PlayStateChangeables.botPlay || PlayState.loadRep ? " | " : "") : "") +
			(!PlayStateChangeables.botPlay
				|| PlayState.loadRep ? "Score:" + (Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score) +
					(FlxG.save.data.accuracyDisplay ?
						" | Combo Breaks:"
						+ PlayState.misses
						+
						" | Accuracy:"
						+ (PlayStateChangeables.botPlay && !PlayState.loadRep ? "N/A" : HelperFunctions.truncateFloat(accuracy, 2) + " %")
						+
						" | "
						+ GenerateLetterRank(accuracy) : "") : "");
	}
}

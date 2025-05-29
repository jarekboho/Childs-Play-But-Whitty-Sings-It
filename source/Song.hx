package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Event
{
	public var name:String;
	public var position:Float;
	public var value:Float;
	public var type:String;

	public function new(name:String, pos:Float, value:Float, type:String)
	{
		this.name = name;
		this.position = pos;
		this.value = value;
		this.type = type;
	}
}

typedef SongData =
{
	@:deprecated
	var ?song:String;

	var songName:String;

	var songId:String;

	var chartVersion:String;
	var notes:Array<SwagSection>;
	var eventObjects:Array<Event>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var ?validScore:Bool;
	var ?offset:Int;
}

typedef SongMeta =
{
	var ?offset:Int;
	var ?name:String;
}

class Song
{
	public static var latestChart:String = "KE1";

	public static function loadFromJsonRAW(rawJson:String)
	{
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}
		var jsonData = Json.parse(rawJson);

		return parseJSONshit("rawsong", jsonData, ["name" => jsonData.name]);
	}

	public static function loadFromJson(songId:String, difficulty:String):SongData
	{
		var songFile = '$songId/$songId$difficulty';

		var rawJson = Paths.loadJSON('songs/$songFile');
		var rawMetaJson = Paths.loadJSON('songs/$songId/_meta');

		return parseJSONshit(songId, rawJson, rawMetaJson);
	}

	public static function conversionChecks(song:SongData):SongData
	{
		var ba = song.bpm;

		var index = 0;
		trace("conversion stuff " + song.songId + " " + song.notes.length);
		var convertedStuff:Array<Song.Event> = [];

		if (song.eventObjects == null)
			song.eventObjects = [new Song.Event("Init BPM", 0, song.bpm, "BPM Change")];

		for (i in song.eventObjects)
		{
			var name = Reflect.field(i, "name");
			var type = Reflect.field(i, "type");
			var pos = Reflect.field(i, "position");
			var value = Reflect.field(i, "value");

			convertedStuff.push(new Song.Event(name, pos, value, type));
		}

		song.eventObjects = convertedStuff;

		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (i in song.eventObjects)
		{
			if (i.type == "BPM Change")
			{
				var beat:Float = i.position;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				TimingStruct.addTiming(beat, i.value, endBeat, 0);

				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					var step = ((60 / data.bpm) * 1000) / 4;
					TimingStruct.AllTimings[currentIndex].startStep = Math.floor(((data.endBeat / (data.bpm / 60)) * 1000) / step);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
				}

				currentIndex++;
			}
		}

		for (i in song.notes)
		{
			if (i.altAnim)
				i.CPUAltAnim = i.altAnim;

			var currentBeat = 4 * index;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				continue;

			var beat:Float = currentSeg.startBeat + (currentBeat - currentSeg.startBeat);

			if (i.changeBPM && i.bpm != ba)
			{
				trace("converting changebpm for section " + index);
				ba = i.bpm;
				song.eventObjects.push(new Song.Event("FNF BPM Change " + index, beat, i.bpm, "BPM Change"));
			}

			for (ii in i.sectionNotes)
			{
				if (song.chartVersion == null)
				{
					ii[3] = false;
					ii[4] = TimingStruct.getBeatFromTime(ii[0]);
				}

				if (ii[3] == 0)
					ii[3] == false;
			}

			index++;
		}

		song.chartVersion = latestChart;

		return song;
	}

	public static function parseJSONshit(songId:String, jsonData:Dynamic, jsonMetaData:Dynamic):SongData
	{
		var songData:SongData = cast jsonData.song;

		songData.songId = songId;

		if (songData.validScore == null)
			songData.validScore = true;

		var songMetaData:SongMeta = cast jsonMetaData;
		if (songMetaData.name != null)
		{
			songData.songName = songMetaData.name;
		}
		else
		{
			songData.songName = songId.split('-').join(' ');
		}

		songData.offset = songMetaData.offset != null ? songMetaData.offset : 0;

		return Song.conversionChecks(songData);
	}
}

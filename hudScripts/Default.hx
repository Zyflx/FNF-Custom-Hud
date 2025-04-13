import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

import backend.Difficulty;

var infoText: FlxText;
var judgementCounter: FlxText;
var songWatermark: FlxText;
var versionWatermark: FlxText;

final ranks: Array<Dynamic> = [
    [100, 'S+'],
    [95, 'S'],
    [90, 'A'],
    [85, 'B+'],
    [80, 'B'],
    [75, 'C+'],
    [70, 'C'],
    [65, 'D+'],
    [60, 'D']
];

function onCreatePost():Void {
    final down: Bool = ClientPrefs.data.downScroll;
    final font: String = Paths.font('PhantomMuff.ttf');

    scoreTxt.kill();
    if(cpuControlled) botplayTxt.font = font;

    timeBar.angle = 90;
    timeBar.leftToRight = false;
    timeBar.setColors(FlxColor.BLACK, FlxColor.WHITE);
    timeBar.x = (FlxG.width - timeBar.width) + 180;
    timeBar.screenCenter(0x10);

    timeTxt.x = timeBar.x - 50;
    timeTxt.font = font;
    timeTxt.screenCenter(0x10);

    infoText = uiGroup.add(new FlxText(15, down ? 15 : FlxG.height - 115, 0, 'Score: 0\nMisses: 0\nAccuracy: 0%\nRating: N/A', 22));
    infoText.setFormat(font, 22, FlxColor.WHITE, 'left', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    infoText.active = false;
    infoText.antialiasing = true;
    infoText.borderSize = 2;

    judgementCounter = uiGroup.add(new FlxText(15, 0, 0, 'Sick: 0\nGood: 0\nBad: 0\nShit: 0\nCombo: 0', 22));
    judgementCounter.setFormat(font, 22, FlxColor.WHITE, 'left', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    judgementCounter.active = false;
    judgementCounter.antialiasing = true;
    judgementCounter.borderSize = 2;
    judgementCounter.screenCenter(0x10);

    songWatermark = uiGroup.add(new FlxText(15, down ? FlxG.height - 30 : 15, 0, '', 22));
    songWatermark.setFormat(font, 22, FlxColor.WHITE, 'left', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    songWatermark.active = false;
    songWatermark.antialiasing = true;
    songWatermark.borderSize = 2;
    songWatermark.text = StringTools.replace(PlayState.SONG.song, '-', ' ') + ' - ' + Difficulty.getString().toUpperCase();

    versionWatermark = uiGroup.add(new FlxText(0, down ? FlxG.height - 30 : 15, 0, 'Custom Hud REWRITE - v0.1', 22));
    versionWatermark.setFormat(font, 22, FlxColor.WHITE, 'left', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    versionWatermark.active = false;
    versionWatermark.antialiasing = true;
    versionWatermark.borderSize = 2;
    versionWatermark.x = (FlxG.width - versionWatermark.width) - 15;

    game.updateIconsScale = (delta: Float) -> {
        final lerpVal: Float = Math.exp(-delta * 20.0);
        final lerpP1: Float = FlxMath.lerp(1.0, iconP1.scale.x, lerpVal);
        final lerpP2: Float = FlxMath.lerp(1.0, iconP2.scale.x, lerpVal);

        iconP1.scale.set(lerpP1, lerpP1);
        iconP1.updateHitbox();

        iconP2.scale.set(lerpP2, lerpP2);
        iconP2.updateHitbox();

        iconP1.origin.set(30, 0);
        iconP2.origin.set(70, 0);
    }
}

function goodNoteHit(note: Note):Void {
    if(!note.isSustainNote)
        updateJudgementCounter();
}

function noteMiss(note: Note):Void {
    updateJudgementCounter();
}

function noteMissPress(column: Int):Void {
    updateJudgementCounter();
}

function onUpdateScore():Void {
    if(songHits <= 0) return;
    final accuracy: Float = FlxMath.roundDecimal(ratingPercent * 100, 2);
    final rank: String = getRank(accuracy);
    infoText.text = 'Score: ' + songScore + '\nMisses: ' + songMisses + '\nAccuracy: ' + (accuracy + '%') + '\nRating: ' + ratingName + (rank != '' ? ' (' + rank + ')' : '');
}

function updateJudgementCounter():Void {
    final sicks: Int = ratingsData[0].hits;
    final goods: Int = ratingsData[1].hits;
    final bads: Int = ratingsData[2].hits;
    final shits: Int = ratingsData[3].hits;
    judgementCounter.text = 'Sick: ' + sicks + '\nGood: ' + goods + '\nBad: ' + bads + '\nShit: ' + shits + '\nCombo: ' + combo;
}

function getRank(accuracy: Float):String {
    for(i in ranks) {
        if(i[0] <= accuracy)
            return i[1];
    }
    return accuracy == 0 ? '' : 'F';
}
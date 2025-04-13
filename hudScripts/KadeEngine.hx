import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

import objects.Bar;
import backend.Difficulty;
import states.MainMenuState;

// This kade ui is based on 1.4.2 with elements from other versions
// I could do 1.8 but i feel that the older versions of kade are more recognizable ui wise

var nps: Int = 0;
var maxNPS: Int = 0;
var noteHitArray: Array<Float> = [];

final ranks: Array<Dynamic> = [
    [99.9935, 'AAAAA'],
    [99.98, 'AAAA:'],
    [99.97, 'AAAA.'],
    [99.95, 'AAAA'],
    [99.9, 'AAA:'],
    [99.8, 'AAA.'],
    [99.7, 'AAA'],
    [99, 'AA:'],
    [96.5, 'AA.'],
    [93, 'AA'],
    [90, 'A:'],
    [85, 'A.'],
    [80, 'A'],
    [70, 'B'],
    [60, 'C']
];

var msText: FlxText;
var lastRating: String = '';
var msColors = ['sick' => FlxColor.CYAN, 'good' => FlxColor.GREEN, 'bad' => FlxColor.ORANGE, 'shit' => FlxColor.RED];
var msHitArray: Array<Float> = [];

function onCreatePost():Void {
    final down: Bool = ClientPrefs.data.downScroll;
    final font: String = Paths.font('vcr.ttf');

    for(i in 0...ratingsData.length)
        ratingsData[i].image = ['sick', 'good', 'bad', 'shit'][i] + '-kade';

    if(!ClientPrefs.data.middleScroll) {
        for(receptor in strumLineNotes)
            receptor.x -= 42;
    }

    timeBar.kill();
    timeTxt.kill();

    healthBar.y = down ? 50 : FlxG.height * 0.9;
    healthBar.setColors(FlxColor.RED, 0xFF66FF33);

    iconP1.y = healthBar.y - (iconP1.height * 0.5);
    iconP2.y = healthBar.y - (iconP2.height * 0.5);

    scoreTxt.size = 16;
    scoreTxt.fieldWidth = 0;
    scoreTxt.borderSize = 1;
    scoreTxt.setPosition(FlxG.width * 0.5 - 235, healthBar.y + 50);

    botplayTxt.size = 42;
    botplayTxt.borderSize = 4;
    botplayTxt.borderQuality = 2;
    botplayTxt.y = healthBar.y + (down ? 100 : -100);

    final watermark: FlxText = uiGroup.add(new FlxText(
        4, down ? FlxG.height * 0.9 + 45 : healthBar.y + 50, 0,
        PlayState.SONG.song + ' ' + Difficulty.getString() + ' - PE ' + MainMenuState.psychEngineVersion, 16
    ));
    watermark.setFormat(font, 16, FlxColor.WHITE, 'right', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    watermark.active = false;

    final positionBar: Bar = uiGroup.add(new Bar(0, down ? FlxG.height * 0.9 + 45 : 14, 'healthBar', () -> return songPercent));
    positionBar.setColors(FlxColor.LIME, FlxColor.GRAY);
    positionBar.screenCenter(0x01);

    final songText: FlxText = uiGroup.add(new FlxText(0, positionBar.y, 0, PlayState.SONG.song, 16));
    songText.setFormat(font, 16, FlxColor.WHITE, 'right', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    songText.screenCenter(0x01);
    songText.active = false;

    msText = uiGroup.add(new FlxText(0, 0, 0, '', 20));
    msText.setFormat(Paths.font('kadePixel.ttf'), 20, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    msText.active = false;
    msText.alpha = 0.0;
    msText.screenCenter();
    msText.x += ClientPrefs.data.comboOffset[0];
    msText.y += ClientPrefs.data.comboOffset[1];

    iconP1.autoAdjustOffset = iconP2.autoAdjustOffset = false;

    final initWidthP1: Float = iconP1.width;
    final initWidthP2: Float = iconP2.width;

    game.updateIconsScale = (delta: Float) -> {
        iconP1.setGraphicSize(Std.int(FlxMath.lerp(initWidthP1, iconP1.width, 0.5 / playbackRate)));
        iconP1.updateHitbox();
        iconP2.setGraphicSize(Std.int(FlxMath.lerp(initWidthP2, iconP2.width, 0.5 / playbackRate)));
        iconP2.updateHitbox();
    }
}

function onUpdatePost(delta: Float):Void {
    for(time in noteHitArray) {
        if(time < Conductor.songPosition) {
            noteHitArray.remove(time);
            nps -= 1;
            onUpdateScore();
        }
    }
    if(maxNPS < nps) maxNPS = nps;

    botplayTxt.alpha = 1.0;
    botplayTxt.visible = cpuControlled;
}

function goodNoteHit(note: Note):Void {
    if(cpuControlled)
        playerStrums.members[note.noteData].playAnim('static', true);

    if(!note.isSustainNote) {
        nps += 1;
        noteHitArray.push(note.strumTime + 1000.0);

        final ms: Float = Math.abs(Conductor.songPosition - note.strumTime + ClientPrefs.data.ratingOffset);
        msHitArray.push(ms);

        var total: Int = 0;
        for(time in msHitArray) total += time; 
        final msAverage: Float = FlxMath.roundDecimal(total / msHitArray.length, 3);

        msText.alpha = 1.0;
        msText.text = FlxMath.roundDecimal(ms, 3) + 'ms (' + msAverage + 'ms)';
        if(note.rating != lastRating) msText.color = msColors.get(note.rating);

        FlxTween.cancelTweensOf(msText);
        FlxTween.tween(msText, {alpha: 0.0}, 0.2 / playbackRate, {startDelay: Conductor.crochet * 0.001 / playbackRate});

        lastRating = note.rating;
    }
}

function opponentNoteHit(note: Note):Void {
    opponentStrums.members[note.noteData].playAnim('static', true);
}

function onUpdateScore():Void {
    final accuracy: Float = FlxMath.roundDecimal(ratingPercent * 100, 2);
    final rank: String = getRank(accuracy);
    scoreTxt.text = !cpuControlled ? ('NPS: ' + nps + ' (Max: ' + maxNPS + ') | Score: ' + songScore + ' | Combo Breaks: ' + songMisses + ' | Accuracy: ' + (accuracy + ' %') + ' | ' + (songHits != 0 ? '(' + StringTools.replace(ratingFC, 'SFC', 'MFC') + ') ' + rank : rank)) : 'NPS: ' + nps + ' (Max: ' + maxNPS + ')';
}

function onEvent(name: String):Void {
    if(name != 'Change Character') return;
    healthBar.setColors(FlxColor.RED, 0xFF66FF33);    
}

function getRank(accuracy: Float):String {
    for(i in ranks) {
        if(accuracy >= i[0])
            return i[1];
    }
    return accuracy == 0.0 ? 'N/A' : 'D';
}
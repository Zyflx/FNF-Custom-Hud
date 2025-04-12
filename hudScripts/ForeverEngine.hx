import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

import backend.Difficulty;
import states.MainMenuState;

var judgementCounter: FlxText;

final ranks: Array<Dynamic> = [
    [100, 'S+'],
    [95, 'S'],
    [90, 'A'],
    [85, 'B'],
    [80, 'C'],
    [75, 'D'],
    [70, 'E']
];

function onCreatePost():Void {
    final down: Bool = ClientPrefs.data.downScroll;
    final font: String = Paths.font('vcr.ttf');

    timeBar.kill();
    timeTxt.kill();

    healthBar.y = down ? 64 : FlxG.height * 0.875;
    healthBar.setColors(FlxColor.RED, 0xFF66FF33);

    iconP1.y = healthBar.y - (iconP1.height * 0.5);
    iconP2.y = healthBar.y - (iconP2.height * 0.5);

    scoreTxt.size = 16;
    scoreTxt.borderSize = 1.5;
    scoreTxt.y = Math.floor(healthBar.y + 40);

    final cornerMark: FlxText = uiGroup.add(new FlxText(0, 0, 0, 'PSYCH ENGINE v' + MainMenuState.psychEngineVersion, 16));
    cornerMark.setFormat(font, 16, FlxColor.WHITE);
    cornerMark.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5);
    cornerMark.active = false;
    cornerMark.antialiasing = true;
    cornerMark.borderSize = 1.5;
    cornerMark.setPosition(FlxG.width - (cornerMark.width + 5), 5);

    final centerMark: FlxText = uiGroup.add(new FlxText(
        0, down ? FlxG.height - 40 : 10, 0,
        '- ' + StringTools.replace(PlayState.SONG.song, '-', ' ') + ' [' + Difficulty.getString().toUpperCase() + '] -', 20)
    );
    centerMark.setFormat(font, 20, FlxColor.WHITE);
    centerMark.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5);
    centerMark.screenCenter(0x01);
    centerMark.active = false;
    centerMark.antialiasing = true;
    centerMark.borderSize = 2;

    judgementCounter = uiGroup.add(new FlxText(15, 0, 0, 'Sick: 0\nGood: 0\nBad: 0\nShit: 0\nMiss: 0', 20));
    judgementCounter.setFormat(font, 20, FlxColor.WHITE, 'left', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    judgementCounter.active = false;
    judgementCounter.antialiasing = true;
    judgementCounter.borderSize = 2;
    judgementCounter.screenCenter(0x10);    

    iconP1.autoAdjustOffset = iconP2.autoAdjustOffset = false;

    game.updateIconsScale = (delta: Float) -> {
        final lerpVal: Float = 1 - (0.15 * (60.0 / FlxG.drawFramerate)) / playbackRate;

        final lerpP1: Float = FlxMath.lerp(1.0, iconP1.scale.x, lerpVal);
        iconP1.scale.set(lerpP1, lerpP1);
        iconP1.updateHitbox();

        final lerpP2: Float = FlxMath.lerp(1.0, iconP2.scale.x, lerpVal);
        iconP2.scale.set(lerpP2, lerpP2);
        iconP2.updateHitbox();
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
    final div: String = ' • ';
    final comboDisp: String = (ratingFC != '' && ratingFC != 'Clear') ? ' [' + ratingFC + ']' : '';
    final accuracy: Float = FlxMath.roundDecimal(ratingPercent * 100, 2);
    scoreTxt.text = 'Score: ' + songScore + div + 'Accuracy: ' + (accuracy + '%') + comboDisp + div +
    'Combo Breaks: ' + songMisses + div + 'Rank: ' + getRank(accuracy);
}

function onEvent(name: String):Void {
    if(name != 'Change Character') return;
    healthBar.setColors(FlxColor.RED, 0xFF66FF33);    
}

function updateJudgementCounter():Void {
    final sicks: Int = ratingsData[0].hits;
    final goods: Int = ratingsData[1].hits;
    final bads: Int = ratingsData[2].hits;
    final shits: Int = ratingsData[3].hits;
    judgementCounter.text = 'Sick: ' + sicks + '\nGood: ' + goods + '\nBad: ' + bads + '\nShit: ' + shits + '\nMiss: ' + songMisses;
}

function getRank(acc: Float):String {
    for(i in ranks) {
        if(i[0] <= acc)
            return i[1];
    }
    return acc == 0.0 ? 'N/A' : 'F';
}
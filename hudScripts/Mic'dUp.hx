import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

import objects.Bar;

var nps: Int = 0;
var noteHitArray: Array<Float> = [];

var missTxt: FlxText;
var accuracyTxt: FlxText;
var npsTxt: FlxText;

function onCreatePost():Void {
    final down: Bool = ClientPrefs.data.downScroll;
    final font: String = Paths.font('vcr.ttf');

    timeBar.kill();
    timeTxt.kill();

    healthBar.y = down ? 50 : FlxG.height * 0.9;
    iconP1.y = healthBar.y - (iconP1.height * 0.5);
    iconP2.y = healthBar.y - (iconP2.height * 0.5);

    scoreTxt.fieldWidth = 0;
    scoreTxt.size = 20;
    scoreTxt.alignment = 'right';
    scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
    scoreTxt.setPosition(healthBar.x - healthBar.width * 0.5, down ? healthBar.y - 18 : healthBar.y + 26);
    
    if(cpuControlled) {
        botplayTxt.text  = 'AutoPlayCPU';
        botplayTxt.size = 20;
        botplayTxt.y = healthBar.y;
        botplayTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
    }

    missTxt = uiGroup.add(new FlxText(scoreTxt.x, scoreTxt.y + (down ? 26 : -26), 0, 'Misses: 0', 20));
    missTxt.setFormat(font, 20, FlxColor.WHITE, 'right');
    missTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
    missTxt.active = false;

    accuracyTxt = uiGroup.add(new FlxText(scoreTxt.x, missTxt.y + (down ? 26 : -26), 0, 'Accuracy: 0%', 20));
    accuracyTxt.setFormat(font, 20, FlxColor.WHITE, 'right');
    accuracyTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
    accuracyTxt.active = false;

    npsTxt = uiGroup.add(new FlxText(scoreTxt.x, accuracyTxt.y + (down ? 26 : -26), 0, 'NPS: 0', 20));
    npsTxt.setFormat(font, 20, FlxColor.WHITE, 'right');
    npsTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
    npsTxt.active = false;

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

    final initWidthP1: Float = iconP1.width;
    final initWidthP2: Float = iconP2.width;

    game.updateIconsScale = (delta: Float) -> {
        final lerpVal: Float = 0.09 / playbackRate;
        final divFPS: Float = ClientPrefs.data.framerate / 60.0;
        final lerpP1: Int = Std.int(FlxMath.lerp(iconP1.width, initWidthP1, lerpVal / divFPS));
        final lerpP2: Int = Std.int(FlxMath.lerp(iconP2.width, initWidthP2, lerpVal / divFPS));

        iconP1.setGraphicSize(lerpP1);
        iconP1.updateHitbox();

        iconP2.setGraphicSize(lerpP2);
        iconP2.updateHitbox();

        iconP1.origin.set(50, 0);
        iconP2.origin.set(80, 0);
    }

    addScriptAddon('Mic\'dUpRatings');
}

function onUpdatePost(delta: Float):Void {
    if(cpuControlled) botplayTxt.alpha = 1.0;
    iconP1.visible = iconP2.visible = !cpuControlled;

    for(time in noteHitArray) {
        if(time < Conductor.songPosition) {
            noteHitArray.remove(time);
            nps -= 1;
            updateNPS();
        }
    }
}

function goodNoteHit(note: Note):Void {
    if(!note.isSustainNote) {
        nps += 1;
        noteHitArray.push(note.strumTime + 1000.0);
        updateNPS();
    }
}

function onUpdateScore():Void {
    scoreTxt.text = 'Score: ' + songScore;
    if(songHits == 0) return;
    missTxt.text = 'Misses: ' + songMisses;
    accuracyTxt.text = 'Accuracy: ' + FlxMath.roundDecimal(ratingPercent * 100, 2) + '%';
}

function updateNPS():Void {
    npsTxt.text = 'NPS: ' + nps;
}
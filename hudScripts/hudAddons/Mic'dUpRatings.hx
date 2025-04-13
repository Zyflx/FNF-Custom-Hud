import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

game.showRating = game.showCombo = game.showComboNum = false;

var isPixel: Bool;
var antialias: Bool;
var msText: FlxText;
var lastRating: String = '';
var msColors = ['sick' => FlxColor.CYAN, 'good' => FlxColor.GREEN, 'bad' => FlxColor.RED, 'shit' => FlxColor.RED];

function onCreatePost():Void {
    isPixel = PlayState.isPixelStage;
    antialias = isPixel ? false : ClientPrefs.data.antialiasing;

    msText = uiGroup.add(new FlxText(0, 0, 0, '', 20));
    msText.setFormat(Paths.font('kadePixel.ttf'), 20, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    msText.active = false;
    msText.alpha = 0.0;
}

function goodNoteHit(note: Note):Void {
    if(!note.isSustainNote) {
        final rating: FlxSprite = spawnRating(note.rating, note.strumTime);
        final ms: Float = Math.abs(Conductor.songPosition - note.strumTime + ClientPrefs.data.ratingOffset);

        msText.alpha = 1.0;
        msText.text = FlxMath.roundDecimal(ms, 3) + 'ms';
        msText.setPosition(rating.x + 90, rating.y + 100);
        if(note.rating != lastRating) msText.color = msColors.get(note.rating);

        FlxTween.cancelTweensOf(msText);
        FlxTween.tween(msText, {alpha: 0.0}, 0.2 / playbackRate, {startDelay: Conductor.crochet * 0.001 / playbackRate});

        lastRating = note.rating;
    }
}

function spawnRating(rating: String, time: Float):FlxSprite {
    final ratingPath: String = (isPixel ? 'pixelUI/' : '') + rating + (isPixel ? '-pixel' : '');
    final scale: Float = (isPixel ? 6 : 1) * 0.7;
    final numScale: Float = isPixel ? 6 : 0.5;

    final rating: FlxSprite = new FlxSprite(650, 320).loadGraphic(Paths.image(ratingPath));
    rating.scale.set(scale, scale);
    rating.updateHitbox();
    rating.cameras = [camHUD];
    rating.antialiasing = antialias;
    rating.acceleration.y = 550 * playbackRate * playbackRate;
    rating.velocity.set(-FlxG.random.int(0, 10), -FlxG.random.int(140, 175));
    insert(members.indexOf(uiGroup), rating);

    FlxTween.tween(rating, {alpha: 0.0}, 0.2 / playbackRate, {
        startDelay: Conductor.crochet * 0.001,
        onComplete: _ -> rating.destroy()
    });

    final diff: Float = Math.abs(Conductor.songPosition - time + ClientPrefs.data.ratingOffset) / playbackRate;

    var timing: String = if(diff < Conductor.safeZoneOffset * 0.1) 'early';
    else if(diff > Conductor.safeZoneOffset * -0.1) 'late';
    else '';

    final timingPath: String = (isPixel ? 'pixelUI/' : '') + timing + (isPixel ? '-pixel' : '');

    if(timing != '') {
        final timingSpr: FlxSprite = new FlxSprite(rating.x - 80, rating.y + 80).loadGraphic(Paths.image(timingPath));
        timingSpr.scale = rating.scale;
        timingSpr.updateHitbox();
        timingSpr.acceleration.y = rating.acceleration.y;
        timingSpr.velocity = rating.velocity;
        timingSpr.cameras = [camHUD];
        timingSpr.antialiasing = antialias;
        insert(members.indexOf(uiGroup), timingSpr);

        FlxTween.tween(timingSpr, {alpha: 0.0}, 0.2 / playbackRate, {
            startDelay: Conductor.crochet * 0.001,
            onComplete: _ -> timingSpr.destroy()
        });
    }

    final sepScore: String = StringTools.lpad(combo + '', '0', 3);
    var loop: Int = 0;

    for(i in 0...sepScore.length) {
        final numPath: String = (isPixel ? 'pixelUI/' : '') + 'num' + sepScore.charAt(i) + (isPixel ? '-pixel' : '');

        final num: FlxSprite = new FlxSprite().loadGraphic(Paths.image(numPath));
        num.x = rating.x + (43 * loop) - 40;
        num.y = rating.y + 180;
        num.cameras = [camHUD];
        num.antialiasing = antialias;
        num.scale.set(numScale, numScale);
        num.updateHitbox();
        num.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
        num.velocity.set(FlxG.random.float(-5, 5) * playbackRate, -FlxG.random.int(140, 160) * playbackRate);
        insert(members.indexOf(uiGroup), num);

        FlxTween.tween(num, {alpha: 0.0}, 0.2 / playbackRate, {
            startDelay: Conductor.crochet * 0.002,
            onComplete: _ -> num.destroy()
        });

        loop += 1;
    }

    return rating;
}
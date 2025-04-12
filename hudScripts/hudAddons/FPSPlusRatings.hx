// unlike the ui, these are based on the latest fps version.

game.showRating = game.showComboNum = game.showCombo = false;

function goodNoteHit(note: Note):Void {
    if(!note.isSustainNote)
        spawnRating(note.rating);
}

function spawnRating(rating: String):Void {
    final scale: Float = !PlayState.isPixelStage ? 0.7 : 4.2;
    final ratingPath: String = (PlayState.isPixelStage ? 'pixelUI/' : '') + rating + (PlayState.isPixelStage ? '-pixel' : '');

    final rating: FlxSprite = new FlxSprite(boyfriend.x, boyfriend.y + -50).loadGraphic(Paths.image(ratingPath));
    rating.antialiasing = PlayState.isPixelStage ? false : ClientPrefs.data.antialiasing;
    rating.scale.set(scale, scale);
    rating.updateHitbox();
    rating.x -= rating.width * 0.5;
    rating.y -= rating.height * 0.5;
    rating.acceleration.y = 250 * playbackRate * playbackRate;
    rating.velocity.set(-FlxG.random.int(-5, 5) * playbackRate, -FlxG.random.int(100, 130) * playbackRate);
    add(rating);

    FlxTween.tween(rating, {alpha: 0.0}, 0.2 / playbackRate, {
        startDelay: Conductor.crochet * 0.001 / playbackRate,
        onComplete: _ -> rating.destroy()
    });

    spawnComboNum();
}

function spawnComboNum():Void {
    final comboSplit: String = (combo + '').split('');
    final scale: Float = !PlayState.isPixelStage ? 0.6 : 4.8;
    var width: Float = 0.0;

    for(i in 0...comboSplit.length) {
        final comboNumPath: String = (PlayState.isPixelStage ? 'pixelUI/' : '') + 'num' + comboSplit[i] + (PlayState.isPixelStage ? '-pixel' : '');

        final digit: FlxSprite = new FlxSprite(((boyfriend.x + -175) + width + (5 * i)), boyfriend.y + 5).loadGraphic(Paths.image(comboNumPath));
        width += digit.width * scale;
        digit.antialiasing = PlayState.isPixelStage ? false : ClientPrefs.data.antialiasing;
        digit.scale.set(scale, scale);
        digit.updateHitbox();
        digit.acceleration.y = FlxG.random.int(150, 250) * playbackRate * playbackRate;
        digit.velocity.set(FlxG.random.int(-5, 5) * playbackRate, -FlxG.random.int(100, 130) * playbackRate);
        add(digit);

        FlxTween.tween(digit, {alpha: 0.0}, 0.2 / playbackRate, {
            startDelay: Conductor.crochet * 0.001 / playbackRate,
            onComplete: _ -> digit.destroy()
        });
    }
}
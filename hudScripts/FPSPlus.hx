// Based on pre-vslice content update FPS Plus.

function onCreatePost():Void {
    timeBar.kill();
    timeTxt.kill();

    scoreTxt.size = 22;
    scoreTxt.y = FlxG.height * 0.9 + 36;

    final initWidthP1: Int = iconP1.width;
    final initWidthP2: Int = iconP2.width;

    game.updateIconsScale = (delta: Float) -> {
        iconP1.setGraphicSize(Std.int(initWidthP1 * iconP1.scale.x));
        iconP1.updateHitbox();

        iconP2.setGraphicSize(Std.int(initWidthP2 * iconP2.scale.x));
        iconP2.updateHitbox();

        iconP1.origin.set(80, 0);
        iconP2.origin.set(50, 0);
    }

    addScriptAddon('FPSPlusRatings');
}

function onUpdateScore():Void {
    scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Accuracy: ' + FlxMath.roundDecimal(ratingPercent * 100, 2) + '%';
}

function onBeatHit():Void {
    iconP1.scale.set(1.25, 1.25);
    iconP1.updateHitbox();

    iconP2.scale.set(1.25, 1.25);
    iconP2.updateHitbox();

    FlxTween.cancelTweensOf(iconP1);
    FlxTween.cancelTweensOf(iconP2);

    FlxTween.tween(iconP1.scale, {x: 1, y: 1}, 0.2 / playbackRate, {ease: FlxEase.quintOut});
    FlxTween.tween(iconP2.scale, {x: 1, y: 1}, 0.2 / playbackRate, {ease: FlxEase.quintOut});
}
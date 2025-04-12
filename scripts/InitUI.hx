function onCreate():Void {
    final hudType: String = getModSetting('CustomHUD_hudType', 'FNF-Custom-Hud');
    game.initHScript(Paths.getPath('hudScripts/' + StringTools.replace(hudType, ' ', '') + '.hx'));
}
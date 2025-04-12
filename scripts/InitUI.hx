function onCreate():Void {
    final hudType: String = getModSetting('CustomHUD_hudType', 'FNF-Custom-Hud');
    game.initHScript(Paths.getPath('hudScripts/' + StringTools.replace(hudType, ' ', '') + '.hx'));
    game.setOnHScript('addScriptAddon', (name: String) -> addScriptAddon(name));
}

function addScriptAddon(name: String):Void {
    game.initHScript(Paths.getPath('hudScripts/hudAddons/' + name + '.hx'));
}
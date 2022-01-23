import flixel.FlxG;
import flixel.FlxState;

import flixel.util.FlxColor;

import lime.app.Application;

class CutsceneState extends FlxState
{
    public static var _isStoryMode:Bool;
    private static var _isWeekCutscene:Bool;

    // private var cutscene:Cutscene;

    // Hardcoded which stages/weeks have cutscenes
    private static var stagesWithCutscenes:Array<String> = [];
    private static var weeksWithCutscenes:Array<Int> = [];
 
    private static var _cutsceneName:String;

    override function create()
    {
        super.create();
		FlxG.cameras.bgColor = FlxColor.BLACK;

        goToNextState();

        // if (_cutsceneName != 'null') {
        //     // cutscene = new Cutscene(_cutsceneName, goToNextState);
        //     cutscene.scrollFactor.set();
        //     FlxG.sound.music.stop();
        //     add(cutscene);
        // } else {
        //     Application.current.window.alert('Error in loading cutscene.\nGiven cutscene name: $_cutsceneName');
        //     FlxG.switchState(new MainMenuState());
        // }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    // Used before loading a PlayState
    public static function checkForCutscene(isStory:Bool, nextStage:String):Bool
    {
        if (!isStory)
            return false;
        if (nextStage != "null") {  //  Song cutscene
            if (!stagesWithCutscenes.contains(StringTools.replace(nextStage," ", "-").toLowerCase())) return false;
            _isWeekCutscene = false;
        } else {                    // Week cutscene
            if (!weeksWithCutscenes.contains(PlayState.storyWeek)) return false;
            _isWeekCutscene = true;
        }

        initializeCutscene(isStory, nextStage.toLowerCase());
        return true;
    }

    // Used directly when loading a cutscene from the extras menu (to be made later)
    // Otherwise, called from the above function only
    public static function initializeCutscene(isStory:Bool, stage:String):Void
    {
        _isStoryMode = isStory;
        _cutsceneName = _isWeekCutscene ? getNameFromWeek(PlayState.storyWeek) : getNameFromStage(stage);
    }

    // Each cutscene is considered as 'tied' to a specific song, in that case, it has the song's name
    // A cutscene will play before the song it is tied to
    // Suppose a cutscene named 'rythmic-play'
    // This cutscene would play before the song of the same name when in story mode, or if loaded manually from the extras menu
    private static function getNameFromStage(stage:String):String
    {
        if (stage == 'null') // Won't happen, but better be on the safe side
            trace(' > Error with cutscene name from stage');
        return stage;
    } 
    // A cutscene can also be tied to a specific week, in that case, it has the week's name (as in week1, week2, etc...)
    // A cutscene that is tied to a week plays AFTER the WHOLE week is finished, or if loaded manually from the extras menu.
    private static function getNameFromWeek(week:Int):String
    {
        switch (week) {
            case 1:
                return 'week1';
            default:
                trace(' > Error with cutscene name from week');
                return 'null';
        }
    }

    private function goToNextState():Void
    {
        if (_isStoryMode) {
            if (_isWeekCutscene) {
                FlxG.sound.music.stop();
                FlxG.switchState(new MainMenuState());
            }
            else
                FlxG.switchState(new PlayState());
        }
        else {
            FlxG.sound.music.stop();
            LoadingState.loadAndSwitchState(new MainMenuState());
        }
    }

}
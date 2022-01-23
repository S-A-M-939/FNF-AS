import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;

class DemoInfoState extends FlxState {
    
    private static var N:Int;

    override public function create() {

        var info:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('DemoInfo/Info' + N, 'shared'));
        info.screenCenter(X);
        add(info);

        super.create();
    }

    override public function update(elapsed:Float) {

        if (FlxG.keys.justPressed.ENTER)
            switch (N) {
                case 1:
                    FlxG.switchState(new MainMenuState());
                case 2:
                    FlxG.switchState(new StoryMenuState());
            }
    }

    public static function infoFromState(state:String) {
        switch (state) {
            case 'Title':
                N = 1;
            case 'DemoEnd':
                N = 2;
        }
    }

}
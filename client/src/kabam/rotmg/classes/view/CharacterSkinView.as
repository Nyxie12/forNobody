package kabam.rotmg.classes.view
{
import com.company.assembleegameclient.screens.AccountScreen;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import io.decagames.rotmg.ui.buttons.SliceScalingButton;
import io.decagames.rotmg.ui.defaults.DefaultLabelFormat;
import io.decagames.rotmg.ui.sliceScaling.SliceScalingBitmap;
import io.decagames.rotmg.ui.texture.TextureParser;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.game.view.CreditDisplay;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.ui.view.components.ScreenBase;
import org.osflash.signals.Signal;
import org.osflash.signals.natives.NativeMappedSignal;

public class CharacterSkinView extends Sprite
{


    private const base:ScreenBase = makeScreenBase();

    private const account:AccountScreen = makeAccountScreen();

    private const lines:Shape = makeLines();


    private const graphic:SliceScalingBitmap = makeScreenGraphic();

    private const playBtn:SliceScalingButton = makePlayButton();

    private const backBtn:SliceScalingButton = makeBackButton();

    private const list:CharacterSkinListView = makeListView();

    private const detail:ClassDetailView = makeClassDetailView();

    public const play:Signal = new NativeMappedSignal(playBtn,"click");

    public const back:Signal = new NativeMappedSignal(backBtn,"click");

    private var title:TextFieldDisplayConcrete;

    public function CharacterSkinView()
    {
        super();
    }

    private function makeScreenBase() : ScreenBase
    {
        var _loc1_:ScreenBase = new ScreenBase();
        addChild(_loc1_);
        return _loc1_;
    }

    private function makeAccountScreen() : AccountScreen
    {
        var _loc1_:AccountScreen = new AccountScreen();
        addChild(_loc1_);
        makeTitleText();
        return _loc1_;
    }

    private function makeTitleText() : void
    {
        this.title = new TextFieldDisplayConcrete().setSize(30).setColor(0xFFFFFF).setBold(true);
        this.title.setAutoSize(TextFieldAutoSize.CENTER);
        this.title.setBold(true);
        this.title.setStringBuilder(new LineBuilder().setParams("Skins"));
        this.title.filters = [new DropShadowFilter(0,0,0,1,8,8)];
        this.title.x = 400 - this.title.width / 2;
        this.title.y = 15;
        addChild(this.title);
    }

    private function makeLines() : Shape
    {
        var _loc1_:Shape = new Shape();
        _loc1_.graphics.clear();
        _loc1_.graphics.lineStyle(2,5526612);
        _loc1_.graphics.moveTo(0,105);
        _loc1_.graphics.lineTo(800,105);
        _loc1_.graphics.moveTo(346,105);
        _loc1_.graphics.lineTo(346,526);
        addChild(_loc1_);
        return _loc1_;
    }

    private function makeScreenGraphic() : SliceScalingBitmap
    {
        var _loc1_:SliceScalingBitmap = TextureParser.instance.getSliceScalingBitmap("UI","popup_header_title",800);
        _loc1_.y = 502.5;
        addChild(_loc1_);
        return _loc1_;
    }

        private function makePlayButton() : SliceScalingButton
        {
            var _loc1_:* = null;
            _loc1_ = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI","generic_green_button"));
            _loc1_.setLabel("Play",DefaultLabelFormat.questButtonCompleteLabel);
            _loc1_.width = 100;
            _loc1_.x = 350;
            _loc1_.y = 520;
            addChild(_loc1_);
            return _loc1_;
        }

        private function makeBackButton() : SliceScalingButton
        {
            var _loc1_:* = null;
            _loc1_ = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI","generic_green_button"));
            _loc1_.setLabel("Back",DefaultLabelFormat.questButtonCompleteLabel);
            _loc1_.width = 100;
            _loc1_.x = 90;
            _loc1_.y = 520;
            addChild(_loc1_);
            return _loc1_;
        }

        private function makeListView() : CharacterSkinListView
        {
            var _loc1_:* = null;
            _loc1_ = new CharacterSkinListView();
            _loc1_.x = 351;
            _loc1_.y = 110;
            addChild(_loc1_);
            return _loc1_;
        }

        private function makeClassDetailView() : ClassDetailView
        {
            var _loc1_:* = null;
        _loc1_ = new ClassDetailView();
        _loc1_.x = 5;
        _loc1_.y = 110;
        addChild(_loc1_);
        return _loc1_;
    }
}
}

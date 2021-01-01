package com.company.assembleegameclient.screens.charrects
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.DropShadowFilter;
import io.decagames.rotmg.ui.buttons.SliceScalingButton;
import io.decagames.rotmg.ui.texture.TextureParser;
import kabam.rotmg.assets.services.IconFactory;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

public class BuyCharacterRect extends CharacterRect
{

    public static const BUY_CHARACTER_RECT_CLASS_NAME_TEXT:String = "BuyCharacterRect.classNameText";


    private var model:PlayerModel;

    public function BuyCharacterRect(param1:PlayerModel)
    {
        super();
        this.model = param1;
        super.color = 2039583;
        super.overColor = 4342338;
        className = new LineBuilder().setParams("BuyCharacterRect.classNameText",{"nth":param1.getMaxCharacters() + 1});
        super.init();
        this.makeIcon();
        this.makePriceText();
        this.makeCurrency();
    }

    private function makeCurrency() : void
    {
        var _loc2_:BitmapData = this.model.getCharSlotCurrency() == 0?IconFactory.makeCoin():IconFactory.makeFame();
        var _loc1_:Bitmap = new Bitmap(_loc2_);
        var _loc3_:* = 0.8;
        _loc1_.scaleY = _loc3_;
        _loc1_.scaleX = _loc3_;
        _loc1_.x = 130 + 52 - 8;
        _loc1_.y = 38;
        selectContainer.addChild(_loc1_);
    }

    private function makePriceText() : void
    {
        var _loc1_:* = null;
        _loc1_ = new TextFieldDisplayConcrete().setSize(14).setColor(16777215).setAutoSize("right");
        _loc1_.setStringBuilder(new StaticStringBuilder(this.model.getCharSlotPrice().toString()));
        _loc1_.filters = [new DropShadowFilter(0,0,0,1,8,8)];
        _loc1_.x = 130 + 52 - 8;
        _loc1_.y = 38;
        selectContainer.addChild(_loc1_);
    }

    private function makeIcon() : void
    {
        var _loc1_:* = null;
        _loc1_ = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI","add_button"));
        _loc1_.x = 100;
        _loc1_.y = 18;
        addChild(_loc1_);
    }
}
}

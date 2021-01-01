package com.company.assembleegameclient.screens
{
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;
import io.decagames.rotmg.ui.sliceScaling.SliceScalingBitmap;
import io.decagames.rotmg.ui.texture.TextureParser;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

public class AccountLoadingScreen extends Sprite
{


    private var loadingText_:TextFieldDisplayConcrete;

    private var screenGraphic:SliceScalingBitmap;

    public function AccountLoadingScreen()
    {
        super();
        this.screenGraphic = TextureParser.instance.getSliceScalingBitmap("UI","popup_header_title",800);
        this.screenGraphic.y = 502.5;
        addChild(this.screenGraphic);
        this.loadingText_ = new TextFieldDisplayConcrete().setSize(30).setColor(16777215).setBold(true);
        this.loadingText_.setStringBuilder(new LineBuilder().setParams("Loading.text"));
        this.loadingText_.filters = [new DropShadowFilter(0,0,0,1,4,4)];
        this.loadingText_.setAutoSize("center").setVerticalAlign("middle");
        addChild(this.loadingText_);
        addEventListener("addedToStage",this.onAddedToStage);
    }

    protected function onAddedToStage(param1:Event) : void
    {
        removeEventListener("addedToStage",this.onAddedToStage);
        this.loadingText_.x = stage.stageWidth / 2;
        this.loadingText_.y = 540;
    }
}
}

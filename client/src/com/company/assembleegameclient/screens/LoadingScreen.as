package com.company.assembleegameclient.screens
{
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;
import io.decagames.rotmg.ui.sliceScaling.SliceScalingBitmap;
import io.decagames.rotmg.ui.texture.TextureParser;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.ui.view.components.ScreenBase;

public class LoadingScreen extends Sprite
{


    private var text:TextFieldDisplayConcrete;

    private var screenGraphic:SliceScalingBitmap;

    public function LoadingScreen()
    {
        this.text = new TextFieldDisplayConcrete();
        super();
        addChild(new ScreenBase());
        this.screenGraphic = TextureParser.instance.getSliceScalingBitmap("UI","popup_header_title",800);
        this.screenGraphic.y = 502.5;
        addChild(this.screenGraphic);
        this.text.setSize(30).setColor(16777215).setVerticalAlign("middle").setAutoSize("center").setBold(true);
        this.text.y = 540;
        addEventListener("addedToStage",this.onAdded);
        this.text.setStringBuilder(new LineBuilder().setParams("Loading.text"));
        this.text.filters = [new DropShadowFilter(0,0,0,1,4,4)];
        addChild(this.text);
    }

    private function onAdded(param1:Event) : void
    {
        removeEventListener("addedToStage",this.onAdded);
        this.text.x = stage.stageWidth / 2;
    }

    public function setTextKey(param1:String) : void
    {
        this.text.setStringBuilder(new LineBuilder().setParams(param1));
    }
}
}

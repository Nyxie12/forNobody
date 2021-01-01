package com.company.assembleegameclient.screens.charrects
{
import com.company.rotmg.graphics.StarGraphic;
import com.company.util.AssetLibrary;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.ColorTransform;
import io.decagames.rotmg.ui.sliceScaling.SliceScalingBitmap;
import io.decagames.rotmg.ui.texture.TextureParser;
import io.decagames.rotmg.utils.colors.Tint;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.StringBuilder;

public class CharacterRect extends Sprite
{

    public static const WIDTH:int = 760;

    public static const HEIGHT:int = 70;


    public var color:uint;

    public var overColor:uint;

    private var box:SliceScalingBitmap;

    protected var maxedText:TextFieldDisplayConcrete;

    protected var taglineClassIcon:Sprite;

    protected var taglineClassText:TextFieldDisplayConcrete;

    protected var taglineFameIcon:Bitmap;

    protected var taglineFameText:TextFieldDisplayConcrete;

    protected var classNameText:TextFieldDisplayConcrete;

    protected var className:StringBuilder;

    public var selectContainer:Sprite;

    protected var maxed:StringBuilder;

    protected var maxedColor:uint;

    public function CharacterRect()
    {
        super();
    }

    protected static function makeDropShadowFilter() : Array
    {
        return [new DropShadowFilter(0,0,0,1,8,8)];
    }

    public function init() : void
    {
        tabChildren = false;
        this.makeBox();
        this.makeContainer();
        this.makeClassNameText();
        this.addEventListeners();
    }

    private function addEventListeners() : void
    {
        addEventListener("mouseOver",this.onMouseOver);
        addEventListener("rollOut",this.onRollOut);
    }

    public function makeBox() : void
    {
        this.box = TextureParser.instance.getSliceScalingBitmap("UI","popup_header_title",760);
        this.box.height = 70;
        this.box.x = 0;
        this.box.y = 0;
        addChild(this.box);
    }

    protected function onMouseOver(param1:MouseEvent) : void
    {
        this.drawBox(true);
    }

    protected function onRollOut(param1:MouseEvent) : void
    {
        this.drawBox(false);
    }

    private function drawBox(param1:Boolean) : void
    {
        if(param1)
        {
            Tint.add(this.box,13224393,0.2);
        }
        else
        {
            this.box.transform.colorTransform = new ColorTransform();
        }
        this.box.scaleX = 1;
        this.box.scaleY = 1;
        this.box.x = 0;
        this.box.y = 0;
    }

    public function makeContainer() : void
    {
        this.selectContainer = new Sprite();
        this.selectContainer.mouseChildren = false;
        this.selectContainer.buttonMode = true;
        this.selectContainer.graphics.beginFill(16711935,0);
        this.selectContainer.graphics.drawRect(0,0,760,70);
        addChild(this.selectContainer);
    }

    protected function makeClassNameText() : void
    {
        this.classNameText = new TextFieldDisplayConcrete().setSize(18).setColor(16777215);
        this.classNameText.setBold(true);
        this.classNameText.setStringBuilder(this.className);
        this.classNameText.filters = makeDropShadowFilter();
        this.classNameText.x = 130 + 13;
        this.classNameText.y = 17;
        this.selectContainer.addChild(this.classNameText);
    }

    protected function makeMaxedText() : void
    {
        this.maxedText = new TextFieldDisplayConcrete().setSize(13).setColor(maxedColor).setBold(true);
        this.maxedText.setStringBuilder(this.maxed);
        this.maxedText.filters = makeDropShadowFilter();
        this.maxedText.x = 130 + 195;
        this.maxedText.y = 20;
        this.selectContainer.addChild(this.maxedText);
    }

    protected function makeTagline(param1:StringBuilder, param2:StringBuilder = null, param3:Boolean = false) : void
    {
        this.taglineClassIcon = new StarGraphic();
        this.taglineClassIcon.transform.colorTransform = !!param3?new ColorTransform(1,1,0):new ColorTransform(0.701960784313725,0.701960784313725,0.701960784313725);
        this.taglineClassIcon.scaleX = 0.9;
        this.taglineClassIcon.scaleY = 0.9;
        this.taglineClassIcon.x = 130 + 13;
        this.taglineClassIcon.y = 40;
        this.taglineClassIcon.filters = [new DropShadowFilter(0,0,0)];
        this.selectContainer.addChild(this.taglineClassIcon);
        this.taglineClassText = new TextFieldDisplayConcrete().setSize(14).setColor(!!param3?16776960:11776947);
        this.taglineClassText.setStringBuilder(param1);
        this.taglineClassText.filters = makeDropShadowFilter();
        this.taglineClassText.x = 130 + 13;
        this.taglineClassText.y = 38;
        this.selectContainer.addChild(this.taglineClassText);
        if(param2 != null)
        {
            this.taglineFameIcon = new Bitmap(AssetLibrary.getImageFromSet("lofiInterfaceBig",30));
            this.taglineFameIcon.transform.colorTransform = new ColorTransform(0.701960784313725,0.701960784313725,0.701960784313725);
            this.taglineFameIcon.filters = [new DropShadowFilter(0,0,0)];
            this.taglineFameIcon.x = 130 + 65;
            this.taglineFameIcon.y = 38;
            this.selectContainer.addChild(this.taglineFameIcon);
            this.taglineFameText = new TextFieldDisplayConcrete().setSize(14).setColor(11776947);
            this.taglineFameText.setStringBuilder(param2);
            this.taglineFameText.filters = makeDropShadowFilter();
            this.taglineFameText.x = 130 + 65 + 4;
            this.taglineFameText.y = 38;
            this.selectContainer.addChild(this.taglineFameText);
        }
    }
}
}

﻿package com.company.assembleegameclient.screens
{
import com.company.assembleegameclient.appengine.CharacterStats;
import com.company.assembleegameclient.appengine.SavedCharacter;
import com.company.assembleegameclient.ui.tooltip.ClassToolTip;
import com.company.assembleegameclient.ui.tooltip.ToolTip;
import com.company.assembleegameclient.util.FameUtil;
import com.company.rotmg.graphics.StarGraphic;
import com.company.util.AssetLibrary;
import com.gskinner.motion.GTween;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.ColorTransform;
import io.decagames.rotmg.ui.sliceScaling.SliceScalingBitmap;
import io.decagames.rotmg.ui.texture.TextureParser;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.util.components.LegacyBuyButton;
import org.osflash.signals.natives.NativeSignal;

public class CharacterBox extends Sprite
{

    public static const DELETE_CHAR:String = "DELETE_CHAR";

    public static const ENTER_NAME:String = "ENTER_NAME";

    private static const fullCT:ColorTransform = new ColorTransform(0.8,0.8,0.8);

    private static const emptyCT:ColorTransform = new ColorTransform(0.2,0.2,0.2);


    private var SaleTag:Class;

    public var playerXML_:XML = null;

    public var charStats_:CharacterStats;

    public var model:PlayerModel;

    public var available_:Boolean;

    private var graphicContainer_:Sprite;

    private var graphic_:SliceScalingBitmap;

    private var bitmap_:Bitmap;

    private var statusText_:TextFieldDisplayConcrete;

    private var classNameText_:TextFieldDisplayConcrete;

    private var buyButton_:LegacyBuyButton;

    private var cost:int = 0;

    private var lock_:Bitmap;

    private var saleText_:TextFieldDisplayConcrete;

    private var unlockedText_:TextFieldDisplayConcrete;

    private var saleTag_;

    public var buyButtonClicked_:NativeSignal;

    public var characterSelectClicked_:NativeSignal;

    public function CharacterBox(param1:XML, param2:CharacterStats, param3:PlayerModel, param4:Boolean = false)
    {
        var _loc5_:* = null;
        this.SaleTag = CharacterBox_SaleTag;
        super();
        this.model = param3;
        this.playerXML_ = param1;
        this.charStats_ = param2;
        this.available_ = param4 || param3.isLevelRequirementsMet(this.objectType());
        if(!this.available_)
        {
            this.graphic_ = TextureParser.instance.getSliceScalingBitmap("UI","popup_content_inset");
            this.cost = this.playerXML_.UnlockCost;
        }
        else
        {
            this.graphic_ = TextureParser.instance.getSliceScalingBitmap("UI","popup_content_inset");
        }
        this.graphic_.width = 100;
        this.graphic_.height = 100;
        this.graphicContainer_ = new Sprite();
        addChild(this.graphicContainer_);
        this.graphicContainer_.addChild(this.graphic_);
        this.characterSelectClicked_ = new NativeSignal(this.graphicContainer_,"click",MouseEvent);
        this.bitmap_ = new Bitmap(null);
        this.setImage(2,0,0);
        this.bitmap_.x = this.graphic_.x + this.bitmap_.width / 2 - 12;
        this.bitmap_.y = this.graphic_.y;
        addChild(this.bitmap_);
        this.classNameText_ = new TextFieldDisplayConcrete().setSize(14).setColor(16777215).setAutoSize("center").setTextWidth(this.graphic_.width).setBold(true);
        this.classNameText_.setStringBuilder(new LineBuilder().setParams(ClassToolTip.getDisplayId(this.playerXML_)));
        this.classNameText_.filters = [new DropShadowFilter(0,0,0,1,4,4)];
        this.classNameText_.x = this.graphic_.x + this.classNameText_.width / 2;
        this.classNameText_.y = this.graphic_.y + 90;
        addChild(this.classNameText_);
        this.setBuyButton();
        this.setStatusButton();
        if(this.available_)
        {
            _loc5_ = this.getStars(FameUtil.numStars(param3.getBestFame(this.objectType())),FameUtil.STARS.length);
            _loc5_.y = 60;
            _loc5_.x = this.graphic_.width / 2 - _loc5_.width / 2;
            _loc5_.filters = [new DropShadowFilter(0,0,0,1,4,4)];
            this.graphicContainer_.addChild(_loc5_);
            this.classNameText_.y = 74;
        }
        else
        {
            this.lock_ = new Bitmap(AssetLibrary.getImageFromSet("lofiInterface2",5));
            this.lock_.scaleX = 2;
            this.lock_.scaleY = 2;
            this.lock_.x = 4;
            this.lock_.y = 8;
            addChild(this.lock_);
            addChild(this.statusText_);
            this.classNameText_.y = 78;
        }
    }

    public function objectType() : int
    {
        return int(this.playerXML_.@type);
    }

    public function unlock() : void
    {
        var _loc2_:* = null;
        var _loc1_:* = null;
        if(this.available_ == false)
        {
            this.available_ = true;
            this.graphicContainer_.removeChild(this.graphic_);
            this.graphic_ = TextureParser.instance.getSliceScalingBitmap("UI","popup_content_inset");
            this.graphic_.width = 100;
            this.graphic_.height = 100;
            this.graphicContainer_.addChild(this.graphic_);
            this.setImage(2,0,0);
            this.bitmap_.x = this.graphic_.x + this.bitmap_.width / 2 - 12;
            this.bitmap_.y = this.graphic_.y;
            addChild(this.bitmap_);
            this.classNameText_.x = this.graphic_.x + this.classNameText_.width / 2;
            this.classNameText_.y = this.graphic_.y + 90;
            addChild(this.classNameText_);
            if(contains(this.statusText_))
            {
                removeChild(this.statusText_);
            }
            if(contains(this.buyButton_))
            {
                removeChild(this.buyButton_);
            }
            if(this.lock_ && contains(this.lock_))
            {
                removeChild(this.lock_);
            }
            if(this.saleTag_ && contains(this.saleTag_))
            {
                removeChild(this.saleTag_);
            }
            if(this.saleText_ && contains(this.saleText_))
            {
                removeChild(this.saleText_);
            }
            _loc2_ = this.getStars(FameUtil.numStars(this.model.getBestFame(this.objectType())),FameUtil.STARS.length);
            _loc2_.y = 60;
            _loc2_.x = this.graphic_.width / 2 - _loc2_.width / 2;
            _loc2_.filters = [new DropShadowFilter(0,0,0,1,4,4)];
            addChild(_loc2_);
            this.classNameText_.y = 74;
            if(!this.unlockedText_)
            {
                this.getCharacterUnlockText();
            }
            addChild(this.unlockedText_);
            _loc1_ = new GTween(this.unlockedText_,2.5,{
                "alpha":0,
                "y":-30
            });
            _loc1_.onComplete = this.removeUnlockText;
        }
    }

    private function removeUnlockText(param1:GTween) : void
    {
        removeChild(this.unlockedText_);
    }

    public function getTooltip() : ToolTip
    {
        return new ClassToolTip(this.playerXML_,this.model,this.charStats_);
    }

    public function setOver(param1:Boolean) : void
    {
        if(!this.available_)
        {
            return;
        }
        if(param1)
        {
            transform.colorTransform = new ColorTransform(1.2,1.2,1.2);
        }
        else
        {
            transform.colorTransform = new ColorTransform(1,1,1);
        }
    }

    private function setImage(param1:int, param2:int, param3:Number) : void
    {
        this.bitmap_.bitmapData = SavedCharacter.getImage(null,this.playerXML_,param1,param2,param3,this.available_,false);
        this.bitmap_.x = this.graphic_.width / 2 - this.bitmap_.bitmapData.width / 2;
    }

    private function getStars(param1:int, param2:int) : Sprite
    {
        var _loc6_:* = null;
        var _loc5_:int = 0;
        var _loc4_:int = 0;
        var _loc3_:Sprite = new Sprite();
        while(_loc5_ < param1)
        {
            _loc6_ = new StarGraphic();
            _loc6_.x = _loc4_;
            _loc6_.transform.colorTransform = fullCT;
            _loc3_.addChild(_loc6_);
            _loc4_ = _loc4_ + _loc6_.width;
            _loc5_++;
        }
        while(_loc5_ < param2)
        {
            _loc6_ = new StarGraphic();
            _loc6_.x = _loc4_;
            _loc6_.transform.colorTransform = emptyCT;
            _loc3_.addChild(_loc6_);
            _loc4_ = _loc4_ + _loc6_.width;
            _loc5_++;
        }
        return _loc3_;
    }

    public function setSale(param1:int) : void
    {
        if(!this.saleTag_)
        {
            this.saleTag_ = new this.SaleTag();
            this.saleTag_.x = 38;
            this.saleTag_.y = 8;
        }
        if(!this.saleText_)
        {
            this.setSaleText();
        }
    }

    private function setBuyButton() : void
    {
        this.buyButton_ = new LegacyBuyButton("Purchase.buyFor",13,this.cost,0);
        this.buyButton_.y = this.buyButton_.y + this.graphic_.height;
        this.buyButton_.setWidth(this.graphic_.width);
        this.buyButtonClicked_ = new NativeSignal(this.buyButton_,"click",MouseEvent);
    }

    private function setStatusButton() : void
    {
        this.statusText_ = new TextFieldDisplayConcrete().setSize(14).setColor(16711680).setAutoSize("center").setBold(true).setTextWidth(this.graphic_.width);
        this.statusText_.setStringBuilder(new LineBuilder().setParams("CharacterBox.locked"));
        this.statusText_.filters = [new DropShadowFilter(0,0,0,1,4,4)];
        this.statusText_.y = 58;
    }

    private function setSaleText() : void
    {
        this.saleText_ = new TextFieldDisplayConcrete().setSize(14).setColor(16777215).setAutoSize("center").setBold(true).setTextHeight(this.saleTag_.height).setTextWidth(this.saleTag_.width);
        this.saleText_.x = 42;
        this.saleText_.y = 12;
    }

    private function getCharacterUnlockText() : void
    {
        this.unlockedText_ = new TextFieldDisplayConcrete().setSize(14).setColor(65280).setBold(true).setAutoSize("center");
        this.unlockedText_.filters = [new DropShadowFilter(0,0,0,1,4,4)];
        this.unlockedText_.setStringBuilder(new LineBuilder().setParams("CharacterBox.classUnlocked"));
        this.unlockedText_.y = -20;
    }

    public function setIsBuyButtonEnabled(param1:Boolean) : void
    {
        this.buyButton_.setEnabled(param1);
    }
}
}

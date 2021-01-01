package com.company.assembleegameclient.screens
{
import com.company.assembleegameclient.objects.ObjectLibrary;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextFieldAutoSize;
import flash.filters.DropShadowFilter;

import io.decagames.rotmg.ui.buttons.SliceScalingButton;
import io.decagames.rotmg.ui.defaults.DefaultLabelFormat;
import io.decagames.rotmg.ui.sliceScaling.SliceScalingBitmap;
import io.decagames.rotmg.ui.texture.TextureParser;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.game.view.CreditDisplay;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.ui.view.components.ScreenBase;
import org.osflash.signals.Signal;


public class NewCharacterScreen extends Sprite
{


    private var backButton_:SliceScalingButton;

    private var buttonsBackground:SliceScalingBitmap;

    private var creditDisplay_:CreditDisplay;

    private var boxes_:Object;

    public var tooltip:Signal;

    public var close:Signal;

    public var selected:Signal;

    public var buy:Signal;

    private var isInitialized:Boolean = false;

    private var title:TextFieldDisplayConcrete;

    public function NewCharacterScreen()
    {
        this.boxes_ = {};
        super();
        this.tooltip = new Signal(Sprite);
        this.selected = new Signal(int);
        this.close = new Signal();
        this.buy = new Signal(int);
        addChild(new ScreenBase());
        addChild(new AccountScreen());
        this.makeTitleText();
    }

    public function initialize(param1:PlayerModel) : void
    {
        var _loc2_:int = 0;
        var _loc3_:* = null;
        var _loc6_:int = 0;
        var _loc7_:* = null;
        var _loc4_:Boolean = false;
        var _loc5_:* = null;
        if(this.isInitialized)
        {
            return;
        }
        this.isInitialized = true;
        this.buttonsBackground = TextureParser.instance.getSliceScalingBitmap("UI","popup_header_title",800);
        this.buttonsBackground.y = 502.5;
        addChild(this.buttonsBackground);
        this.backButton_ = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI","generic_green_button"));
        this.backButton_.x = 350;
        this.backButton_.y = 520;
        this.backButton_.width = 100;
        this.backButton_.setLabel("Done",DefaultLabelFormat.questButtonCompleteLabel);
        this.backButton_.addEventListener("click",this.onBackClick);
        addChild(this.backButton_);
        this.creditDisplay_ = new CreditDisplay();
        this.creditDisplay_.draw(param1.getCredits(),param1.getFame());
        addChild(this.creditDisplay_);
        _loc2_ = 0;
        while(_loc2_ < ObjectLibrary.playerChars_.length)
        {
            _loc3_ = ObjectLibrary.playerChars_[_loc2_];
            _loc6_ = _loc3_.@type;
            _loc7_ = _loc3_.@id;
            if(!param1.isClassAvailability(_loc7_,"unavailable"))
            {
                _loc4_ = param1.isClassAvailability(_loc7_,"unrestricted");
                _loc5_ = new CharacterBox(_loc3_,param1.getCharStats()[_loc6_],param1,_loc4_);
                _loc5_.x = 100 + 110 * (int(_loc2_ % 6)) + 70 - _loc5_.width;
                _loc5_.y = 90 + 110 * (int(_loc2_ / 6)) - 10;
                this.boxes_[_loc6_] = _loc5_;
                _loc5_.addEventListener("rollOver",this.onCharBoxOver);
                _loc5_.addEventListener("rollOut",this.onCharBoxOut);
                _loc5_.characterSelectClicked_.add(this.onCharBoxClick);
                _loc5_.buyButtonClicked_.add(this.onBuyClicked);
                if(_loc6_ == 784 && !_loc5_.available_)
                {
                    _loc5_.setSale(75);
                }
                addChild(_loc5_);
            }
            _loc2_++;
        }
        this.creditDisplay_.x = stage.stageWidth;
        this.creditDisplay_.y = 20;
    }

    private function makeTitleText() : void
    {
        this.title = new TextFieldDisplayConcrete().setSize(30).setColor(0xFFFFFF);
        this.title.setAutoSize(TextFieldAutoSize.CENTER);
        this.title.setBold(true);
        this.title.setStringBuilder(new LineBuilder().setParams("Classes"));
        this.title.filters = [new DropShadowFilter(0,0,0,1,8,8)];
        this.title.x = 400 - this.title.width / 2;
        this.title.y = 15;
        addChild(this.title);
    }

    private function onBackClick(param1:Event) : void
    {
        this.close.dispatch();
    }

    private function onCharBoxOver(param1:MouseEvent) : void
    {
        var _loc2_:CharacterBox = param1.currentTarget as CharacterBox;
        _loc2_.setOver(true);
        this.tooltip.dispatch(_loc2_.getTooltip());
    }

    private function onCharBoxOut(param1:MouseEvent) : void
    {
        var _loc2_:CharacterBox = param1.currentTarget as CharacterBox;
        _loc2_.setOver(false);
        this.tooltip.dispatch(null);
    }

    private function onCharBoxClick(param1:MouseEvent) : void
    {
        this.tooltip.dispatch(null);
        var _loc2_:CharacterBox = param1.currentTarget.parent as CharacterBox;
        if(!_loc2_.available_)
        {
            return;
        }
        var _loc3_:int = _loc2_.objectType();
        this.selected.dispatch(_loc3_);
    }

    public function updateCreditsAndFame(param1:int, param2:int) :void
    {
        this.creditDisplay_.draw(param1,param2);
    }

    public function update(param1:PlayerModel) : void
    {
        var _loc3_:* = null;
        var _loc6_:int = 0;
        var _loc7_:* = null;
        var _loc4_:Boolean = false;
        var _loc5_:* = null;
        var _loc2_:int = 0;
        while(_loc2_ < ObjectLibrary.playerChars_.length)
        {
            _loc3_ = ObjectLibrary.playerChars_[_loc2_];
            _loc6_ = _loc3_.@type;
            _loc7_ = String(_loc3_.@id);
            if(!param1.isClassAvailability(_loc7_,"unavailable"))
            {
                _loc4_ = param1.isClassAvailability(_loc7_,"unrestricted");
                _loc5_ = this.boxes_[_loc6_];
                if(_loc5_)
                {
                    _loc5_.setIsBuyButtonEnabled(true);
                    if(_loc4_ || param1.isLevelRequirementsMet(_loc6_))
                    {
                        _loc5_.unlock();
                    }
                }
            }
            _loc2_++;
        }
    }

    private function onBuyClicked(param1:MouseEvent) : void
    {
        var _loc3_:int = 0;
        var _loc2_:CharacterBox = param1.currentTarget.parent as CharacterBox;
        if(_loc2_ && !_loc2_.available_)
        {
            _loc3_ = _loc2_.playerXML_.@type;
            _loc2_.setIsBuyButtonEnabled(false);
            this.buy.dispatch(_loc3_);
        }
    }
}
}

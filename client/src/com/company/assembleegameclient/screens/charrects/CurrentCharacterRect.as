package com.company.assembleegameclient.screens.charrects
{
import com.company.assembleegameclient.appengine.CharacterStats;
import com.company.assembleegameclient.appengine.SavedCharacter;
import com.company.assembleegameclient.screens.events.DeleteCharacterEvent;
import com.company.assembleegameclient.ui.tooltip.MyPlayerToolTip;
import com.company.assembleegameclient.ui.tooltip.TextToolTip;
import com.company.assembleegameclient.util.FameUtil;
import com.company.rotmg.graphics.DeleteXGraphic;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import io.decagames.rotmg.fame.FameContentPopup;
import io.decagames.rotmg.ui.buttons.SliceScalingButton;
import io.decagames.rotmg.ui.popups.signals.ShowPopupSignal;
import io.decagames.rotmg.ui.texture.TextureParser;

import kabam.rotmg.assets.services.IconFactory;
import kabam.rotmg.classes.model.CharacterClass;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.text.model.TextKey;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import org.osflash.signals.Signal;
import org.swiftsuspenders.Injector;

public class CurrentCharacterRect extends CharacterRect
{

    private static var toolTip_:MyPlayerToolTip = null;

    private static var fameToolTip:TextToolTip = null;


    public const selected:Signal = new Signal();

    public const deleteCharacter:Signal = new Signal();

    public const showToolTip:Signal = new Signal(Sprite);

    public const hideTooltip:Signal = new Signal();

    public var charName:String;

    public var charStats:CharacterStats;

    public var char:SavedCharacter;

    public var myPlayerToolTipFactory:MyPlayerToolTipFactory;

    private var charType:CharacterClass;

    private var deleteButton:Sprite;

    private var infoButton:Sprite;

    private var icon:DisplayObject;

    private var fameBitmap:Bitmap;

    private var fameBitmapContainer:Sprite;

    public var level_:int = 0;

    protected var statsMaxedText:TextFieldDisplayConcrete;

    public function CurrentCharacterRect(_arg1:String, _arg2:CharacterClass, _arg3:SavedCharacter, _arg4:CharacterStats)
    {
        this.myPlayerToolTipFactory = new MyPlayerToolTipFactory();
        super();
        this.charName = _arg1;
        this.charType = _arg2;
        this.char = _arg3;
        this.charStats = _arg4;
        var _local5:String = _arg2.name;
        var _local6:int = _arg3.charXML_.Level;
        super.className = new LineBuilder().setParams(TextKey.CURRENT_CHARACTER_DESCRIPTION,{
            "className":_local5,
            "level":_local6
        });
        super.color = 6052956;
        super.overColor = 8355711;
        super.init();
        this.makeStatsMaxedText();
        this.makeTaglineText();
        this.makeDeleteButton();
        this.addEventListeners();
        this.makeInfoButton();
    }

    private function addEventListeners() : void
    {
        addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
        selectContainer.addEventListener(MouseEvent.CLICK,this.onSelect);
        this.deleteButton.addEventListener(MouseEvent.CLICK,this.onDelete);
    }

    private function onSelect(_arg1:MouseEvent) : void
    {
        this.selected.dispatch(this.char);
    }

    private function onFameClick(param1:MouseEvent) : void
    {
        var injector:Injector = StaticInjectorContext.getInjector();
        var popupSignal:ShowPopupSignal = injector.getInstance(ShowPopupSignal);
        popupSignal.dispatch(new FameContentPopup(this.char.charId()));
    }

    private function onDelete(_arg1:MouseEvent) : void
    {
        this.deleteCharacter.dispatch(this.char);
    }

    public function setIcon(_arg1:DisplayObject):void {
        ((this.icon) && (selectContainer.removeChild(this.icon)));
        this.icon = _arg1;
        this.icon.x = CharacterRectConstants.ICON_POS_X + 85;
        this.icon.y = CharacterRectConstants.ICON_POS_Y + 5;
        ((this.icon) && (selectContainer.addChild(this.icon)));
    }


    private function makeTaglineText() : void
    {
        if(this.getNextStarFame() > 0)
        {
            super.makeTagline(new LineBuilder().setParams("{quest} / 5",{"quest":(this.charStats == null?0:this.charStats.numStars())}),new LineBuilder().setParams("{fame} / {nextStarFame} Fame",{
                "fame":this.char.fame(),
                "nextStarFame":this.getNextStarFame()
            }));
        }
        else
        {
            super.makeTagline(new LineBuilder().setParams("{quest} / 5",{"quest":5}),new LineBuilder().setParams("All Class Quests completed",{"fame":this.char.fame()}),true);
        }
        taglineClassText.x = taglineClassText.x + taglineClassIcon.width;
        taglineFameText.x = taglineFameText.x + taglineFameIcon.width;
    }

    private function getNextStarFame() : int
    {
        return FameUtil.nextStarFame(this.charStats == null?int(0):int(this.charStats.bestFame()),this.char.fame());
    }

    private function makeDeleteButton() : void
    {
        this.deleteButton = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI","close_button"));
        this.deleteButton.x = 698;
        this.deleteButton.y = 17;
        addChild(this.deleteButton);
    }

    private function makeInfoButton() : void
    {
        this.infoButton = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI","info_button"));
        this.infoButton.x = 24;
        this.infoButton.y = 17;
        addChild(this.infoButton);
    }

    override protected function onMouseOver(_arg_1:MouseEvent) : void
    {
        super.onMouseOver(_arg_1);
        this.removeToolTip();
        if(_arg_1.target.name == "fame_ui")
        {
            fameToolTip = new TextToolTip(3552822,10197915,"Fame","Click to get an Overview!",225);
            this.showToolTip.dispatch(fameToolTip);
        }
        else
        {
            toolTip_ = this.myPlayerToolTipFactory.create(this.charName,this.char.charXML_,this.charStats);
            toolTip_.createUI();
            this.showToolTip.dispatch(toolTip_);
        }
    }

    override protected function onRollOut(_arg1:MouseEvent) : void
    {
        super.onRollOut(_arg1);
        this.removeToolTip();
    }

    private function onRemovedFromStage(param1:Event) : void
    {
        this.removeToolTip();
        selectContainer.removeEventListener(MouseEvent.CLICK,this.onSelect);
        this.fameBitmapContainer.removeEventListener(MouseEvent.CLICK,this.onFameClick);
        this.deleteButton.removeEventListener(MouseEvent.CLICK,this.onDelete);
        this.infoButton.removeEventListener(MouseEvent.CLICK,this.onFameClick);
    }

    private function removeToolTip() : void
    {
        this.hideTooltip.dispatch();
    }

    private function onDeleteDown(_arg1:MouseEvent) : void
    {
        _arg1.stopImmediatePropagation();
        dispatchEvent(new DeleteCharacterEvent(this.char));
    }

    private function makeStatsMaxedText() : void
    {
        var maxedStats:int = 0;
        maxedStats = this.getMaxedStats();
        var color:* = 16572160;
        this.statsMaxedText = new TextFieldDisplayConcrete().setSize(18);
        this.statsMaxedText.setBold(true);
        this.statsMaxedText.setColor(color);
        this.statsMaxedText.setStringBuilder(new StaticStringBuilder(maxedStats > 8 ? maxedStats + "/16" : maxedStats + "/8"));
        this.statsMaxedText.x = maxedStats <= 9 ? CharacterRectConstants.STATS_MAXED_POS_X : CharacterRectConstants.STATS_MAXED_POS_X - 10;
        this.statsMaxedText.y = CharacterRectConstants.STATS_MAXED_POS_Y;
        switch (maxedStats)
        {
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7:
                color = uint(11776947);
                break;
            case 16:
                color = uint(16711680);
                break;
        }

        this.statsMaxedText.setColor(color);
        this.statsMaxedText.filters = makeDropShadowFilter();
        selectContainer.addChild(this.statsMaxedText);
    }

    private function getMaxedStats() : int
    {
        var locl:int = 0;
        if(this.char.hp() >= this.charType.hp.max)
        {
            locl++;
        }
        if(this.char.mp() >= this.charType.mp.max)
        {
            locl++;
        }
        if(this.char.att() >= this.charType.attack.max)
        {
            locl++;
        }
        if(this.char.def() >= this.charType.defense.max)
        {
            locl++;
        }
        if(this.char.spd() >= this.charType.speed.max)
        {
            locl++;
        }
        if(this.char.dex() >= this.charType.dexterity.max)
        {
            locl++;
        }
        if(this.char.vit() >= this.charType.hpRegeneration.max)
        {
            locl++;
        }
        if(this.char.wis() >= this.charType.mpRegeneration.max)
        {
            locl++;
        }
        return locl;
    }
}
}

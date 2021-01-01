package com.company.assembleegameclient.ui.tooltip {
import com.company.assembleegameclient.constants.InventoryOwnerTypes;
import com.company.assembleegameclient.game.events.KeyInfoResponseSignal;
import com.company.assembleegameclient.misc.UILabel;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.LineBreakDesign;
import com.company.assembleegameclient.util.FilterUtil;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.assembleegameclient.util.TierUtil;
import com.company.util.AssetLibrary;
import com.company.util.BitmapUtil;
import com.company.util.KeyCodes;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.TimerEvent;
import flash.filters.DropShadowFilter;
import flash.utils.Dictionary;
import flash.utils.Timer;

import kabam.rotmg.constants.ActivationType;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.messaging.impl.data.StatData;
import kabam.rotmg.messaging.impl.incoming.KeyInfoResponse;
import kabam.rotmg.text.model.TextKey;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.AppendingLineBuilder;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import kabam.rotmg.text.view.stringBuilder.StringBuilder;
import kabam.rotmg.ui.model.HUDModel;

import com.company.assembleegameclient.util.MathUtil;

public class EquipmentToolTip extends ToolTip {

    private static const MAX_WIDTH:int = 230;

    public static var keyInfo:Dictionary = new Dictionary();

    private var iconSize:Number = 60;
    private var icon:Bitmap;
    public var titleText:TextFieldDisplayConcrete;
    private var tierText:UILabel;
    private var descText:TextFieldDisplayConcrete;
    private var line1:LineBreakDesign;
    private var effectsText:TextFieldDisplayConcrete;
    private var line2:LineBreakDesign;
    private var restrictionsText:TextFieldDisplayConcrete;
    private var player:Player;
    private var isEquippable:Boolean = false;
    private var objectType:int;
    private var titleOverride:String;
    private var descriptionOverride:String;
    private var curItemXML:XML = null;
    private var objectXML:XML = null;
    private var slotTypeToTextBuilder:SlotComparisonFactory;
    private var restrictions:Vector.<Restriction>;
    private var effects:Vector.<Effect>;
    private var uniqueEffects:Vector.<Effect>;
    private var itemSlotTypeId:int;
    private var invType:int;
    private var inventorySlotID:uint;
    private var inventoryOwnerType:String;
    private var isInventoryFull:Boolean;
    private var playerCanUse:Boolean;
    private var comparisonResults:SlotComparisonResult;
    private var powerText:TextFieldDisplayConcrete;
    private var keyInfoResponse:KeyInfoResponseSignal;
    private var originalObjectType:int;
    private var legendaryText:TextFieldDisplayConcrete;
    private var Text:TextFieldDisplayConcrete;
    private var sameActivateEffect:Boolean;

    public function EquipmentToolTip(_arg1:int, _arg2:Player, _arg3:int, _arg4:String) {
        var _local8:HUDModel;
        this.uniqueEffects = new Vector.<Effect>();
        this.objectType = _arg1;
        this.originalObjectType = this.objectType;
        this.player = _arg2;
        this.invType = _arg3;
        this.inventoryOwnerType = _arg4;
        this.isInventoryFull = ((_arg2) ? _arg2.isInventoryFull() : false);
        if ((((this.objectType >= 0x9000)) && ((this.objectType <= 0xF000)))) {
            this.objectType = 36863;
        }
        this.playerCanUse = ((_arg2) ? ObjectLibrary.isUsableByPlayer(this.objectType, _arg2) : false);
        var _local5:int = ((_arg2) ? ObjectLibrary.getMatchingSlotIndex(this.objectType, _arg2) : -1);
        var _local6:uint = ((((this.playerCanUse) || ((this.player == null)))) ? 0x363636 : 6036765);
        var _local7:uint = ((((this.playerCanUse) || ((_arg2 == null)))) ? 0x9B9B9B : 10965039);
        super(_local6, 1, _local7, 1, true);
        this.slotTypeToTextBuilder = new SlotComparisonFactory();
        this.objectXML = ObjectLibrary.xmlLibrary_[this.objectType];
        this.isEquippable = !((_local5 == -1));
        this.effects = new Vector.<Effect>();
        this.itemSlotTypeId = int(this.objectXML.SlotType);
        if (this.player == null) {
            this.curItemXML = this.objectXML;
        }
        else {
            if (this.isEquippable) {
                if (this.player.equipment_[_local5] != -1) {
                    this.curItemXML = ObjectLibrary.xmlLibrary_[this.player.equipment_[_local5]];
                }
            }
        }
        this.addIcon();
        this.addTitle();
        this.addDescriptionText();
        this.addTierText();
        this.handleWisMod();
        this.buildCategorySpecificText();
        this.addUniqueEffectsToList();
        this.sameActivateEffect = false;
        this.addActivateTagsToEffectsList();
        this.addNumProjectiles();
        this.addProjectileTagsToEffectsList();
        this.addRateOfFire();
        this.addActivateOnEquipTagsToEffectsList();
        this.addDoseTagsToEffectsList();
        this.addMpCostTagToEffectsList();
        this.addHpCostTagToEffectsList();
        this.addFameBonusTagToEffectsList();
        this.addCooldown();
        this.addArcGapToEffectsList();
        this.makeEffectsList();
        this.makeLineTwo();
        this.makeLegendaryExtraText();
        this.makeRestrictionList();
        this.makeRestrictionText();
        //this.makeDropsText();
    }

    private static function parse(str:String):Number {
        for (var i:Number = 0; i < str.length; i++) {
            var c:String = str.charAt(i);
            if (c != "0") break;
        }

        return Number(str.substr(i));
    }

    private function makeLegendaryExtraText() : void
    {
        if(this.objectXML.hasOwnProperty("Legend"))
        {
            this.legendaryText = new TextFieldDisplayConcrete().setSize(12).setColor(0xcc0066).setBold(true).setTextWidth(MAX_WIDTH - 4).setWordWrap(true);
            this.legendaryText.setStringBuilder(new StaticStringBuilder().setString(this.objectXML.Legend.Name + ": " + this.objectXML.Legend.Description));
            switch(Parameters.data_.ItemDataOutlines)
            {
                case 0:
                    this.legendaryText.filters = FilterUtil.getTextOutlineFilter();
                    break;
                case 1:
                    this.legendaryText.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
            }
            waiter.push(this.legendaryText.textChanged);
            addChild(this.legendaryText);
        }
    }

    /*private function makeDropsText() : void
    {
        if(this.objectXML.hasOwnProperty("Drops"))
        {
            this.Text = new TextFieldDisplayConcrete().setSize(12).setColor(0xcc0066).setBold(true).setTextWidth(MAX_WIDTH - 4).setWordWrap(true);
            this.Text.setStringBuilder(new StaticStringBuilder().setString("Drops from: [" + this.objectXML.DropsFrom.Name + "]"));
            switch(Parameters.data_.ItemDataOutlines)
            {
                case 0:
                    this.Text.filters = FilterUtil.getTextOutlineFilter();
                    break;
                case 1:
                    this.Text.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
            }
            waiter.push(this.Text.textChanged);
            addChild(this.Text);
        }
    }*/

    private function onKeyInfoResponse(_arg1:KeyInfoResponse):void {
        this.keyInfoResponse.remove(this.onKeyInfoResponse);
        this.removeTitle();
        this.removeDesc();
        this.titleOverride = _arg1.name;
        this.descriptionOverride = _arg1.description;
        keyInfo[this.originalObjectType] = [_arg1.name, _arg1.description, _arg1.creator];
        this.addTitle();
        this.addDescriptionText();
    }

    private function addUniqueEffectsToList():void {
        var _local1:XMLList;
        var _local2:XML;
        var _local3:String;
        var _local4:String;
        var _local5:String;
        var _local6:AppendingLineBuilder;
        if (this.objectXML.hasOwnProperty("ExtraTooltipData")) {
            _local1 = this.objectXML.ExtraTooltipData.EffectInfo;
            for each (_local2 in _local1) {
                _local3 = _local2.attribute("name");
                _local4 = _local2.attribute("description");
                _local5 = ((((_local3) && (_local4))) ? ": " : "\n");
                _local6 = new AppendingLineBuilder();
                if (_local3) {
                    _local6.pushParams(_local3);
                }
                if (_local4) {
                    _local6.pushParams(_local4, {}, TooltipHelper.getOpenTag(16777103), TooltipHelper.getCloseTag());
                }
                _local6.setDelimiter(_local5);
                this.uniqueEffects.push(new Effect(TextKey.BLANK, {"data": _local6}));
            }
        }
    }

    private function isEmptyEquipSlot():Boolean {
        return (((this.isEquippable) && ((this.curItemXML == null))));
    }

    private function addIcon():void {
        var _local1:XML = ObjectLibrary.xmlLibrary_[this.objectType];
        var _local2:int = 5;
        if ((((this.objectType == 4874)) || ((this.objectType == 4618)))) {
            _local2 = 8;
        }
        if (_local1.hasOwnProperty("ScaleValue")) {
            _local2 = _local1.ScaleValue;
        }
        var _local3:BitmapData = ObjectLibrary.getRedrawnTextureFromType(this.objectType, 60, true, true, _local2);
        _local3 = BitmapUtil.cropToBitmapData(_local3, 4, 4, (_local3.width - 8), (_local3.height - 8));
        this.icon = new Bitmap(_local3);
        addChild(this.icon);
    }

    /*
    private function addTierText():void {
        var _local1 = (this.isPet() == false);
        var _local2 = (this.objectXML.hasOwnProperty("Consumable") == false);
        var _local3 = (this.objectXML.hasOwnProperty("Treasure") == false);
        var _local4:Boolean = this.objectXML.hasOwnProperty("Tier");
        if (((((_local1) && (_local2))) && (_local3))) {

            if (_local4) {
                this.tierText = new TextFieldDisplayConcrete().setSize(16).setColor(0xFFFFFF).setTextWidth(30).setBold(true);
                this.tierText.setStringBuilder(new LineBuilder().setParams(TextKey.TIER_ABBR, {"tier": this.objectXML.Tier}));
                addChild(this.tierText);
            }
            else {
                if (this.objectXML.hasOwnProperty("@setType")) { //ST
                    this.tierText = new TextFieldDisplayConcrete().setSize(16).setTextWidth(30).setBold(true);
                    this.tierText.setColor(0xFF9900);
                    this.tierText.setStringBuilder(new StaticStringBuilder("ST"));
                    addChild(this.tierText);
                }
                else {
                    if (this.objectXML.hasOwnProperty("@unique")) { //Unique
                        this.tierText = new TextFieldDisplayConcrete().setSize(16).setTextWidth(30).setBold(true);
                        this.tierText.setColor(0xFFce00);
                        this.titleText.setColor(0xFFce00);
                        this.tierText.setStringBuilder(new StaticStringBuilder("UN"));
                        addChild(this.tierText);
                    }
                    else {
                        if (this.objectXML.hasOwnProperty("@unholylg")) { //Unholy Legendary
                            this.tierText = new TextFieldDisplayConcrete().setSize(16).setTextWidth(14).setBold(true);
                            this.tierText.setColor(0x6F28CC);
                            this.titleText.setColor(0x6F28CC);
                            this.tierText.setStringBuilder(new StaticStringBuilder("U-LG"));
                            addChild(this.tierText);
                        }
                        else {
                            if (this.objectXML.hasOwnProperty("@legendary")) { //Legendary
                                this.tierText = new TextFieldDisplayConcrete().setSize(16).setTextWidth(30).setBold(true);
                                this.titleText.setColor(0xFFFF00);
                                this.tierText.setColor(0xFFFF00);
                                this.tierText.setStringBuilder(new StaticStringBuilder("LG"));
                                addChild(this.tierText);
                            }
                            else {
                                if (this.objectXML.hasOwnProperty("@reskin")) { //Reskins
                                    this.tierText = new TextFieldDisplayConcrete().setSize(16).setTextWidth(30).setBold(true);
                                    this.tierText.setColor(0xFFce00);
                                    this.tierText.setStringBuilder(new StaticStringBuilder("RS"));
                                    addChild(this.tierText);
                                }


                                else {
                                    this.tierText = new TextFieldDisplayConcrete().setSize(16).setTextWidth(30).setBold(true);
                                    this.tierText.setColor(9055202);
                                    this.tierText.setStringBuilder(new LineBuilder().setParams(TextKey.UNTIERED_ABBR));
                                    addChild(this.tierText);
                                }

                            }
                        }
                    }
                }
            }
        }
    }*/

    private function isPet():Boolean {
        var activateTags:XMLList;
        activateTags = this.objectXML.Activate.(text() == "PermaPet");
        return ((activateTags.length() >= 1));
    }

    private function removeTitle() {
        removeChild(this.titleText);
    }

    private function removeDesc() {
        removeChild(this.descText);
    }

    private function addTitle() : void
    {
        var _local_1:int = this.playerCanUse || this.player == null?int(16777215):int(16549442);
        this.titleText = new TextFieldDisplayConcrete().setSize(16).setColor(_local_1).setBold(true).setTextWidth(MAX_WIDTH - this.icon.width - 4 - 30).setWordWrap(true);
        this.titleText.setStringBuilder(new LineBuilder().setParams(ObjectLibrary.typeToDisplayId_[this.objectType]));
        switch(Parameters.data_.ItemDataOutlines)
        {
            case 0:
                this.titleText.filters = FilterUtil.getTextOutlineFilter();
                break;
            case 1:
                this.titleText.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
        }
        waiter.push(this.titleText.textChanged);
        addChild(this.titleText);
    }

    private function buildUniqueTooltipData():String {
        var _local1:XMLList;
        var _local2:Vector.<Effect>;
        var _local3:XML;
        if (this.objectXML.hasOwnProperty("ExtraTooltipData")) {
            _local1 = this.objectXML.ExtraTooltipData.EffectInfo;
            _local2 = new Vector.<Effect>();
            for each (_local3 in _local1) {
                _local2.push(new Effect(_local3.attribute("name"), _local3.attribute("description")));
            }
        }
        return ("");
    }

    private function makeEffectsList() : void
    {
        var _local_1:AppendingLineBuilder = null;
        if(this.effects.length != 0 || this.comparisonResults.lineBuilder != null || this.objectXML.hasOwnProperty("ExtraTooltipData"))
        {
            this.line1 = new LineBreakDesign(MAX_WIDTH - 12,0);
            this.effectsText = new TextFieldDisplayConcrete().setSize(14).setColor(11776947).setTextWidth(MAX_WIDTH).setWordWrap(true).setHTML(true);
            _local_1 = this.getEffectsStringBuilder();
            this.effectsText.setStringBuilder(_local_1);
            switch(Parameters.data_.ItemDataOutlines)
            {
                case 0:
                    this.effectsText.filters = FilterUtil.getTextOutlineFilter();
                    break;
                case 1:
                    this.effectsText.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
            }
            if(_local_1.hasLines())
            {
                addChild(this.line1);
                addChild(this.effectsText);
            }
        }
    }

    private function getEffectsStringBuilder():AppendingLineBuilder {
        var _local1:AppendingLineBuilder = new AppendingLineBuilder();
        this.appendEffects(this.uniqueEffects, _local1);
        if (this.comparisonResults.lineBuilder.hasLines()) {
            _local1.pushParams(TextKey.BLANK, {"data": this.comparisonResults.lineBuilder});
        }
        this.appendEffects(this.effects, _local1);
        return (_local1);
    }

    private function appendEffects(_arg1:Vector.<Effect>, _arg2:AppendingLineBuilder):void {
        var _local3:Effect;
        var _local4:String;
        var _local5:String;
        for each (_local3 in _arg1) {
            _local4 = "";
            _local5 = "";
            if (_local3.color_) {
                _local4 = (('<font color="#' + _local3.color_.toString(16)) + '">');
                _local5 = "</font>";
            }
            _arg2.pushParams(_local3.name_, _local3.getValueReplacementsWithColor(), _local4, _local5);
        }
    }



    private function addRateOfFire():void
    {
        var _local_2:String;
        var _local_1:ComPairTag = new ComPairTag(this.objectXML, this.curItemXML, "RateOfFire", 1);
        if (!_local_1.a == 1 || !(_local_1.a == _local_1.b))
        {
            _local_1.a = MathUtil.round((_local_1.a * 100), 2);
            _local_1.b = MathUtil.round((_local_1.b * 100), 2);
            _local_2 = TooltipHelper.compare(_local_1.a, _local_1.b, true, "%");
            this.effects.push(new Effect(TextKey.RATE_OF_FIRE, {"data":_local_2}));
        }
        else
        {
            if ((this.objectXML.hasOwnProperty("RateOfFire") && !(this.comparisonResults.processedTags[this.objectXML.RateOfFire.toXMLString()]) == true))
            {
                if (!this.comparisonResults.processedTags[this.objectXML.RateOfFire.toXMLString()])
                {
                    this.effects.push(new Effect("Rate of Fire: {rof}", {"rof": Math.round(this.objectXML.RateOfFire * 100) + "%"}));
                }
            }
        }
    }
    private function addArcGapToEffectsList():void {
        if (((this.objectXML.hasOwnProperty("ArcGap")) && (!(this.comparisonResults.processedTags[this.objectXML.ArcGap.toXMLString()]) == true))) {
            if (!this.comparisonResults.processedTags[this.objectXML.ArcGap.toXMLString()]) {
                this.effects.push(new Effect("Arc Gap: {arcgap}",  {"arcgap": Math.round(this.objectXML.ArcGap)}));
            }
        }
    }
    private function addCooldown():void
    {
        var _local_1:ComPairTag = new ComPairTag(this.objectXML, this.curItemXML, "Cooldown", 0.5);
        if (((!(_local_1.a == 0.5)) || (!(_local_1.a == _local_1.b))))
        {
            this.effects.push(new Effect("Cooldown: {cd}", {"cd":TooltipHelper.compareAndGetPlural(_local_1.a, _local_1.b, "second", false)}));
        }
        else
        {
            if (this.objectXML.hasOwnProperty("Cooldown") && !(this.comparisonResults.processedTags[this.objectXML.Cooldown.toXMLString()]) == true)
            {
                if (!this.comparisonResults.processedTags[this.objectXML.Cooldown.toXMLString()])
                {
                    this.effects.push(new Effect("Cooldown: {cd}", {"cd":TooltipHelper.getPlural(_local_1.a, "second")}));
                }
            }
        }
    }

    private function addNumProjectiles():void
    {
        var _local_1:ComPairTag = new ComPairTag(this.objectXML, this.curItemXML, "NumProjectiles", 1);
        if (((!(_local_1.a == 1)) || (!(_local_1.a == _local_1.b))))
        {
            this.effects.push(new Effect(TextKey.SHOTS, {"numShots":TooltipHelper.compare(_local_1.a, _local_1.b)}));
        }
    }


    private function addFameBonusTagToEffectsList():void {
        var _local1:int;
        var _local2:uint;
        var _local3:int;
        if (this.objectXML.hasOwnProperty("FameBonus")) {
            _local1 = int(this.objectXML.FameBonus);
            _local2 = ((this.playerCanUse) ? TooltipHelper.BETTER_COLOR : TooltipHelper.NO_DIFF_COLOR);
            if (((!((this.curItemXML == null))) && (this.curItemXML.hasOwnProperty("FameBonus")))) {
                _local3 = int(this.curItemXML.FameBonus.text());
                _local2 = TooltipHelper.getTextColor((_local1 - _local3));
            }
            this.effects.push(new Effect(TextKey.FAME_BONUS, {"percent": (this.objectXML.FameBonus + "%")}).setReplacementsColor(_local2));
        }
    }



    private function addMpCostTagToEffectsList():void
    {
        var mpCostA:int;
        var mpCostB:int;
        if (this.objectXML.hasOwnProperty("MpEndCost"))
        {
            mpCostA = (mpCostB = this.objectXML.MpEndCost);
            if (((this.curItemXML) && (this.curItemXML.hasOwnProperty("MpEndCost"))))
            {
                mpCostB = this.curItemXML.MpEndCost;
            }
            this.effects.push(new Effect(TextKey.MP_COST, {"cost":TooltipHelper.compare(mpCostA, mpCostB, false)}));
        }
        else
        {
            if (this.objectXML.hasOwnProperty("MpCost"))
            {
                mpCostA = (mpCostB = this.objectXML.MpCost);
                if (((this.curItemXML) && (this.curItemXML.hasOwnProperty("MpCost"))))
                {
                    mpCostB = this.curItemXML.MpCost;
                }
                this.effects.push(new Effect(TextKey.MP_COST, {"cost":TooltipHelper.compare(mpCostA, mpCostB, false)}));
            }
        }
    }
    private function addHpCostTagToEffectsList():void {

        var hpCostA:int;
        var hpCostB:int;
        if (this.objectXML.hasOwnProperty("HpCost"))
        {
            hpCostA = (hpCostB = this.objectXML.MpCost);
            if (((this.curItemXML) && (this.curItemXML.hasOwnProperty("MpCost"))))
            {
                hpCostB = this.curItemXML.MpCost;
            }
            this.effects.push(new Effect(TextKey.MP_COST, {"cost":TooltipHelper.compare(hpCostB, hpCostA, true)}));
        }
        if (((this.objectXML.hasOwnProperty("HpCost")) && (!(this.comparisonResults.processedTags[this.objectXML.HpCost[0].toXMLString()])))) {
            if (!this.comparisonResults.processedTags[this.objectXML.HpCost[0].toXMLString()]) {
                this.effects.push(new Effect("HP Cost: {cost}",  {"cost": this.objectXML.HpCost}));
            }
        }
    }

    private function addTierText():void {
        this.tierText = TierUtil.getTierTag(this.objectXML,16);
        if(this.tierText)
        {
            addChild(this.tierText);
            switch(Parameters.data_.ItemDataOutlines)
            {
                case 0:
                    this.tierText.filters = FilterUtil.getTextOutlineFilter();
                    break;
                case 1:
                    this.tierText.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
            }
        }
    }

    private function addDoseTagsToEffectsList():void {
        if (this.objectXML.hasOwnProperty("Doses")) {
            this.effects.push(new Effect(TextKey.DOSES, {"dose": this.objectXML.Doses}));
        }
        if (this.objectXML.hasOwnProperty("Quantity")) {
            this.effects.push(new Effect("Quantity: {quantity}", {"quantity": this.objectXML.Quantity}));
        }
    }

    private function addProjectileTagsToEffectsList():void
    {
        var _local_1:XML;
        if (this.objectXML.hasOwnProperty("Projectile"))
        {
            _local_1 = ((this.curItemXML == null) ? null : this.curItemXML.Projectile[0]);
            this.addProjectile(this.objectXML.Projectile[0], _local_1);
        }
    }

    private function addProjectile(_arg_1:XML, _arg_2:XML=null):void
    {
        var _local_15:XML;
        var _local_3:ComPairTag = new ComPairTag(_arg_1, _arg_2, "MinDamage");
        var _local_4:ComPairTag = new ComPairTag(_arg_1, _arg_2, "MaxDamage");
        var _local_5:ComPairTag = new ComPairTag(_arg_1, _arg_2, "Speed");
        var _local_6:ComPairTag = new ComPairTag(_arg_1, _arg_2, "LifetimeMS");
        var _local_7:ComPairTagBool = new ComPairTagBool(_arg_1, _arg_2, "Boomerang");
        var _local_8:ComPairTagBool = new ComPairTagBool(_arg_1, _arg_2, "Parametric");
        var _local_9:ComPairTag = new ComPairTag(_arg_1, _arg_2, "Magnitude", 3);
        var _local_10:Number = ((_local_8.a) ? _local_9.a : MathUtil.round((((_local_5.a * _local_6.a) / (int(_local_7.a) + 1)) / 10000), 2));
        var _local_11:Number = ((_local_8.b) ? _local_9.b : MathUtil.round((((_local_5.b * _local_6.b) / (int(_local_7.b) + 1)) / 10000), 2));
        var _local_12:Number = ((_local_4.a + _local_3.a) / 2);
        var _local_13:Number = ((_local_4.b + _local_3.b) / 2);
        var _local_14:String = ((_local_3.a == _local_4.a) ? _local_3.a : ((_local_3.a + " - ") + _local_4.a)).toString();
        this.effects.push(new Effect(TextKey.DAMAGE, {"damage":TooltipHelper.wrapInFontTag(_local_14, ("#" + TooltipHelper.getTextColor((_local_12 - _local_13)).toString(16)))}));
        this.effects.push(new Effect(TextKey.RANGE, {"range":TooltipHelper.compare(_local_10, _local_11)}));
        if (_arg_1.hasOwnProperty("MultiHit"))
        {
            this.effects.push(new Effect(TextKey.MULTIHIT, {}).setColor(TooltipHelper.NO_DIFF_COLOR));
        }
        if (_arg_1.hasOwnProperty("PassesCover"))
        {
            this.effects.push(new Effect(TextKey.PASSES_COVER, {}).setColor(TooltipHelper.NO_DIFF_COLOR));
        }
        if (_arg_1.hasOwnProperty("ArmorPiercing"))
        {
            this.effects.push(new Effect(TextKey.ARMOR_PIERCING, {}).setColor(TooltipHelper.NO_DIFF_COLOR));
        }
        if (_local_8.a)
        {
            this.effects.push(new Effect("Shots are parametric", {}).setColor(TooltipHelper.NO_DIFF_COLOR));
        }
        else
        {
            if (_local_7.a)
            {
                this.effects.push(new Effect("Shots boomerang", {}).setColor(TooltipHelper.NO_DIFF_COLOR));
            }
        }
        if (_arg_1.hasOwnProperty("ConditionEffect"))
        {
            this.effects.push(new Effect(TextKey.SHOT_EFFECT, {"effect":""}));
        }
        for each (_local_15 in _arg_1.ConditionEffect)
        {
            this.effects.push(new Effect(TextKey.EFFECT_FOR_DURATION, {
                "effect":_local_15,
                "duration":_local_15.@duration
            }).setColor(TooltipHelper.NO_DIFF_COLOR));
        }
    }

    private function addActivateTagsToEffectsList():void
    {
        var activateXML:XML;
        var val:String;
        var stat:int;
        var amt:int;
        var test:String;
        var activationType:String;
        var compareXML:XML;
        var effectColor:uint;
        var current:XML;
        var tokens:Object;
        var template:String;
        var effectColor2:uint;
        var current2:XML;
        var statStr:String;
        var tokens2:Object;
        var template2:String;
        var replaceParams:Object;
        var rNew:Number;
        var rCurrent:Number;
        var dNew:Number;
        var dCurrent:Number;
        var comparer:Number;
        var rNew2:Number;
        var rCurrent2:Number;
        var dNew2:Number;
        var dCurrent2:Number;
        var aNew2:Number;
        var aCurrent2:Number;
        var comparer2:Number;
        var alb:AppendingLineBuilder;
        for each (activateXML in this.objectXML.Activate)
        {
            test = this.comparisonResults.processedTags[activateXML.toXMLString()];
            if (this.comparisonResults.processedTags[activateXML.toXMLString()] != true)
            {
                activationType = activateXML.toString();
                compareXML = ((this.curItemXML == null) ? null : this.curItemXML.Activate.(text() == activationType)[0]);
                switch (activationType)
                {
                    case ActivationType.COND_EFFECT_AURA:
                        this.effects.push(new Effect(TextKey.PARTY_EFFECT, {"effect":new AppendingLineBuilder().pushParams(TextKey.WITHIN_SQRS, {"range":activateXML.@range}, TooltipHelper.getOpenTag(TooltipHelper.NO_DIFF_COLOR), TooltipHelper.getCloseTag())}));
                        this.effects.push(new Effect(TextKey.EFFECT_FOR_DURATION, {
                            "effect":activateXML.@effect,
                            "duration":activateXML.@duration
                        }).setColor(TooltipHelper.NO_DIFF_COLOR));
                        break;
                    case ActivationType.COND_EFFECT_SELF:
                        this.effects.push(new Effect(TextKey.EFFECT_ON_SELF, {"effect":""}));
                        this.effects.push(new Effect(TextKey.EFFECT_FOR_DURATION, {
                            "effect":activateXML.@effect,
                            "duration":activateXML.@duration
                        }));
                        break;
                    case ActivationType.STAT_BOOST_SELF:
                        this.effects.push(new Effect("{amount} {stat} for {duration} ", {
                            "amount":this.prefix(activateXML.@amount),
                            "stat":new LineBuilder().setParams(StatData.statToName(int(activateXML.@stat))),
                            "duration":TooltipHelper.getPlural(activateXML.@duration, "second")
                        }));
                        break;
                    case ActivationType.HEAL:
                        this.effects.push(new Effect(TextKey.INCREMENT_STAT, {
                            "statAmount":(("+" + activateXML.@amount) + " "),
                            "statName":new LineBuilder().setParams(TextKey.STATUS_BAR_HEALTH_POINTS)
                        }));
                        break;
                    case ActivationType.HEAL_NOVA:
                        if (((activateXML.hasOwnProperty("@damage")) && (int(activateXML.@damage) > 0)))
                        {
                            this.effects.push(new Effect("{damage} damage within {range} sqrs", {
                                "damage":activateXML.@damage,
                                "range":activateXML.@range
                            }));
                        }
                        this.effects.push(new Effect(TextKey.PARTY_HEAL, {"effect":new AppendingLineBuilder().pushParams(TextKey.HP_WITHIN_SQRS, {
                                "amount":activateXML.@amount,
                                "range":activateXML.@range
                            }, TooltipHelper.getOpenTag(TooltipHelper.NO_DIFF_COLOR), TooltipHelper.getCloseTag())}));
                        break;
                    case ActivationType.MAGIC:
                        this.effects.push(new Effect(TextKey.INCREMENT_STAT, {
                            "statAmount":(("+" + activateXML.@amount) + " "),
                            "statName":new LineBuilder().setParams(TextKey.STATUS_BAR_MANA_POINTS)
                        }));
                        break;
                    case ActivationType.MAGIC_NOVA:
                        this.effects.push(new Effect(TextKey.FILL_PARTY_MAGIC, (((activateXML.@amount + " MP at ") + activateXML.@range) + " sqrs")));
                        break;
                    case ActivationType.TELEPORT:
                        this.effects.push(new Effect(TextKey.BLANK, {"data":new LineBuilder().setParams(TextKey.TELEPORT_TO_TARGET)}));
                        break;
                    case ActivationType.BULLET_NOVA:
                        this.getSpell(activateXML, compareXML);
                        break;
                    case ActivationType.VAMPIRE_BLAST:
                        this.getSkull(activateXML, compareXML);
                        break;
                    case ActivationType.TRAP:
                        this.getTrap(activateXML, compareXML);
                        break;
                    case ActivationType.STASIS_BLAST:
                        this.effects.push(new Effect(TextKey.STASIS_GROUP, {"stasis":new AppendingLineBuilder().pushParams(TextKey.SEC_COUNT, {"duration":activateXML.@duration}, TooltipHelper.getOpenTag(TooltipHelper.NO_DIFF_COLOR), TooltipHelper.getCloseTag())}));
                        break;
                    case ActivationType.DECOY:
                        this.getDecoy(activateXML, compareXML);
                        break;
                    case ActivationType.LIGHTNING:
                        this.getLightning(activateXML, compareXML);
                        break;
                    case ActivationType.POISON_GRENADE:
                        this.getPoison(activateXML, compareXML);
                        break;
                    case ActivationType.REMOVE_NEG_COND:
                        this.effects.push(new Effect(TextKey.REMOVES_NEGATIVE, {}).setColor(TooltipHelper.NO_DIFF_COLOR));
                        break;
                    case ActivationType.REMOVE_NEG_COND_SELF:
                        this.effects.push(new Effect(TextKey.REMOVES_NEGATIVE, {}).setColor(TooltipHelper.NO_DIFF_COLOR));
                        break;
                    case ActivationType.GENERIC_ACTIVATE:
                        effectColor = 16777103;
                        if (this.curItemXML != null)
                        {
                            current = this.getEffectTag(this.curItemXML, activateXML.@effect);
                            if (current != null)
                            {
                                rNew = Number(activateXML.@range);
                                rCurrent = Number(current.@range);
                                dNew = Number(activateXML.@duration);
                                dCurrent = Number(current.@duration);
                                comparer = ((rNew - rCurrent) + (dNew - dCurrent));
                                if (comparer > 0)
                                {
                                    effectColor = 0xFF00;
                                }
                                else
                                {
                                    if (comparer < 0)
                                    {
                                        effectColor = 0xFF0000;
                                    }
                                }
                            }
                        }
                        tokens = {
                            "range":activateXML.@range,
                            "effect":activateXML.@effect,
                            "duration":activateXML.@duration
                        };
                        template = "Within {range} sqrs {effect} for {duration} seconds";
                        if (activateXML.@target != "enemy")
                        {
                            this.effects.push(new Effect(TextKey.PARTY_EFFECT, {"effect":LineBuilder.returnStringReplace(template, tokens)}).setReplacementsColor(effectColor));
                        }
                        else
                        {
                            this.effects.push(new Effect(TextKey.ENEMY_EFFECT, {"effect":LineBuilder.returnStringReplace(template, tokens)}).setReplacementsColor(effectColor));
                        }
                        break;
                    case ActivationType.STAT_BOOST_AURA:
                        effectColor2 = 16777103;
                        if (this.curItemXML != null)
                        {
                            current2 = this.getStatTag(this.curItemXML, activateXML.@stat);
                            if (current2 != null)
                            {
                                rNew2 = Number(activateXML.@range);
                                rCurrent2 = Number(current2.@range);
                                dNew2 = Number(activateXML.@duration);
                                dCurrent2 = Number(current2.@duration);
                                aNew2 = Number(activateXML.@amount);
                                aCurrent2 = Number(current2.@amount);
                                comparer2 = (((rNew2 - rCurrent2) + (dNew2 - dCurrent2)) + (aNew2 - aCurrent2));
                                if (comparer2 > 0)
                                {
                                    effectColor2 = 0xFF00;
                                }
                                else
                                {
                                    if (comparer2 < 0)
                                    {
                                        effectColor2 = 0xFF0000;
                                    }
                                }
                            }
                        }
                        stat = int(activateXML.@stat);
                        statStr = LineBuilder.getLocalizedString2(StatData.statToName(stat));
                        tokens2 = {
                            "range":activateXML.@range,
                            "stat":statStr,
                            "amount":activateXML.@amount,
                            "duration":activateXML.@duration
                        };
                        template2 = "Within {range} sqrs increase {stat} by {amount} for {duration} seconds";
                        this.effects.push(new Effect(TextKey.PARTY_EFFECT, {"effect":LineBuilder.returnStringReplace(template2, tokens2)}).setReplacementsColor(effectColor2));
                        break;
                    case ActivationType.INCREMENT_STAT:
                        stat = int(activateXML.@stat);
                        amt = int(activateXML.@amount);
                        replaceParams = {};
                        if (((!(stat == StatData.HP_STAT)) && (!(stat == StatData.MP_STAT))))
                        {
                            val = TextKey.PERMANENTLY_INCREASES;
                            replaceParams["statName"] = new LineBuilder().setParams(StatData.statToName(stat));
                            this.effects.push(new Effect(val, replaceParams).setColor(16777103));
                            break;
                        }
                        val = TextKey.BLANK;
                        alb = new AppendingLineBuilder().setDelimiter(" ");
                        alb.pushParams(TextKey.BLANK, {"data":new StaticStringBuilder(("+" + amt))});
                        alb.pushParams(StatData.statToName(stat));
                        replaceParams["data"] = alb;
                        this.effects.push(new Effect(val, replaceParams));
                        break;
                }
            }
        }
    }

    private function getSpell(_arg_1:XML, _arg_2:XML=null):void
    {
        var _local_3:ComPair = new ComPair(_arg_1, _arg_2, "numShots", 20);
        var _local_4:String = this.colorUntiered("Spell: ");
        _local_4 = (_local_4 + "{numShots} Shots");
        this.effects.push(new Effect(_local_4, {"numShots":TooltipHelper.compare(_local_3.a, _local_3.b)}));
    }

    private function getSkull(itemA:XML, itemB:XML=null):void
    {
        var wis:int = ((this.player != null) ? this.player.wisdom_ : 10);

        var wisPerRad:int = this.GetIntArgument(itemA, "wisPerRad", 10);
        var incrRad:Number = this.GetFloatArgument(itemA, "incrRad", 0.5);
        var wisDamageBase:int = this.GetIntArgument(itemA, "wisDamageBase", 0);
        var wisMin:int = this.GetIntArgument(itemA, "wisMin", 50);
        var hitsForSelfPuri:int = this.GetIntArgument(itemA, "hitsForSelfPuri", -1);
        var hitsForGroupPuri:int = this.GetIntArgument(itemA, "hitsForGroupPuri", -1);

        var compareRadius:ComPair = new ComPair(itemA, itemB, "radius");

        var compareTotalDmg:ComPair = new ComPair(itemA, itemB, "totalDamage");
        var dmgWismodMath:int = (wis - wisMin >= 0 ? wis - wisMin : 0) * wisDamageBase;
        compareTotalDmg.add(dmgWismodMath);

        var compareHealRange:ComPair = new ComPair(itemA, itemB, "healRange", 5);
        var healRangeWismodMath:Number = MathUtil.round(int(incrRad * MathUtil.round((wis - wisMin) / wisPerRad)), 2);
        compareHealRange.add(healRangeWismodMath);

        var text:String = this.colorUntiered("Skull: ");
        text = (text + (("{damage}" + this.colorWisBonus(dmgWismodMath)) + " damage\n"));
        text = (text + "within {radius} squares\n");

        var compareHeal:ComPair = new ComPair(itemA, itemB, "heal");
        if (compareHeal.a)
        {
            text = (text + "Steals {heal} HP");
        }
        var compareIgnoreDef:ComPair = new ComPair(itemA, itemB, "ignoreDef", 0);
        if (((compareHeal.a) && (compareIgnoreDef.a)))
        {
            text = (text + " and ignores {ignoreDef} defense");
        }
        else
        {
            if (compareIgnoreDef.a)
            {
                text = (text + "Ignores {ignoreDef} defense");
            }
        }
        if (compareHeal.a)
        {
            text = (text + (("\nHeals allies within {healRange}" + this.colorWisBonus(healRangeWismodMath)) + " squares"));
        }
        if (hitsForSelfPuri != -1)
        {
            text = (text + "\n{hitsSelf}: Removes negative conditions on self");
        }
        if (hitsForSelfPuri != -1)
        {
            text = (text + "\n{hitsGroup}: Removes negative conditions on group");
        }
        this.effects.push(new Effect(text, {
            "damage":TooltipHelper.compare(compareTotalDmg.a, compareTotalDmg.b),
            "radius":TooltipHelper.compare(compareRadius.a, compareRadius.b),
            "heal":TooltipHelper.compare(compareHeal.a, compareHeal.b),
            "ignoreDef":TooltipHelper.compare(compareIgnoreDef.a, compareIgnoreDef.b),
            "healRange":TooltipHelper.compare(MathUtil.round(compareHealRange.a, 2), MathUtil.round(compareHealRange.b, 2)),
            "hitsSelf":TooltipHelper.getPlural(hitsForSelfPuri, "Hit"),
            "hitsGroup":TooltipHelper.getPlural(hitsForGroupPuri, "Hit")
        }));
        this.AddConditionToEffects(itemA, itemB, "Nothing", 2.5);
    }


    private function getTrap(_arg_1:XML, _arg_2:XML=null):void
    {
        var _local_3:ComPair = new ComPair(_arg_1, _arg_2, "totalDamage");
        var _local_4:ComPair = new ComPair(_arg_1, _arg_2, "radius");
        var _local_5:ComPair = new ComPair(_arg_1, _arg_2, "duration", 20);
        var _local_6:ComPair = new ComPair(_arg_1, _arg_2, "throwTime", 1);
        var _local_7:ComPair = new ComPair(_arg_1, _arg_2, "sensitivity", 0.5);
        var _local_8:Number = MathUtil.round((_local_4.a * _local_7.a), 2);
        var _local_9:Number = MathUtil.round((_local_4.b * _local_7.b), 2);
        var _local_10:String = this.colorUntiered("Trap: ");
        _local_10 = (_local_10 + "{damage} damage within {radius} squares");
        this.effects.push(new Effect(_local_10, {
            "damage":TooltipHelper.compare(_local_3.a, _local_3.b),
            "radius":TooltipHelper.compare(_local_4.a, _local_4.b)
        }));
        this.AddConditionToEffects(_arg_1, _arg_2, "Slowed", 5);
        this.effects.push(new Effect("{throwTime} to arm for {duration} ", {
            "throwTime":TooltipHelper.compareAndGetPlural(_local_6.a, _local_6.b, "second", false),
            "duration":TooltipHelper.compareAndGetPlural(_local_5.a, _local_5.b, "second")
        }));
        this.effects.push(new Effect("Triggers within {triggerRadius} squares", {"triggerRadius":TooltipHelper.compare(_local_8, _local_9)}));
    }

    private function getLightning(_arg_1:XML, _arg_2:XML=null):void
    {
        var _local_15:String;
        var _local_3:int = ((this.player != null) ? this.player.wisdom_ : 10);
        var _local_4:ComPair = new ComPair(_arg_1, _arg_2, "decrDamage", 0);
        var _local_5:int = this.GetIntArgument(_arg_1, "wisPerTarget", 10);
        var _local_6:int = this.GetIntArgument(_arg_1, "wisDamageBase", _local_4.a);
        var _local_7:int = this.GetIntArgument(_arg_1, "wisMin", 50);
        var _local_8:int = Math.max(0, (_local_3 - _local_7));
        var _local_9:int = int((_local_8 / _local_5));
        var _local_10:int = int(((_local_6 / 10) * _local_8));
        var _local_11:ComPair = new ComPair(_arg_1, _arg_2, "maxTargets");
        _local_11.add(_local_9);
        var _local_12:ComPair = new ComPair(_arg_1, _arg_2, "totalDamage");
        _local_12.add(_local_10);
        var _local_13:String = this.colorUntiered("Lightning: ");
        _local_13 = (_local_13 + (("{targets}" + this.colorWisBonus(_local_9)) + " targets\n"));
        _local_13 = (_local_13 + (("{damage}" + this.colorWisBonus(_local_10)) + " damage"));
        var _local_14:Boolean;
        if (_local_4.a)
        {
            if (_local_4.a < 0)
            {
                _local_14 = true;
            }
            _local_15 = "reduced";
            if (_local_14)
            {
                _local_15 = TooltipHelper.wrapInFontTag("increased", ("#" + TooltipHelper.NO_DIFF_COLOR.toString(16)));
            }
            _local_13 = (_local_13 + ((", " + _local_15) + " by \n{decrDamage} for each subsequent target"));
        }
        this.effects.push(new Effect(_local_13, {
            "targets":TooltipHelper.compare(_local_11.a, _local_11.b),
            "damage":TooltipHelper.compare(_local_12.a, _local_12.b),
            "decrDamage":TooltipHelper.compare(_local_4.a, _local_4.b, false, "", _local_14)
        }));
        this.AddConditionToEffects(_arg_1, _arg_2, "Nothing", 5);
    }

    private function getDecoy(_arg_1:XML, _arg_2:XML=null):void
    {
        var _local_3:ComPair = new ComPair(_arg_1, _arg_2, "duration");
        var _local_4:ComPair = new ComPair(_arg_1, _arg_2, "angleOffset", 0);
        var _local_5:ComPair = new ComPair(_arg_1, _arg_2, "speed", 1);
        var _local_6:ComPair = new ComPair(_arg_1, _arg_2, "distance", 8);
        var _local_7:Number = MathUtil.round((_local_6.a / (_local_5.a * 5)), 2);
        var _local_8:Number = MathUtil.round((_local_6.b / (_local_5.b * 5)), 2);
        var _local_9:ComPair = new ComPair(_arg_1, _arg_2, "numShots", 0);
        var _local_10:String = this.colorUntiered("Decoy: ");
        _local_10 = (_local_10 + "{duration}");
        if (_local_4.a)
        {
            _local_10 = (_local_10 + " at {angleOffset}");
        }
        _local_10 = (_local_10 + "\n");
        if (_local_5.a == 0)
        {
            _local_10 = (_local_10 + "Decoy does not move");
        }
        else
        {
            _local_10 = (_local_10 + "{distance} in {travelTime}");
        }
        if (_local_9.a)
        {
            _local_10 = (_local_10 + "\nShots: {numShots}");
        }
        this.effects.push(new Effect(_local_10, {
            "duration":TooltipHelper.compareAndGetPlural(_local_3.a, _local_3.b, "second"),
            "angleOffset":TooltipHelper.compareAndGetPlural(_local_4.a, _local_4.b, "degree"),
            "distance":TooltipHelper.compareAndGetPlural(_local_6.a, _local_6.b, "square"),
            "travelTime":TooltipHelper.compareAndGetPlural(_local_7, _local_8, "second"),
            "numShots":TooltipHelper.compare(_local_9.a, _local_9.b)
        }));
    }

    private function getPoison(_arg_1:XML, _arg_2:XML=null):void
    {
        var _local_3:ComPair = new ComPair(_arg_1, _arg_2, "totalDamage");
        var _local_4:ComPair = new ComPair(_arg_1, _arg_2, "radius");
        var _local_5:ComPair = new ComPair(_arg_1, _arg_2, "duration");
        var _local_6:ComPair = new ComPair(_arg_1, _arg_2, "throwTime", 1);
        var _local_7:ComPair = new ComPair(_arg_1, _arg_2, "impactDamage", 0);
        var _local_8:Number = (_local_3.a - _local_7.a);
        var _local_9:Number = (_local_3.b - _local_7.b);
        var _local_10:String = this.colorUntiered("Poison: ");
        _local_10 = (_local_10 + "{totalDamage} damage");
        if (_local_7.a)
        {
            _local_10 = (_local_10 + " ({impactDamage} on impact)");
        }
        _local_10 = (_local_10 + " within {radius}");
        _local_10 = (_local_10 + " over {duration}");
        this.effects.push(new Effect(_local_10, {
            "totalDamage":TooltipHelper.compare(_local_3.a, _local_3.b, true, "", false, (!(this.sameActivateEffect))),
            "radius":TooltipHelper.compareAndGetPlural(_local_4.a, _local_4.b, "square", true, (!(this.sameActivateEffect))),
            "impactDamage":TooltipHelper.compare(_local_7.a, _local_7.b, true, "", false, (!(this.sameActivateEffect))),
            "duration":TooltipHelper.compareAndGetPlural(_local_5.a, _local_5.b, "second", false, (!(this.sameActivateEffect)))
        }));
        this.AddConditionToEffects(_arg_1, _arg_2, "Nothing", 5);
        this.sameActivateEffect = true;
    }

    private function AddConditionToEffects(_arg_1:XML, _arg_2:XML, _arg_3:String="Nothing", _arg_4:Number=5):void
    {
        var _local_6:ComPair;
        var _local_7:String;
        var _local_5:String = ((_arg_1.hasOwnProperty("@condEffect")) ? _arg_1.@condEffect : _arg_3);
        if (_local_5 != "Nothing")
        {
            _local_6 = new ComPair(_arg_1, _arg_2, "condDuration", _arg_4);
            if (_arg_2)
            {
                _local_7 = ((_arg_2.hasOwnProperty("@condEffect")) ? _arg_2.@condEffect : _arg_3);
                if (_local_7 == "Nothing")
                {
                    _local_6.b = 0;
                }
            }
            this.effects.push(new Effect("Inflicts {condition} for {duration} ", {
                "condition":_local_5,
                "duration":TooltipHelper.compareAndGetPlural(_local_6.a, _local_6.b, "second")
            }));
        }
    }

    private function GetIntArgument(itemXML:XML, effect:String, defa:int=0):int
    {
        return ((itemXML.hasOwnProperty(("@" + effect))) ? int(itemXML.@[effect]) : defa);
    }

    private function GetFloatArgument(itemXML:XML, effect:String, defa:Number=0):Number
    {
        return ((itemXML.hasOwnProperty(("@" + effect))) ? Number(itemXML.@[effect]) : defa);
    }

    private function GetStringArgument(itemXML:XML, effect:String, defa:String=""):String
    {
        return ((itemXML.hasOwnProperty(("@" + effect))) ? itemXML.@[effect] : defa);
    }

    private function colorWisBonus(_arg_1:Number):String
    {
        if (_arg_1)
        {
            return (TooltipHelper.wrapInFontTag(((" (+" + _arg_1) + ")"), ("#" + TooltipHelper.WIS_BONUS_COLOR.toString(16))));
        }
        return ("");
    }

    private function colorUntiered(_arg_1:String):String
    {
        var _local_2:Boolean = this.objectXML.hasOwnProperty("Tier");
        var _local_3:Boolean = this.objectXML.hasOwnProperty("@setType");
        if (_local_3)
        {
            return (TooltipHelper.wrapInFontTag(_arg_1, ("#" + TooltipHelper.SET_COLOR.toString(16))));
        }
        if (!_local_2)
        {
            return (TooltipHelper.wrapInFontTag(_arg_1, ("#" + TooltipHelper.UNTIERED_COLOR.toString(16))));
        }
        return (_arg_1);
    }

    private function getEffectTag(xml:XML, effectValue:String):XML {
        var matches:XMLList;
        var tag:XML;
        matches = xml.Activate.(text() == ActivationType.GENERIC_ACTIVATE);
        for each (tag in matches) {
            if (tag.@effect == effectValue) {
                return (tag);
            }
        }
        return (null);
    }

    private function getStatTag(xml:XML, statValue:String):XML {
        var matches:XMLList;
        var tag:XML;
        matches = xml.Activate.(text() == ActivationType.STAT_BOOST_AURA);
        for each (tag in matches) {
            if (tag.@stat == statValue) {
                return (tag);
            }
        }
        return (null);
    }

    private function addActivateOnEquipTagsToEffectsList():void {
        var _local1:XML;
        var _local2:Boolean = true;
        for each (_local1 in this.objectXML.ActivateOnEquip) {
            if (_local2) {
                this.effects.push(new Effect(TextKey.ON_EQUIP, ""));
                _local2 = false;
            }
            if (_local1.toString() == "IncrementStat") {
                this.effects.push(new Effect(TextKey.INCREMENT_STAT, this.getComparedStatText(_local1)).setReplacementsColor(this.getComparedStatColor(_local1)));
            }
        }
    }

    private function getComparedStatText(_arg1:XML):Object {
        var _local2:int = int(_arg1.@stat);
        var _local3:int = int(_arg1.@amount);
        var _local4:String = (((_local3) > -1) ? "+" : "");
        return ({
            "statAmount": ((_local4 + String(_local3)) + " "),
            "statName": new LineBuilder().setParams(StatData.statToName(_local2))
        });
    }

    private function prefix(_arg_1:int):String
    {
        var _local_2:String = ((_arg_1 > -1) ? "+" : "");
        return (_local_2 + _arg_1);
    }

    private function getComparedStatColor(activateXML:XML):uint {
        var match:XML;
        var otherAmount:int;
        var stat:int = int(activateXML.@stat);
        var amount:int = int(activateXML.@amount);
        var textColor:uint = ((this.playerCanUse) ? TooltipHelper.BETTER_COLOR : TooltipHelper.NO_DIFF_COLOR);
        var otherMatches:XMLList;
        if (this.curItemXML != null) {
            otherMatches = this.curItemXML.ActivateOnEquip.(@stat == stat);
        }
        if (((!((otherMatches == null))) && ((otherMatches.length() == 1)))) {
            match = XML(otherMatches[0]);
            otherAmount = int(match.@amount);
            textColor = TooltipHelper.getTextColor((amount - otherAmount));
        }
        if (amount < 0) {
            textColor = 0xFF0000;
        }
        return (textColor);
    }

    private function addEquipmentItemRestrictions():void {
        if (this.objectXML.hasOwnProperty("Treasure") == false) {
            this.restrictions.push(new Restriction(TextKey.EQUIP_TO_USE, 0xB3B3B3, false));
            if (((this.isInventoryFull) || ((this.inventoryOwnerType == InventoryOwnerTypes.CURRENT_PLAYER)))) {
                this.restrictions.push(new Restriction(TextKey.DOUBLE_CLICK_EQUIP, 0xB3B3B3, false));
            }
            else {
                this.restrictions.push(new Restriction(TextKey.DOUBLE_CLICK_TAKE, 0xB3B3B3, false));
            }
        }
    }

    private function addAbilityItemRestrictions():void {
        this.restrictions.push(new Restriction(TextKey.KEYCODE_TO_USE, 0xFFFFFF, false));
    }

    private function addConsumableItemRestrictions():void {
        this.restrictions.push(new Restriction(TextKey.CONSUMED_WITH_USE, 0xB3B3B3, false));
        if (((this.isInventoryFull) || ((this.inventoryOwnerType == InventoryOwnerTypes.CURRENT_PLAYER)))) {
            this.restrictions.push(new Restriction(TextKey.DOUBLE_CLICK_OR_SHIFT_CLICK_TO_USE, 0xFFFFFF, false));
        }
        else {
            this.restrictions.push(new Restriction(TextKey.DOUBLE_CLICK_TAKE_SHIFT_CLICK_USE, 0xFFFFFF, false));
        }
    }

    private function addReusableItemRestrictions():void {
        this.restrictions.push(new Restriction(TextKey.CAN_BE_USED_MULTIPLE_TIMES, 0xB3B3B3, false));
        this.restrictions.push(new Restriction(TextKey.DOUBLE_CLICK_OR_SHIFT_CLICK_TO_USE, 0xFFFFFF, false));
    }

    private var spriteFile:String = null;
    private var first:Number = -1;
    private var last:Number = -1;
    private var next:Number = -1;
    private var animatedTimer:Timer;

    private function makeAnimation(event:TimerEvent = null):void {
        if (this.spriteFile == null)
            return;

        var size:int = this.iconSize;
        var bitmapData:BitmapData = AssetLibrary.getImageFromSet(this.spriteFile, this.next);

        if (Parameters.itemTypes16.indexOf(this.objectType) != -1 || bitmapData.height == 16)
            size = (size * 0.5);

        bitmapData = TextureRedrawer.redraw(bitmapData, size, true, 0, true, 5);

        this.icon.bitmapData = bitmapData;
        this.icon.x = this.icon.y = - 4;

        this.next++;

        if (this.next > this.last)
            this.next = this.first;
    }

    private function makeRestrictionList():void {
        var _local2:XML;
        var _local3:Boolean;
        var _local4:int;
        var _local5:int;
        this.restrictions = new Vector.<Restriction>();
        if (((((this.objectXML.hasOwnProperty("VaultItem")) && (!((this.invType == -1))))) && (!((this.invType == ObjectLibrary.idToType_["Vault Chest"]))))) {
            this.restrictions.push(new Restriction(TextKey.STORE_IN_VAULT, 16549442, true));
        }
		var spritePeriod:int = -1;
        var spriteFile:String = null;
        var spriteArray:Array = null;
        var first:Number = -1;
        var last:Number = -1;
        var next:Number = -1;
        var makeAnimation:Function;
        var hasPeriod:Boolean = this.objectXML.hasOwnProperty("@spritePeriod");
        var hasFile:Boolean = this.objectXML.hasOwnProperty("@spriteFile");
        var hasArray:Boolean = this.objectXML.hasOwnProperty("@spriteArray");
        var hasAnimatedSprites:Boolean = hasPeriod && hasFile && hasArray;

        if (hasPeriod)
            spritePeriod = 1000 / this.objectXML.attribute("spritePeriod");

        if (hasFile)
            spriteFile = this.objectXML.attribute("spriteFile");

        if (hasArray) {
            spriteArray = String(this.objectXML.attribute("spriteArray")).split('-');
            first = parse(spriteArray[0]);
            last = parse(spriteArray[1]);
        }

        if (hasAnimatedSprites && spritePeriod != -1 && spriteFile != null && spriteArray != null && first != -1 && last != -1) {
            this.spriteFile = spriteFile;
            this.first = first;
            this.last = last;
            this.next = this.first;
            this.animatedTimer = new Timer(spritePeriod);
            this.animatedTimer.addEventListener(TimerEvent.TIMER, this.makeAnimation);
            this.animatedTimer.start();
        }
        //Speciality
        if (this.objectXML.hasOwnProperty("@Quirk")) {
            this.restrictions.push(new Restriction("Speciality: Quirk", 0x39ff14, true));
        }
        if (this.objectXML.hasOwnProperty("@VeryRare")) {
            this.restrictions.push(new Restriction("Speciality: Very Rare", 0x02a4d3, true));
        }
        if (this.objectXML.hasOwnProperty("@Artifact")) {
            this.restrictions.push(new Restriction("Speciality: Artifact", 0xFFA500, true));
        }
        if (this.objectXML.hasOwnProperty("@legendary")) {
            this.restrictions.push(new Restriction("Speciality: Legendary", 0xFFFF00, true));
        }
        if (this.objectXML.hasOwnProperty("@Mythical")) {
            this.restrictions.push(new Restriction("Speciality: Mythical", 0xf10038, true));
        }
        if (this.objectXML.hasOwnProperty("@reskin")) {
            this.restrictions.push(new Restriction("Reskinned Item.", 0xFFce00, true));
        }
        if (this.objectXML.hasOwnProperty("@setType")) {
            this.restrictions.push(new Restriction("Speciality: Artifact", 0xFF9900, false));
        }
        if (this.objectXML.hasOwnProperty("@red")) {
            this.restrictions.push(new Restriction("Speciality: Legendary", 0xcc0066, false));
        }
        if (this.objectXML.hasOwnProperty("@fiery")) {
            this.restrictions.push(new Restriction("Speciality: Fiery", 0xff4500, true));
        }
        if (this.objectXML.hasOwnProperty("@unique")) {
            this.restrictions.push(new Restriction("Speciality: Unique", 0xf8d568, false));
        }
        if (this.objectXML.hasOwnProperty("@unholy")) { //unholy tier
            this.restrictions.push(new Restriction("Speciality: Unholy", 0x6F28CC, false));
        }
        if (this.objectXML.hasOwnProperty("@unholylg")) { //unholy legendary tier
            this.restrictions.push(new Restriction("Speciality: (Unholy) Legendary", 0x6F28CC, true));
        }
        if (this.objectXML.hasOwnProperty("@emoteunlocker")) { //unholy legendary tier
            this.restrictions.push(new Restriction("Emote Unlocking item.", 0x9fa91f, true));
        }
        if (this.objectXML.hasOwnProperty("Common")) {
            this.restrictions.push(new Restriction("Rarity: Common", 0x72ff59, true));
        }
        if (this.objectXML.hasOwnProperty("Uncommon")) {
            this.restrictions.push(new Restriction("Rarity: Uncommon", 0x72ff59, true));
        }
        if (this.objectXML.hasOwnProperty("Rare")) {
            this.restrictions.push(new Restriction("Rarity: Rar" +
                    "e", 0x249eff, true));
        }
        if (this.objectXML.hasOwnProperty("Divine")) {
            this.restrictions.push(new Restriction("Rarity: Divine", 0xD0DEEC, true));
        }
        if (this.objectXML.hasOwnProperty("Epic")) {
            this.restrictions.push(new Restriction("Rarity: Epic", 0x572cb2, true));
        }
        //Additional Information about items
        if (this.objectXML.hasOwnProperty("AdditionalInfo")) {
            this.restrictions.push(new Restriction("Additional Information: " + this.objectXML.AdditionalInfo, 0xFFFFFF, false));
        }
        //SB
        if (this.objectXML.hasOwnProperty("Soulbound")) {
            this.restrictions.push(new Restriction(TextKey.ITEM_SOULBOUND, 0xB3B3B3, false));
        }

        if (this.playerCanUse) {
            if (this.objectXML.hasOwnProperty("Usable")) {
                this.addAbilityItemRestrictions();
                this.addEquipmentItemRestrictions();
            }
            else {
                if (this.objectXML.hasOwnProperty("Consumable")) {
                    this.addConsumableItemRestrictions();
                }
                else {
                    if (this.objectXML.hasOwnProperty("InvUse")) {
                        this.addReusableItemRestrictions();
                    }
                    else {
                        this.addEquipmentItemRestrictions();
                    }
                }
            }
        }
        else {
            if (this.player != null) {
                this.restrictions.push(new Restriction(TextKey.NOT_USABLE_BY, 16549442, true));
            }
        }
        var _local1:Vector.<String> = ObjectLibrary.usableBy(this.objectType);
        if (_local1 != null) {
            this.restrictions.push(new Restriction(TextKey.USABLE_BY, 0xB3B3B3, false));
        }
        for each (_local2 in this.objectXML.EquipRequirement) {
            _local3 = ObjectLibrary.playerMeetsRequirement(_local2, this.player);
            if (_local2.toString() == "Stat") {
                _local4 = int(_local2.@stat);
                _local5 = int(_local2.@value);
                this.restrictions.push(new Restriction(((("Requires " + StatData.statToName(_local4)) + " of ") + _local5), ((_local3) ? 0xB3B3B3 : 16549442), ((_local3) ? false : true)));
            }
        }
    }

    private function makeLineTwo():void {
        this.line2 = new LineBreakDesign((MAX_WIDTH - 12), 0);
        addChild(this.line2);
    }

    private function makeRestrictionText() : void
    {
        if(this.restrictions.length != 0)
        {
            this.restrictionsText = new TextFieldDisplayConcrete().setSize(14).setColor(11776947).setTextWidth(MAX_WIDTH - 4).setIndent(-10).setLeftMargin(10).setWordWrap(true).setHTML(true);
            this.restrictionsText.setStringBuilder(this.buildRestrictionsLineBuilder());
            switch(Parameters.data_.ItemDataOutlines)
            {
                case 0:
                    this.restrictionsText.filters = FilterUtil.getTextOutlineFilter();
                    break;
                case 1:
                    this.restrictionsText.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
            }
            waiter.push(this.restrictionsText.textChanged);
            addChild(this.restrictionsText);
        }
    }

    private function buildRestrictionsLineBuilder():StringBuilder {
        var _local2:Restriction;
        var _local3:String;
        var _local4:String;
        var _local5:String;
        var _local1:AppendingLineBuilder = new AppendingLineBuilder();
        for each (_local2 in this.restrictions) {
            _local3 = ((_local2.bold_) ? "<b>" : "");
            _local3 = _local3.concat((('<font color="#' + _local2.color_.toString(16)) + '">'));
            _local4 = "</font>";
            _local4 = _local4.concat(((_local2.bold_) ? "</b>" : ""));
            _local5 = ((this.player) ? ObjectLibrary.typeToDisplayId_[this.player.objectType_] : "");
            _local1.pushParams(_local2.text_, {
                "unUsableClass": _local5,
                "usableClasses": this.getUsableClasses(),
                "keyCode": KeyCodes.CharCodeStrings[Parameters.data_.useSpecial]
            }, _local3, _local4);
        }
        return (_local1);
    }

    private function getUsableClasses():StringBuilder {
        var _local3:String;
        var _local1:Vector.<String> = ObjectLibrary.usableBy(this.objectType);
        var _local2:AppendingLineBuilder = new AppendingLineBuilder();
        _local2.setDelimiter(", ");
        for each (_local3 in _local1) {
            _local2.pushParams(_local3);
        }
        return (_local2);
    }

    private function addDescriptionText() : void
    {
        var _local_1:int = 0;
        if(this.objectXML.hasOwnProperty("Legendary"))
        {
            _local_1 = 0xcc0066;
        }
        else
        {
            _local_1 = 11776947;
        }
        this.descText = new TextFieldDisplayConcrete().setSize(14).setColor(_local_1).setTextWidth(MAX_WIDTH).setWordWrap(true);
        this.descText.setStringBuilder(new LineBuilder().setParams(String(this.objectXML.Description)));
        switch(Parameters.data_.ItemDataOutlines)
        {
            case 0:
                this.descText.filters = FilterUtil.getTextOutlineFilter();
                break;
            case 1:
                this.descText.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
        }
        waiter.push(this.descText.textChanged);
        addChild(this.descText);
    }

    override protected function alignUI():void {
        this.titleText.x = (this.icon.width + 4);
        this.titleText.y = ((this.icon.height / 2) - (this.titleText.height / 2));
        if (this.tierText) {
            this.tierText.y = ((this.icon.height / 2) - (this.tierText.height / 2));
            this.tierText.x = (MAX_WIDTH - 30);
        }
        this.descText.x = 4;
        this.descText.y = (this.icon.height + 2);
        if (contains(this.line1)) {
            this.line1.x = 8;
            this.line1.y = ((this.descText.y + this.descText.height) + 8);
            this.effectsText.x = 4;
            this.effectsText.y = (this.line1.y + 8);
        }
        else {
            this.line1.y = (this.descText.y + this.descText.height);
            this.effectsText.y = this.line1.y;
        }
        this.line2.x = 8;
        this.line2.y = ((this.effectsText.y + this.effectsText.height) + 8);
        var _local1:uint = (this.line2.y + 8);
        if (this.restrictionsText) {
            this.restrictionsText.x = 4;
            this.restrictionsText.y = _local1;
            _local1 = (_local1 + this.restrictionsText.height);
        }
        if (this.powerText) {
            if (contains(this.powerText)) {
                this.powerText.x = 4;
                this.powerText.y = _local1;
            }
        }
        if (this.legendaryText) {
            if (contains(this.legendaryText)) {
                this.legendaryText.x = 4;
                this.legendaryText.y = _local1;
            }
        }
    }

    private function buildCategorySpecificText():void {
        if (this.curItemXML != null) {
            this.comparisonResults = this.slotTypeToTextBuilder.getComparisonResults(this.objectXML, this.curItemXML);
        }
        else {
            this.comparisonResults = new SlotComparisonResult();
        }
    }

    private function handleWisMod():void {
        var _local3:XML;
        var _local4:XML;
        var _local5:String;
        var _local6:String;
        if (this.player == null) {
            return;
        }
        var _local1:Number = (this.player.wisdom_ + this.player.wisdomBoost_);
        if (_local1 < 30) {
            return;
        }
        var _local2:Vector.<XML> = new Vector.<XML>();
        if (this.curItemXML != null) {
            this.curItemXML = this.curItemXML.copy();
            _local2.push(this.curItemXML);
        }
        if (this.objectXML != null) {
            this.objectXML = this.objectXML.copy();
            _local2.push(this.objectXML);
        }
        for each (_local4 in _local2) {
            for each (_local3 in _local4.Activate) {
                _local5 = _local3.toString();
                if (_local3.@effect != "Stasis") {
                    _local6 = _local3.@useWisMod;
                    if (!(((((((_local6 == "")) || ((_local6 == "false")))) || ((_local6 == "0")))) || ((_local3.@effect == "Stasis")))) {
                        switch (_local5) {
                            case ActivationType.HEAL_NOVA:
                                _local3.@amount = this.modifyWisModStat(_local3.@amount, 0);
                                _local3.@range = this.modifyWisModStat(_local3.@range);
                                break;
                            case ActivationType.COND_EFFECT_AURA:
                                _local3.@duration = this.modifyWisModStat(_local3.@duration);
                                _local3.@range = this.modifyWisModStat(_local3.@range);
                                break;
                            case ActivationType.COND_EFFECT_SELF:
                                _local3.@duration = this.modifyWisModStat(_local3.@duration);
                                break;
                            case ActivationType.STAT_BOOST_AURA:
                                _local3.@amount = this.modifyWisModStat(_local3.@amount, 0);
                                _local3.@duration = this.modifyWisModStat(_local3.@duration);
                                _local3.@range = this.modifyWisModStat(_local3.@range);
                                break;
                            case ActivationType.GENERIC_ACTIVATE:
                                _local3.@duration = this.modifyWisModStat(_local3.@duration);
                                _local3.@range = this.modifyWisModStat(_local3.@range);
                                break;
                        }
                    }
                }
            }
        }
    }

    private function modifyWisModStat(_arg1:String, _arg2:Number = 1):String {
        var _local5:Number;
        var _local6:int;
        var _local7:Number;
        var _local3 = "-1";
        var _local4:Number = (this.player.wisdom_ + this.player.wisdomBoost_);
        if (_local4 < 30) {
            _local3 = _arg1;
        }
        else {
            _local5 = Number(_arg1);
            _local6 = (((_local5) < 0) ? -1 : 1);
            _local7 = (((_local5 * _local4) / 150) + (_local5 * _local6));
            _local7 = (Math.floor((_local7 * Math.pow(10, _arg2))) / Math.pow(10, _arg2));
            if ((_local7 - (int(_local7) * _local6)) >= ((1 / Math.pow(10, _arg2)) * _local6)) {
                _local3 = _local7.toFixed(1);
            }
            else {
                _local3 = _local7.toFixed(0);
            }
        }
        return (_local3);
    }


}
}

import kabam.rotmg.text.view.stringBuilder.AppendingLineBuilder;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

class ComPair
{

    public var a:Number;
    public var b:Number;

    public function ComPair(_arg_1:XML, _arg_2:XML, _arg_3:String, _arg_4:Number=0)
    {
        this.a = (this.b = ((_arg_1.hasOwnProperty(("@" + _arg_3))) ? Number(_arg_1.@[_arg_3]) : _arg_4));
        if (_arg_2)
        {
            this.b = ((_arg_2.hasOwnProperty(("@" + _arg_3))) ? Number(_arg_2.@[_arg_3]) : _arg_4);
        }
    }

    public function add(_arg_1:Number):void
    {
        this.a = (this.a + _arg_1);
        this.b = (this.b + _arg_1);
    }


}

class ComPairTag
{

    public var a:Number;
    public var b:Number;

    public function ComPairTag(_arg_1:XML, _arg_2:XML, _arg_3:String, _arg_4:Number=0)
    {
        this.a = (this.b = ((_arg_1.hasOwnProperty(_arg_3)) ? _arg_1[_arg_3] : _arg_4));
        if (_arg_2)
        {
            this.b = ((_arg_2.hasOwnProperty(_arg_3)) ? _arg_2[_arg_3] : _arg_4);
        }
    }

    public function add(_arg_1:Number):void
    {
        this.a = (this.a + _arg_1);
        this.b = (this.b + _arg_1);
    }


}

class ComPairTagBool
{

    public var a:Boolean;
    public var b:Boolean;

    public function ComPairTagBool(_arg_1:XML, _arg_2:XML, _arg_3:String, _arg_4:Boolean=false)
    {
        this.a = (this.b = ((_arg_1.hasOwnProperty(_arg_3)) ? true : _arg_4));
        if (_arg_2)
        {
            this.b = ((_arg_2.hasOwnProperty(_arg_3)) ? true : _arg_4);
        }
    }

}

class Effect {

    public var name_:String;
    public var valueReplacements_:Object;
    public var replacementColor_:uint = 16777103;
    public var color_:uint = 0xB3B3B3;

    public function Effect(_arg1:String, _arg2:Object) {
        this.name_ = _arg1;
        this.valueReplacements_ = _arg2;
    }

    public function setColor(_arg1:uint):Effect {
        this.color_ = _arg1;
        return (this);
    }

    public function setReplacementsColor(_arg1:uint):Effect {
        this.replacementColor_ = _arg1;
        return (this);
    }

    public function getValueReplacementsWithColor():Object {
        var _local4:String;
        var _local5:LineBuilder;
        var _local1:Object = {};
        var _local2 = "";
        var _local3 = "";
        if (this.replacementColor_) {
            _local2 = (('</font><font color="#' + this.replacementColor_.toString(16)) + '">');
            _local3 = (('</font><font color="#' + this.color_.toString(16)) + '">');
        }
        for (_local4 in this.valueReplacements_) {
            if ((this.valueReplacements_[_local4] is AppendingLineBuilder)) {
                _local1[_local4] = this.valueReplacements_[_local4];
            }
            else {
                if ((this.valueReplacements_[_local4] is LineBuilder)) {
                    _local5 = (this.valueReplacements_[_local4] as LineBuilder);
                    _local5.setPrefix(_local2).setPostfix(_local3);
                    _local1[_local4] = _local5;
                }
                else {
                    _local1[_local4] = ((_local2 + this.valueReplacements_[_local4]) + _local3);
                }
            }
        }
        return (_local1);
    }


}
class Restriction {

    public var text_:String;
    public var color_:uint;
    public var bold_:Boolean;

    public function Restriction(_arg1:String, _arg2:uint, _arg3:Boolean) {
        this.text_ = _arg1;
        this.color_ = _arg2;
        this.bold_ = _arg3;
    }

}


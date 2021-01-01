package kabam.rotmg.Forge
{
import com.company.assembleegameclient.game.AGameSprite;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import io.decagames.rotmg.ui.buttons.SliceScalingButton;
import io.decagames.rotmg.ui.defaults.DefaultLabelFormat;
import io.decagames.rotmg.ui.popups.header.PopupHeader;
import io.decagames.rotmg.ui.popups.modal.ModalPopup;
import io.decagames.rotmg.ui.sliceScaling.SliceScalingBitmap;
import io.decagames.rotmg.ui.texture.TextureParser;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

import kabam.rotmg.ui.view.components.DarkLayer;

import org.osflash.signals.Signal;

public class ForgeUI extends Sprite
{
    private var gs_:AGameSprite;
    public var DecaUi:SliceScalingBitmap;
    public var Background:SliceScalingBitmap;
    public var quitButton:SliceScalingButton;
    public var forgeButton:SliceScalingButton;
    public const close:Signal = new Signal();
    public var BackgroundButton:SliceScalingBitmap;
    private var backgroundAll:SliceScalingBitmap;
    private var nameTextBackground:SliceScalingBitmap;
    public var Title:TextFieldDisplayConcrete;

    public function ForgeUI(arg1:AGameSprite)
    {
        this.gs_ = arg1;
        this.backgroundAll = TextureParser.instance.getSliceScalingBitmap("UI", "popup_header", 600);
        this.backgroundAll.y = 0;
        addChild(this.backgroundAll);
        this.nameTextBackground = TextureParser.instance.getSliceScalingBitmap("UI", "popup_header_title", 400);
        this.nameTextBackground.y = this.backgroundAll.y + 26;
        this.nameTextBackground.x = 105;
        addChild(this.nameTextBackground);
        this.Title = new TextFieldDisplayConcrete().setSize(30).setColor(0xFFFFFF).setBold(true);
        this.Title.setAutoSize(TextFieldAutoSize.CENTER);
        this.Title.setBold(true);
        this.Title.setStringBuilder(new LineBuilder().setParams("Forge"));
        this.Title.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8)];
        this.Title.x = nameTextBackground.x + 200;
        this.Title.y = nameTextBackground.y + 20;
        addChild(this.Title);

        this.Background = TextureParser.instance.getSliceScalingBitmap("UI", "tab_cointainer_background");
        this.Background.width = 575;
        this.Background.height = 404;
        this.Background.x = 10;
        this.Background.y = 125;
        addChild(this.Background);

        this.BackgroundButton = SliceScalingBitmap(TextureParser.instance.getSliceScalingBitmap("UI","main_button_decoration_dark",155));
        this.BackgroundButton.x = 285;
        this.BackgroundButton.y = 451;
        this.BackgroundButton.scaleX = 0.9;
        this.BackgroundButton.scaleY = 0.9;
        addChild(this.BackgroundButton);
        this.forgeButton = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI","generic_green_button"));
        this.forgeButton.x = 305;
        this.forgeButton.y = 455;
        this.forgeButton.width = 100;
        this.forgeButton.setLabel("Forge",DefaultLabelFormat.defaultModalTitle);
        addChild(this.forgeButton);

        this.addForgeUI();
    }

    private var slot1:InventorySlot;
    private var slot2:InventorySlot;
    private var slot3:InventorySlot;
    private var slot4:InventorySlot;
    private var slot5:InventorySlot;
    private var slot6:InventorySlot;

    private var slot7:InventorySlot;
    private var slot8:InventorySlot;
    private var slot9:InventorySlot;
    private var slot10:InventorySlot;
    private var slot11:InventorySlot;

    private var slot12:InventorySlot;
    private var slot13:InventorySlot;
    private var slot14:InventorySlot;
    private var slot15:InventorySlot;

    private var slot16:InventorySlot;
    private var slot17:InventorySlot;
    private var slot18:InventorySlot;

    private var slot19:InventorySlot;

    private function addForgeUI() : void
    {

        this.slot1 = new InventorySlot();
        this.slot1.x = 20;
        this.slot1.y = 165;
        addChild(this.slot1);
        this.slot2 = new InventorySlot();
        this.slot2.x = 110;
        this.slot2.y = 165;
        addChild(this.slot2);
        this.slot3 = new InventorySlot();
        this.slot3.x = 200;
        this.slot3.y = 165;
        addChild(this.slot3);
        this.slot4 = new InventorySlot();
        this.slot4.x = 290;
        this.slot4.y = 165;
        addChild(this.slot4);
        this.slot5 = new InventorySlot();
        this.slot5.x = 380;
        this.slot5.y = 165;
        addChild(this.slot5);
        this.slot6 = new InventorySlot();
        this.slot6.x = 470;
        this.slot6.y = 165;
        addChild(this.slot6);

        this.slot7 = new InventorySlot();
        this.slot7.x = 65;
        this.slot7.y = 235;
        addChild(this.slot7);
        this.slot8 = new InventorySlot();
        this.slot8.x = 155;
        this.slot8.y = 235;
        addChild(this.slot8);
        this.slot9 = new InventorySlot();
        this.slot9.x = 245;
        this.slot9.y = 235;
        addChild(this.slot9);
        this.slot10 = new InventorySlot();
        this.slot10.x = 335;
        this.slot10.y = 235;
        addChild(this.slot10);
        this.slot11 = new InventorySlot();
        this.slot11.x = 425;
        this.slot11.y = 235;
        addChild(this.slot11);

        this.slot12 = new InventorySlot();
        this.slot12.x = 110;
        this.slot12.y = 305;
        addChild(this.slot12);
        this.slot13 = new InventorySlot();
        this.slot13.x = 200;
        this.slot13.y = 305;
        addChild(this.slot13);
        this.slot14 = new InventorySlot();
        this.slot14.x = 290;
        this.slot14.y = 305;
        addChild(this.slot14);
        this.slot15 = new InventorySlot();
        this.slot15.x = 380;
        this.slot15.y = 305;
        addChild(this.slot15);

        addChild(this.slot12);
        this.slot16 = new InventorySlot();
        this.slot16.x = 155;
        this.slot16.y = 375;
        addChild(this.slot16);
        this.slot17 = new InventorySlot();
        this.slot17.x = 245;
        this.slot17.y = 375;
        addChild(this.slot17);
        this.slot18 = new InventorySlot();
        this.slot18.x = 335;
        this.slot18.y = 375;
        addChild(this.slot18);

        this.slot19 = new InventorySlot();
        this.slot19.x = 200;
        this.slot19.y = 445;
        addChild(this.slot19);
    }

    public function getItemSlot1() : InventorySlot
    {
        return this.slot1;
    }

    public function getItemSlot2() : InventorySlot
    {
        return this.slot2;
    }

    private function onClose(param1:Event) : void
    {
        this.close.dispatch();
    }
}
}
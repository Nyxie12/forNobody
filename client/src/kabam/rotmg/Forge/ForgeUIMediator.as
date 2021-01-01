package kabam.rotmg.Forge
{
import com.company.assembleegameclient.game.AGameSprite;
import com.company.assembleegameclient.sound.SoundEffectLibrary;
import flash.events.MouseEvent;

import kabam.lib.net.api.MessageProvider;
import kabam.lib.net.impl.SocketServer;
import kabam.rotmg.dialogs.control.CloseDialogsSignal;
import kabam.rotmg.dialogs.control.OpenDialogNoModalSignal;
import kabam.rotmg.game.signals.AddTextLineSignal;
import kabam.rotmg.messaging.impl.GameServerConnection;
import kabam.rotmg.messaging.impl.data.SlotObjectData;
import kabam.rotmg.messaging.impl.outgoing.ForgeItem;
import org.swiftsuspenders.Injector;
import robotlegs.bender.bundles.mvcs.Mediator;

public class ForgeUIMediator extends Mediator
{


    [Inject]
    public var injector:Injector;

    [Inject]
    public var closeDialogs:CloseDialogsSignal;

    [Inject]
    public var socketServer:SocketServer;

    [Inject]
    public var messages:MessageProvider;

    [Inject]
    public var view:ForgeUI;

    [Inject]
    public var gameSprite:AGameSprite;

    [Inject]
    public var openNoModalDialog:OpenDialogNoModalSignal;

    [Inject]
    public var addTextLine:AddTextLineSignal;

    [Inject]
    public var itemslot1:InventorySlot;

    [Inject]
    public var itemslot2:InventorySlot;

    [Inject]
    public var slot1Data:SlotObjectData;

    [Inject]
    public var slot2Data:SlotObjectData;

    public function ForgeUIMediator()
    {
        super();
    }

    override public function initialize() : void
    {
        this.view.close.add(this.onCancel);
        this.clearItemslots();
        this.itemslot1 = this.view.getItemSlot1();
        this.itemslot2 = this.view.getItemSlot2();
        this.view.forgeButton.addEventListener(MouseEvent.CLICK,this.onButtonForge);
    }

    private function clearItemslots() : void
    {
        this.itemslot1 = null;
        this.itemslot2 = null;
    }

    protected function onButtonForge(_arg_1:MouseEvent) : void
    {
        var _local_1:ForgeItem = null;
        this.slot1Data = new SlotObjectData();
        this.slot1Data.objectId_ = this.itemslot1.objectId;
        this.slot1Data.objectType_ = this.itemslot1.itemId;
        this.slot1Data.slotId_ = this.itemslot1.slotId;
        this.slot2Data = new SlotObjectData();
        this.slot2Data.objectId_ = this.itemslot2.objectId;
        this.slot2Data.objectType_ = this.itemslot2.itemId;
        this.slot2Data.slotId_ = this.itemslot2.slotId;
        _local_1 = this.messages.require(GameServerConnection.FORGEITEM) as ForgeItem;
        _local_1.item1 = this.slot1Data;
        _local_1.item2 = this.slot2Data;
        this.socketServer.sendMessage(_local_1);
        this.closeDialogs.dispatch();
    }

    override public function destroy() : void
    {
        this.view.close.remove(this.onCancel);
    }

    private function onCancel() : void
    {
        SoundEffectLibrary.play("button_click");
        this.closeDialogs.dispatch();
    }
}
}
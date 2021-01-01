package kabam.rotmg.Forge
{
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.util.DisplayHierarchy;
import flash.events.Event;
import flash.events.MouseEvent;
import kabam.rotmg.pets.view.components.slot.FeedFuseSlot;

public class InventorySlot extends FeedFuseSlot
{
    private var unblockItemUpdates:Function;

    public function InventorySlot()
    {
        super();
        itemSprite.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
        this.updateTitle();
    }

    override protected function onRemovedFromStage(param1:Event) : void
    {
        super.onRemovedFromStage(param1);
        this.unblockSlot();
    }

    public function setItem(param1:int, param2:int, param3:int, param4:Function) : void
    {
        if(this.itemId != param1)
        {
            this.unblockSlot();
            this.itemId = param1;
            this.slotId = param2;
            this.objectId = param3;
            itemBitmap.bitmapData = ObjectLibrary.getRedrawnTextureFromType(param1,80,true);
            alignBitmapInBox();
            this.updateTitle();
            this.unblockItemUpdates = param4;
        }
    }

    public function updateTitle() : void
    {
        if(itemId && itemId != -1)
        {
            //setTitle("Ready to Forge.",{});
        }
        else
        {
            //setTitle("Unready to Forge",{});
        }
    }

    private function alignImage(param1:int, param2:int) : void
    {
        itemBitmap.x = -itemBitmap.width / 2;
        itemBitmap.y = -itemBitmap.height / 2;
        itemSprite.x = param1;
        itemSprite.y = param2;
    }

    private function onMouseDown(param1:MouseEvent) : void
    {
        this.alignImage(param1.stageX,param1.stageY);
        itemSprite.startDrag(true);
        itemSprite.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
        if(itemSprite.parent != null && itemSprite.parent != stage)
        {
            removeChild(itemSprite);
            stage.addChild(itemSprite);
        }
    }

    private function onMouseUp(param1:MouseEvent) : void
    {
        itemSprite.stopDrag();
        itemSprite.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
        stage.removeChild(itemSprite);
        addChild(itemSprite);
        alignBitmapInBox();
        var _loc2_:* = DisplayHierarchy.getParentWithTypeArray(itemSprite.dropTarget,InventorySlot);
        if(!(_loc2_ is InventorySlot))
        {
            this.unblockSlot();
            itemId = -1;
            itemBitmap.bitmapData = null;
            this.updateTitle();
        }
    }

    private function unblockSlot() : void
    {
        this.unblockItemUpdates && this.unblockItemUpdates();
        this.unblockItemUpdates = null;
    }
}
}
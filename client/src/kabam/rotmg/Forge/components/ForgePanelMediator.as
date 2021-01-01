package kabam.rotmg.Forge.components
{
import com.company.assembleegameclient.game.AGameSprite;
import flash.events.MouseEvent;

import kabam.rotmg.dialogs.control.OpenDialogNoModalSignal;
import kabam.rotmg.Forge.ForgeUI;

import robotlegs.bender.bundles.mvcs.Mediator;

public class ForgePanelMediator extends Mediator
{


    [Inject]
    public var view:ForgePanel;

    [Inject]
    public var openDialog:OpenDialogNoModalSignal;

    [Inject]
    public var gameSprite:AGameSprite;

    public function ForgePanelMediator()
    {
        super();
    }

    override public function initialize() : void
    {
        this.view.button.addEventListener(MouseEvent.CLICK,this.onButtonLeftClick);
    }

    private function onButtonLeftClick(_arg1:MouseEvent) : void
    {
        this.openDialog.dispatch(new ForgeUI(this.gameSprite));
    }

    override public function destroy() : void
    {
        super.destroy();
    }
}
}

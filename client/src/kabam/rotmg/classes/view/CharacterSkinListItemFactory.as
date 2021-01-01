package kabam.rotmg.classes.view
{
import com.company.assembleegameclient.parameters.Parameters;
import com.company.util.AssetLibrary;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import kabam.rotmg.assets.services.CharacterFactory;
import kabam.rotmg.classes.model.CharacterSkin;
import kabam.rotmg.classes.model.CharacterSkins;
import kabam.rotmg.util.components.LegacyBuyButton;

public class CharacterSkinListItemFactory
{


    [Inject]
    public var characters:CharacterFactory;

    public function CharacterSkinListItemFactory()
    {
        super();
    }

    public function make(param1:CharacterSkins) : Vector.<DisplayObject>
    {
        var _loc2_:* = undefined;
        var _loc3_:int = 0;
        var _loc5_:int = 0;
        _loc2_ = param1.getListedSkins();
        _loc3_ = _loc2_.length;
        var _loc4_:Vector.<DisplayObject> = new Vector.<DisplayObject>(_loc3_,true);
        while(_loc5_ < _loc3_)
        {
            _loc4_[_loc5_] = this.makeCharacterSkinTile(_loc2_[_loc5_]);
            _loc5_++;
        }
        return _loc4_;
    }

    private function makeCharacterSkinTile(param1:CharacterSkin) : CharacterSkinListItem
    {
        var _loc2_:CharacterSkinListItem = new CharacterSkinListItem();
        _loc2_.setSkin(this.makeIcon(param1));
        _loc2_.setModel(param1);
        _loc2_.setLockIcon(AssetLibrary.getImageFromSet("lofiInterface2",5));
        return _loc2_;
    }

    private function makeBuyButton() : LegacyBuyButton
    {
        return new LegacyBuyButton("",16,0,5);
    }

    private function makeIcon(param1:CharacterSkin) : Bitmap
    {
        var _loc2_:int = Parameters.skinTypes16.indexOf(param1.id) != -1 || param1.is16x16?50:100;
        var _loc3_:BitmapData = this.characters.makeIcon(param1.template,_loc2_);
        return new Bitmap(_loc3_);
    }
}
}

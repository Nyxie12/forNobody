package com.company.assembleegameclient.util
{
import com.company.assembleegameclient.misc.DefaultLabelFormat;
import com.company.assembleegameclient.misc.UILabel;
import com.company.assembleegameclient.ui.tooltip.TooltipHelper;

public class TierUtil
{


    public function TierUtil()
    {
        super();
    }

    public static function getTierTag(_arg_1:XML, _arg_2:int = 12) : UILabel
    {
        var _local_9:UILabel = null;
        var _local_10:Number = NaN;
        var _local_11:String = null;
        var _local_3:* = isPet(_arg_1) == false;
        var _local_4:* = _arg_1.hasOwnProperty("Consumable") == false;
        var _local_6:* = _arg_1.hasOwnProperty("Treasure") == false;
        var _local_7:* = _arg_1.hasOwnProperty("PetFood") == false;
        var _local_8:Boolean = _arg_1.hasOwnProperty("Tier");
        if(_local_3 && _local_4 && _local_6 && _local_7)
        {
            _local_9 = new UILabel();
            if(_local_8)
            {
                _local_10 = 16777215;
                _local_11 = "T" + _arg_1.Tier;
            }
            else if (_arg_1.hasOwnProperty("@Normal"))
            {
                _local_10 = 0xb2b6b9;
                _local_11 = "NT";
            }
            else if (_arg_1.hasOwnProperty("@Divine"))
            {
                _local_10 = 0xD0DEEC;
                _local_11 = "DV";
            }
            else if (_arg_1.hasOwnProperty("@Quirk"))
            {
                _local_10 = 0x39ff14;
                _local_11 = "QT";
            }
            else if (_arg_1.hasOwnProperty("@Artifact"))
            {
                _local_10 = 0xFFA500;
                _local_11 = "AT";
            }
            else if (_arg_1.hasOwnProperty("@legendary"))
            {
                _local_10 = 0xFFFF00;
                _local_11 = "LG";
            }
            else if (_arg_1.hasOwnProperty("@Mythical"))
            {
                _local_10 = 0xf10038;
                _local_11 = "MT";
            }
            else if (_arg_1.hasOwnProperty("@unholylg"))
            {
                _local_10 = 0x6F28CC;
                _local_11 = "UT";
            }
            else if(_arg_1.hasOwnProperty("@setType"))
            {
                _local_10 = TooltipHelper.SET_COLOR;
                _local_11 = "ST";
            }
            else if(_arg_1.hasOwnProperty("@VeryRare"))
            {
                _local_10 = 0x02a4d3;
                _local_11 = "VR";
            }
            else if (_arg_1.hasOwnProperty("@unique"))
            {
                _local_10 = 0xf8d568;
                _local_11 = "UT";
            }
            else if (_arg_1.hasOwnProperty("@vanity"))
            {
                _local_10 = 0xed61c;
                _local_11 = "V";
            }
            else if (_arg_1.hasOwnProperty("@red"))
            {
                _local_10 = 0xcc0066;
                _local_11 = "UT";
            }
            else if (_arg_1.hasOwnProperty("@fiery"))
            {
                _local_10 = 0xff4500;
                _local_11 = "F";
            }
            else
            {
                _local_10 = TooltipHelper.UNTIERED_COLOR;
                _local_11 = "UT";
            }
            _local_9.text = _local_11;
            DefaultLabelFormat.tierLevelLabel(_local_9,_arg_2,_local_10);
            return _local_9;
        }
        return null;
    }

    public static function isPet(itemDataXML:XML) : Boolean
    {
        var activateTags:XMLList = null;
        activateTags = itemDataXML.Activate.(text() == "PermaPet");
        return activateTags.length() >= 1;
    }
}
}

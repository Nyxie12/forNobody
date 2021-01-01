package com.company.assembleegameclient.screens
{
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.ColorTransform;
import io.decagames.rotmg.ui.sliceScaling.SliceScalingBitmap;
import io.decagames.rotmg.ui.texture.TextureParser;
import kabam.rotmg.servers.api.Server;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

public class ServerBox extends Sprite
{

    public static const WIDTH:int = 384;

    public static const HEIGHT:int = 52;


    public var value_:String;

    private var nameText_:TextFieldDisplayConcrete;

    private var statusText_:TextFieldDisplayConcrete;

    private var selected_:Boolean = false;

    private var over_:Boolean = false;

    private var background:SliceScalingBitmap;

    public function ServerBox(param1:Server)
    {
        super();
        this.value_ = param1 == null?null:param1.name;
        this.nameText_ = new TextFieldDisplayConcrete().setSize(18).setColor(16777215).setBold(true);
        if(param1 == null)
        {
            this.nameText_.setStringBuilder(new LineBuilder().setParams("ServerBox.best"));
        }
        else
        {
            this.nameText_.setStringBuilder(new StaticStringBuilder(param1.name));
        }
        this.background = TextureParser.instance.getSliceScalingBitmap("UI","popup_content_inset");
        this.background.width = 384;
        this.background.height = 52;
        addChild(this.background);
        this.nameText_.filters = [new DropShadowFilter(0,0,0,1,8,8)];
        this.nameText_.x = 18;
        this.nameText_.setVerticalAlign("middle");
        this.nameText_.y = 52 / 2;
        addChild(this.nameText_);
        this.addUI(param1);
        addEventListener("mouseOver",this.onMouseOver);
        addEventListener("rollOut",this.onRollOut);
    }

    private function addUI(param1:Server) : void
    {
        param1 = param1;
        var onTextChanged:Function = function():void
        {
            makeStatusText(color,text);
        };
        if(param1 != null)
        {
            var color:uint = 65280;
            var text:String = "ServerBox.normal";
            if(param1.isFull())
            {
                color = 16711680;
                text = "ServerBox.full";
            }
            else if(param1.isCrowded())
            {
                color = 16549442;
                text = "ServerBox.crowded";
            }
            this.nameText_.textChanged.addOnce(onTextChanged);
        }
    }

    private function makeStatusText(param1:uint, param2:String) : void
    {
        this.statusText_ = new TextFieldDisplayConcrete().setSize(18).setColor(param1).setBold(true).setAutoSize("center");
        this.statusText_.setStringBuilder(new LineBuilder().setParams(param2));
        this.statusText_.filters = [new DropShadowFilter(0,0,0,1,8,8)];
        this.statusText_.x = 288;
        this.statusText_.y = 52 / 2 - this.nameText_.height / 2;
        addChild(this.statusText_);
    }

    public function setSelected(param1:Boolean) : void
    {
        this.selected_ = param1;
        if(param1)
        {
            this.background.transform.colorTransform = new ColorTransform(1.5,1.5,1.5);
        }
        else
        {
            this.background.transform.colorTransform = new ColorTransform();
        }
    }

    private function onMouseOver(param1:MouseEvent) : void
    {
        this.over_ = true;
        if(!this.selected_)
        {
            this.background.transform.colorTransform = new ColorTransform(1.2,1.2,1.2);
        }
    }

    private function onRollOut(param1:MouseEvent) : void
    {
        this.over_ = false;
        if(!this.selected_)
        {
            this.background.transform.colorTransform = new ColorTransform();
        }
    }
}
}

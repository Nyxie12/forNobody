package kabam.rotmg.chat.control {
// Decompiled by AS3 Sorcerer 1.40
// https://www.as3sorcerer.com/


import com.company.assembleegameclient.parameters.Parameters;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;

import kabam.rotmg.build.api.BuildData;

import kabam.rotmg.chat.model.ChatMessage;
import kabam.rotmg.dailyLogin.model.DailyLoginModel;

import kabam.rotmg.game.signals.AddTextLineSignal;
import kabam.rotmg.text.model.TextKey;

import flash.events.Event;

import kabam.rotmg.ui.model.HUDModel;

public class ParseChatMessageCommand {

    [Inject]
    public var data:String;
    [Inject]
    public var hudModel:HUDModel;
    [Inject]
    public var addTextLine:AddTextLineSignal;
    [Inject]
    public var client:AppEngineClient;
    [Inject]
    public var account:Account;
    [Inject]
    public var buildData:BuildData;
    [Inject]
    public var dailyLoginModel:DailyLoginModel;

    public function execute():void{
        var _local1:Array;
        var _local2:Number;
        var _local3:Number;
        if (this.data.charAt(0) == "/"){
            _local1 = this.data.substr(1, this.data.length).split(" ");
            switch (_local1[0]){
                case "help":
                    this.addTextLine.dispatch(ChatMessage.make(Parameters.HELP_CHAT_NAME, TextKey.HELP_COMMAND));
                    return;
                case "mscale":
                    if (_local1.length == 2 && _local1[1] >= 0.5 && _local1[1] <= 5) {
                        Parameters.data_["mscale"] = _local1[1];
                        Parameters.save();
                        Parameters.root.dispatchEvent(new Event(Event.RESIZE));

                        this.addTextLine.dispatch(ChatMessage.make(Parameters.HELP_CHAT_NAME, ("Map Scale: " + _local1[1])));
                    }
                    else
                        this.addTextLine.dispatch(ChatMessage.make(Parameters.HELP_CHAT_NAME, (("Map Scale: " + Parameters.data_.mscale) + " - Usage: /mscale <any number between 0.5 and 5>")));
                    return;
            };
        };
        this.hudModel.gameSprite.gsc_.playerText(this.data);
    }

}
}//package kabam****tmg.chat.control

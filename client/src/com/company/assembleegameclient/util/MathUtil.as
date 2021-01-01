package com.company.assembleegameclient.util
{
public class MathUtil
{

    public static const TO_DEG:Number = (180 / Math.PI);//57.2957795130823
    public static const TO_RAD:Number = (Math.PI / 180);//0.0174532925199433


    public static function round(input:Number, power:int=0):Number
    {
        var notation:int = Math.pow(10, power);
        return (Math.round((input * notation)) / notation);
    }


}
}//package com.company.assembleegameclient.util


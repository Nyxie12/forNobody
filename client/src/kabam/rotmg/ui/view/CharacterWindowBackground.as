package kabam.rotmg.ui.view {
import com.company.util.GraphicsUtil;

import flash.display.GradientType;
import flash.display.GraphicsGradientFill;
import flash.display.GraphicsPath;
import flash.display.IGraphicsData;
import flash.display.Sprite;

public class CharacterWindowBackground extends Sprite {

    private const gradientFill:GraphicsGradientFill = new GraphicsGradientFill(GradientType.LINEAR,[0,0],[0,1],[0,255],GraphicsUtil.getGradientMatrix(10,600));
    private const gradientPath:GraphicsPath = GraphicsUtil.getRectPath(0,0,10,600);
    private const gradientGraphicsData:Vector.<IGraphicsData> = new <IGraphicsData>[gradientFill,gradientPath,GraphicsUtil.END_FILL];

    public function CharacterWindowBackground() {
        super();
        var bg:Sprite = new Sprite();
        bg.graphics.beginFill(3552822);
        bg.graphics.drawRect(0, 0, 200, 600);
        addChild(bg);
        var gradient:Sprite = new Sprite();
        gradient.graphics.drawGraphicsData(this.gradientGraphicsData);
        gradient.x = -10;
        addChild(gradient);
    }
}
}
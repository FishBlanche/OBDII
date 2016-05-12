package components
{
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	import mx.formatters.NumberBaseRoundType;
	import mx.formatters.NumberFormatter;

	public class tools
	{
		
		public function tools()
		{
		}
		
		//绘制温度表曲线画圆
		public static function circCurveTo(graphics:Graphics, fromAngle:Number,toAngle:Number,centerx:Number,centery:Number,radius:Number):Point
		{
			var startPoint:Point = new Point((Math.cos(fromAngle)*radius) + centerx,(Math.sin(fromAngle)*radius) + centery);//开始位置
			graphics.moveTo(startPoint.x,startPoint.y);
			var slope:Number = Math.PI/512;//坡度 如太低就不准确，会多出一段
			for(var i:Number = fromAngle; i < toAngle; i+= slope)
			{
				var p1:Point = new Point((Math.cos(i+slope/2)*(radius))+centerx,(Math.sin(i+slope/2)*(radius))+centery);//控制点
				var p2:Point = new Point((Math.cos(i+slope)*radius)+centerx,(Math.sin(i+slope)*radius)+centery);
				//graphics.lineTo(p1.x,p1.y);
				
				graphics.curveTo(p1.x,p1.y,p2.x,p2.y);
			}
			
//			graphics.moveTo(startPoint.x,startPoint.y);
//			graphics.lineTo(50,50);
			graphics.endFill();
			return startPoint;
		}
		//绘制温度表范围颜色
		public static function rangeColor(graphics:Graphics, fromAngle:Number,toAngle:Number,centerx:Number,centery:Number,radius:Number):void{
			var radius1:Number = radius * 0.85;
			var radius2:Number = radius * 0.95;
			
			var startPoint:Point = new Point((Math.cos(fromAngle)*radius1) + centerx,(Math.sin(fromAngle)*radius1) + centery);//开始位置
			var endPoint:Point = new Point((Math.cos(toAngle)*radius1) + centerx,(Math.sin(toAngle)*radius1) + centery);//开始位置
			
			radius = radius * 0.9;
			var startPoint2:Point = new Point((Math.cos(fromAngle)*radius2) + centerx,(Math.sin(fromAngle)*radius2) + centery);//开始位置
			var endPoint2:Point = new Point((Math.cos(toAngle)*radius2) + centerx,(Math.sin(toAngle)*radius2) + centery);//开始位置
			
			graphics.moveTo(startPoint.x,startPoint.y);
			graphics.lineTo(startPoint2.x,startPoint2.y);
			
			
			graphics.moveTo(startPoint2.x,startPoint2.y);
			var slope2:Number = Math.PI/512;//坡度 如太低就不准确，会多出一段
			
			var p11:Point;//控制点
			var p22:Point;
			for(var j:Number = fromAngle; j < toAngle; j+= slope2)
			{
				p11 = new Point((Math.cos(j+slope2/2)*(radius2))+centerx,(Math.sin(j+slope2/2)*(radius2))+centery);//控制点
				p22 = new Point((Math.cos(j+slope2)*radius2)+centerx,(Math.sin(j+slope2)*radius2)+centery);
				//graphics.lineTo(p1.x,p1.y);
				
				graphics.curveTo(p11.x,p11.y,p22.x,p22.y);
			}
			
			//graphics.moveTo(p2.x,p2.y);
			graphics.lineTo(endPoint.x,endPoint.y);
			

			//graphics.moveTo(startPoint.x,startPoint.y);
			var slope:Number = Math.PI/512;//坡度 如太低就不准确，会多出一段
			var p1:Point ;//控制点
			var p2:Point ;
			for(var i:Number = toAngle; i > fromAngle; i-= slope)
			{
				p1 = new Point((Math.cos(i+slope/2)*(radius1))+centerx,(Math.sin(i+slope/2)*(radius1))+centery);//控制点
				p2 = new Point((Math.cos(i+slope)*radius1)+centerx,(Math.sin(i+slope)*radius1)+centery);
				//graphics.lineTo(p1.x,p1.y);
				
				graphics.curveTo(p2.x,p2.y,p1.x,p1.y);
			}
			graphics.endFill();
		}
		//绘制温度计刻度
		public static var labels:Array = new Array(); //刻度数字
		
		public static function drawTick(sp:UIComponent,graphics:Graphics,startX:Number,startY:Number,endX:Number,endY:Number,calibrations:Array):Point
		{
			
			var startPoint:Point= new Point(startX,startY);//开始点
			var endPoint:Point= new Point(endX,endY);//结束点
			var tempPoint:Point = new Point(0,0);   //临时点
			tempPoint.x= startPoint.x;
			
			var l:Number = startY - endY;//刻度总高度
			var gap:Number = l/(calibrations.length-1);//主刻度间距
			var gap2:Number = gap/10;//小刻度间距
			
			for(var i:int = 0; i < calibrations.length; i++)
			{
				//绘制摄氏主刻度
				tempPoint.y= startPoint.y - (i*gap);
				graphics.moveTo(tempPoint.x ,tempPoint.y);
				graphics.lineTo(tempPoint.x - tempPoint.x * 0.6,tempPoint.y);
				
				//下面是添加摄氏刻度数字到数组

					var tf2:TextField = new TextField();
					tf2.antiAliasType = AntiAliasType.ADVANCED;
					tf2.autoSize = TextFieldAutoSize.LEFT;
					tf2.text = calibrations[i];
					tf2.selectable = false;
					var fontSize:int = startX*0.255;
					var format:TextFormat = new TextFormat("Verdana",fontSize,0x990099);
					tf2.setTextFormat(format);
					labels.push(tf2);
				//绘制摄氏小刻度
				if(i <calibrations.length  -1){
					for(var j:int=1;j<10;j++){
						var tempY:int= tempPoint.y - (j*gap2);
						graphics.moveTo(tempPoint.x ,tempY);
						if(j==5){
							graphics.lineTo(tempPoint.x-tempPoint.x * 0.3,tempY);//中间
						}else{
							graphics.lineTo(tempPoint.x-tempPoint.x * 0.15,tempY);//小刻度
						}
					}
				}
				
			}
			//设置刻度数字的位置
			for(var z:int = 0; z < calibrations.length; z++)
			{
				tempPoint.y= startPoint.y - (z*gap);
				sp.addChild(labels[z]);
				labels[z].x = tempPoint.x *0.5 - labels[z].width/2;
				labels[z].y = tempPoint.y - labels[z].height;
				
			}
			//trace("tools:"+l);
			//trace(startX*0.255+"tools:"+endY);
			graphics.endFill();
			return startPoint;
		}
		//绘制华氏温度计刻度
		public static var labelsF:Array = new Array(); //刻度数字
		
		public static function drawTickF(sp:UIComponent,graphics:Graphics,startX:Number,startY:Number,endX:Number,endY:Number,calibrations:Array):Point
		{
			
			var startPoint:Point= new Point(startX,startY);//开始点
			var endPoint:Point= new Point(endX,endY);//结束点
			var tempPoint:Point = new Point(0,0);   //临时点
			tempPoint.x= startPoint.x;
			
			var l:Number = startY - endY;//刻度总高度
			var gap:Number = l/(calibrations.length-1);//主刻度间距
			var gap2:Number = gap/10;//小刻度间距
			
			startPoint.y = startPoint.y - gap2;
			endPoint.y = endPoint.y + gap2;
			
			l = startPoint.y - endPoint.y;  //重新设定总高度，和摄氏度对应
			gap = l/(calibrations.length-1);//主刻度间距 重新设定
			gap2 = gap/10;//小刻度间距 重新设定
			
			
			for(var i:int = 0; i < calibrations.length; i++)
			{
				//绘制摄氏主刻度
				tempPoint.y= startPoint.y - (i*gap);
				graphics.moveTo(tempPoint.x ,tempPoint.y);
				graphics.lineTo(tempPoint.x + tempPoint.x * 0.4,tempPoint.y);
				
				//下面是添加摄氏刻度数字到数组
				
				var tf3:TextField = new TextField();
				tf3.antiAliasType = AntiAliasType.ADVANCED;
				tf3.autoSize = TextFieldAutoSize.LEFT;
				tf3.text = calibrations[i];
				tf3.selectable = false;
				var fontSize:int = startX*0.17;
				var format:TextFormat = new TextFormat("Verdana",fontSize,0x990099);
				tf3.setTextFormat(format);
				labelsF.push(tf3);
				
				//绘制摄氏小刻度
				if(i <calibrations.length  -1){
					for(var j:int=1;j<10;j++){
						var tempY:int= tempPoint.y - (j*gap2);
						graphics.moveTo(tempPoint.x ,tempY);
						if(j==5){
							graphics.lineTo(tempPoint.x+tempPoint.x * 0.2,tempY);//中间
						}else{
							graphics.lineTo(tempPoint.x+tempPoint.x * 0.1,tempY);//小刻度
						}
					}
				}
				
			}
			//设置刻度数字的位置
			for(var z:int = 0; z < calibrations.length; z++)
			{
				tempPoint.y= startPoint.y - (z*gap);
				sp.addChild(labelsF[z]);
				labelsF[z].x = tempPoint.x *1.3 - labelsF[z].width/2;
				labelsF[z].y = tempPoint.y - labelsF[z].height;
				
			}
			
			graphics.endFill();
			return startPoint;
		}
	}
}
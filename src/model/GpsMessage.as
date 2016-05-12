package model
{
	import baidu.map.basetype.LngLat;
	import baidu.map.overlay.geometry.Polyline;
	import baidu.map.symbol.Symbol;
	import baidu.map.symbol.PolylineSymbol;
	
	public class GpsMessage
	{
		public var id:int=-1;
		public var  status:String="1";
		public var longtitude:Number=0;
		public var latitude:Number=0;
		public var receiveDate:Date; //数据到达时间
	
		public var polyline:Polyline=new Polyline(new <LngLat>[],new PolylineSymbol(0x0000ff,0.8, 5));
		public function GpsMessage()
		{
		}
	}
}
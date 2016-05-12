package model
{
	 

	public class BdatMessage
	{
		public var  id:int;
		public var status:String; //1为正常
		
		public var  vbat:Number=0;//电瓶电压(V)
		public var  rpm:Number=0;//发动机转速(rpm)
		public var spd:Number=0;//车速(km/h)
		public var tp:Number=0;//节气门开度(%)
		public var lod:Number=0;//(%)
		public var ect:Number=0;//冷却液温度水温(℃)
		public var fli:Number=0;//邮箱剩余油量(%)
		public var mph:Number=0;//瞬时油耗(L/h或L/100km)
		
		public var receiveDate:Date; //数据到达时间
		 
		public function BdatMessage()
		{
		}
		
	}
}
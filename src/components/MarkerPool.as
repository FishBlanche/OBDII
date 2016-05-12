package components
{
	import baidu.map.overlay.Marker;

	public class MarkerPool
	{
		private static var MAX_VALUE:uint;
		private static var GROWTH_VALUE:uint;
		private static var counter:uint;
		private static var pool:Vector.<Marker>;
		private static var currentMarker:Marker;
		public function MarkerPool()
		{
		}
		public static function initialize(maxPoolSize:int,growthValue:int):void
		{
			MAX_VALUE=maxPoolSize;
			GROWTH_VALUE=growthValue;
			counter=maxPoolSize;
			var i:int=maxPoolSize;
			pool=new Vector.<Marker>(MAX_VALUE);
			
			while(--i>-1)
			{
			//	trace("i"+i);
				pool[i]=new Marker;
			}
		}
		public static function getMarker():Marker
		{
			if(counter>0)
			{
				return currentMarker=pool[--counter];
			}
			var i:uint=GROWTH_VALUE;
			while(--i>-1)
			{
				pool.unshift(new Marker());
			}
			counter=GROWTH_VALUE;
			return getMarker();
		}
		public static function disposeMarker(disposedMarker:Marker):void{
			pool[counter++]=disposedMarker;
		}
	}
}
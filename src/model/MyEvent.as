package model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class MyEvent extends Event
	{
		public var data:int;  
		public function MyEvent(type:String,data:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data=data;
		}
	}
}
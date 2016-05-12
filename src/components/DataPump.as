package components
{	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayList;
	import mx.messaging.ChannelSet;
	import mx.messaging.Consumer;
	import mx.messaging.channels.AMFChannel;
	import mx.messaging.events.ChannelEvent;
	import mx.messaging.events.ChannelFaultEvent;
	import mx.messaging.events.MessageEvent;
	import mx.messaging.events.MessageFaultEvent;
	import mx.messaging.messages.IMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.StringUtil;
	
	import spark.managers.PersistenceManager;
	
	import baidu.map.basetype.LngLat;
	
	import model.BdatHistoryMap;
	import model.BdatMessage;
	import model.GpsHistoryMap;
	import model.GpsMessage;
	import model.MyEvent;
	 
	public class DataPump  extends EventDispatcher
	{
	//	private var timerMe:Timer=new Timer(5000);
		private	var httpservice:HTTPService = new HTTPService();
		private var curlng:Number;//当前位置的经度
		private var curlat:Number;//当前位置纬度
    	private var markerclng:Number;//当前位置的经度
		private var markerclat:Number;//当前位置纬度
	    private var prelng:Number;//当前位置的经度
		private var prelat:Number;//当前位置纬度
		private var pianyilng:Number;
		private var pianyilat:Number;
		private	var pianyiOK:Boolean=false;
		//all the buffer are located here, from which data for showing is extracted.
	//	public  var sensingBuf:Array = new Array();
		public static var GpsSensingList:Vector.<GpsMessage>=new Vector.<GpsMessage>;
		public static var BdatSensingList:Vector.<BdatMessage>=new Vector.<BdatMessage>;
	    public static var BdatMapList:Vector.<BdatHistoryMap>=new Vector.<BdatHistoryMap>;
		public static var  GpsMapList:Vector.<GpsHistoryMap>=new Vector.<GpsHistoryMap>;
	 
		private var messageVector:Vector.<String>=new Vector.<String>;
		private var i:int=0;
		private	var j:int=1;
		private var consumer:Consumer=new Consumer();  
 		private var myAMF:AMFChannel=new AMFChannel();
		private var channelSet:ChannelSet=new ChannelSet();
	   
		private  var serveraddress:PersistenceManager = new PersistenceManager();
		private  function  faultHandle(event:FaultEvent):void
		{ 
			trace("MapView  request error");
			trace(event.fault.faultString);
			trace(event.fault.faultDetail);
		}
		private function successhandler(event:ResultEvent):void{
			pianyiOK=false;
		 	
			if(httpservice.lastResult)
			{ 
				if(httpservice.lastResult.GeocoderSearchResponse.status==0)
				{
					
					markerclng=httpservice.lastResult.GeocoderSearchResponse.result.location.lng;
					markerclat=httpservice.lastResult.GeocoderSearchResponse.result.location.lat;
					pianyilng=markerclng-curlng;	 
					pianyilat=markerclat-curlat;
					prelng=curlng;
					prelat=curlat;
					pianyiOK=true;
				    trace(markerclng+","+markerclat);
				}
				else
				{
				//	transLoc.send();
				}
			}
			else
			{
				
			//	transLoc.send();
			}
		}
		public function DataPump()
		{		
		//	timer.addEventListener(TimerEvent.TIMER,timer_handle,false,0,true);
		//	timer.start();
			//myAMF.url="http://s.sensehuge.com:8400/1/messagebroker/amf";
			 
					myAMF.url = "http://61.160.106.206:28088/obd_server/messagebroker/amf"
				 	trace("myAMF.url"+myAMF.url);
					channelSet.addChannel(myAMF); 
				    consumer.destination="newSense";  
				  	consumer.subtopic="message";  
					consumer.channelSet=channelSet;  
					consumer.addEventListener(MessageEvent.MESSAGE, messageHandler,false,0,true);  
					consumer.addEventListener(ChannelFaultEvent.FAULT, fault,false,0,true);  
					consumer.addEventListener(ChannelEvent.CONNECT, connected,false,0,true); 
					consumer.addEventListener(MessageFaultEvent.FAULT, fault2,false,0,true);  
					consumer.subscribe();
					
			//		timerMe.addEventListener(TimerEvent.TIMER,postmessageHandler,false,0,true);
			//		timerMe.start();
					
					
					httpservice.url = "http://api.map.baidu.com/geocoder/v2/";
				    var param:Object = new Object;
					param.ak="FA0d58214f5d7b41c6ff6803a651eb1a";
					param.coordtype="wgs84ll";
					param.location="31.48745,120.382613";
					curlng=120.382613;
					curlat=31.48745;
					httpservice.send(param);
					httpservice.addEventListener(ResultEvent.RESULT,successhandler,false,0,true);
					httpservice.addEventListener(FaultEvent.FAULT,faultHandle,false,0,true);
			 
		 
		 
		 
		}
		
		public function getConsumer():Consumer
		{
			return consumer;
		}
		public function refresh():void
		{
			consumer.subscribe();
		}
		private function messageHandler(event:MessageEvent):void  
		{
			trace("messageHandler"+event.message.body.toString());
			messageVector.push(StringUtil.trim(event.message.body.toString()));
			postmessageHandler();
		}
		private function postmessageHandler():void  
		{   
	    	 if(messageVector.length>0)
			 {
				 var tempId:int=-1;
				 var longtitude:Number=0;
				 var latitude:Number=0;
				 var receiveTime:Date;
				 var  vbat:Number=-1;//电瓶电压(V)
				 var  rpm:Number=-1;//发动机转速(rpm)
				 var spd:Number=-1;//车速(km/h)
				 var tp:Number=-1;//节气门开度(%)
				 var lod:Number=-1;//发动机负荷(%)
				 var ect:Number=-1;//冷却液温度水温(℃)
				 var fli:Number=-1;//邮箱剩余油量(%)
				 var mph:Number=-1;//瞬时油耗(L/h或L/100km)
				
				 var entyArray:Array =   messageVector.shift().split(",");
				 var lenArray:int=entyArray.length;
				 var childArr:Array;
				 childArr=entyArray[0].split(":");
				 
				 
				 if(childArr[0]=="bdat")
				 {
					 trace("childArr[0]==bdat");
					 for(j=1;j<lenArray;j++)
					 {
						 childArr=entyArray[j].split(":");
						 if(childArr.length==2)
						 {
							 if(childArr[1]=="")
							 {
								 return;
							 }
							 switch(childArr[0])
							 {
								 case "id": tempId=int(childArr[1]);
									 break;
								 case "rpm": rpm=Number(childArr[1]);
									 break;
								 case "spd":spd=Number(childArr[1]);
									 break;
								 case "vbat": vbat=Number(childArr[1]);
									 break;
								 case "mph":mph=Number(childArr[1]);
									 break;
								 case "tp": tp=Number(childArr[1]);
									 break;
								 case "lod":lod=Number(childArr[1]);
									 break;
								 case "ect": ect=Number(childArr[1]);
									 break;
								 case "fli":fli=Number(childArr[1]);
									 break;
								 case "receiveDate":receiveTime=Date(childArr[1]);
								 default:break;
							 }
						 }
					 }
					 var lenHisBdat:int=BdatMapList.length;
					 for(var k:int=0;k<lenHisBdat;k++)
					 {
						 if(BdatMapList[k].id==tempId)
						 {
							 var  bdatMe:BdatMessage=new BdatMessage;
							 bdatMe.ect=ect;
							 bdatMe.fli=fli;
							 bdatMe.lod=lod;
							 bdatMe.mph=mph;
							 bdatMe.rpm=rpm;
							 bdatMe.spd=spd;
							 bdatMe.tp=tp;
							 bdatMe.vbat=vbat;
							 bdatMe.receiveDate=receiveTime;
							 BdatMapList[k].bdatVector.push(bdatMe);
							 break;
						 }
					 }
					 if(k==lenHisBdat)
					 {
						 var bdatMap:BdatHistoryMap=new BdatHistoryMap;
						 bdatMap.id=tempId;
						 var  bdatMe:BdatMessage=new BdatMessage;
						 bdatMe.ect=ect;
						 bdatMe.fli=fli;
						 bdatMe.lod=lod;
						 bdatMe.mph=mph;
						 bdatMe.rpm=rpm;
						 bdatMe.spd=spd;
						 bdatMe.tp=tp;
						 bdatMe.vbat=vbat;
						 bdatMe.receiveDate=receiveTime;
						 bdatMap.bdatVector.push(bdatMe);
						 BdatMapList.push(bdatMap);
					 }
					 //BdatSensingList各个节点最新数据更新
					 var lenBdat:int=BdatSensingList.length;
					 for(i=0;i<lenBdat;i++)
					 {
						 if(BdatSensingList[i].id==tempId)
						 {
							 BdatSensingList[i].ect=ect;
							 BdatSensingList[i].fli=fli;
							 BdatSensingList[i].lod=lod;
							 BdatSensingList[i].mph=mph;
							 BdatSensingList[i].rpm=rpm;
							 BdatSensingList[i].spd=spd;
							 BdatSensingList[i].tp=tp;
							 BdatSensingList[i].vbat=vbat;
							 BdatSensingList[i].receiveDate=receiveTime;
							 break;
						 }
					 }
					 if(i==lenBdat)
					 {
						 var newBdat:BdatMessage=new BdatMessage;
						 newBdat.id=tempId;
						 newBdat.ect=ect;
						 newBdat.fli=fli;
						 newBdat.lod=lod;
						 newBdat.mph=mph;
						 newBdat.rpm=rpm;
						 newBdat.spd=spd;
						 newBdat.tp=tp;
						 newBdat.vbat=vbat;
						 newBdat.receiveDate=receiveTime;
						 BdatSensingList.unshift(newBdat);
					 }
					 trace("dispatchEvent");
					 dispatchEvent(new MyEvent("bdatValueChange",int(tempId),true));	
				 }
				 else if(childArr[0]=="gps")
				 {
					  trace("--gps---" );
					 for(j=1;j<lenArray;j++)
					 {
						 childArr=entyArray[j].split(":");
						 if(childArr.length==2)
						 {
							 if(childArr[1]=="")
							 {
								 return;
							 }
							 switch(childArr[0])
							 {
								 case "id": tempId=int(childArr[1]);
									 break;
								 case "longtitude": longtitude=Number(childArr[1]);
									 break;
								 case "latitude":latitude=Number(childArr[1]);
									 break;
								 case "receiveDate":receiveTime=Date(childArr[1]);
								 default:break;
							 }
						 }
					 }
					 //纠偏
					 if(pianyiOK&&(longtitude-prelng>=-0.05&&longtitude-prelng<=0.05)&&(latitude-prelat>=-0.05&&latitude-prelat<=0.05))
					 {
						 longtitude=longtitude+pianyilng;
						 latitude=latitude+pianyilat;
					 }
					 else
					 {
						 curlng=longtitude;
						 curlat=latitude;
						 var param:Object = new Object;
						 param.ak="FA0d58214f5d7b41c6ff6803a651eb1a";
						 param.coordtype="wgs84ll";
						 param.location=curlat+","+curlng;
						 httpservice.send(param);
						 return;
					 }
					 //GpsMapList各个节点历史数据
					 var lenHisGps:int=GpsMapList.length;
					 for(var k:int=0;k<lenHisGps;k++)
					 {
						 if(GpsMapList[k].id==tempId)
						 {
							 
							 var newgps:LngLat=new LngLat(longtitude,latitude);
							 GpsMapList[k].gpsVector.push(newgps);
							 break;
						 }
					 }
					 if(k==lenHisGps)
					 {
						 var gpsMap:GpsHistoryMap=new GpsHistoryMap;
						 gpsMap.id=tempId;
						 var newgps:LngLat=new LngLat(longtitude,latitude);
						 gpsMap.gpsVector.push(newgps);
						 GpsMapList.push(gpsMap);
					 }
					 //GpsSensingList各个节点最新数据更新
					 var lenGps:int=GpsSensingList.length;
					 
					 for(i=0;i<lenGps;i++)
					 {
						 if(GpsSensingList[i].id==tempId)
						 {
							 GpsSensingList[i].longtitude=longtitude;
							 GpsSensingList[i].latitude=latitude;
							 GpsSensingList[i].receiveDate=receiveTime;
						 
							 break;
						 }
					 }
					 if(i==lenGps)
					 {
						 var newGpsNode:GpsMessage=new GpsMessage;
						 newGpsNode.id=tempId;
						 newGpsNode.longtitude=longtitude;
						 newGpsNode.latitude=latitude;   
						 newGpsNode.receiveDate=receiveTime;
						 newGpsNode.polyline.name=newGpsNode.id.toString();
						 
						 GpsSensingList.unshift(newGpsNode);
						 
					 }
					 dispatchEvent(new MyEvent("positionChange",int(tempId),true));				
				 }
		 
			 }
		   
		}
		  
		 
		private function parseUTCDate( str : String ) : Date {
			var matches : Array = str.match(/(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d.\d)Z/);
			
			var d : Date = new Date();
			
			d.setUTCFullYear(int(matches[1]), int(matches[2]) - 1, int(matches[3]));
			d.setUTCHours(int(matches[4]), int(matches[5]), int(matches[6]), 0);
			return d;
		}
		
		
		private function connected(e:ChannelEvent):void  
		{			 
			trace("---connected----");
		}  
		
		
		private function fault(e:ChannelFaultEvent):void  
		{  
			trace("---channel fault----"+e.faultDetail);
			var timer:Timer = new Timer(5000,1);
			timer.addEventListener(TimerEvent.TIMER,timer_Handler);
			timer.start();
			//consumer.unsubscribe();

			//consumer.subscribe();
			
		}  
		
		protected function timer_Handler(event:TimerEvent):void
		{
			// TODO Auto-generated method stub
			consumer.subscribe();
		}
		
		private function fault2(e:MessageFaultEvent):void  
		{  
			trace("---message fault----");
		    var timer:Timer = new Timer(5000,1);
		 	timer.addEventListener(TimerEvent.TIMER,timer_Handler);
			timer.start();
 
			//consumer.subscribe();
		}  
	 
	}  

}	
	

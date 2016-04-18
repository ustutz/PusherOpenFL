package example;

import haxe.Json;
import io.pusherhx.events.PusherConnectionStatusEvent;
import io.pusherhx.events.PusherEvent;
import io.pusherhx.vo.PusherOptions;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.Lib;
import io.pusherhx.Pusher;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import tjson.TJSON;

/**
 * ...
 * @author Urs Stutz
 */
class PusherBitstamp {
	
	static var APP_KEY:String = 'de504dc5763aeef9ff52';
	static var ORIGIN:String = 'http://localhost/';
	
	static var AUTH_ENDPOINT:String = 'https://myserver/auth.php';
	static var SECURE:Bool = true;
	
	var reconnectTimer:Timer;
	var pusher:Pusher;
	
	public function new() {
		initPusher();
	}
	
	
	public function initPusher():Void {
		
		var pusherOptions = new PusherOptions( APP_KEY, ORIGIN );
		
		pusher = new Pusher( pusherOptions );
		
		// Pusher event handling
		pusher.addEventListener(PusherEvent.CONNECTION_ESTABLISHED, pusher_CONNECTION_ESTABLISHED);
		// Pusher websocket event handling
		pusher.addEventListener(PusherConnectionStatusEvent.WS_DISCONNECTED, pusher_WS_DISCONNECTED);
		pusher.addEventListener(PusherConnectionStatusEvent.WS_FAILED, pusher_WS_FAILED);
		pusher.addEventListener(PusherConnectionStatusEvent.WS_INTERRUPTED, pusher_WS_INTERRUPTED);
		
		// Connect websocket
		pusher.connect();
		
		// Reconnect timer
		reconnectTimer = new Timer(1000, 1);
		reconnectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, reconnectTimer_TIMER_COMPLETE);
		reconnectTimer.start();
	}
	
	function reconnectTimer_TIMER_COMPLETE(event:TimerEvent):Void {
		
		pusher.connect();
	}
	
	function pusher_WS_DISCONNECTED(event:PusherConnectionStatusEvent):Void {
		
		trace("Disconnected! " + Json.stringify(event.data));
		
		// Reconnect pusher
		reconnectTimer.reset();
		reconnectTimer.start();
	}
	
	function pusher_WS_FAILED(event:PusherConnectionStatusEvent):Void	{
		
		trace("Connection Failed! " + Json.stringify(event.data));
		
		// Reconnect pusher
		reconnectTimer.reset();
		reconnectTimer.start();
	}
	
	function pusher_WS_INTERRUPTED(event:PusherConnectionStatusEvent):Void {

		trace("Connection interrupt! " + Json.stringify(event.data));
	}
	
	/**
	 * On successful connection subscribe a new channel and hear for events
	 * */
	function pusher_CONNECTION_ESTABLISHED(event:PusherEvent):Void {
		
		trace( "Connected!" );
		
		var tradesChannel = pusher.subscribe( 'live_trades' );
		tradesChannel.addEventListener( 'trade', onData );
		
		trace( "waiting for data..." );
		
	}
	
	function onData( event:PusherEvent ):Void {
		
		trace( event.data );
	}
}
// The MIT License (MIT)
//
// Copyright (c) 2014 Tilman Griesel - <http://rocketengine.io> <http://github.com/TilmanGriesel>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//		
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

package io.pusherhx;

import openfl.net.WebSocket;
import openfl.events.Event;
import openfl.events.EventDispatcher;

import io.pusherhx.channel.PusherChannel;
import io.pusherhx.events.PusherChannelEvent;
import io.pusherhx.events.PusherConnectionStatusEvent;
import io.pusherhx.events.PusherEvent;
import io.pusherhx.utils.PusherConstants;
import io.pusherhx.vo.PusherOptions;
import io.pusherhx.vo.PusherStatus;
import io.pusherhx.vo.WebsocketStatus;

/**
 * Pusher <http://pusher.com> ActionScript3 Client Library
 * @author Tilman Griesel <https://github.com/TilmanGriesel>
 */
class Pusher extends EventDispatcher
{
	
	static var VERSION:String = '0.1.6';
	
	public var verboseLogging:Bool;
	
	// pusherhx vars
	var pusherOptions:PusherOptions;
	public var pusherStatus(default,null):PusherStatus;
	
	// websocket vars
	var websocket:WebSocket;
	var websocketStatus:WebsocketStatus;
	
	// channel bucket
	var channelBucket:Array<PusherChannel>;
	
	/**
	 * @param options all required options for the pusher connection
	 * */
	public function new(options:PusherOptions)
	{
		super();
		
		verboseLogging = false;
		
		// parameter check
		if(options == null)
			throw 'Options cannot be null';
		
		// store options
		pusherOptions = options;
		
		// create small storage object for the websocket and pusher status
		websocketStatus = new WebsocketStatus();
		pusherStatus = new PusherStatus();
		
		// create channel bucket
		channelBucket = new Array<PusherChannel>();
		this.addEventListener(PusherEvent.CONNECTION_ESTABLISHED, this_CONNECTION_ESTABLISHED);
	}

	public function connect():Void
	{
		trace('Connecting...');
		// connect to websocket server
		connectWebsocket();
	}
	
	/**
	 * inital websocket connection
	 * */
	function connectWebsocket():Void
	{
		// check for websocket status storage object
		if(websocketStatus == null)
			throw 'websocket status cannot be null';

		// check for pusher status storage object
		if(pusherStatus == null)
			throw 'pusher status cannot be null';
		
		// check if connection attempt is already in progress
		if(websocketStatus.connecting)
		{
			trace('Already attempting a connection. Aborting...');
			return;
		}
		
		// check if websocket is already connected
		if(websocketStatus.connected)
		{
			trace('Connection is already established. Aborting connection attempt...');
			return;
		}
		
		trace('Environment check successfully completed.');
		
		// update status
		pusherStatus.connecting = true;
		websocketStatus.connecting = true;
		
		// get pusher url
		var pusherURL:String;
		if(pusherOptions.secure)
		{
			pusherURL = pusherOptions.pusherSecureURL;
		}
		else
		{
			pusherURL = pusherOptions.pusherURL;
		}
		
		//trace( "pusherURL " + pusherURL );
		
		// Initialize websocket
		websocket = new WebSocket( pusherURL, pusherOptions.origin, 'wskey', false, ['echo-protocol'] );
		websocket.onOpen.add( onWSOpen );
		websocket.onClose.add( onWSClose );
		websocket.onError.add( onFail );
		websocket.onTextPacket.add( onWSMessage );
		
	}
	
	function onWSOpen( v:Dynamic ):Void
	{	
		trace("Websocket open");
		// store status
		websocketStatus.connected = true;
	}
	
	function onWSMessage(msg:String = ''):Void
	{
		if(verboseLogging) trace('receiving << [', msg, ']');
		
		var pusherEvent:PusherEvent = null;
		
		//try to parse new pusher event from websocket message
		try
		{
			pusherEvent = PusherEvent.parse(StringTools.htmlUnescape(msg));
		}
		catch(e:Dynamic)
		{
			trace('Websocket message parsing error: ' + e.message + ' | message: ' + StringTools.htmlUnescape(msg));
			return;
		}
		
		// look in the channel bucket if channel subscribed and dispatch event on it
		if(pusherEvent.channel != null)
		{
			for(i in 0...channelBucket.length)
			{
				var channel = channelBucket[i];
				if(channel.name == pusherEvent.channel)
				{
					channel.dispatchEvent(pusherEvent);
				}
			}
		}
		else
		{
			// redispatch pusher event
			this.dispatchEvent(pusherEvent);
		}		
	}
	
	function onWSClose( v:Dynamic ):Void
	{
		trace('Websocket closed');
		
		websocketStatus.connected = false;
		websocketStatus.connecting = false;
		websocketStatus.socketID = null;
		
		var evt:PusherConnectionStatusEvent = new PusherConnectionStatusEvent(PusherConnectionStatusEvent.WS_DISCONNECTED);
		//evt.data.code = code;
		//evt.data.msg = msg;
		this.dispatchEvent(evt);
	}
	
	function onFail(msg:String = ''):Void
	{
		trace('Websocket failed ', msg);
		
		websocketStatus.connected = false;
		websocketStatus.connecting = false;
		websocketStatus.socketID = null;
		
		var evt:PusherConnectionStatusEvent = new PusherConnectionStatusEvent(PusherConnectionStatusEvent.WS_FAILED);
		//evt.data.code = code;
		evt.data.msg = msg;
		this.dispatchEvent(evt);
	}
	
	function onWSInterrupt():Void
	{
		trace('Websocket interrupted!');
		
		var evt:PusherConnectionStatusEvent = new PusherConnectionStatusEvent(PusherConnectionStatusEvent.WS_INTERRUPTED);
		//evt.data.interrupted = value;
		this.dispatchEvent(evt);
	}
	
	function this_CONNECTION_ESTABLISHED(event:PusherEvent):Void
	{
		trace('Websocket connection established. socket id: ' + event.data.socket_id);
		
		this.dispatchEvent(new PusherConnectionStatusEvent(PusherConnectionStatusEvent.WS_ESTABLISHED));
		
		pusherStatus.connected = true;
		if(event.data.socket_id != null)
		{
			websocketStatus.socketID = event.data.socket_id;
		}
	}
	
	/**
	 * Subscribes a pusher channel with the given name.
	 * add native event listeners to it
	 * @param channelName The name of your channel
	 * @return a channel instance for event listening and dispatching
	 */	
	public function subscribe(channelName:String):PusherChannel
	{
		// check the pusher connection
		if(pusherStatus.connected == false)
			throw 'cannot subscribe "' + channelName + '" because the pusher service is not connected!';
		
		// pusher channel implentation
		var pusherChannel:PusherChannel;
		
		// define channel type
		if(channelName.indexOf(PusherConstants.CHANNEL_NAME_PRIVATE_PREFIX) != -1)
		{
			trace('subscribing channel "' + channelName + '"...'); 
			pusherChannel = new PusherChannel(PusherChannel.PRIVATE, channelName, dispatchPusherEvent, true, websocketStatus.socketID, pusherOptions.authEndpoint);
		}
		else
		{
			trace('subscribing public channel "' + channelName + '"...'); 
			pusherChannel = new PusherChannel(PusherChannel.PUBLIC, channelName, dispatchPusherEvent);
		}
		
		// add internal channel event listeners
		pusherChannel.addEventListener(PusherChannelEvent.SETUP_COMPLETE, pusherChannel_SETUP_COMPLETE);
		
		// initialize channel (perform auth request etc.)
		pusherChannel.init();
		return pusherChannel;
	}
	
	/**
	 * subscribe channel after setup complete event
	 * */
	function pusherChannel_SETUP_COMPLETE(event:Event):Void
	{
		trace( " pusherChannel_SETUP_COMPLETE" );
		// get channel
		var pusherChannel = cast(event.target, PusherChannel);
		
		// create new channel object
		channelBucket.push(pusherChannel);
		
		// create new pusher event
		var pusherEvent:PusherEvent = new PusherEvent(PusherEvent.SUBSCRIBE);
		pusherEvent.data.channel = pusherChannel.name;
		if (pusherChannel.authenticationSignature.indexOf(pusherOptions.applicationKey + ':') == 0)
			pusherEvent.data.auth = pusherChannel.authenticationSignature;
		else
			pusherEvent.data.auth = pusherOptions.applicationKey + ':' + pusherChannel.authenticationSignature;

		
		// dispatch event to pusher service
		dispatchPusherEvent(pusherEvent);
	}
	
	/**
	 * Remove and unsubscribe channel
	 * */
	public function unsubscribe(channelName:String):Void
	{
		// create new pusher event
		var pusherEvent:PusherEvent = new PusherEvent(PusherEvent.UNSUBSCRIBE);
		pusherEvent.data.channel = channelName;
		
		// search for channel in bucket
		for(i in 0...channelBucket.length)
		{
			var channel = channelBucket[i];
			if(channel.name == pusherEvent.channel)
			{
				// remove channel from bucket
				channelBucket.splice(i, 1);
			}
		}
	}
	
	/**
	 * dispatch event to pusher service
	 * **/
	public function dispatchPusherEvent(event:PusherEvent):Void
	{
		// check websocket connection
		if(websocketStatus.connected == false)
		{
			trace('Websocket is not connected... Cannot dispatch event!');
		}
		
		if(verboseLogging) trace('sending >> [', event.toJSON(), ']');
		websocket.sendText(event.toJSON());
	}
	
}


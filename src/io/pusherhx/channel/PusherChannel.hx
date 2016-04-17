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

package io.pusherhx.channel;
	
import openfl.events.EventDispatcher;

import io.pusherhx.auth.PusherAuthenticator;
import io.pusherhx.events.PusherAuthenticationEvent;
import io.pusherhx.events.PusherChannelEvent;
import io.pusherhx.events.PusherEvent;
import io.pusherhx.utils.PusherConstants;

/**
 * Pusher <http://pusher.com> Channel
 * @author Tilman Griesel <https://github.com/TilmanGriesel>
 */
class PusherChannel extends EventDispatcher
{
	static public var PUBLIC:String = 'public';
	static public var PRIVATE:String = 'private';
	static public var PRESENCE:String = 'presence';
	
	public var type(default,null):String;
	public var name:String;
	public var pusherEventDispatcherCallback(null,default):PusherEvent->Void;
	public var authenticationSignature(default,null):String = '';
	
	var authenticationRequired:Bool;
	var socketID:String;
	var authenticationEndPoint:String;
	
	public function new(	type:String, 
							name:String, pusherEventDispatcherCallback:PusherEvent->Void,
							authenticationRequired:Bool = false, socketID:String = '',
							authenticationEndPoint:String = '')
	{
		super();
		// copy vars
		this.type = type;
		this.name = name;
		this.pusherEventDispatcherCallback = pusherEventDispatcherCallback;
		
		this.authenticationRequired = authenticationRequired;
		this.socketID = socketID;
		this.authenticationEndPoint = authenticationEndPoint;

	}
	
	public function init():Void
	{
		// if authentication is required (/ presence channels) load the signature from the server
		// and dispatch the complete event after it
		// else dispatch complete event immediately
		if(authenticationRequired)
		{
			if(authenticationEndPoint == '')
				throw 'The authentication endpoint cannot be empty if authentication is enabled!';
			
			authenticate(socketID, authenticationEndPoint);
		}
		else
		{
			this.dispatchEvent(new PusherEvent(PusherChannelEvent.SETUP_COMPLETE));
		}
	}
	
	/**
	 * Dispatch pusher event on the channel
	 * notice: the channel name and the "client" prefix will be set
	 * automatically 
	 * @param Pusher event
	 * */
	public function dispatchPusherEvent(event:PusherEvent):Void
	{
		if(pusherEventDispatcherCallback == null)
			return;
		
		event.channel = name;
		event.event = PusherConstants.CLIENT_EVENT_NAME_PREFIX + event.event;
		
		event.data.auth = authenticationSignature;
		pusherEventDispatcherCallback(event);
	}
	
	function authenticate(socketID:String, authenticationEndPoint:String):Void
	{
		var pusherAuthenticator:PusherAuthenticator = new PusherAuthenticator();
		pusherAuthenticator.addEventListener(PusherAuthenticationEvent.SUCCESSFUL, pusherAuthenticator_SUCESSFULL, false, 0, true);
		pusherAuthenticator.addEventListener(PusherAuthenticationEvent.FAILED, pusherAuthenticator_FAILED, false, 0, true);
		
		pusherAuthenticator.authenticate(socketID, authenticationEndPoint, name);
	}
	
	function pusherAuthenticator_SUCESSFULL(event:PusherAuthenticationEvent):Void
	{
		authenticationSignature = event.signature;
		this.dispatchEvent(new PusherEvent(PusherChannelEvent.SETUP_COMPLETE));
	}
	
	function pusherAuthenticator_FAILED(event:PusherAuthenticationEvent):Void
	{
		this.dispatchEvent(new PusherEvent(PusherChannelEvent.SETUP_FAILED));
	}
	
}

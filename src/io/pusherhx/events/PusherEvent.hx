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

package io.pusherhx.events;

import haxe.Json;
import openfl.events.Event;
import tjson.TJSON;

import io.pusherhx.utils.PusherConstants;

/**
 * Pusher <http://pusher.com> PusherEvent
 * @author Tilman Griesel <https://github.com/TilmanGriesel>
 */
class PusherEvent extends Event
{
	// constants
	static public var CONNECTION_ESTABLISHED:String = PusherConstants.CONNECTION_ESTABLISHED_EVENT_NAME;
	static public var CONNECTION_DISCONNECTED:String = PusherConstants.CONNECTION_DISCONNECTED_EVENT_NAME;
	static public var CONNECTION_FAILED:String = PusherConstants.CONNECTION_FAILED_EVENT_NAME;
	static public var ERROR_EVENT_NAME:String = PusherConstants.ERROR_EVENT_NAME;
	static public var SUBSCRIPTION_SUCCEEDED:String = PusherConstants.SUBSCRIPTION_SUCCEEDED_EVENT_NAME;
	static public var MEMBER_ADDED:String = PusherConstants.MEMBER_ADDED_EVENT_NAME;
	static public var MEMBER_REMOVED:String = PusherConstants.MEMBER_REMOVED_EVENT_NAME;
	static public var SUBSCRIBE:String = PusherConstants.SUBSCRIBE_EVENT_NAME;
	static public var UNSUBSCRIBE:String = PusherConstants.UNSUBSCRIBE_EVENT_NAME;
	
	// vars
	public var event:String;
	public var channel:String;
	public var data:Dynamic;
	
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false):Void 
	{
		super(type, bubbles, cancelable);
		
		event = type;
		data = { };
	}
	
	override public function clone():Event 
	{ 
		return new PusherEvent(this.type, this.bubbles, this.cancelable);
	} 
	
	/**
	 * Parse JSON String to an pusher event
	 * @param data json encoded pusher message
	 * @return pusher event
	 * */
	public static function parse(data:Null<String>):PusherEvent
	{
		// check if message object is null
		if(data == null)
			throw 'data cannot be empty';
		
		//trace( "incoming data: " + data );
			
		// decode JSON data string to an raw object
		//var decodedObject = Json.parse( decodeURIComponent(data));
		var decodedObject = TJSON.parse(data);
		
		var pusherEvent:PusherEvent = null;
		
		
		// parse "event" property
		if(decodedObject.event != null)
		{
			// replace client event name prefix
			var eventName:String =  decodedObject.event;
			if(eventName.indexOf(PusherConstants.CLIENT_EVENT_NAME_PREFIX) != -1)
			{
				eventName = StringTools.replace( eventName, PusherConstants.CLIENT_EVENT_NAME_PREFIX, '');	
			}
			
			// create new pusher event
			pusherEvent = new PusherEvent(eventName);
		}
		else
		{
			throw 'cannot find "event" property!';
		}
		
		// parse "data" property
		if(decodedObject.data != null)
		{
			
			try
			{
				pusherEvent.data = TJSON.parse(decodedObject.data);
			}
			catch(e:Dynamic)
			{
				throw('Cannot parse data part! ' + decodedObject.data );
			}
		}
		
		// parse "channel" property
		if(decodedObject.channel != null)
		{
			pusherEvent.channel = decodedObject.channel;
		}
		
		// return pusher event
		return pusherEvent;
	}
	
	/**
	 * Returns the AS3 event as an Pusher JSON String
	 * @return Pusher JSON Event String
	 * */
	public function toJSON():String
	{
		var pusherEvent:PusherEventData = {
			channel : this.channel,
			data : this.data,
			event : this.event
		}
		
		var eventString:String = Json.stringify(pusherEvent);
		return eventString;
	}
}

typedef PusherEventData = {
	channel:String,
	data:Dynamic,
	event:String
}
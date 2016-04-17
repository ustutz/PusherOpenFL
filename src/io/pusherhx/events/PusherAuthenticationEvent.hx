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

import openfl.events.Event;

/**
 * Pusher <http://pusher.com> PusherAuthenticationEvent
 * @author Tilman Griesel <https://github.com/TilmanGriesel>
 */
class PusherAuthenticationEvent extends Event
{
	// var
	static public var SUCCESSFUL:String = 'successful';
	static public var FAILED:String = 'failed';
	
	// vars
	public var signature(default,null):String;
	
	public function new(type:String, signature:String = '', bubbles:Bool = false, cancelable:Bool = false):Void 
	{ 
		super(type, bubbles, cancelable);
		this.signature = signature;
	}
	
	override public function clone():Event 
	{ 
		return new PusherAuthenticationEvent(this.type, this.signature, this.bubbles, this.cancelable);
	} 
	
	override public function toString():String 
	{ 
		return formatToString("PusherAuthenticationEvent", "type", "signature", "bubbles", "cancelable", "eventPhase"); 
	}
}

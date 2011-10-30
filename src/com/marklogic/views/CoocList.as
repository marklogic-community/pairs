﻿/* ----------------------------------------------------------------------	Copyright 2002-2010 MarkLogic Corporation.  All Rights Reserved.---------------------------------------------------------------------- */package com.marklogic.views {		import flash.display.Sprite;	import com.marklogic.interfaces.IListItem;	import com.marklogic.interfaces.IList;	import flash.events.MouseEvent;	import com.marklogic.events.CoocListEvent;	import flash.display.Graphics;	import com.marklogic.ui.ListTitleField;	import com.marklogic.views.FilterManager;	import com.marklogic.controls.FilterBox;	import com.marklogic.controls.CoocListItem;	import com.caurina.transitions.Tweener;		import ListBackBtn;		public class CoocList extends Sprite implements IList {				// Constants:		protected const PADDING:Number = 1;		protected const MAX_SIZE:Number = 35;		protected const MIN_SIZE:Number = 12;		// Public Properties:		// Private Properties:		protected var _itemHolder:Sprite;		protected var _lineHolder:Sprite;		protected var _mode:String;		protected var _title:ListTitleField;		protected var _listBackBtn:ListBackBtn;		protected var _backLabel:String;		protected var _filterManager:FilterManager;		protected var _index:int;		protected var _rendererClass:Class;		protected var _searchLabel:String;				protected var _yVal:Array = [];				// UI Elements:				// Initialization:		public function CoocList() { configUI(); }				// Public Methods:		public function removeItems():void {			_filterManager.clearFilters();			var count:uint = _itemHolder.numChildren;			for (var i:uint=0;i<count;i++) { _itemHolder.removeChildAt(0); }			_title.label = '';			_lineHolder.graphics.clear();			_title.visible = _listBackBtn.visible = false;		}				public function addFilter(value:*):void {			if (value) { 				if (value is Array) {					_filterManager.singleDisplay = false;					var l:Number = value.length;					for (var i:int=0;i<l;i++) { _filterManager.addFilter(value[i]); }				} else {					// Single filter added either on KeyUp or KeyDown					_filterManager.singleDisplay = true;					_filterManager.addFilter(value);				}			}			invalidateDisplay();		}				public function clearFilter():void {			_filterManager.clearFilters();			invalidateDisplay();		}				public function set renderer(value:Class):void {			_rendererClass = value;		}				public function showSelectedState():void { }				public function set dataProvider(value:XMLList):void {			removeItems();			var i:int = 0;			var data:XML;			var obj:Object = {};			var l:Number = value.length();						var total:Number = 0;			var avg:Number = 0;			var midFont:Number = 22; // <- make bigger for larger average fontsize;						for (i=0;i<l;i++) { total += Number(value[i].@value.split(',').join('')); }						avg = l > 0 ? (total/l) : 1;			//avg = l > 0 ? Math.round(total/l) : 1;			//trace("avg:",avg);			if (l > 0) {				var big:Number = Number(value[0].@value.split(',').join(''));				var small:Number = Number(value[l-1].@value.split(',').join(''));			}			//trace("big-small:",big-small);			if ((big-small) > 0) {				if ((big-small) < avg) {					if (avg <= 1) {						//trace("-- 1 --");						midFont = (17 + (big-small)/10);					} else {						//trace("-- 2 --");										midFont = (22 - Math.ceil((big-small)/l));					}				} else if (avg > 1) {					//trace("-- 3 --");					midFont = 22;					//midFont = (avg > 1) ? Math.round(22 - ((big-small)/10)) : Math.round(17 + ((big-small)/10)); // This fixes the edge case where most items have a count of 1				} else if (avg <= 1) {					midFont = 20;//(17 + (big-small)/10);					//trace("-- 4 --");				}			} else {				//trace("-- 5 --");				midFont = 20.5;			}			//midFont = (avg > 1) ? 22 : 17; // This fixes the edge case where most items have a count of 1						//midFont = (avg > 1) ? Math.round(22 - ((big-small)/10)) : Math.round(17 + ((big-small)/10)); // This fixes the edge case where most items have a count of 1						i=0;			var __y:Number = 0;			_itemHolder.x = _filterManager.width + 4;			var g:Graphics = _lineHolder.graphics;			g.clear();			var item:IListItem;			_yVal = [];			var index:Number = 0;			var dataArr:Array = [];			for each(data in value){				var multiplier:Number = Number(data.@value.split(',').join(''))/avg;				if (multiplier < 0.6 && avg <= 2) {					multiplier = 0.7;				}				var ptSize = Math.round(multiplier * midFont);				item = new _rendererClass();				item.hide();				item.fromXML(data);				item.size = Math.min(Math.max(ptSize, MIN_SIZE), MAX_SIZE);				_itemHolder.addChild(item as Sprite);				item.y = Math.round(__y);				_yVal.push(item.y+item.height/2);				__y += (item.height + PADDING);			}		}				public function showItems():void {			var l:int;			var i:int;			var item:IListItem;			if (_mode == 'singleMode') {				_filterManager.clearFilters();				label = _backLabel;				invalidateDisplay();				l = _yVal.length;				for (i=0; i<l; i++) {					item = _itemHolder.getChildAt(i) as IListItem;					item.show((i*(10)) / 100);				}			} else {				l = _itemHolder.numChildren;				for (i=0;i<l;i++) {					item = _itemHolder.getChildAt(i) as IListItem;					item.show((i*(10)) / 100);				}			}		}				public function set searchLabel(value:String):void {			_searchLabel = value;		}		public function findSearchItem():IListItem { return null; }		public function hideItems(p_tween:Boolean=true):void { }				public function set index(value:int):void { _index = value; }				public function set mode(value:String):void {			_mode = value;			_title.visible = (_mode == 'singleMode');			_listBackBtn.visible = (_index != 0);		}				public function set label(value:String):void {			_backLabel = value;			_title.label = value;			if (value.length > 45) { _title.truncate(20); _title.toolTip = true; }			_title.visible = _listBackBtn.visible = true;			_title.width = 250;		}		public function get label():String { return _backLabel; }				public function recalculateWidth():void {			var l:int;			var i:int;			var item:IListItem;			l = _yVal.length;			for (i=0; i<l; i++) {				item = _itemHolder.getChildAt(i) as IListItem;				item.recalculateWidth();			}		}				// Protected Methods:		protected function onBackClick(p_event:MouseEvent):void { dispatchEvent(new CoocListEvent(CoocListEvent.BACK,{})); }				protected function invalidateDisplay():void {			var centerPoint:Number = 150;			var g:Graphics = _lineHolder.graphics;			g.clear();			var item:IListItem;			var i:int = 0;			var l:int = _yVal.length;			//			var speed:Number;			var _titleX:Number;			var _lineHolderX:Number;			var _itemHolderX:Number;			 _title.y = centerPoint - _title.height/2;			 _listBackBtn.y = _title.y + _title.height/2 - _listBackBtn.height/2;			// _title.y = _listBackBtn.y = centerPoint - _title.height/2; // Original			if (_mode == 'singleMode') {				_titleX = _listBackBtn.width + 5;				if (_filterManager.length > 0 ) {					_filterManager.y = 5;					_filterManager.x = (_index != 0) ? _listBackBtn.x + _listBackBtn.width + 2 : 0;					speed = (.4 * _filterManager.length);					_titleX = _filterManager.x + _filterManager.width + 5;					Tweener.addTween(_title,{x:_titleX,time:speed, transition:'easeoutexpo'});					_lineHolderX = _titleX + _title.width + 10;					_itemHolderX = (_lineHolderX + _lineHolder.width ) + 100;					Tweener.addTween(_lineHolder,{x:_lineHolderX,time:speed, transition:'easeoutexpo'});					Tweener.addTween(_itemHolder,{x:_itemHolderX,time:speed, transition:'easeoutexpo'});				} else {					_lineHolderX = _titleX + _title.width + 10;					_itemHolderX = _lineHolderX + 100;					Tweener.addTween(_title,{x:_titleX,time:.5,transition:'easeoutexpo'});					Tweener.addTween(_lineHolder,{x:_lineHolderX,time:.5,transition:'easeoutexpo'});					Tweener.addTween(_itemHolder,{x:_itemHolderX ,time:.5,transition:'easeoutexpo'});				}				//								g.moveTo(0,centerPoint);				g.lineStyle(1,0x333333);				for (i=0; i<l; i++) {					g.lineTo(_itemHolderX - _lineHolderX, _yVal[i]);					g.moveTo(0,150);					item = _itemHolder.getChildAt(i) as IListItem;				}							} else {				if (_filterManager.length > 0 ) {					speed = (.4 * _filterManager.length);					_title.label = '';					_listBackBtn.visible = (_index != 0);					_filterManager.x = (_index != 0) ? _listBackBtn.x + _listBackBtn.width + 2 : 0;					_filterManager.y = 5;					Tweener.addTween(_itemHolder,{x:_filterManager.x + _filterManager.width + 3,time:speed, transition:'easeoutexpo'});									} else {					// no need;					//Tweener.addTween(_itemHolder,{x:0,time:.5, transition:'easeoutexpo' });				}			}		}				// Private Methods:		protected function configUI():void {			_rendererClass = CoocListItem;			_itemHolder= new Sprite();			_lineHolder = new Sprite();			_title = new ListTitleField();			_listBackBtn = new ListBackBtn();			addChild(_itemHolder);			addChild(_lineHolder);			addChild(_listBackBtn);			addChild(_title);			_filterManager = new FilterManager();			addChild(_filterManager);			_title.label = '';			_title.visible = false;			_listBackBtn.visible = false;			_listBackBtn.addEventListener(MouseEvent.CLICK,onBackClick,false,0,true);		}	}	}
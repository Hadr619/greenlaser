using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.ActivityMonitor as Act;
using Toybox.Communications as Comm;


class GreenLaserView extends Ui.WatchFace {
	
	var heart;
	var sarpanchBold;
	var sarpanchReg;
	var ampm;
	var garminSym;
	
    function initialize() {
        WatchFace.initialize();

    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc)); 
        heart = Ui.loadResource(Rez.Drawables.heart);
        sarpanchBold = Ui.loadResource(Rez.Fonts.sarpanchBold);
        sarpanchReg = Ui.loadResource(Rez.Fonts.sarpanchReg);
        garminSym = Ui.loadResource(Rez.Fonts.garminSym);
    }

    function onShow() {
    }

    function onUpdate(dc) {
    	dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    	dc.clear();
    	var smallFont = Gfx.FONT_SYSTEM_SMALL;
    	var activity = ActivityMonitor.getInfo();
    	var clockTime = Sys.getClockTime();
    	var hour = clockTime.hour;
    	var minute = Lang.format("$1$",[clockTime.min.format("%02d")]);
    	var today = Time.today();
    	var dateInfo = Time.Gregorian.info(today, Time.FORMAT_MEDIUM);
    	var date = Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week.toUpper(), dateInfo.month.toUpper(), dateInfo.day]);
    	var dayOfWeek = dateInfo.day_of_week.toUpper();
    	var month = dateInfo.month.toUpper();
    	var day = dateInfo.day;
    	var monthDim = dc.getTextDimensions(month,smallFont);
		var dayOfWeekDim = dc.getTextDimensions(dayOfWeek,smallFont);
		//var dayDim = dc.getTextDimensions(day,smallFont);
    	var percent =  activity.steps.toFloat()/activity.stepGoal;
    	var hrtIter = (Act has :HeartRateIterator) ? Act.getHeartRateHistory(1, true) : null;   
    	
    	var x = (dc.getWidth() / 2);
    	var y = (dc.getHeight() / 2);
    	
 
    	var batteryPercent = Lang.format("$1$%", [Sys.getSystemStats().battery.format("%02d")]);


    	var messages = Sys.getDeviceSettings();
    	var newMessages = messages.notificationCount + " messages";
    	
    	
		//TIME
    	if(!Sys.getDeviceSettings().is24Hour){
    	  	ampm = (hour > 11) ? "PM" : "AM";
			hour = hour % 12;
			hour = (hour == 0) ? 12 : hour;
			if(hour > 10){
				
				hour = hour.format("%02d");
				var minuteDim = dc.getTextDimensions(minute,sarpanchReg);
		    	var hourDim = dc.getTextDimensions(hour,sarpanchBold);
		    	var minuteHeight = minuteDim[1];
		    	var minuteWidth = minuteDim[0];
		    	var hourWidth = hourDim[0];
				dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_BLACK);
				dc.drawText(x - 10, 15, sarpanchBold, hour.toString(), Gfx.TEXT_JUSTIFY_RIGHT);
				dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_BLACK);
				dc.drawText(x - 10, 15, sarpanchReg, Lang.format("$1$",[clockTime.min.format("%02d")]), Gfx.TEXT_JUSTIFY_LEFT);
				dc.drawText((x + minuteWidth) - 10, minuteHeight - 20, Gfx.FONT_SYSTEM_XTINY, ampm, Gfx.TEXT_JUSTIFY_LEFT);
			} else {
			
				hour = hour.format("%02d");
				var minuteDim = dc.getTextDimensions(minute,sarpanchReg);
		    	var hourDim = dc.getTextDimensions(hour,sarpanchBold);
		    	var minuteHeight = minuteDim[1];
		    	var minuteWidth = minuteDim[0];
		    	var hourWidth = hourDim[0];
				dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_BLACK);
				dc.drawText(x, 15, sarpanchBold, hour.toString(), Gfx.TEXT_JUSTIFY_RIGHT);
				dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_BLACK);
				dc.drawText(x , 15, sarpanchReg, Lang.format("$1$",[clockTime.min.format("%02d")]), Gfx.TEXT_JUSTIFY_LEFT);
				dc.drawText(x + minuteWidth, minuteHeight - 20, Gfx.FONT_SYSTEM_XTINY, ampm, Gfx.TEXT_JUSTIFY_LEFT);
			}
			
			
    	}

		//DATE
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    	dc.drawText((x - monthDim[0]) - 10,(dc.getHeight() / 2) -5, smallFont, dayOfWeek, Gfx.TEXT_JUSTIFY_LEFT);
    	dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
    	dc.drawText(x,(dc.getHeight() / 2) - 5, smallFont, month, Gfx.TEXT_JUSTIFY_LEFT);
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    	dc.drawText((x + monthDim[0]) + 5,(dc.getHeight() / 2) - 5, smallFont, day, Gfx.TEXT_JUSTIFY_LEFT);

    	
    	//STEPS BAR
    	if(percent >= 100){
    		dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_BLACK);
    		dc.fillRectangle(0, x + 15, dc.getWidth(), 2);
    
    	} else {

    			dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_BLACK);
    			dc.fillCircle((dc.getWidth() * percent) + 4, x + 15, 2);
    			dc.drawCircle((dc.getWidth() * percent) + 4, x + 15, 4);
    			dc.fillRectangle(0, x + 15, dc.getWidth() * percent, 2);
    	
    	}
    	

		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		//CHECK HR
        if (hrtIter != null) {
        	var hrtRate = "---";		// Default display if no heart rate available
        	if (hrtIter.getMax() != hrtIter.INVALID_HR_SAMPLE) {
        		hrtRate = hrtIter.getMax() + " bpm";
        	}
        	dc.drawText(x - 10, y + 45, smallFont, hrtRate, Gfx.TEXT_JUSTIFY_CENTER);
        }
        
        //DRAW HEART
		var hrtRateDim = dc.getTextDimensions(hrtIter.getMax().toString(), Gfx.FONT_SYSTEM_SMALL);
    	dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_BLACK);
    	dc.drawText(x + hrtRateDim[0] , y + 47, garminSym, "B", Gfx.TEXT_JUSTIFY_LEFT);
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		
        
        //DISPLAY MESSAGE COUNT
        dc.drawText(x,y + 65, Gfx.FONT_SYSTEM_XTINY, newMessages, Gfx.TEXT_JUSTIFY_CENTER);
        
        
        //BATTERY
        var batteryDim = dc.getTextDimensions(batteryPercent, smallFont);
        
		if(Sys.getSystemStats().battery <= 25){
		dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_BLACK);
		dc.drawText(x, 10, Gfx.FONT_XTINY, batteryPercent, Gfx.TEXT_JUSTIFY_CENTER);
		} else {
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		dc.drawText(x, 10, Gfx.FONT_XTINY, batteryPercent, Gfx.TEXT_JUSTIFY_CENTER);
		}
		
		
		
		
		//BLUETOOTH SYMBOL FOR IF PHONE IS CONNECTED
		if(Sys.getDeviceSettings().phoneConnected == true){
			dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
			dc.drawText((x + batteryDim[0]) - 3, 11, garminSym, "A", Gfx.TEXT_JUSTIFY_CENTER);
		}else {
			dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
			dc.drawText((x + batteryDim[0]) - 3, 11, garminSym, "A", Gfx.TEXT_JUSTIFY_CENTER);
		}
		
        //View.onUpdate(dc);

    }

    function onHide() {
    }

    function onExitSleep() {
    }
    function onEnterSleep() {
    }

}

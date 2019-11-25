package io.funxion.logviewer;

import java.util.Timer;
import java.util.TimerTask;
import java.util.logging.Logger;

import javax.annotation.PostConstruct;

public class LogGenerator {
	private static Logger logger = Logger.getLogger(LogGenerator.class.getName());
	private static Timer timer = new Timer();
	
	private static boolean initialized = false;
	
	public static void init() {
		if(!initialized){
			System.out.println("Log Generator Initialized");
			//Cleanup all Docker Stats more than 1 week old
			TimerTask task = new TimerTask() {
	            @Override
	            public void run() { 
	            	logger.finest("Finest Log Message");
	            	logger.fine("Fine Log Message");
	            	logger.warning("Warning Log Message");
	            	logger.info("Info Log Message");
	            	logger.finer("Finer Log Message");
	            }
	        };
	        timer.schedule(task, 60, 30*1000);
	        initialized = true;
		}
	}
}

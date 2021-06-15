package com.metanorma.utils;

import com.metanorma.sts2mn;

/**
 *
 * @author Alexander Dyuzhev
 */
public final class LoggerHelper {
    public static final String LOGGER_NAME = sts2mn.class.getPackage().getName() + "." + sts2mn.class;
    
    private LoggerHelper() {
     
    }
    
    public static void setupLogger() {
        //System.setProperty("java.util.logging.SimpleFormatter.format", "[%1$tF %1$tT] [%4$s] %5$s%6$s%n");
        System.setProperty("java.util.logging.SimpleFormatter.format", "%5$s%6$s%n");
    }
}

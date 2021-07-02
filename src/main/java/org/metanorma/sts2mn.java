package org.metanorma;

import org.metanorma.utils.Util;
import static org.metanorma.Constants.*;
import org.metanorma.utils.LoggerHelper;
import java.io.PrintWriter;
import java.io.StringWriter;

import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

/**
 * This class for the command line application for XsltConverter (conversion of an NISO/ISO XML file to Metanorma XML or AsciiDoc)
 */
public class sts2mn {
    
    static boolean DEBUG = false;

    static String VER = Util.getAppVersion();
    
    static final Options optionsInfo = new Options() {
        {
            addOption(Option.builder("v")
                    .longOpt("version")
                    .desc("display application version")
                    .required(true)
                    .build());
        }
    };
    

    static final Options options = new Options() {
        {
            addOption(Option.builder("f")
                    .longOpt("format")
                    .desc("output format")
                    .hasArg()
                    .argName("adoc|xml")
                    .required(false)
                    .build());
            addOption(Option.builder("o")
                    .longOpt("output")
                    .desc("output file name")
                    .hasArg()
                    .required(false)
                    .build());
            addOption(Option.builder("s")
                    .longOpt("split-bibdata")
                    .desc("create MN Adoc and Relaton XML")                    
                    .required(false)
                    .build());
            addOption(Option.builder("img")
                    .longOpt("imagesdir")
                    .desc("folder with images (default 'images')")
                    .hasArg()
                    .required(false)
                    .build());
            addOption(Option.builder("t")
                    .longOpt("type")
                    .desc("type of standard to generate (for xml output format)")
                    .hasArg()
                    .required(false)
                    .build());
            addOption(Option.builder("v")
                    .longOpt("version")
                    .desc("display application version")
                    .required(false)
                    .build());            
        }
    };

    static final String USAGE = getUsage();

    
    /**
     * Main method.
     *
     * @param args command-line arguments
     * @throws org.apache.commons.cli.ParseException
     */
    public static void main(String[] args) throws ParseException {
        
        LoggerHelper.setupLogger();
                
        CommandLineParser parser = new DefaultParser();
               
        boolean cmdFail = false;
        
        try {
            CommandLine cmdInfo = parser.parse(optionsInfo, args);
            printVersion(cmdInfo.hasOption("version"));            
        } catch (ParseException exp) {
            cmdFail = true;
        }
        
        if(cmdFail) {            
            try {             
                CommandLine cmd = parser.parse(options, args);
                
                System.out.print("sts2mn ");
                printVersion(cmd.hasOption("version"));
                
                System.out.println("\n");

                List<String> arglist = cmd.getArgList();
                if (arglist.isEmpty() || arglist.get(0).trim().length() == 0) {
                    throw new ParseException("");
                }
                
                XsltConverter converter = new XsltConverter();
                converter.setInputFilePath(arglist.get(0));
                converter.setOutputFilePath(cmd.getOptionValue("output"));
                converter.setOutputFormat(cmd.getOptionValue("format"));
                converter.setImagesDir(cmd.getOptionValue("imagesdir"));
                converter.setIsSplitBibdata(cmd.hasOption("split-bibdata"));
                converter.setDebugMode(cmd.hasOption("debug"));
                converter.setTypeStandard(cmd.getOptionValue("type"));
                
                boolean result = converter.process();
                
                if (!result) {
                    System.exit(ERROR_EXIT_CODE);
                }
                cmdFail = false;
            } catch (ParseException exp) {
                cmdFail = true;            
            }
        }
        
        if (cmdFail) {
            System.out.println(USAGE);
            System.exit(ERROR_EXIT_CODE);
        }
    }

    
    private static String getUsage() {
        StringWriter stringWriter = new StringWriter();
        PrintWriter pw = new PrintWriter(stringWriter);
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp(pw, 80, CMD, "", options, 0, 0, "");
        pw.flush();
        return stringWriter.toString();
    }

    private static void printVersion(boolean print) {
        if (print) {            
            System.out.println(VER);
        }
    }       

}
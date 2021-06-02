package com.metanorma;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import org.apache.commons.cli.ParseException;

import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import static org.junit.Assert.assertTrue;

import org.junit.contrib.java.lang.system.EnvironmentVariables;
import org.junit.contrib.java.lang.system.ExpectedSystemExit;
import org.junit.contrib.java.lang.system.SystemOutRule;
import org.junit.rules.TestName;

public class sts2mnTests {

    static String XMLFILE_MN;// = "test.mn.xml";
    //final String XMLFILE_STS = "test.sts.xml";
    
    @Rule
    public final ExpectedSystemExit exitRule = ExpectedSystemExit.none();

    @Rule
    public final SystemOutRule systemOutRule = new SystemOutRule().enableLog();

    @Rule
    public final EnvironmentVariables envVarRule = new EnvironmentVariables();

    @Rule public TestName name = new TestName();
    
    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
        XMLFILE_MN = System.getProperty("inputXML");        
    }
    
    @Test
    public void notEnoughArguments() throws ParseException {
        System.out.println(name.getMethodName());
        exitRule.expectSystemExitWithStatus(-1);
        String[] args = new String[]{""};
        sts2mn.main(args);

        assertTrue(systemOutRule.getLog().contains(sts2mn.USAGE));
    }

    
    @Test
    public void xmlNotExists() throws ParseException {
        System.out.println(name.getMethodName());
        exitRule.expectSystemExitWithStatus(-1);

        String[] args = new String[]{"nonexist.xml"};
        sts2mn.main(args);

        assertTrue(systemOutRule.getLog().contains(
                String.format(sts2mn.INPUT_NOT_FOUND, sts2mn.XML_INPUT, args[1])));
    }

    @Test
    public void unknownOutputFormat() throws ParseException {
        System.out.println(name.getMethodName());
        exitRule.expectSystemExitWithStatus(-1);

        String[] args = new String[]{"--format", "abc", XMLFILE_MN};
        sts2mn.main(args);

        assertTrue(systemOutRule.getLog().contains(
                String.format(sts2mn.UNKNOWN_OUTPUT_FORMAT, args[1])));
    }
    
    

    @Test
    public void successConvertToAdocDefault() throws ParseException {
        System.out.println(name.getMethodName());
        String outFileName = new File(XMLFILE_MN).getAbsolutePath();
        outFileName = outFileName.substring(0, outFileName.lastIndexOf('.') + 1);
        Path fileout = Paths.get(outFileName + "adoc");
        fileout.toFile().delete();
        
        String[] args = new String[]{XMLFILE_MN};
        sts2mn.main(args);

        assertTrue(Files.exists(fileout));        
    }
    
    @Test
    public void successConvertToAdoc() throws ParseException {
        System.out.println(name.getMethodName());
        String outFileName = new File(XMLFILE_MN).getAbsolutePath();
        outFileName = outFileName.substring(0, outFileName.lastIndexOf('.') + 1);
        Path fileout = Paths.get(outFileName + "adoc");
        fileout.toFile().delete();
        
        String[] args = new String[]{"--format", "adoc", XMLFILE_MN};
        sts2mn.main(args);

        assertTrue(Files.exists(fileout));        
    }
    
    @Test
    public void successConvertToAdocOutputSpecified() throws ParseException {
        System.out.println(name.getMethodName());
        Path fileout = Paths.get(System.getProperty("buildDirectory"), "custom.adoc");
        fileout.toFile().delete();
        
        String[] args = new String[]{"--format", "adoc", "--output", fileout.toAbsolutePath().toString(), XMLFILE_MN};
        sts2mn.main(args);

        assertTrue(Files.exists(fileout));
    }

    @Test
    public void successConvertToRelativeAdocOutputSpecified() throws ParseException {
        System.out.println(name.getMethodName());
        Path fileout = Paths.get(".", "target", "custom_relative.adoc");
        fileout.toFile().delete();

        String[] args = new String[]{"--format", "adoc", "--output", fileout.toString(), XMLFILE_MN};
        sts2mn.main(args);

        assertTrue(Files.exists(fileout));
    }
    
    @Test
    public void successConvertToXML() throws ParseException {
        System.out.println(name.getMethodName());
        String outFileName = new File(XMLFILE_MN).getAbsolutePath();
        outFileName = outFileName.substring(0, outFileName.lastIndexOf('.') + 1);
        Path fileout = Paths.get(outFileName + "mn.xml");
        fileout.toFile().delete();
        
        String[] args = new String[]{"--format", "xml", XMLFILE_MN};
        sts2mn.main(args);

        assertTrue(Files.exists(fileout));        
    }
    
    @Test
    public void successSplitBibData() throws ParseException {
        System.out.println(name.getMethodName());
        String outFileName = new File(XMLFILE_MN).getAbsolutePath();
        outFileName = outFileName.substring(0, outFileName.lastIndexOf('.') + 1);
        Path fileoutAdoc = Paths.get(outFileName + "adoc");
        Path fileoutRxl = Paths.get(outFileName + "rxl");
        fileoutAdoc.toFile().delete();
        fileoutRxl.toFile().delete();
        
        String[] args = new String[]{"--split-bibdata", XMLFILE_MN};
        sts2mn.main(args);

        assertTrue(Files.exists(fileoutAdoc));
        assertTrue(Files.exists(fileoutRxl));
    }
    //--split-bibdata
    
}

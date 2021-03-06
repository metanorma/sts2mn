package org.metanorma;

import org.metanorma.sts2mn;
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

import static org.metanorma.Constants.*;

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
                String.format(INPUT_NOT_FOUND, XML_INPUT, args[1])));
    }

    @Test
    public void unknownOutputFormat() throws ParseException {
        System.out.println(name.getMethodName());
        exitRule.expectSystemExitWithStatus(-1);

        String[] args = new String[]{"--format", "abc", XMLFILE_MN};
        sts2mn.main(args);

        assertTrue(systemOutRule.getLog().contains(
                String.format(UNKNOWN_OUTPUT_FORMAT, args[1])));
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
        String user_dir = System.getProperty("user.dir");
        System.setProperty("user.dir", System.getProperty("buildDirectory"));

        String filename = "custom_relative.adoc";
        System.out.println(name.getMethodName());
        Path fileout = Paths.get(System.getProperty("buildDirectory"), "custom_relative.adoc");
        fileout.toFile().delete();

        String[] args = new String[]{"--format", "adoc", "--output", filename,
                Paths.get(System.getProperty("buildDirectory"), "..", XMLFILE_MN).normalize().toString()};
        sts2mn.main(args);
        System.setProperty("user.dir", user_dir); // we should restore value for another tests
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
    public void successConvertToADOCWithImageLink() throws ParseException {
        System.out.println(name.getMethodName());
        String XMLFILE_MN_WITH_IMGLINK = XMLFILE_MN + ".img.xml";
        if (Files.exists(Paths.get(XMLFILE_MN_WITH_IMGLINK))) {

            String outFileName = Paths.get(System.getProperty("buildDirectory"), "imgtest", "document.adoc").toString();
                    
            Path fileout = Paths.get(outFileName);
            fileout.toFile().delete();

            Path imageout = Paths.get(System.getProperty("buildDirectory"), "imgtest", "img" ,"image.png");
            imageout.toFile().delete();

            String[] args = new String[]{"--format", "adoc", "--imagesdir", "img", "--output", outFileName, XMLFILE_MN_WITH_IMGLINK};
            sts2mn.main(args);

            assertTrue(Files.exists(fileout));
            assertTrue(Files.exists(imageout));
        }
    }
    
    @Test
    public void successConvertToXMLWithImageLink() throws ParseException {
        System.out.println(name.getMethodName());
        String XMLFILE_MN_WITH_IMGLINK = XMLFILE_MN + ".img.xml";
        if (Files.exists(Paths.get(XMLFILE_MN_WITH_IMGLINK))) {

            String outFileName = Paths.get(System.getProperty("buildDirectory"), "imgtest", "document.xml").toString();
                    
            Path fileout = Paths.get(outFileName);
            fileout.toFile().delete();

            Path imageout = Paths.get(System.getProperty("buildDirectory"), "imgtest", "img" ,"image.png");
            imageout.toFile().delete();
            
            String[] args = new String[]{"--format", "xml", "--imagesdir", "img", "--output", outFileName, XMLFILE_MN_WITH_IMGLINK};
            sts2mn.main(args);

            
            assertTrue(Files.exists(fileout));
            assertTrue(Files.exists(imageout));
        }
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

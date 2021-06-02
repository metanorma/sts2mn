package com.metanorma;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Comparator;

import java.util.List;
import java.util.Scanner;
import java.util.UUID;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;

/**
 * This class for the conversion of an NISO/ISO XML file to Metanorma XML or AsciiDoc
 */
public class sts2mn {

    static final String CMD = "java -jar sts2mn.jar [options] xml_file";
    static final String INPUT_NOT_FOUND = "Error: %s file '%s' not found!";
    static final String UNKNOWN_OUTPUT_FORMAT = "Unknown output format '%s'!";
    static final String XML_INPUT = "XML";
    static final String XML_OUTPUT = "XML";    
    static final String XSL_INPUT = "XSL";
    static final String INPUT_LOG = "Input: %s (%s)";    
    static final String OUTPUT_LOG = "Output: %s (%s)";

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
            addOption(Option.builder("v")
                    .longOpt("version")
                    .desc("display application version")
                    .required(false)
                    .build());            
        }
    };

    static final String USAGE = getUsage();

    static final int ERROR_EXIT_CODE = -1;

    final String SPLIT = "///SPLIT ";
    
    String outputFormat = "adoc";
    
    boolean splitBibdata = false;
    
    static final String TMPDIR = System.getProperty("java.io.tmpdir");
    
    static final Path tmpfilepath  = Paths.get(TMPDIR, UUID.randomUUID().toString());
    
    /**
     * Main method.
     *
     * @param args command-line arguments
     * @throws org.apache.commons.cli.ParseException
     */
    public static void main(String[] args) throws ParseException {

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
                if(cmd.hasOption("version")) {                    
                    System.out.print(VER);
                }                
                System.out.println("\n");

                printVersion(cmd.hasOption("version"));
                
                List<String> arglist = cmd.getArgList();
                if (arglist.isEmpty() || arglist.get(0).trim().length() == 0) {
                    throw new ParseException("");
                }
                
                String argXMLin = arglist.get(0);
                
                boolean remoteFile = false;
                if (argXMLin.toLowerCase().startsWith("http") || argXMLin.toLowerCase().startsWith("www.")) {
                    remoteFile = true;
                    //download to temp folder
                    System.out.println("Downloading " + argXMLin + "...");
                    if (!Util.isUrlExists(argXMLin)) {
                        System.out.println(String.format(INPUT_NOT_FOUND, XML_INPUT, argXMLin));
                        System.exit(ERROR_EXIT_CODE);
                    }
                    URL url = new URL(argXMLin);
                    String urlFilename = new File(url.getFile()).getName();
                    InputStream in = url.openStream();                    
                    Path localPath = Paths.get(tmpfilepath.toString(), urlFilename);
                    Files.createDirectories(tmpfilepath);
                    Files.copy(in, localPath, StandardCopyOption.REPLACE_EXISTING);
                    argXMLin = localPath.toString();
                    System.out.println("Done!");
                }
                
                
                File fXMLin = new File(argXMLin);
                if (!fXMLin.exists()) {
                    System.out.println(String.format(INPUT_NOT_FOUND, XML_INPUT, fXMLin));
                    System.exit(ERROR_EXIT_CODE);
                }

                String outFileName = fXMLin.getAbsolutePath();
                
                if (remoteFile) {
                    outFileName = Paths.get(System.getProperty("user.dir"), new File(outFileName).getName()).toString();
                }
                
                outFileName = outFileName.substring(0, outFileName.lastIndexOf('.') + 1);
                
                String format = "adoc";
                if (cmd.hasOption("format")) {
                    format = cmd.getOptionValue("format");
                    if (!format.equals("adoc") && !format.equals("xml")) {
                        System.out.println(String.format(UNKNOWN_OUTPUT_FORMAT, format));
                        System.exit(ERROR_EXIT_CODE);
                    }
                }
                
                if (format.equals("xml")) {
                    outFileName = outFileName + "mn." + format;                    
                } else {
                    outFileName = outFileName + format;
                }
                
                if (cmd.hasOption("output")) {
                    outFileName = cmd.getOptionValue("output");
                }
                
                File fileOut = new File(outFileName);
                
                /*DEBUG = cmd.hasOption("debug"); */

                System.out.println(String.format(INPUT_LOG, XML_INPUT, fXMLin));                
                System.out.println(String.format(OUTPUT_LOG, format.toUpperCase(), fileOut));
                System.out.println();

                try {
                    sts2mn app = new sts2mn();
                    app.setOutputFormat(format);
                    app.setSplitBibdata(cmd.hasOption("split-bibdata"));
                    app.convertsts2mn(fXMLin, fileOut);
                    System.out.println("End!");
                
                } catch (Exception e) {
                    e.printStackTrace(System.err);
                    System.exit(ERROR_EXIT_CODE);
                }
                cmdFail = false;
            } catch (ParseException exp) {
                cmdFail = true;            
            } catch (IOException ex) {
                System.err.println(ex.toString());
            }
        }
        
        // flush temporary folder
        if (!DEBUG) {
            Util.FlushTempFolder(tmpfilepath);
        }
        
        if (cmdFail) {
            System.out.println(USAGE);
            System.exit(ERROR_EXIT_CODE);
        }
    }

    private void convertsts2mn(File fXMLin, File fileOut) throws IOException, TransformerException, SAXParseException {
        
        try {
            
            Source srcXSL = null;
            
            String outputFolder = fileOut.getAbsoluteFile().getParent();
            String bibdataFileName = fileOut.getName();
           
            // skip validating 
            //found here: https://moleshole.wordpress.com/2009/10/08/ignore-a-dtd-when-using-a-transformer/
            XMLReader rdr = XMLReaderFactory.createXMLReader();
            rdr.setEntityResolver(new EntityResolver() {
		@Override
		public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException {
                    if (systemId.endsWith(".dtd")) {
                            StringReader stringInput = new StringReader(" ");
                            return new InputSource(stringInput);
                    }
                    else {
                            return null; // use default behavior
                    }
		}
            });
            
            
            TransformerFactory factory = TransformerFactory.newInstance();
            Transformer transformer = factory.newTransformer();
            //Source src = new StreamSource(fXMLin);
            Source src = new SAXSource(rdr, new InputSource(new FileInputStream(fXMLin)));
            
            System.out.println("Transforming...");
            
            if (outputFormat.equals("xml") || splitBibdata) {
                srcXSL = new StreamSource(Util.getStreamFromResources(getClass().getClassLoader(), "sts2mn.xsl"));
                transformer = factory.newTransformer(srcXSL);
                transformer.setParameter("split-bibdata", splitBibdata);
                
                transformer.setParameter("debug", DEBUG);
            
                StringWriter resultWriter = new StringWriter();
                StreamResult sr = new StreamResult(resultWriter);
            
                transformer.transform(src, sr);
                
                String xmlSTS = resultWriter.toString();
                
                File xmlFileOut = fileOut;
                if (splitBibdata) { //relaton XML
                    String relatonXML = xmlFileOut.getAbsolutePath();
                    relatonXML = relatonXML.substring(0, relatonXML.lastIndexOf(".")) + ".rxl";
                    xmlFileOut = new File(relatonXML);
                }
                try (BufferedWriter writer = Files.newBufferedWriter(Paths.get(xmlFileOut.getAbsolutePath()))) {
                    writer.write(xmlSTS);
                }
            }
            
            src = new SAXSource(rdr, new InputSource(new FileInputStream(fXMLin)));
            
            if (outputFormat.equals("adoc") || splitBibdata) {
                
                // linearize XML
                Source srcXSLidentity = new StreamSource(Util.getStreamFromResources(getClass().getClassLoader(), "linearize.xsl"));
                transformer = factory.newTransformer(srcXSLidentity);
                
                StringWriter resultWriteridentity = new StringWriter();
                StreamResult sridentity = new StreamResult(resultWriteridentity);
                transformer.transform(src, sridentity);
                String xmlidentity = resultWriteridentity.toString();
                
                // load linearized xml
                src = new StreamSource(new StringReader(xmlidentity));
                srcXSL = new StreamSource(Util.getStreamFromResources(getClass().getClassLoader(), "sts2mn.adoc.xsl"));
                transformer = factory.newTransformer(srcXSL);
                transformer.setParameter("split-bibdata", splitBibdata);
                transformer.setParameter("docfile", bibdataFileName);
                transformer.setParameter("pathSeparator", File.separator);
                transformer.setParameter("outpath", outputFolder);
                transformer.setParameter("debug", DEBUG);
            
                StringWriter resultWriter = new StringWriter();
                StreamResult sr = new StreamResult(resultWriter);
                
                transformer.transform(src, sr);
                String adocSTS = resultWriter.toString();
                
                File adocFileOut = fileOut;
                if (splitBibdata) { //relaton XML
                    String bibdataAdoc = adocFileOut.getAbsolutePath();
                    bibdataAdoc = bibdataAdoc.substring(0, bibdataAdoc.lastIndexOf(".")) + ".adoc";
                    adocFileOut = new File(bibdataAdoc);
                }
                
                try (Scanner scanner = new Scanner(adocSTS)) {
                    String outputFile = adocFileOut.getAbsolutePath();
                    StringBuilder sbBuffer = new StringBuilder();
                    while (scanner.hasNextLine()) {
                        String line = scanner.nextLine();
                        if (line.startsWith(SPLIT)) {
                            writeBuffer(sbBuffer, outputFile);
                            // ///SPLIT body/body-en.doc[] --> body/body-en.doc
                            outputFile = line.substring(line.indexOf(SPLIT) + SPLIT.length(), line.length() - 2);                        
                            outputFile = Paths.get(outputFolder, outputFile).toString();
                            new File(new File(outputFile).getParent()).mkdirs();
                        } else {
                            sbBuffer.append(line);
                            sbBuffer.append(System.getProperty("line.separator"));
                        }                    
                    }
                    writeBuffer(sbBuffer, outputFile);
                }
            }
            
        } catch (SAXParseException e) {            
            throw (e);
        } catch (Exception e) {
            e.printStackTrace(System.err);
            System.exit(ERROR_EXIT_CODE);
        }
    }
    
    private void writeBuffer(StringBuilder sbBuffer, String outputFile) throws IOException {
        try (BufferedWriter writer = Files.newBufferedWriter(Paths.get(outputFile))) {
            writer.write(sbBuffer.toString());
        }
        sbBuffer.setLength(0);
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

    public void setOutputFormat(String outputFormat) {
        this.outputFormat = outputFormat;
    }

    public void setSplitBibdata(boolean splitBibdata) {
        this.splitBibdata = splitBibdata;
    }

    
}
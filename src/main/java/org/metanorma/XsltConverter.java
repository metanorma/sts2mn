package org.metanorma;

import org.metanorma.utils.Task;
import org.metanorma.utils.Util;
import static org.metanorma.Constants.*;
import org.metanorma.utils.LoggerHelper;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import java.util.logging.Logger;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;

/**
 *
 * @author Alexander Dyuzhev
 */

/**
 * This class for the conversion of an NISO/ISO XML file to Metanorma XML or AsciiDoc
 */
public class XsltConverter {

    private static final Logger logger = Logger.getLogger(LoggerHelper.LOGGER_NAME);
    
    private final String TMPDIR = System.getProperty("java.io.tmpdir");
    private final Path tmpfilepath  = Paths.get(TMPDIR, UUID.randomUUID().toString());
    
    private String inputFilePath = "document.xml"; // default input file name
    private boolean isInputFileRemote = false; // true, if inputFilePath starts from http, https, www.
    
    private String outputFilePath = ""; // default output file name
    
    private String outputFormat = "adoc"; // default output format is 'adoc'
    
    private String imagesDir = "images"; // default image dir - 'images'
    
    private boolean isSplitBibdata = false;
    
    private boolean isDebugMode = false; // default no debug
    
    private String typeStandard = ""; // default value empty - allows to determine standard via xslt
    
    final String SPLIT = "///SPLIT ";
    
    public XsltConverter() {
        
    }

    public void setInputFilePath(String inputFilePath) {
        this.inputFilePath = inputFilePath;
        
    }

    public void setOutputFilePath(String outputFilePath) {
        if (outputFilePath != null) {
            this.outputFilePath = outputFilePath;
        }
    }

    public void setOutputFormat(String outputFormat) {
        if (outputFormat != null) {
            this.outputFormat = outputFormat.toLowerCase();
        }
    }

    public void setImagesDir(String imagesDir) {
        if (imagesDir != null) {
            this.imagesDir = imagesDir;
        }
    }

    public void setIsSplitBibdata(boolean isSplitBibdata) {
        this.isSplitBibdata = isSplitBibdata;
    }

    public void setDebugMode(boolean isDebugMode) {
        this.isDebugMode = isDebugMode;
    }

    public void setTypeStandard(String typeStandard) {
        if (typeStandard != null) {
            this.typeStandard = typeStandard;
        }
    }
    
    
    
    
    private void setDefaultOutputFilePath() {
        if (outputFilePath.isEmpty()) {
            File fInputFilePath = new File(inputFilePath);
            outputFilePath = fInputFilePath.getAbsolutePath();
            if (isInputFileRemote) {
                outputFilePath = Paths.get(System.getProperty("user.dir"), new File(outputFilePath).getName()).toString();
            }
            String outputFilePathWithoutExtension = outputFilePath.substring(0, outputFilePath.lastIndexOf('.') + 1);
            
            if (outputFormat.equals("xml")) {
                outputFilePath = outputFilePathWithoutExtension + "mn." + outputFormat;                    
            } else { // adoc
                outputFilePath = outputFilePathWithoutExtension + outputFormat;
            }
            
        }
    }
    
    public boolean process() {
        
        try {
            
        
            if (inputFilePath.toLowerCase().startsWith("http") || inputFilePath.toLowerCase().startsWith("www.")) {
                isInputFileRemote = true;
                inputFilePath = Util.downloadFile(inputFilePath, tmpfilepath);
                if (inputFilePath.isEmpty()) {
                    return false;
                }
            }

            File fXMLin = new File(inputFilePath);
            if (!fXMLin.exists()) {
                //System.out.println(String.format(INPUT_NOT_FOUND, XML_INPUT, fXMLin));
                logger.severe(String.format(INPUT_NOT_FOUND, XML_INPUT, fXMLin));
                return false;
            }

            if (!outputFormat.equals("adoc") && !outputFormat.equals("xml")) {
                //System.out.println(String.format(UNKNOWN_OUTPUT_FORMAT, outputFormat));
                logger.severe(String.format(UNKNOWN_OUTPUT_FORMAT, outputFormat));
                return false;
            }

            setDefaultOutputFilePath();

            File fileOut = new File(outputFilePath);

            logger.info(String.format(INPUT_LOG, XML_INPUT, fXMLin));
            
            logger.info(String.format(OUTPUT_LOG, outputFormat.toUpperCase(), fileOut));
            logger.info("");
            
            convertsts2mn(fXMLin, fileOut);


            logger.info("End!");
        
        
        } catch (Exception e) {
            e.printStackTrace(System.err);
            return false;
        }
        
        // flush temporary folder
        if (!isDebugMode) {
            Util.FlushTempFolder(tmpfilepath);
        }
        
        return true;
    }
    
    private void convertsts2mn(File fXMLin, File fileOut) throws IOException, TransformerException, SAXException, SAXParseException {
            
        //Source srcXSL = null;

        String inputFolder = fXMLin.getAbsoluteFile().getParent();
        String outputFolder = fileOut.getAbsoluteFile().getParent();

        String bibdataFileName = fileOut.getName();
        String bibdataFileExt = Util.getFileExtension(bibdataFileName);
        bibdataFileName = bibdataFileName.substring(0, bibdataFileName.indexOf(bibdataFileExt) - 1);

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

        logger.info("Transforming...");

        if (outputFormat.equals("xml") ||  isSplitBibdata) {
            Source srcXSL = new StreamSource(Util.getStreamFromResources(getClass().getClassLoader(), "sts2mn.xsl"));
            transformer = factory.newTransformer(srcXSL);
            transformer.setParameter("split-bibdata", isSplitBibdata);
            transformer.setParameter("imagesdir", imagesDir);
            transformer.setParameter("outpath", outputFolder);
            transformer.setParameter("typestandard", typeStandard);
            transformer.setParameter("debug", isDebugMode);

            StringWriter resultWriter = new StringWriter();
            StreamResult sr = new StreamResult(resultWriter);

            transformer.transform(src, sr);

            String xmlMetanorma = resultWriter.toString();

            File xmlFileOut = fileOut;
            if (isSplitBibdata) { //relaton XML
                String relatonXML = xmlFileOut.getAbsolutePath();
                relatonXML = relatonXML.substring(0, relatonXML.lastIndexOf(".")) + ".rxl";
                xmlFileOut = new File(relatonXML);
            }

            Files.createDirectories(Paths.get(xmlFileOut.getParent()));
            try (BufferedWriter writer = Files.newBufferedWriter(Paths.get(xmlFileOut.getAbsolutePath()))) {
                writer.write(xmlMetanorma);
            }

        }

        if (outputFormat.equals("adoc") || isSplitBibdata) {
            src = new SAXSource(rdr, new InputSource(new FileInputStream(fXMLin)));

            // linearize XML
            String xmlLinearized = linearizeXML(src);

            src = new StreamSource(new StringReader(xmlLinearized));
            Source srcXSL = new StreamSource(Util.getStreamFromResources(getClass().getClassLoader(), "sts2mn.adoc.xsl"));
            transformer = factory.newTransformer(srcXSL);
            transformer.setParameter("split-bibdata", isSplitBibdata);
            transformer.setParameter("docfile_name", bibdataFileName);
            transformer.setParameter("docfile_ext", bibdataFileExt);
            transformer.setParameter("pathSeparator", File.separator);
            transformer.setParameter("outpath", outputFolder);
            transformer.setParameter("imagesdir", imagesDir);
            transformer.setParameter("debug", isDebugMode);

            StringWriter resultWriter = new StringWriter();
            StreamResult sr = new StreamResult(resultWriter);

            transformer.transform(src, sr);
            String adocMetanorma = resultWriter.toString();

            File adocFileOut = fileOut;
            if (isSplitBibdata) { //relaton XML
                String bibdataAdoc = adocFileOut.getAbsolutePath();
                bibdataAdoc = bibdataAdoc.substring(0, bibdataAdoc.lastIndexOf(".")) + ".adoc";
                adocFileOut = new File(bibdataAdoc);
            }

            // no need to save resulted adoc here, because it saved via xslt xsl:redirect
            /*
            try (Scanner scanner = new Scanner(adocMetanorma)) {
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
                    }
                    else {
                        sbBuffer.append(line);
                        sbBuffer.append(System.getProperty("line.separator"));
                    }                    
                }
                writeBuffer(sbBuffer, outputFile);
            }*/
        }

        Task.copyImages(inputFolder, imagesDir, outputFolder);
    }
    
    private String linearizeXML(Source src) throws TransformerConfigurationException, IOException, TransformerException {
        TransformerFactory factory = TransformerFactory.newInstance();
        Source srcXSLlinearize = new StreamSource(Util.getStreamFromResources(getClass().getClassLoader(), "linearize.xsl"));
        Transformer transformer = factory.newTransformer(srcXSLlinearize);

        StringWriter resultWriteridentity = new StringWriter();
        StreamResult sridentity = new StreamResult(resultWriteridentity);
        transformer.transform(src, sridentity);
        return resultWriteridentity.toString();
    }
    
    private void writeBuffer(StringBuilder sbBuffer, String outputFile) throws IOException {
        try (BufferedWriter writer = Files.newBufferedWriter(Paths.get(outputFile))) {
            writer.write(sbBuffer.toString());
        }
        sbBuffer.setLength(0);
    }
}

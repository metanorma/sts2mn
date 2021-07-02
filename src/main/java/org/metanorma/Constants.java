package org.metanorma;

/**
 *
 * @author Alexander Dyuzhev
 */
public final class Constants {
    public static final String CMD = "java -jar sts2mn.jar [options] xml_file";
    public static final String INPUT_NOT_FOUND = "Error: %s file '%s' not found!";
    public static final String UNKNOWN_OUTPUT_FORMAT = "Unknown output format '%s'!";
    public static final String XML_INPUT = "XML";
    public static final String XML_OUTPUT = "XML";    
    public static final String XSL_INPUT = "XSL";
    public static final String INPUT_LOG = "Input: %s (%s)";    
    public static final String OUTPUT_LOG = "Output: %s (%s)";
    public static final int ERROR_EXIT_CODE = -1;
}

package com.metanorma;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.Enumeration;
import java.util.jar.Attributes;
import java.util.jar.Manifest;

/**
 *
 * @author Alexander Dyuzhev
 */
public class Util {
   
    public static String getAppVersion() {
        String version = "";
        try {
            Enumeration<URL> resources = sts2mn.class.getClassLoader().getResources("META-INF/MANIFEST.MF");
            while (resources.hasMoreElements()) {
                Manifest manifest = new Manifest(resources.nextElement().openStream());
                // check that this is your manifest and do what you need or get the next one
                Attributes attr = manifest.getMainAttributes();
                String mainClass = attr.getValue("Main-Class");
                if(mainClass != null && mainClass.contains("com.metanorma.sts2mn")) {
                    version = manifest.getMainAttributes().getValue("Implementation-Version");
                }
            }
        } catch (IOException ex)  {
            version = "";
        }
        
        return version;
    }
 
    // get file from classpath, resources folder
    public static InputStream getStreamFromResources(ClassLoader classLoader, String fileName) throws Exception {        
        InputStream stream = classLoader.getResourceAsStream(fileName);
        if (stream == null) {
            throw new Exception("Cannot get resource \"" + fileName + "\" from Jar file.");
        }
        return stream;
    }
    
    public static void FlushTempFolder(Path tmpfilepath) {
        if (Files.exists(tmpfilepath)) {
            //Files.deleteIfExists(tmpfilepath);
            try {
                Files.walk(tmpfilepath)
                    .sorted(Comparator.reverseOrder())
                        .map(Path::toFile)
                            .forEach(File::delete);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
    
    public static String getJavaTempDir() {
        return System.getProperty("java.io.tmpdir");
    }    
    
    
    public void callRuby() {
        StringBuilder sb = new StringBuilder();
        try {
            Process process = Runtime.getRuntime().exec("ruby script.rb");
            process.waitFor();

            BufferedReader processIn = new BufferedReader(
                    new InputStreamReader(process.getInputStream()));

            String line;
            while ((line = processIn.readLine()) != null) {
                //System.out.println(line);
                sb.append(line);
            } 
            
        } 
        catch (Exception e) {
            e.printStackTrace();
        }
        
    }
    
    public static boolean isUrlExists(String urlname){
    try {
        HttpURLConnection.setFollowRedirects(false);        
        HttpURLConnection con = (HttpURLConnection) new URL(urlname).openConnection();
        con.setRequestMethod("HEAD");
        return (con.getResponseCode() == HttpURLConnection.HTTP_OK ||
                con.getResponseCode() == HttpURLConnection.HTTP_MOVED_TEMP);
    }
    catch (Exception e) {
       e.printStackTrace();
       return false;
    }
  }
    
    
  public static String getListStartValue(String type, String label) {
      
    label = label.toUpperCase();
    
    if (type.equals("roman") || type.equals("roman_upper")) {
        //https://www.w3resource.com/java-exercises/math/java-math-exercise-7.php
        int len = label.length();
        label = label + " ";
        int result = 0;
        for (int i = 0; i < len; i++) {
            char ch   = label.charAt(i);
            char next_char = label.charAt(i+1);

            if (ch == 'M') {
                result += 1000;
            } else if (ch == 'C') {
                if (next_char == 'M') {
                    result += 900;
                    i++;
                } else if (next_char == 'D') {
                    result += 400;
                    i++;
                } else {
                    result += 100;
                }
            } else if (ch == 'D') {
                result += 500;
            } else if (ch == 'X') {
                if (next_char == 'C') {
                    result += 90;
                    i++;
                } else if (next_char == 'L') {
                    result += 40;
                    i++;
                } else {
                    result += 10;
                }
            } else if (ch == 'L') {
                result += 50;
            } else if (ch == 'I') {
                if (next_char == 'X') {
                    result += 9;
                    i++;
                } else if (next_char == 'V') {
                    result += 4;
                    i++;
                } else {
                    result++;
                }
            } else { // if (ch == 'V')
                result += 5;
            }
        }

        return String.valueOf(result);
    }
    else if (type.equals("alphabet") || type.equals("alphabet_upper")) {
        return String.valueOf((int)(label.charAt(0)) - 64);
    }
      
    return "";
  }
}

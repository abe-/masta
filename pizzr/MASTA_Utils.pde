///////////////////////////////////////////////////////
// UI - openFile(), processFile(file)
// file dialog
///////////////////////

void openFile() {
  // Stop the main loop:
  openingFile = true;
  
  selectInput("Select a STL file to process:", "processFile");
}

void updateFile() {
  // Stop the main loop:
  openingFile = true;
  
  initMesh(lastFile);
  
  // Restart the main loop:
  openingFile = false;    
}

void processFile(File selection) {
  if (selection != null) {
    println(selection.getAbsolutePath());
    lastFile = selection.getAbsolutePath(); 
    initMesh(lastFile);
  }
  
  // Restart the main loop:
  openingFile = false;  
}


///////////////////////////////////////////////////////
// UI - controlEvent(event)
// Receives user UI events
///////////////////////
/*
public void controlEvent(ControlEvent theEvent) {
  println(theEvent.controller().name()+" = "+theEvent.value());  
  if (theEvent.controller().value() != 0) {
    formName = theEvent.controller().name();
    formId = int(theEvent.value());
    
    println("FormName is " + formName);    
    println("FormId is " + formId);
    output.println("FormName is " + formName);    
    output.println("FormId is " + formId);
    
    String url = forms.get(formName);
    String file = fileDownload(url, sketchPath);
  }
}
*/


///////////////////////////////////////////////////////
// UI - RetrieveForms()
// Connects to MASTA and retreives and shows the list of forms in the server
///////////////////////
/*
public void RetrieveForms() {
  try  {
    DefaultHttpClient httpClient = new DefaultHttpClient();
    HttpGet           httpGet   = new HttpGet( url + "views/forms" );
    
    println( "executing request: " + httpGet.getRequestLine() );
    
    HttpResponse response = httpClient.execute( httpGet );
    HttpEntity   entity   = response.getEntity();
    
    
    println("----------------------------------------");
    println( response.getStatusLine() );
    println("----------------------------------------");
    
    if (entity != null ) {
      JSONArray root = new JSONArray( EntityUtils.toString(entity) );

      for (int n = 0; n < root.length(); n++) {
        JSONObject obj = root.getJSONObject(n);
        String title = (String)obj.get("node_title");
        String stl = (String)obj.get("nid");
        String formId = (String)obj.get("node_type");
        forms.put(title, stl);
        formList.add(title, int(formId)).setLabel(title);
      }
      entity.consumeContent();
      
      if (forms.size() > 0) {
        formList.setColorBackground(color(0,100,0));        
      }
    }

    // When HttpClient instance is no longer needed, 
    // shut down the connection manager to ensure
    // immediate deallocation of all system resources
    httpClient.getConnectionManager().shutdown();       
    
  } catch( Exception e ) { e.printStackTrace(); }
   

}
*/

///////////////////////////////////////////////////////
// UI - PostForms()
// Connects to MASTA and uploads the atoms of a form
///////////////////////
void PostForms() {
// TODO with OAuth
}


///////////////////////////////////////////////////////
// UTILS - fileUrl()
// Downloads a file to a directory given its URL and locatFileName
///////////////////////
/*
public void fileUrl(String fAddress, String localFileName, String destinationDir) {
    OutputStream outStream = null;
    URLConnection  uCon = null;

    InputStream is = null;
    try {
        URL Url;
        byte[] buf;
        int ByteRead,ByteWritten=0;
        Url= new URL(fAddress);
        outStream = new BufferedOutputStream(new
        FileOutputStream(destinationDir+"\\"+localFileName));

        uCon = Url.openConnection();
        is = uCon.getInputStream();
        buf = new byte[1024];
        while ((ByteRead = is.read(buf)) != -1) {
            outStream.write(buf, 0, ByteRead);
            ByteWritten += ByteRead;
        }
        println("--- Downloaded Successfully.");
        println("--- File name:\""+localFileName+ "\"\nNo ofbytes :" + ByteWritten);
        output.println("--- Downloaded Successfully.");
        output.println("--- File name:\""+localFileName+ "\"\nNo ofbytes :" + ByteWritten);        
    }
    catch (Exception e) {
        e.printStackTrace();
    }
    finally {
            try {
            is.close();
            outStream.close();
            }
            catch (IOException e) {
              e.printStackTrace();
            }
    }
}

*/

///////////////////////////////////////////////////////
// UTILS - loadFile()
// Retrieves the contents of a file as an array of bytes
///////////////////////

private static byte[] loadFile(File file) throws IOException {
	    InputStream is = new java.io.FileInputStream(file);
 
	    long length = file.length();
	    if (length > Integer.MAX_VALUE) {
	        // File is too large
	    }
	    byte[] bytes = new byte[(int)length];
	    
	    int offset = 0;
	    int numRead = 0;
	    while (offset < bytes.length
	           && (numRead=is.read(bytes, offset, bytes.length-offset)) >= 0) {
	        offset += numRead;
	    }
 
	    if (offset < bytes.length) {
	        throw new IOException("Could not completely read file "+file.getName());
	    }
 
	    is.close();
	    return bytes;
}


///////////////////////////////////////////////////////
// UTILS - fileDownload()
// Downloads a file to a directory given its URL and returns the filename
///////////////////////
/*
public String fileDownload(String fAddress, String destinationDir) {    
    int slashIndex =fAddress.lastIndexOf('/');
    int periodIndex =fAddress.lastIndexOf('.');

    String fileName=fAddress.substring(slashIndex + 1);

    if (periodIndex >=1 &&  slashIndex >= 0 && slashIndex < fAddress.length()-1) {
        fileUrl(fAddress,fileName,destinationDir);
        return fileName;
    }
    else {
        System.err.println("path or file name.");
        return null;
    }
}

*/

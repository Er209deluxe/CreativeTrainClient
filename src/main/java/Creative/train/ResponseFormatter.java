package Creative.train;

/**
 * Write a description of class ResponseFormatter here.
 *
 * @author (your name)
 * @version (a version number or a date)
 */
public class ResponseFormatter
{

    public static String buildResponse(int status, String statusText, String body) {
        if(body.isEmpty()){
            if(status >=400) return "ERR|"+status+"|"+ statusText;
            
        }
        return status + "|" + statusText + "|" + body;
    }
    
}

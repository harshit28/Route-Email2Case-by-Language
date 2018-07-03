//class to parse json response
public with sharing class DetectLanguageClass 
{
    public Data data;
    public DetectLanguageClass(){
        
    }
    
    //wrapper class to parse the response
    public class Data {
        public List<List<Detections>> detections;
    }
    
    //wrapper class to parse the response
    public class Detections {
        public Double confidence;
        public Boolean isReliable;
        public String language;
    }
    
    
}
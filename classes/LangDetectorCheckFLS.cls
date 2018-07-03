public with sharing class LangDetectorCheckFLS 
{
    /* This method ensures the fields are Accessible. Ensuring FLS. */
    public static boolean checkAccessibleFLS(List<String> fieldNames, String objName){
        boolean isSafe = false;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType myObj = schemaMap.get(objName);
        if(myObj.getDescribe().isAccessible()){ 
            for(String fldName: fieldNames){
                SObjectField myField = myObj.getDescribe().fields.getMap().get(fldName);
                if(myField.getDescribe().isAccessible()){
                    isSafe = true;
                }else{
                    isSafe = false;
                    break;
                }    
            }
        }else{
            isSafe = false;
        }
        return isSafe;
    }
    
    /* This method ensures the fields are Createable and Updateable. Ensuring FLS. */
    public static boolean checkUpdateableFLS(List<String> fieldNames, String objName){
        boolean isSafe = false;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType myObj = schemaMap.get(objName);
        if(myObj.getDescribe().isAccessible()){ 
            for(String fldName: fieldNames){
                SObjectField myField = myObj.getDescribe().fields.getMap().get(fldName);
                if(myField.getDescribe().isAccessible() && myField.getDescribe().isCreateable() && myField.getDescribe().isUpdateable()){
                    isSafe = true;
                }else{
                    isSafe = false;
                    break;
                }    
            }
        }else{
            isSafe = false;
        }
        return isSafe;
    }
    
    /* This method ensures the fields are Createable. Ensuring FLS. */
    public static boolean checkCreateableFLS(List<String> fieldNames, String objName){
        boolean isSafe = false;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType myObj = schemaMap.get(objName);
        if(myObj.getDescribe().isAccessible()){ 
            for(String fldName: fieldNames){
                SObjectField myField = myObj.getDescribe().fields.getMap().get(fldName);
                if(myField.getDescribe().isAccessible() && myField.getDescribe().isCreateable()){
                    isSafe = true;
                }else{
                    isSafe = false;
                    break;
                }    
            }
        }else{
            isSafe = false;
        }
        return isSafe;
    }
    
}
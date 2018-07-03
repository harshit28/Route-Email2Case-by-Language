//This class will accept user API input and save it in custom setting
public with sharing class DE_EnterKeyCtrl {
    //this method will upsert custom settings record!!
    @AuraEnabled
    public static void saveApiValue(String apiValue){
        if(apiValue != null){
            
            //Performing encryption on the user entered API key
            Blob key = Crypto.generateAesKey(128); //Generating a random encryption key whenever user enters a new API key
            Blob data = Blob.valueOf(apiValue.trim());
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key, data);
            String b64 = EncodingUtil.base64Encode(encryptedData);
            
            List<String> fName = new List<String>();
            fName.add('LangDetector__API_Key_Value__c');
            fName.add('LangDetector__AES_Key__c');
            
            //check if field is accessible
            if(LangDetectorCheckFLS.checkAccessibleFLS(fName,'LangDetector__API_Key_LD__c')){
                
                LangDetector__API_Key_LD__c apiObj = LangDetector__API_Key_LD__c.getInstance('API Key');
                
                //check if field is updatable or creatable
                if(LangDetectorCheckFLS.checkUpdateableFLS(fName,'LangDetector__API_Key_LD__c')){
                    
                    //saving the encrypted key in custom setting record
                    if(apiObj != null){
                        apiObj.LangDetector__API_Key_Value__c = b64;
                        apiObj.LangDetector__AES_Key__c = EncodingUtil.base64Encode(key);
                        update apiObj;
                    }
                    else{
                        apiObj = new LangDetector__API_Key_LD__c();
                        apiObj.Name = 'API Key';
                        apiObj.LangDetector__API_Key_Value__c = b64;
                        apiObj.LangDetector__AES_Key__c = EncodingUtil.base64Encode(key);
                        insert apiObj;
                    }
                }
            }
        }
    }
    
}
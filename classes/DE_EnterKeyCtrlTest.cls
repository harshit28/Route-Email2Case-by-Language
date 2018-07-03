@isTest
public class DE_EnterKeyCtrlTest 
{
    //Test case for user entered API key encryption
    static testMethod void testSaveApiValue(){
        String sOriginalKey = 'AIzaSyAUsZD7U8GhOJfG4QoWD96XV0zFo7iCmx4';
        String sEncryptVal = 'FFx0IyPJfwl0z0axcbivlx6yP10t3775Tx6Q1J5jx9VSUJ0nhvpDKWkVptPXUzYlzcjX4Grn4DbsiLx+AKmlog==';
        String sAPIKeyName = 'API Key';
        String sAEsKey = 'LqHOk/K82y8+PRUaPT+t8g==';
        //Checking custom settings values
        DE_EnterKeyCtrl.saveApiValue(sOriginalKey);
        
        LangDetector__API_Key_LD__c apikeyObj = LangDetector__API_Key_LD__c.getInstance('API Key');
        System.assertNotEquals(apikeyObj.Id, null);
        
        apikeyObj = new LangDetector__API_Key_LD__c();
        apikeyObj.Name = sAPIKeyName;
        apikeyObj.LangDetector__API_Key_Value__c = sEncryptVal;
        apikeyObj.LangDetector__AES_Key__c = sAEsKey;
        insert apikeyObj;
        System.assertNotEquals(apikeyObj.Id,null);
        System.assertEquals(apikeyObj.Name,'API Key');
        
        DE_EnterKeyCtrl.saveApiValue(sOriginalKey);
        LangDetector__API_Key_LD__c apiObj = LangDetector__API_Key_LD__c.getInstance('API Key');
        System.assertEquals(apiObj.Name,apikeyObj.Name);
        
    }
}
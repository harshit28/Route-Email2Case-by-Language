@isTest
public class DE_Email2CaseLanguageDetectionTest 
{
    //test class for incoming email2case functionality
    static testMethod void testHandleInboundEmail()
    {
        //creating test email
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'test case for english language';
        email.fromName = 'Ronit Naik';
        email.fromAddress = 'naik.s.ronit@gmail.com';
        
        String sOriginalKey = 'AIzaSyAUsZD7U8GhOJfG4QoWD96XV0zFo7iCmx4';
        //String sKey = '1234567890123456';
        String sEncryptFormat = 'AES128';
        
        //performing encryption on key
        Blob key = Crypto.generateAesKey(128);
        Blob data = Blob.valueOf(sOriginalKey);
        Blob encryptedData = Crypto.encryptWithManagedIV(sEncryptFormat, key, data);
        String b64=EncodingUtil.base64Encode(encryptedData);
        
        //inserting encrypted key in custom setting record
        LangDetector__API_Key_LD__c apikeyObj = new LangDetector__API_Key_LD__c();
        apikeyObj.Name = 'API Key';
        apikeyObj.LangDetector__API_Key_Value__c = b64;
        apikeyObj.LangDetector__AES_Key__c = EncodingUtil.base64Encode(key);
        insert apikeyObj;
        
        LangDetector__API_Key_LD__c apiObj = LangDetector__API_Key_LD__c.getInstance('API Key');
        System.assertEquals(apiObj.Name,apikeyObj.Name);
        
        Test.startTest();
        
        DE_Email2CaseLanguageDetection obj = new DE_Email2CaseLanguageDetection();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Messaging.InboundEmailResult result = obj.handleInboundEmail(email, env);
        System.assertEquals(result.success, true);
        
        //To check recently created case has same test subject
        Case cs = [Select CaseNumber, Subject from Case order by CreatedDate desc limit 1];
        system.debug('cs:'+cs);
        System.assertEquals(cs.Subject, 'test case for english language');
        
        Test.stopTest();
        
    }
    //Test case for exception negative testing
    static testMethod void testHandleInboundEmail2()
    {
        Messaging.InboundEmail email2 = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();
        
        email2.subject = 'questa è una prova di posta elettronica di esempio';
        email2.fromName = 'Ronit Naik';
        env2.fromAddress = 'naik.s.ronit@gmail.com';
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.lastName = 'Name';
        con.email='naik.s.ronit@gmail.com';
        insert con;
        
        Contact cont = [Select Name, Email from Contact order by CreatedDate desc limit 1];
        System.assertEquals(cont.Email, 'naik.s.ronit@gmail.com');
        
        
        DE_Email2CaseLanguageDetection obj2 = new DE_Email2CaseLanguageDetection();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Messaging.InboundEmailResult result2 = obj2.handleInboundEmail(email2, env2);
        System.assertEquals(result2.success, false);
        
    }
}
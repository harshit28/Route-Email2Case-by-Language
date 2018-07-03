//This class handles the incoming email and will create a case and will route it to a specific queue based on language
global with sharing class DE_Email2CaseLanguageDetection implements Messaging.InboundEmailHandler
{
    //This method handles email and handles the functionality to create a case
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        try
        {
            List<String> fieldNamesContact = new List<String>();
            fieldNamesContact.add('FirstName');
            fieldNamesContact.add('LastName');
            fieldNamesContact.add('Email');
            // Check if the above fields are accessible for the below query. Ensuring FLS.
            if(!LangDetectorCheckFLS.checkAccessibleFLS(fieldNamesContact,'Contact')){
                system.debug('return null if contact fields not accesible');
                return null;
            }
            
            List<String> fieldNamesCase = new List<String>();
            fieldNamesCase.add('Subject');
            fieldNamesCase.add('Description');
            fieldNamesCase.add('Origin');
            fieldNamesCase.add('ContactId');
            fieldNamesCase.add('LangDetector__Language__c');
            
            // Check if the above fields are accessible for the below query. Ensuring FLS.
            if(!LangDetectorCheckFLS.checkAccessibleFLS(fieldNamesCase,'Case')){
                system.debug('return null if case fields not accesible');
                return null;
            }
            
            Contact con;
            boolean flag = false;
            String[] Name;
            //Check if the sender is already a contact
            if([select count() from Contact where email=:email.fromAddress]!=0)
            {
                system.debug('inside if');
                con = [Select Id,Name from Contact where email=:email.fromAddress];
            }
            //If sender is not an existing contact create a new contact.
            else
            {
                
                con = new Contact();
                if(email.fromName!=null && email.fromName!='')
                {
                    Name = email.fromName.split(' ',2);
                    system.debug('name:'+Name);
                    con.firstName = Name[0];
                    con.lastName = Name[1];
                }
                con.Email = email.fromAddress;
                flag = true;
            }
            
            //Create a case with details of the email
            Case c = new Case();
            c.Subject = email.Subject;
            c.Description = email.plainTextBody;
            c.Origin = 'Email';
            
            
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            dmlOpts.EmailHeader.triggerAutoResponseEmail = true; 
            
            c.setOptions(dmlOpts);
            
            
            
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            List<String> fName = new List<String>();
            fName.add('LangDetector__API_Key_Value__c');
            fName.add('LangDetector__AES_Key__c');
            
            
            //check if custom setting field is accessible
            if(!LangDetectorCheckFLS.checkAccessibleFLS(fName,'LangDetector__API_Key_LD__c')){
                return null;
            }
            
            LangDetector__API_Key_LD__c apikeyObj = LangDetector__API_Key_LD__c.getValues('API Key');
            if(apikeyObj == null)
            {
                DE_APIException apiEx = new DE_APIException('Please check your API Key!','');
                apiEx.setMessage('Please enter your API Key!');
                throw apiEx; 
            }
            String keyToDecrypt = apikeyObj.LangDetector__API_Key_Value__c;
            String Aes = apikeyObj.LangDetector__AES_Key__c;
            
            //Performing decryption on the encrypted key
            Blob AesKey = EncodingUtil.base64Decode(Aes);
            Blob b64decoded = EncodingUtil.base64Decode(keyToDecrypt);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES128', AesKey, b64decoded);
            String key = decryptedData.toString();
            
            String text = email.Subject;            
            string url = 'https://translation.googleapis.com/language/translate/v2/detect?key='+key+'&q=' + EncodingUtil.urlEncode(text, 'UTF-8') ;
            
            req.setMethod('GET');            
            req.setEndPoint(url);            
            System.debug('URL ' + url);
            
            String jsonResults = '';            
            
            HTTPResponse resp = http.send(req);            
            jsonResults = resp.getBody();
            String st = resp.getStatus();
            
            if(st != null && st.equals('Bad Request'))
            {
                
                DE_APIException apiEx = new DE_APIException('Please check your API Key!','');
                apiEx.setMessage('Please check your API Key!');
                throw apiEx; 
            }
            
            //Parse the json response
            List<DetectLanguageClass.Detections> detectList = new List<DetectLanguageClass.Detections>();
            DetectLanguageClass jsonVar  = (DetectLanguageClass) System.JSON.deserialize(resp.getBody(), DetectLanguageClass.Class);
            if(jsonVar.data.detections[0] != null && jsonVar.data.detections[0].size()>0){
                detectList = jsonVar.data.detections[0];
            }
            
            if(detectList != null && detectList.size()>0){
                if(detectList[0].language == 'en')
                {
                    c.Language__c = 'English';
                }
                else if(detectList[0].language == 'nl')
                {
                    c.Language__c = 'Dutch';
                }
                else if(detectList[0].language == 'fr')
                {
                    c.Language__c = 'French';
                }
                else if(detectList[0].language == 'de')
                {
                    c.Language__c = 'German';
                }
                else if(detectList[0].language == 'hi')
                {
                    c.Language__c = 'Hindi';
                }
                else if(detectList[0].language == 'ga')
                {
                    c.Language__c = 'Irish';
                }
                else if(detectList[0].language == 'it')
                {
                    c.Language__c = 'Italian';
                }
                else if(detectList[0].language == 'ja')
                {
                    c.Language__c = 'Japanese';
                }
                else if(detectList[0].language == 'ko')
                {
                    c.Language__c = 'Korean';
                }
                else if(detectList[0].language == 'la')
                {
                    c.Language__c = 'Latin';
                }
                else if(detectList[0].language == 'fa')
                {
                    c.Language__c = 'Persian';
                }
                else if(detectList[0].language == 'ru')
                {
                    c.Language__c = 'Russian';
                }
                else if(detectList[0].language == 'sr')
                {
                    c.Language__c = 'Serbian';
                }
                else if(detectList[0].language == 'es')
                {
                    c.Language__c = 'Spanish';
                }
                else if(detectList[0].language == 'sv')
                {
                    c.Language__c = 'Swedish';
                }
                else if(detectList[0].language == 'th')
                {
                    c.Language__c = 'Thai';
                }
                else if(detectList[0].language == 'tr')
                {
                    c.Language__c = 'Turkish';
                }
                else
                {
                    c.Language__c = 'Other';
                }
            }
            
            List<String> fieldNamesContactInsertList = new List<String>();
            fieldNamesContactInsertList.add('FirstName');
            fieldNamesContactInsertList.add('LastName');
            fieldNamesContactInsertList.add('Email');
            // Check if the above fields are creatable for the below query. Ensuring FLS.
            if(!LangDetectorCheckFLS.checkCreateableFLS(fieldNamesContactInsertList,'Contact')){
                return null;
            }
            
            List<String> fieldNamesCaseInsertList = new List<String>();
            fieldNamesCaseInsertList.add('Subject');
            fieldNamesCaseInsertList.add('Description');
            fieldNamesCaseInsertList.add('Origin');
            fieldNamesCaseInsertList.add('ContactId');
            fieldNamesCaseInsertList.add('LangDetector__Language__c');
            // Check if the above fields are creatable for the below query. Ensuring FLS.
            if(!LangDetectorCheckFLS.checkCreateableFLS(fieldNamesCaseInsertList,'Case')){
                return null;
            }
            
            if(flag==true)
                insert con;
            
            c.contactId = con.Id;
            c.SuppliedName = con.Name;
            insert c;
            
        }
        catch(DE_APIException apiEx)
        {
            result.success = false;
            result.message = apiEx.getMessage();
        }
        catch(Exception e)
        {
            system.debug('e:'+e.getMessage());
            result.success = false;
            result.message = e.getMessage();
        }
        
        return result;
    } 
}
@isTest
public class DE_APIExceptionTest 
{
    static testMethod void testDE_APIException()
    {
        //MyException me1 = new MyException('hgh');
        try
        {
            String st = 'Bad Request';
            if(st.equals('Bad Request'))
            {
                DE_APIException apiEx = new DE_APIException('Please check your API Key!','');
                apiEx.setMessage('Please check your API Key!');
                throw apiEx; 
            }
        }
        catch(DE_APIException apiEx)
        {
            system.debug('apiEx:'+apiEx);
            System.Assert(apiEx.getMessage().contains('Please check your API Key!'), 'API Key is not accepted.');
        }
    }
}
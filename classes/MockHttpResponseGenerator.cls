@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req) 
    {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://translation.googleapis.com/language/translate/v2/detect?key=AIzaSyAUsZD7U8GhOJfG4QoWD96XV0zFo7iCmx4&q=test+case+for+english+language', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'+
		'  \"data\": {'+
		'    \"detections\": ['+
		'      ['+
		'        {'+
		'          \"confidence\": 0.61016535758972168,'+
		'          \"isReliable\": false,'+
		'          \"language\": \"ox\"'+
		'        }'+
		'      ]'+
		'    ]'+
		'  }'+
		'}');
        res.setStatusCode(200);
        return res;
    }
}
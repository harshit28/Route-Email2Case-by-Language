({
    doInit : function(component, event, helper) 
    {
        
    },
    saveValue : function(component, event, helper)
    {
        console.log('in save');
        console.log(component.get("v.apiValue"));
        var apiValue = component.get("v.apiValue");
        var toastEvent = $A.get("e.force:showToast");
        if(apiValue == undefined || apiValue == null || apiValue == ''){
            
            toastEvent.setParams({
                "message": "Please enter a valid API Key!",
                "type" : "error"
            });
            toastEvent.fire();
        } else{       
            var action = component.get("c.saveApiValue");
            action.setParams({ "apiValue" : apiValue });
            action.setCallback(this, function(response) {
                console.log(response.getReturnValue());
                var rec = response.getReturnValue();
                console.log('return after save: '+rec);
                
                toastEvent.setParams({
                    
                    "message": "Key has been saved!",
                    "type" : "success"
                });
                toastEvent.fire();
            });
            $A.enqueueAction(action); 
        }
    }
})
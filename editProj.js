function prodAction(psku, actionType) { 
	var params = new Array();
	var pSKU = null;
	var elements = ["name", "price", "sku", "cat"];
	
	for (var i = 0; i < elements.length; i++) {
	    var key = elements[i];
	    var ele = key;

	    if (psku !== undefined && psku !== null) ele = ele + "_" + psku;

	    var element = document.getElementById(ele);
	    var value = element.value;
	    
	    if (actionType === "insert") element.value = null;
	    if (key === "sku")  pSKU = value;

	    params.push(key + "=" + value);
	}

	if (psku !== undefined && psku !== null) params.push("psku=" + psku);

	params.push("action=" + actionType);

	makeRequest(params, actionType, pSKU);
}


function makeRequest(params, actionType, PSKU){
	var xmlHttp=new XMLHttpRequest();	
	
	xmlHttp.onreadystatechange=function() {
		if (xmlHttp.readyState != 4) return;
		
		if (xmlHttp.status != 200) {
			alert("HTTP status is " + xmlHttp.status + " instead of 200");
			return;
		};

		var responseDoc = xmlHttp.responseText;
		var response = eval('(' + responseDoc + ')');
		switch (actionType){
		    case "insert":
		        if (response.success) {
		            var table = document.getElementById("productsTable");

		            var row = table.insertRow(table.rows.length);
		            row.id = response.sku;
		            
		            var html ='<td><input id="name_'+ response.sku + '" value="'+ response.name+ '" name="uName" />' +
        			'</td><td><input id="price_'+ response.sku + '" value="'+ response.price+ '" name="uPrice" />' +
        			'</td><td><input id="sku_'+ response.sku + '" value="'+ response.sku+ '" name="uSKU" />' +
        			'</td><td><input id="cat_'+ response.sku + '" value="'+ response.cat+ '" name="uCategory" />' +
        			'</td><td><input onClick="prodAction('+ response.sku +',\'delete\');" type="button" value="Delete"/>' +
        			'</td><td><input onClick="prodAction('+ response.sku +',\'update\');" type="button" value="Update"/></td>';

		            row.innerHTML = html;
		            document.getElementById('response').innerHTML = "Insert Complete";
		        }
			break;
			
			case "update":
			    if (response.success) {
					document.getElementById('response').innerHTML = responseDoc.trim();
				}
			break;
			
			case "delete":
			    if (response.success) {
			    	var row = document.getElementById(PSKU);
					var parent = document.getElementById("prods");
					document.getElementById('response').innerHTML =  "product with sku: " + PSKU + " deleted";
					parent.removeChild(row);
				}
			break;
		
		}

	};
	
	// Send XHR request
	//var url = "editProj.jsp"
	var url="editProj.jsp?" + params.join("&");
	xmlHttp.open("POST",url,true);
	xmlHttp.send(null);
}
<% response.setContentType("text/xml") ; %>
<% 
String person=request.getParameter("person") ;
if (person!=null && person.equals("AV"))
  {
%>
<company>
 <compname>Vandelay Industries</compname>
 <contname>Inc.</contname>
 <address>9500 Gilman Drive</address>
 <city>La Jolla</city>
 <country>USA</country>
</company>
<%
  }
else if (person!=null && person.equals("JP"))
  {
%>
<company>
 <compname>Acme Industries</compname>
 <contname>Inc.</contname>
 <address>1200 Innovation Drive</address>
 <city>La Jolla</city>
 <country>USA</country>
</company>
<%
  }
else if (person!=null && person.equals("ND"))
  {
%>
<company>
 <compname>Foo Industries</compname>
 <contname>Inc.</contname>
 <address>999 Zero Drive</address>
 <city>La Jolla</city>
 <country>USA</country>
</company>
<%
  }
%>

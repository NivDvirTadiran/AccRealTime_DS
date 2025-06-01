<%@page import="tadiran.webnla.servlet.NLAService" pageEncoding="UTF-8"%>

<%
    if (!NLAService.isConnected())
    {
        response.sendError(response.SC_SERVICE_UNAVAILABLE);
        System.out.println("alive.jsp return SC_SERVICE_UNAVAILABLE (503)");
    }
    //else
    //{
    //    //response.setStatus(SC_OK);
    //    System.out.println("alive.jsp NLAService is Connected");
    //}
%>

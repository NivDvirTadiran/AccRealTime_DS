package tadiran.webnla.filter;
import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;



@WebFilter(filterName = "CorsFilter", urlPatterns = "/*", asyncSupported = true)
public final class CorsFilter implements Filter {
		 
	final static Logger LOGGER = LogManager.getLogger(CorsFilter.class);
	/**
	     * Default constructor.
	     */
	    public CorsFilter() {
		LOGGER.info("constructor");
	        // TODO Auto-generated constructor stub
	    }
	 
	    /**
	     * @see Filter#destroy()
	     */
	    public void destroy() {
	    	LOGGER.info("destroy CorsFilter");

	        // TODO Auto-generated method stub
	    }
	 
	    /**
	     * @see Filter#doFilter(ServletRequest, ServletResponse, FilterChain)
	     */
	    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain)
	            throws IOException, ServletException {
	 
	        HttpServletRequest request = (HttpServletRequest) servletRequest;
	        //LOGGER.info("CorsFilter HTTP Request: " + request.getMethod());
	 
	        // Authorize (allow) all domains to consume the content
	        ((HttpServletResponse) servletResponse).setHeader("Access-Control-Allow-Origin", "*");
			((HttpServletResponse) servletResponse).setHeader("Access-Control-Allow-Headers", "content-type,Authorization");
	        ((HttpServletResponse) servletResponse).setHeader("Access-Control-Allow-Methods","GET, OPTIONS, HEAD, PUT, POST");
	 
	        HttpServletResponse resp = (HttpServletResponse) servletResponse;
	 
	        // For HTTP OPTIONS verb/method reply with ACCEPTED status code -- per CORS handshake
	        if (request.getMethod().equals("OPTIONS")) {
	            resp.setStatus(HttpServletResponse.SC_ACCEPTED);
	            return;
	        }
	 
	        // pass the request along the filter chain
	        chain.doFilter(request, servletResponse);
	    }
	 
	    /**
	     * @see Filter#init(FilterConfig)
	     */
	    public void init(final FilterConfig fConfig) throws ServletException {
	    	LOGGER.info("init CorsFilter: " + fConfig.toString());

	        // TODO Auto-generated method stub
	    }
	 
	}

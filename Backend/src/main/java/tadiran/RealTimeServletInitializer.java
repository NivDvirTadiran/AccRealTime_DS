package tadiran;






import lombok.extern.log4j.Log4j2;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;


import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.ServletListenerRegistrationBean;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import tadiran.webnla.accrealtime.config.AdminApplicationContextInitializer;
import tadiran.webnla.servlet.SessionsListener;

@Log4j2
@SpringBootApplication
@EnableScheduling
public class RealTimeServletInitializer extends SpringBootServletInitializer {
    private static final Logger logger = LogManager.getLogger(RealTimeServletInitializer.class);
/*
    @Override
    public void onStartup(ServletContext servletContext) {

        WebApplicationContext rootAppContext = createRootApplicationContext(servletContext);
        if (rootAppContext != null) {
            servletContext.addListener(new ContextLoaderListener(rootAppContext) {
                @Override
                public void contextInitialized(ServletContextEvent event) {
                    // no-op because the application context is already initialized
                }
            });
        }
        else {
            logger.warn("No ContextLoaderListener registered, as createRootApplicationContext() did not "
                    + "return an application context");
        }

    }
*/
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(RealTimeServletInitializer.class).initializers(new AdminApplicationContextInitializer());
    }

    public static void main(String[] args) {
        SpringApplication sa = new SpringApplication(RealTimeServletInitializer.class);
        ConfigurableApplicationContext ctx = sa.run(args);
    }


    @Configuration
    //@EnableWebMvc
   @ComponentScan(basePackages = { "tadiran.webnla" })
    public class WebConfiguration implements WebMvcConfigurer {
        @Override
        public void addViewControllers(ViewControllerRegistry registry) {
            registry.addViewController("/").setViewName("forward:/index.html");
        }
/*
        @Bean
        public UrlBasedViewResolver viewResolver() {
            UrlBasedViewResolver resolver
                    = new UrlBasedViewResolver();
            resolver.setPrefix("/");
            resolver.setSuffix(".jsp");
            resolver.setViewClass(JstlView.class);
            return resolver;
        }*/
    }

    @Bean
    public ServletListenerRegistrationBean<SessionsListener> sessionsListener() {
        ServletListenerRegistrationBean<SessionsListener> listenerRegBean =
                new ServletListenerRegistrationBean<>();

        listenerRegBean.setListener(new SessionsListener());
        return listenerRegBean;
    }



}

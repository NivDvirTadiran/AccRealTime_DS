package tadiran.webnla.accrealtime;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.krysalis.jcharts.Chart;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/auth")
public class TemplateController {
    protected final Logger logger = LogManager.getLogger(this.getClass());

    @GetMapping("/check")
    @ResponseStatus(value = HttpStatus.OK)
    public String doPing(HttpServletResponse response)
    {
        return "{\"OK\":\"OK\"}";
    }

    @GetMapping("/Agents.Brief_Report")
    @ResponseStatus(value = HttpStatus.OK)
    public String table(HttpServletRequest request, HttpServletResponse response) {
        request.getSession(true);
        Chart chart;


        // prepare common chart params
        String title=request.getParameter("title");
        if ("".equals(title))
            title=null;
        request.setAttribute("title",title);

        String keys=request.getParameter("keys");
        if (keys==null)
            throw new IllegalArgumentException("No keys specified");

        request.setAttribute("fields",keys.split("[ ]*,[ ]*"));

        String size=request.getParameter("size");
        if ("".equals(size))
            size=null;


        String type=request.getParameter("type");



        return "{\"OK\":\"OK\"}";
    }

    /*
    *
    * users:
    *   agent ✔
    *   classes_of_service ✔
    *   sup ✔
    *
    * routing:
    *   irn ✔
    *   dnis ✔
    *   domain ✔
    *   ani_prefix ✔
    *   services ✔
    *   ani ✔
    *   announcers X
    *   dial_lists ✔
    *
    * reporting:
    *   grp  ✔
    *   ivr_apps ✔
    *   s_grp ✔
    *
    * system:
    *   Skill/user_fields ✔
    *   shifts ✔
    *   edbc_conn_name_info ✔
    *   block_allow_rules_list ✔
    *
    * */

}

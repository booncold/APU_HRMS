package com.apu.hrms.servlet.manager;

import com.apu.hrms.facade.ReportFacade;
import com.apu.hrms.util.JsonLite;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Manager reports page. Chart data is embedded as JSON for Chart.js.
 * Uses a tiny hand-rolled JSON encoder (no extra Maven dependency).
 */
@WebServlet("/manager/reports")
public class ManagerReportServlet extends HttpServlet {

    private static final String PAGE = "/WEB-INF/views/manager/reports.jsp";

    @EJB
    private ReportFacade reportFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setAttribute("summary", reportFacade.summaryCards());
        request.setAttribute(
                "occupancyFloorJson",
                JsonLite.toJson(reportFacade.occupancyByFloor())
        );
        request.setAttribute(
                "occupancyTypeJson",
                JsonLite.toJson(reportFacade.occupancyByType())
        );
        request.setAttribute(
                "revenueJson",
                JsonLite.toJson(reportFacade.revenueLastDays(14))
        );
        request.setAttribute(
                "statusJson",
                JsonLite.toJson(reportFacade.bookingStatusDistribution())
        );
        request.setAttribute(
                "hkJson",
                JsonLite.toJson(reportFacade.housekeeperCompletions())
        );
        request.setAttribute(
                "activityJson",
                JsonLite.toJson(reportFacade.feedbackAndCommentCounts())
        );

        request.getRequestDispatcher(PAGE).forward(request, response);
    }

}

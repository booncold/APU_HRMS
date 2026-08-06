package com.apu.hrms.servlet;

import com.apu.hrms.facade.ReportFacade;
import com.apu.hrms.util.JsonLite;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/manager/dashboard")
public class ManagerDashboardServlet extends HttpServlet {

    private static final String DASHBOARD_PAGE =
            "/WEB-INF/views/manager/dashboard.jsp";

    @EJB
    private ReportFacade reportFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setAttribute(
                "roomAvailability",
                reportFacade.roomAvailabilityByType()
        );
        request.setAttribute(
                "reviewQueue",
                reportFacade.reviewQueueCounts()
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

        request.getRequestDispatcher(DASHBOARD_PAGE)
                .forward(request, response);
    }
}

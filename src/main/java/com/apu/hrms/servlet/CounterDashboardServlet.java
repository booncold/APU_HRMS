package com.apu.hrms.servlet;

import com.apu.hrms.facade.BookingFacade;
import com.apu.hrms.facade.CleaningTaskFacade;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/counter/dashboard")
public class CounterDashboardServlet extends HttpServlet {

    private static final String DASHBOARD_PAGE =
            "/WEB-INF/views/counter/dashboard.jsp";

    @EJB
    private BookingFacade bookingFacade;

    @EJB
    private CleaningTaskFacade cleaningTaskFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        LocalDate today = LocalDate.now();
        request.setAttribute("today", today);
        request.setAttribute(
                "todayCheckInCount",
                bookingFacade.findCheckInsForDate(today).size()
        );
        request.setAttribute(
                "todayCheckOutCount",
                bookingFacade.findCheckOutsForDate(today).size()
        );
        request.setAttribute(
                "unassignedCleaningCount",
                cleaningTaskFacade.countRoomsAwaitingAssignment()
        );
        request.setAttribute(
                "currentBookings",
                bookingFacade.findUpcomingDetailed(today, 8)
        );

        request.getRequestDispatcher(DASHBOARD_PAGE)
                .forward(request, response);
    }
}

package com.apu.hrms.servlet;

import com.apu.hrms.entity.BookingOrder;
import com.apu.hrms.entity.User;
import com.apu.hrms.facade.BookingFacade;
import com.apu.hrms.facade.UserFacade;
import com.apu.hrms.util.SessionUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/customer/dashboard")
public class CustomerDashboardServlet extends HttpServlet {

    private static final String DASHBOARD_PAGE =
            "/WEB-INF/views/customer/dashboard.jsp";

    private static final int DASHBOARD_BOOKING_LIMIT = 3;

    @EJB
    private BookingFacade bookingFacade;

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        Long customerId = SessionUtil.getLoggedInUserId(request);
        User customer = customerId == null
                ? null
                : userFacade.findActiveById(customerId);
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<BookingOrder> bookings = bookingFacade.findByCustomer(customer);
        int visibleCount = Math.min(DASHBOARD_BOOKING_LIMIT, bookings.size());

        LocalDate today = LocalDate.now();
        request.setAttribute(
                "dashboardBookings",
                bookings.subList(0, visibleCount)
        );
        request.setAttribute("totalBookingCount", bookings.size());
        request.setAttribute("today", today);
        request.setAttribute("maxCheckIn", today.plusDays(5));
        request.setAttribute("defaultCheckOut", today.plusDays(1));

        request.getRequestDispatcher(DASHBOARD_PAGE)
                .forward(request, response);
    }
}

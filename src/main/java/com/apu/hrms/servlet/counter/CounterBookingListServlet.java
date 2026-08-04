package com.apu.hrms.servlet.counter;

import com.apu.hrms.facade.BookingFacade;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/counter/bookings")
public class CounterBookingListServlet extends HttpServlet {

    private static final String PAGE =
            "/WEB-INF/views/counter/booking-list.jsp";

    @EJB
    private BookingFacade bookingFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setAttribute("bookingList", bookingFacade.findAllDetailed());
        request.setAttribute("successMessage", request.getParameter("success"));
        request.setAttribute("errorMessage", request.getParameter("error"));

        request.getRequestDispatcher(PAGE)
                .forward(request, response);
    }
}

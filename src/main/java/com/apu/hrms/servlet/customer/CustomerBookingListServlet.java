package com.apu.hrms.servlet.customer;

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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/customer/bookings")
public class CustomerBookingListServlet extends HttpServlet {

    private static final String PAGE =
            "/WEB-INF/views/customer/booking-list.jsp";

    @EJB
    private BookingFacade bookingFacade;

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        User customer =
                userFacade.findActiveById(
                        SessionUtil.getLoggedInUserId(request)
                );

        List<BookingOrder> bookings = bookingFacade.findByCustomer(customer);
        Map<Long, Boolean> canCancelMap = new HashMap<>();
        for (BookingOrder order : bookings) {
            canCancelMap.put(order.getId(), bookingFacade.canCancel(order));
        }

        request.setAttribute("bookingList", bookings);
        request.setAttribute("canCancelMap", canCancelMap);
        request.setAttribute("successMessage", request.getParameter("success"));
        request.setAttribute("errorMessage", request.getParameter("error"));

        request.getRequestDispatcher(PAGE)
                .forward(request, response);
    }
}

package com.apu.hrms.servlet.customer;

import com.apu.hrms.entity.BookingOrder;
import com.apu.hrms.facade.BookingFacade;
import com.apu.hrms.util.SessionUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/customer/bookings/cancel")
public class CustomerCancelBookingServlet extends HttpServlet {

    @EJB
    private BookingFacade bookingFacade;

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String ctx = request.getContextPath();
        Long customerId = SessionUtil.getLoggedInUserId(request);
        Long orderId = parseId(request.getParameter("orderId"));

        try {
            BookingOrder order = bookingFacade.cancelBooking(orderId, customerId);
            String msg = "Booking " + order.getOrderNo()
                    + " cancelled. Refund (if any) is marked pending and "
                    + "is expected within 3 days (demo policy).";
            response.sendRedirect(
                    ctx + "/customer/bookings?success=" + encode(msg)
            );
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(
                    ctx + "/customer/bookings?error=" + encode(ex.getMessage())
            );
        }
    }

    private Long parseId(String raw) {
        try {
            return Long.valueOf(raw);
        } catch (Exception ex) {
            return null;
        }
    }

    private String encode(String value) {
        return URLEncoder.encode(
                value == null ? "" : value,
                StandardCharsets.UTF_8
        );
    }
}

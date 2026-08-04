package com.apu.hrms.servlet.counter;

import com.apu.hrms.entity.BookingRoom;
import com.apu.hrms.facade.BookingFacade;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/counter/check-out")
public class CounterCheckOutServlet extends HttpServlet {

    private static final String PAGE = "/WEB-INF/views/counter/check-out.jsp";

    @EJB
    private BookingFacade bookingFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setAttribute("stayList", bookingFacade.findActiveStays());
        request.setAttribute("successMessage", request.getParameter("success"));
        request.setAttribute("errorMessage", request.getParameter("error"));

        request.getRequestDispatcher(PAGE).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String ctx = request.getContextPath();
        Long bookingRoomId = parseId(request.getParameter("bookingRoomId"));

        try {
            BookingRoom line = bookingFacade.checkOut(bookingRoomId);
            String msg = "Checked out room " + line.getRoomNumberSnapshot()
                    + ". Room marked as needs cleaning.";
            response.sendRedirect(
                    ctx + "/counter/check-out?success=" + encode(msg)
            );
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(
                    ctx + "/counter/check-out?error=" + encode(ex.getMessage())
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

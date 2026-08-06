package com.apu.hrms.servlet.counter;

import com.apu.hrms.entity.BookingRoom;
import com.apu.hrms.facade.BookingFacade;
import jakarta.ejb.EJB;
import jakarta.ejb.EJBException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;

@WebServlet("/counter/check-in")
public class CounterCheckInServlet extends HttpServlet {

    private static final String PAGE = "/WEB-INF/views/counter/check-in.jsp";

    @EJB
    private BookingFacade bookingFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        LocalDate today = LocalDate.now();
        request.setAttribute("today", today);
        request.setAttribute(
                "checkInList",
                bookingFacade.findCheckInsDueByDate(today)
        );
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
            BookingRoom line = bookingFacade.checkIn(bookingRoomId);
            String msg = "Checked in room " + line.getRoomNumberSnapshot() + ".";
            response.sendRedirect(
                    ctx + "/counter/check-in?success=" + encode(msg)
            );
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(
                    ctx + "/counter/check-in?error=" + encode(ex.getMessage())
            );
        } catch (EJBException ex) {
            String businessMessage = findBusinessMessage(ex);
            if (businessMessage == null) {
                throw new ServletException("Unable to complete check-in.", ex);
            }
            response.sendRedirect(
                    ctx + "/counter/check-in?error=" + encode(businessMessage)
            );
        }
    }

    private String findBusinessMessage(Throwable throwable) {
        Throwable current = throwable;
        while (current != null) {
            if (current instanceof IllegalArgumentException) {
                return current.getMessage();
            }
            current = current.getCause();
        }
        return null;
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

package com.apu.hrms.servlet.customer;

import com.apu.hrms.entity.BookingOrder;
import com.apu.hrms.entity.User;
import com.apu.hrms.facade.BookingFacade;
import com.apu.hrms.facade.CommentFacade;
import com.apu.hrms.facade.UserFacade;
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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/customer/comments")
public class CustomerCommentServlet extends HttpServlet {

    private static final String PAGE = "/WEB-INF/views/customer/comment-form.jsp";

    @EJB
    private CommentFacade commentFacade;

    @EJB
    private BookingFacade bookingFacade;

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        User me = userFacade.findActiveById(SessionUtil.getLoggedInUserId(request));
        if (me == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<BookingOrder> bookings = bookingFacade.findByCustomer(me);
        Long preselect = parseId(request.getParameter("orderId"));
        List<User> mentionable = List.of();
        if (preselect != null) {
            mentionable = commentFacade.findMentionableStaff(preselect);
        }

        request.setAttribute("bookings", bookings);
        request.setAttribute("preselectOrderId", preselect);
        request.setAttribute("mentionableStaff", mentionable);
        request.setAttribute("myComments", commentFacade.findByCustomer(me));
        request.setAttribute("successMessage", request.getParameter("success"));
        request.setAttribute("errorMessage", request.getParameter("error"));

        request.getRequestDispatcher(PAGE).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath();
        Long customerId = SessionUtil.getLoggedInUserId(request);
        String action = request.getParameter("action");

        // Load mentionable staff when order changes
        if ("loadStaff".equals(action)) {
            Long orderId = parseId(request.getParameter("orderId"));
            response.sendRedirect(
                    ctx + "/customer/comments"
                            + (orderId == null ? "" : "?orderId=" + orderId)
            );
            return;
        }

        Long orderId = parseId(request.getParameter("orderId"));
        String content = request.getParameter("content");
        String[] staffParams = request.getParameterValues("staffIds");
        List<Long> staffIds = new ArrayList<>();
        if (staffParams != null) {
            for (String s : staffParams) {
                Long id = parseId(s);
                if (id != null) {
                    staffIds.add(id);
                }
            }
        }

        try {
            commentFacade.submitComment(customerId, orderId, content, staffIds);
            response.sendRedirect(
                    ctx + "/customer/comments?success="
                            + encode("Comment submitted successfully.")
            );
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(
                    ctx + "/customer/comments?error=" + encode(ex.getMessage())
                            + (orderId == null ? "" : "&orderId=" + orderId)
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

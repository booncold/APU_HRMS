package com.apu.hrms.servlet.housekeeper;

import com.apu.hrms.entity.Feedback;
import com.apu.hrms.entity.User;
import com.apu.hrms.facade.FeedbackFacade;
import com.apu.hrms.facade.RoomFacade;
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

@WebServlet("/housekeeper/feedback")
public class HousekeeperFeedbackServlet extends HttpServlet {

    private static final String PAGE = "/WEB-INF/views/housekeeper/feedback-form.jsp";

    @EJB
    private FeedbackFacade feedbackFacade;

    @EJB
    private RoomFacade roomFacade;

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        User me = loadHousekeeper(request);
        if (me == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setAttribute("rooms", roomFacade.findAllActive());
        request.setAttribute("myFeedbacks", feedbackFacade.findByHousekeeper(me));
        request.setAttribute("successMessage", request.getParameter("success"));
        request.setAttribute("errorMessage", request.getParameter("error"));
        request.setAttribute("preselectRoomId", request.getParameter("roomId"));

        request.getRequestDispatcher(PAGE).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String ctx = request.getContextPath();
        Long housekeeperId = SessionUtil.getLoggedInUserId(request);
        Long roomId = parseId(request.getParameter("roomId"));
        String content = request.getParameter("content");

        try {
            Feedback feedback = feedbackFacade.submitFeedback(
                    housekeeperId,
                    roomId,
                    content
            );
            String msg = "Feedback saved for room "
                    + feedback.getRoom().getRoomNumber() + ".";
            response.sendRedirect(
                    ctx + "/housekeeper/feedback?success=" + encode(msg)
            );
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(
                    ctx + "/housekeeper/feedback?error=" + encode(ex.getMessage())
                            + (roomId == null ? "" : "&roomId=" + roomId)
            );
        }
    }

    private User loadHousekeeper(HttpServletRequest request) {
        Long id = SessionUtil.getLoggedInUserId(request);
        if (id == null) {
            return null;
        }
        return userFacade.findActiveById(id);
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

package com.apu.hrms.servlet.manager;

import com.apu.hrms.facade.FeedbackFacade;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/manager/feedbacks")
public class ManagerFeedbackListServlet extends HttpServlet {

    private static final String PAGE = "/WEB-INF/views/manager/feedback-list.jsp";

    @EJB
    private FeedbackFacade feedbackFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setAttribute("feedbackList", feedbackFacade.findAll());
        request.getRequestDispatcher(PAGE).forward(request, response);
    }
}

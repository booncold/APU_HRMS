package com.apu.hrms.servlet.manager;

import com.apu.hrms.facade.CommentFacade;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/manager/comments")
public class ManagerCommentListServlet extends HttpServlet {

    private static final String PAGE = "/WEB-INF/views/manager/comment-list.jsp";

    @EJB
    private CommentFacade commentFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setAttribute("commentList", commentFacade.findAll());
        request.getRequestDispatcher(PAGE).forward(request, response);
    }
}

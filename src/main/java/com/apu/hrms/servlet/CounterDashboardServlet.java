package com.apu.hrms.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/counter/dashboard")
public class CounterDashboardServlet extends HttpServlet {

    private static final String DASHBOARD_PAGE =
            "/WEB-INF/views/counter/dashboard.jsp";

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null ||
                !"COUNTER_STAFF".equals(session.getAttribute("loggedInUserRole"))) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );

            return;
        }

        request.getRequestDispatcher(DASHBOARD_PAGE)
                .forward(request, response);
    }
}

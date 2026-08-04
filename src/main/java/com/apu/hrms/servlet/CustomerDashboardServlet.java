package com.apu.hrms.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/customer/dashboard")
public class CustomerDashboardServlet extends HttpServlet {

    private static final String DASHBOARD_PAGE =
            "/WEB-INF/views/customer/dashboard.jsp";

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.getRequestDispatcher(DASHBOARD_PAGE)
                .forward(request, response);
    }
}

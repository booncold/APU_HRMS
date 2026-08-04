package com.apu.hrms.servlet.counter;

import com.apu.hrms.facade.UserFacade;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/counter/customers")
public class CustomerListServlet extends HttpServlet {

    private static final String PAGE =
            "/WEB-INF/views/counter/customer-list.jsp";

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        // Always load full list; filtering is done live in the browser.
        request.setAttribute(
                "customerList",
                userFacade.findAllCustomers()
        );
        request.setAttribute("successMessage", request.getParameter("success"));
        request.setAttribute("errorMessage", request.getParameter("error"));

        request.getRequestDispatcher(PAGE)
                .forward(request, response);
    }
}

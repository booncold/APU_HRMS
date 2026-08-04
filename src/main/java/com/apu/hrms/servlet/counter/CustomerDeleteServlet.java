package com.apu.hrms.servlet.counter;

import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
import com.apu.hrms.facade.UserFacade;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/counter/customers/delete")
public class CustomerDeleteServlet extends HttpServlet {

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Long id = parseId(request.getParameter("id"));
        User customer =
                id == null ? null : userFacade.findActiveById(id);

        String redirect;

        if (customer == null || customer.getRole() != UserRole.CUSTOMER) {
            redirect = request.getContextPath()
                    + "/counter/customers?error="
                    + encode("Customer not found.");
        } else {
            userFacade.softDelete(customer);
            redirect = request.getContextPath()
                    + "/counter/customers?success="
                    + encode("Customer deleted.");
        }

        response.sendRedirect(redirect);
    }

    private Long parseId(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            return Long.valueOf(raw.trim());
        } catch (NumberFormatException exception) {
            return null;
        }
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}

package com.apu.hrms.servlet;

import com.apu.hrms.entity.PasswordResetToken;
import com.apu.hrms.facade.PasswordResetFacade;
import com.apu.hrms.util.ValidationUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private static final String PAGE =
            "/WEB-INF/views/auth/reset-password.jsp";

    @EJB
    private PasswordResetFacade passwordResetFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String token = request.getParameter("token");
        PasswordResetToken valid = passwordResetFacade.findValidToken(token);
        if (valid == null) {
            request.setAttribute(
                    "errorMessage",
                    "This reset link is invalid or has expired. Request a new one."
            );
            request.setAttribute("tokenValid", false);
        } else {
            request.setAttribute("tokenValid", true);
            request.setAttribute("token", token);
        }
        request.getRequestDispatcher(PAGE).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String token = request.getParameter("token");
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");

        Map<String, String> errors = ValidationUtil.newErrorMap();
        ValidationUtil.validatePassword(errors, password, true);
        if (password != null && !password.equals(confirm)) {
            errors.put("confirmPassword", "Passwords do not match.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("token", token);
            request.setAttribute(
                    "tokenValid",
                    passwordResetFacade.findValidToken(token) != null
            );
            request.getRequestDispatcher(PAGE).forward(request, response);
            return;
        }

        try {
            passwordResetFacade.resetPassword(token, password);
            response.sendRedirect(
                    request.getContextPath()
                            + "/login?success=Password+updated.+Please+sign+in."
            );
        } catch (IllegalArgumentException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("tokenValid", false);
            request.getRequestDispatcher(PAGE).forward(request, response);
        }
    }
}

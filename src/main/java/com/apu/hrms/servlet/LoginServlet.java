package com.apu.hrms.servlet;

import com.apu.hrms.entity.User;
import com.apu.hrms.facade.UserFacade;
import com.apu.hrms.util.PasswordUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final String LOGIN_PAGE =
            "/WEB-INF/views/auth/login.jsp";

    @EJB
    private UserFacade userFacade;

    /**
     * Handles opening the login page.
     *
     * Example:
     * GET /login
     */
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        HttpSession existingSession =
                request.getSession(false);

        if (existingSession != null
                && existingSession.getAttribute("loggedInUserRole") != null) {

            String role =
                    String.valueOf(
                            existingSession.getAttribute("loggedInUserRole")
                    );

            response.sendRedirect(
                    request.getContextPath() + dashboardPathForRole(role)
            );
            return;
        }

        if (request.getParameter("success") != null) {
            request.setAttribute("infoMessage", request.getParameter("success"));
        }
        request.getRequestDispatcher(LOGIN_PAGE)
                .forward(request, response);
    }

    /**
     * Handles submission of the login form.
     *
     * Example:
     * POST /login
     */
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        /*
         * Ensures submitted text uses UTF-8.
         * This must be called before getParameter().
         */
        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        /*
         * Remove unnecessary spaces around the email.
         */
        if (email != null) {
            email = email.trim();
        }

        String emailError =
                validateEmail(email);

        String passwordError =
                validatePassword(password);

        /*
         * Input is invalid:
         * send the error back to login.jsp.
         */
        if (emailError != null || passwordError != null) {
            request.setAttribute(
                    "emailError",
                    emailError
            );

            request.setAttribute(
                    "passwordError",
                    passwordError
            );

            request.setAttribute(
                    "enteredEmail",
                    email
            );

            request.getRequestDispatcher(LOGIN_PAGE)
                    .forward(request, response);

            return;
        }

        User user =
                userFacade.findByEmail(email);

        String submittedPasswordHash =
                PasswordUtil.hashPassword(password);

        if (user == null ||
                !submittedPasswordHash.equals(user.getPasswordHash())) {

            request.setAttribute(
                    "emailError",
                    "Invalid email or password."
            );

            request.setAttribute(
                    "enteredEmail",
                    email
            );

            request.getRequestDispatcher(LOGIN_PAGE)
                    .forward(request, response);

            return;
        }

        request.setAttribute(
                "enteredEmail",
                email
        );

        HttpSession session =
                request.getSession();

        session.setAttribute(
                "loggedInUserId",
                user.getId()
        );

        session.setAttribute(
                "loggedInUserName",
                user.getName()
        );

        session.setAttribute(
                "loggedInUserRole",
                user.getRole().name()
        );

        response.sendRedirect(
                request.getContextPath() + getDashboardPath(user)
        );
    }

    private String getDashboardPath(User user) {
        return dashboardPathForRole(user.getRole().name());
    }

    private String dashboardPathForRole(String role) {
        return switch (role) {
            case "MANAGER" -> "/manager/dashboard";
            case "COUNTER_STAFF" -> "/counter/dashboard";
            case "HOUSEKEEPER" -> "/housekeeper/dashboard";
            case "CUSTOMER" -> "/customer/dashboard";
            default -> "/login";
        };
    }

    /**
     * Returns an email error message when validation fails.
     * Returns null when the email input is valid.
     */
    private String validateEmail(String email) {

        if (email == null || email.isBlank()) {
            return "Email address is required.";
        }

        if (!email.contains("@")) {
            return "Email address must contain @.";
        }

        return null;
    }

    /**
     * Returns a password error message when validation fails.
     * Returns null when the password input is valid.
     */
    private String validatePassword(String password) {

        if (password == null || password.isBlank()) {
            return "Password is required.";
        }

        return null;
    }
}

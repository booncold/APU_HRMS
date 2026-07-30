package com.apu.hrms.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final String LOGIN_PAGE =
            "/WEB-INF/views/auth/login.jsp";

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

            request.setAttribute(
                    "enteredPassword",
                    password
            );

            request.getRequestDispatcher(LOGIN_PAGE)
                    .forward(request, response);

            return;
        }

        /*
         * Temporary result.
         *
         * Database authentication has not been
         * implemented yet. This confirms that
         * the form and server-side validation work.
         */
        request.setAttribute(
                "infoMessage",
                "Input accepted. Database authentication will be connected next."
        );

        request.setAttribute(
                "enteredEmail",
                email
        );

        request.getRequestDispatcher(LOGIN_PAGE)
                .forward(request, response);
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

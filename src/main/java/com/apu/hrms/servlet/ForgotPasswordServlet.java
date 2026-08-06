package com.apu.hrms.servlet;

import com.apu.hrms.facade.PasswordResetFacade;
import com.apu.hrms.util.MailUtil;
import com.apu.hrms.util.ValidationUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Forgot-password: create one-time token, email when SMTP is configured.
 * When SMTP is not configured, a local demo reset link is shown (assignment-friendly).
 * Response message is always generic to reduce email enumeration.
 */
@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private static final String PAGE =
            "/WEB-INF/views/auth/forgot-password.jsp";

    @EJB
    private PasswordResetFacade passwordResetFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setAttribute("smtpConfigured", MailUtil.isConfigured());
        request.getRequestDispatcher(PAGE).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String email = ValidationUtil.trim(request.getParameter("email"));

        // Always show the same base message (anti-enumeration)
        String info =
                "If an account exists for that email, a password reset link has been prepared.";

        String token = passwordResetFacade.requestResetToken(email);
        boolean mailed = false;
        String demoLink = null;

        if (token != null) {
            String link = request.getScheme() + "://"
                    + request.getServerName()
                    + (request.getServerPort() == 80 || request.getServerPort() == 443
                    ? "" : ":" + request.getServerPort())
                    + request.getContextPath()
                    + "/reset-password?token=" + token;

            mailed = passwordResetFacade.sendResetEmail(email, link);
            if (!mailed) {
                demoLink = link;
            }
        }

        request.setAttribute("infoMessage", info);
        request.setAttribute("smtpConfigured", MailUtil.isConfigured());
        request.setAttribute("mailSent", mailed);
        request.setAttribute("demoResetLink", demoLink);
        request.getRequestDispatcher(PAGE).forward(request, response);
    }
}

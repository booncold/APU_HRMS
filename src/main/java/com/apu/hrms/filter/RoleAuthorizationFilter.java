package com.apu.hrms.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Ensures the logged-in role matches the URL area being accessed.
 * /profile is shared by all authenticated roles.
 * Mapping and order are declared in web.xml.
 */
public class RoleAuthorizationFilter implements Filter {

    @Override
    public void doFilter(
            ServletRequest servletRequest,
            ServletResponse servletResponse,
            FilterChain chain
    ) throws IOException, ServletException {

        HttpServletRequest request =
                (HttpServletRequest) servletRequest;

        HttpServletResponse response =
                (HttpServletResponse) servletResponse;

        HttpSession session =
                request.getSession(false);

        if (session == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        String role =
                String.valueOf(session.getAttribute("loggedInUserRole"));

        String path =
                request.getRequestURI().substring(
                        request.getContextPath().length()
                );

        if (!isAllowed(path, role)) {
            response.sendRedirect(
                    request.getContextPath() + dashboardForRole(role)
            );
            return;
        }

        chain.doFilter(servletRequest, servletResponse);
    }

    private boolean isAllowed(String path, String role) {
        if (path.equals("/profile") || path.startsWith("/profile/")) {
            return true;
        }

        if (path.startsWith("/manager/")) {
            return "MANAGER".equals(role);
        }

        if (path.startsWith("/counter/")) {
            return "COUNTER_STAFF".equals(role);
        }

        if (path.startsWith("/housekeeper/")) {
            return "HOUSEKEEPER".equals(role);
        }

        if (path.startsWith("/customer/")) {
            return "CUSTOMER".equals(role);
        }

        return false;
    }

    private String dashboardForRole(String role) {
        return switch (role) {
            case "MANAGER" -> "/manager/dashboard";
            case "COUNTER_STAFF" -> "/counter/dashboard";
            case "HOUSEKEEPER" -> "/housekeeper/dashboard";
            case "CUSTOMER" -> "/customer/dashboard";
            default -> "/login";
        };
    }
}

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
 * Blocks unauthenticated access to protected application paths.
 * Mapping and order are declared in web.xml.
 */
public class AuthenticationFilter implements Filter {

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

        boolean loggedIn =
                session != null
                        && session.getAttribute("loggedInUserId") != null
                        && session.getAttribute("loggedInUserRole") != null;

        if (!loggedIn) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        chain.doFilter(servletRequest, servletResponse);
    }
}

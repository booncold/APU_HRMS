package com.apu.hrms.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public final class SessionUtil {

    private SessionUtil() {
    }

    public static HttpSession requireSession(HttpServletRequest request) {
        return request.getSession(false);
    }

    public static Long getLoggedInUserId(HttpServletRequest request) {
        HttpSession session = requireSession(request);
        if (session == null) {
            return null;
        }

        Object value = session.getAttribute("loggedInUserId");
        if (value instanceof Long longValue) {
            return longValue;
        }
        if (value instanceof Number number) {
            return number.longValue();
        }
        return null;
    }

    public static String getLoggedInUserRole(HttpServletRequest request) {
        HttpSession session = requireSession(request);
        if (session == null) {
            return null;
        }
        Object role = session.getAttribute("loggedInUserRole");
        return role == null ? null : String.valueOf(role);
    }

    public static boolean isRole(HttpServletRequest request, String role) {
        return role != null && role.equals(getLoggedInUserRole(request));
    }
}

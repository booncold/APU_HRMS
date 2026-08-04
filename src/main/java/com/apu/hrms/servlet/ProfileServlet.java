package com.apu.hrms.servlet;

import com.apu.hrms.entity.User;
import com.apu.hrms.facade.UserFacade;
import com.apu.hrms.util.PasswordUtil;
import com.apu.hrms.util.PhoneUtil;
import com.apu.hrms.util.SessionUtil;
import com.apu.hrms.util.ValidationUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private static final String PAGE = "/WEB-INF/views/common/profile.jsp";

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        User user = loadUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        fillForm(request, user);
        request.setAttribute("successMessage", request.getParameter("success"));
        request.setAttribute("errorMessage", request.getParameter("error"));
        request.getRequestDispatcher(PAGE).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        User user = loadUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String form = request.getParameter("form");
        if ("password".equals(form)) {
            handlePassword(request, response, user);
        } else {
            handleProfile(request, response, user);
        }
    }

    private void handleProfile(
            HttpServletRequest request,
            HttpServletResponse response,
            User user
    ) throws ServletException, IOException {

        String name = ValidationUtil.trim(request.getParameter("name"));
        String gender = ValidationUtil.trim(request.getParameter("gender"));
        String phoneStored = PhoneUtil.normalize(
                ValidationUtil.trim(request.getParameter("phone"))
        );
        String email = ValidationUtil.trim(request.getParameter("email"));
        String address = ValidationUtil.trim(request.getParameter("address"));
        // IC is identity — keep existing, not editable for safety
        String ic = user.getIc();

        Map<String, String> errors = ValidationUtil.newErrorMap();
        ValidationUtil.requireText(errors, "name", name, "Name is required.");
        ValidationUtil.validateGender(errors, gender);
        ValidationUtil.validatePhone(errors, phoneStored);
        ValidationUtil.validateEmail(errors, email);
        ValidationUtil.requireText(errors, "address", address, "Address is required.");

        if (email != null && !email.equalsIgnoreCase(user.getEmail())) {
            User existing = userFacade.findByEmailIncludingDeleted(email);
            if (existing != null && !existing.getId().equals(user.getId())) {
                errors.put("email", "Email is already in use.");
            }
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("enteredName", name);
            request.setAttribute("enteredGender", gender);
            request.setAttribute("enteredPhone", PhoneUtil.formatForDisplay(phoneStored));
            request.setAttribute("enteredEmail", email);
            request.setAttribute("enteredAddress", address);
            request.setAttribute("enteredIc", ic);
            request.setAttribute("userRole", user.getRole().name());
            request.getRequestDispatcher(PAGE).forward(request, response);
            return;
        }

        user.setName(name);
        user.setGender(gender);
        user.setPhone(phoneStored);
        user.setEmail(email);
        user.setAddress(address);
        userFacade.update(user);

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.setAttribute("loggedInUserName", user.getName());
        }

        response.sendRedirect(
                request.getContextPath() + "/profile?success="
                        + encode("Profile updated.")
        );
    }

    private void handlePassword(
            HttpServletRequest request,
            HttpServletResponse response,
            User user
    ) throws ServletException, IOException {

        String current = request.getParameter("currentPassword");
        String next = request.getParameter("newPassword");
        String confirm = request.getParameter("confirmPassword");

        Map<String, String> errors = ValidationUtil.newErrorMap();
        if (current == null || current.isBlank()) {
            errors.put("currentPassword", "Current password is required.");
        } else if (!PasswordUtil.hashPassword(current).equals(user.getPasswordHash())) {
            errors.put("currentPassword", "Current password is incorrect.");
        }

        ValidationUtil.validatePassword(errors, next, true);
        if (errors.containsKey("password")) {
            errors.put("newPassword", errors.remove("password"));
        }
        if (next != null && !next.equals(confirm)) {
            errors.put("confirmPassword", "New passwords do not match.");
        }

        if (!errors.isEmpty()) {
            fillForm(request, user);
            request.setAttribute("errors", errors);
            request.setAttribute("passwordSection", true);
            request.getRequestDispatcher(PAGE).forward(request, response);
            return;
        }

        user.setPasswordHash(PasswordUtil.hashPassword(next));
        userFacade.update(user);

        response.sendRedirect(
                request.getContextPath() + "/profile?success="
                        + encode("Password changed successfully.")
        );
    }

    private User loadUser(HttpServletRequest request) {
        Long id = SessionUtil.getLoggedInUserId(request);
        if (id == null) {
            return null;
        }
        return userFacade.findActiveById(id);
    }

    private void fillForm(HttpServletRequest request, User user) {
        request.setAttribute("enteredName", user.getName());
        request.setAttribute("enteredGender", user.getGender());
        request.setAttribute(
                "enteredPhone",
                PhoneUtil.formatForDisplay(user.getPhone())
        );
        request.setAttribute("enteredEmail", user.getEmail());
        request.setAttribute("enteredAddress", user.getAddress());
        request.setAttribute("enteredIc", user.getIc());
        request.setAttribute("userRole", user.getRole().name());
    }

    private String encode(String value) {
        try {
            return java.net.URLEncoder.encode(
                    value == null ? "" : value,
                    java.nio.charset.StandardCharsets.UTF_8
            );
        } catch (Exception ex) {
            return "";
        }
    }
}

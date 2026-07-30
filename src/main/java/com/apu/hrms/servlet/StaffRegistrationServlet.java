package com.apu.hrms.servlet;

import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
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
import java.util.HashMap;
import java.util.Map;

@WebServlet("/manager/staff/new")
public class StaffRegistrationServlet extends HttpServlet {

    private static final String STAFF_FORM_PAGE =
            "/WEB-INF/views/manager/staff-form.jsp";

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        if (!isManagerLoggedIn(request)) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );

            return;
        }

        request.getRequestDispatcher(STAFF_FORM_PAGE)
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!isManagerLoggedIn(request)) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );

            return;
        }

        String name =
                trim(request.getParameter("name"));
        String password =
                request.getParameter("password");
        String gender =
                trim(request.getParameter("gender"));
        String phone =
                trim(request.getParameter("phone"));
        String ic =
                trim(request.getParameter("ic"));
        String email =
                trim(request.getParameter("email"));
        String address =
                trim(request.getParameter("address"));
        String roleText =
                trim(request.getParameter("role"));

        Map<String, String> errors =
                validateStaff(
                        name,
                        password,
                        gender,
                        phone,
                        ic,
                        email,
                        address,
                        roleText
                );

        if (!errors.containsKey("email") &&
                userFacade.findByEmail(email) != null) {
            errors.put(
                    "email",
                    "Email is already registered."
            );
        }

        if (!errors.containsKey("ic") &&
                userFacade.existsByIc(ic)) {
            errors.put(
                    "ic",
                    "IC is already registered."
            );
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            preserveInput(
                    request,
                    name,
                    gender,
                    phone,
                    ic,
                    email,
                    address,
                    roleText
            );

            request.getRequestDispatcher(STAFF_FORM_PAGE)
                    .forward(request, response);

            return;
        }

        User staff =
                new User();

        staff.setName(name);
        staff.setPasswordHash(
                PasswordUtil.hashPassword(password)
        );
        staff.setGender(gender);
        staff.setPhone(phone);
        staff.setIc(ic);
        staff.setEmail(email);
        staff.setAddress(address);
        staff.setRole(UserRole.valueOf(roleText));

        userFacade.create(staff);

        request.setAttribute(
                "successMessage",
                "Staff account created successfully."
        );

        request.getRequestDispatcher(STAFF_FORM_PAGE)
                .forward(request, response);
    }

    private boolean isManagerLoggedIn(HttpServletRequest request) {
        HttpSession session =
                request.getSession(false);

        return session != null &&
                "MANAGER".equals(session.getAttribute("loggedInUserRole"));
    }

    private Map<String, String> validateStaff(
            String name,
            String password,
            String gender,
            String phone,
            String ic,
            String email,
            String address,
            String roleText
    ) {

        Map<String, String> errors =
                new HashMap<>();

        if (name == null || name.isBlank()) {
            errors.put("name", "Name is required.");
        }

        if (password == null || password.isBlank()) {
            errors.put("password", "Password is required.");
        }

        if (gender == null || gender.isBlank()) {
            errors.put("gender", "Gender is required.");
        }

        if (phone == null || phone.isBlank()) {
            errors.put("phone", "Phone is required.");
        } else if (!phone.matches("\\+60\\d+")) {
            errors.put(
                    "phone",
                    "Phone must start with +60 and contain numbers only."
            );
        }

        if (ic == null || ic.isBlank()) {
            errors.put("ic", "IC is required.");
        } else if (!ic.matches("\\d{6}-\\d{2}-\\d{4}")) {
            errors.put(
                    "ic",
                    "IC format must be XXXXXX-XX-XXXX."
            );
        }

        if (email == null || email.isBlank()) {
            errors.put("email", "Email is required.");
        } else if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            errors.put("email", "Invalid email address.");
        }

        if (address == null || address.isBlank()) {
            errors.put("address", "Address is required.");
        }

        if (!isStaffRole(roleText)) {
            errors.put("role", "Choose a valid staff role.");
        }

        return errors;
    }

    private boolean isStaffRole(String roleText) {
        return "MANAGER".equals(roleText) ||
                "COUNTER_STAFF".equals(roleText) ||
                "HOUSEKEEPER".equals(roleText);
    }

    private void preserveInput(
            HttpServletRequest request,
            String name,
            String gender,
            String phone,
            String ic,
            String email,
            String address,
            String roleText
    ) {

        request.setAttribute("enteredName", name);
        request.setAttribute("enteredGender", gender);
        request.setAttribute("enteredPhone", phone);
        request.setAttribute("enteredIc", ic);
        request.setAttribute("enteredEmail", email);
        request.setAttribute("enteredAddress", address);
        request.setAttribute("enteredRole", roleText);
    }

    private String trim(String value) {
        if (value == null) {
            return null;
        }

        return value.trim();
    }
}

package com.apu.hrms.servlet.manager;

import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
import com.apu.hrms.facade.UserFacade;
import com.apu.hrms.util.PasswordUtil;
import com.apu.hrms.util.PhoneUtil;
import com.apu.hrms.util.SessionUtil;
import com.apu.hrms.util.StaffPermissionUtil;
import com.apu.hrms.util.ValidationUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet("/manager/staff/edit")
public class StaffEditServlet extends HttpServlet {

    private static final String PAGE =
            "/WEB-INF/views/manager/staff-form.jsp";

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        User actor =
                userFacade.findActiveById(
                        SessionUtil.getLoggedInUserId(request)
                );

        User staff =
                loadTarget(request);

        if (staff == null || actor == null
                || !StaffPermissionUtil.canModifyStaff(actor, staff)) {
            response.sendRedirect(
                    request.getContextPath()
                            + "/manager/staff?error="
                            + encode("You cannot edit this staff account.")
            );
            return;
        }

        fillFormFromUser(request, staff);
        request.setAttribute("formMode", "edit");
        request.setAttribute("staffId", staff.getId());
        request.setAttribute("actorIsSeedAdmin", actor.isSeedAdmin());
        request.setAttribute(
                "passwordHint",
                "Leave blank to keep the current password."
        );

        request.getRequestDispatcher(PAGE)
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User actor =
                userFacade.findActiveById(
                        SessionUtil.getLoggedInUserId(request)
                );

        User staff =
                loadTarget(request);

        if (staff == null || actor == null
                || !StaffPermissionUtil.canModifyStaff(actor, staff)) {
            response.sendRedirect(
                    request.getContextPath()
                            + "/manager/staff?error="
                            + encode("You cannot edit this staff account.")
            );
            return;
        }

        String name = ValidationUtil.trim(request.getParameter("name"));
        String password = request.getParameter("password");
        String gender = ValidationUtil.trim(request.getParameter("gender"));
        String phoneStored =
                PhoneUtil.normalize(
                        ValidationUtil.trim(request.getParameter("phone"))
                );
        String ic = ValidationUtil.trim(request.getParameter("ic"));
        String email = ValidationUtil.trim(request.getParameter("email"));
        String address = ValidationUtil.trim(request.getParameter("address"));
        String roleText = ValidationUtil.trim(request.getParameter("role"));

        Map<String, String> errors = ValidationUtil.newErrorMap();

        ValidationUtil.requireText(errors, "name", name, "Name is required.");
        ValidationUtil.validateGender(errors, gender);
        ValidationUtil.validatePhone(errors, phoneStored);
        ValidationUtil.validateIc(errors, ic);
        ValidationUtil.validateEmail(errors, email);
        ValidationUtil.requireText(errors, "address", address, "Address is required.");
        ValidationUtil.validatePassword(errors, password, false);

        UserRole newRole = parseStaffRole(roleText);
        if (newRole == null) {
            errors.put("role", "Choose a valid staff role.");
        } else if (newRole == UserRole.MANAGER
                && !actor.isSeedAdmin()
                && staff.getRole() != UserRole.MANAGER) {
            // Non-seed cannot promote to manager
            errors.put("role", "Only the seed manager can assign the Manager role.");
        } else if (newRole == UserRole.MANAGER
                && !actor.isSeedAdmin()
                && staff.getRole() == UserRole.MANAGER) {
            // keep as manager - ok for display but non-seed shouldn't reach here
            errors.put("role", "You cannot change manager accounts.");
        } else if (staff.getRole() == UserRole.MANAGER
                && newRole != UserRole.MANAGER
                && !actor.isSeedAdmin()) {
            errors.put("role", "You cannot change manager accounts.");
        } else if (newRole != null
                && newRole != staff.getRole()
                && newRole == UserRole.MANAGER
                && !StaffPermissionUtil.canCreateRole(actor, newRole)) {
            errors.put("role", "Only the seed manager can assign the Manager role.");
        }

        // Non-seed managers cannot change a staff member into/out of manager
        if (newRole != null && !actor.isSeedAdmin()) {
            if (staff.getRole() == UserRole.MANAGER || newRole == UserRole.MANAGER) {
                errors.put("role", "Only the seed manager can manage Manager roles.");
            }
        }

        if (!errors.containsKey("email")
                && userFacade.existsByEmailExcludingId(email, staff.getId())) {
            errors.put("email", "Email is already registered.");
        }

        if (!errors.containsKey("ic")
                && userFacade.existsByIcExcludingId(ic, staff.getId())) {
            errors.put("ic", "IC is already registered.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("formMode", "edit");
            request.setAttribute("staffId", staff.getId());
            request.setAttribute("actorIsSeedAdmin", actor.isSeedAdmin());
            request.setAttribute(
                    "passwordHint",
                    "Leave blank to keep the current password."
            );
            preserveInput(
                    request,
                    name,
                    gender,
                    PhoneUtil.formatForDisplay(phoneStored),
                    ic,
                    email,
                    address,
                    roleText
            );
            request.getRequestDispatcher(PAGE)
                    .forward(request, response);
            return;
        }

        staff.setName(name);
        staff.setGender(gender);
        staff.setPhone(phoneStored);
        staff.setIc(ic);
        staff.setEmail(email);
        staff.setAddress(address);
        staff.setRole(newRole);

        if (password != null && !password.isBlank()) {
            staff.setPasswordHash(PasswordUtil.hashPassword(password));
        }

        userFacade.update(staff);

        response.sendRedirect(
                request.getContextPath()
                        + "/manager/staff?success="
                        + encode("Staff account updated.")
        );
    }

    private User loadTarget(HttpServletRequest request) {
        Long id = parseId(request.getParameter("id"));
        if (id == null) {
            return null;
        }
        return userFacade.findActiveById(id);
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

    private UserRole parseStaffRole(String roleText) {
        if (roleText == null) {
            return null;
        }
        try {
            UserRole role = UserRole.valueOf(roleText);
            if (role == UserRole.CUSTOMER) {
                return null;
            }
            return role;
        } catch (IllegalArgumentException exception) {
            return null;
        }
    }

    private void fillFormFromUser(HttpServletRequest request, User staff) {
        preserveInput(
                request,
                staff.getName(),
                staff.getGender(),
                PhoneUtil.formatForDisplay(staff.getPhone()),
                staff.getIc(),
                staff.getEmail(),
                staff.getAddress(),
                staff.getRole().name()
        );
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

    private String encode(String value) {
        return java.net.URLEncoder.encode(
                value,
                java.nio.charset.StandardCharsets.UTF_8
        );
    }
}

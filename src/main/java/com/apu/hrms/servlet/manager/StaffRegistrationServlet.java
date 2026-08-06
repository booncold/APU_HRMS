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

@WebServlet("/manager/staff/new")
public class StaffRegistrationServlet extends HttpServlet {

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

        request.setAttribute("formMode", "create");
        request.setAttribute("actorIsSeedAdmin", actor != null && actor.isSeedAdmin());
        request.setAttribute("enteredPhone", "+60 ");

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
        ValidationUtil.validatePassword(errors, password, true);
        ValidationUtil.validateGender(errors, gender);
        ValidationUtil.validatePhone(errors, phoneStored);
        ValidationUtil.validateIc(errors, ic);
        ValidationUtil.validateEmail(errors, email);
        ValidationUtil.requireText(errors, "address", address, "Address is required.");

        UserRole role = parseStaffRole(roleText);
        if (role == null) {
            errors.put("role", "Choose a valid staff role.");
        } else if (actor == null
                || !StaffPermissionUtil.canCreateRole(actor, role)) {
            errors.put(
                    "role",
                    "You are not allowed to create this staff role."
            );
        }

        User existingEmail =
                userFacade.findByEmailIncludingDeleted(email);
        if (!errors.containsKey("email")
                && existingEmail != null
                && !existingEmail.isDeleted()) {
            errors.put("email", "Email is already registered.");
        }

        User existingIc =
                userFacade.findByIcIncludingDeleted(ic);
        if (!errors.containsKey("ic")
                && existingIc != null
                && !existingIc.isDeleted()) {
            errors.put("ic", "IC is already registered.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("formMode", "create");
            request.setAttribute(
                    "actorIsSeedAdmin",
                    actor != null && actor.isSeedAdmin()
            );
            if (!errors.containsKey("password")) {
                request.setAttribute("enteredPassword", password);
            }
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

        User staff = new User();
        staff.setName(name);
        staff.setPasswordHash(PasswordUtil.hashPassword(password));
        staff.setGender(gender);
        staff.setPhone(phoneStored);
        staff.setIc(ic);
        staff.setEmail(email);
        staff.setAddress(address);
        staff.setRole(role);
        staff.setSeedAdmin(false);
        staff.setDeleted(false);

        boolean restored =
                userFacade.createOrRestore(staff);

        request.setAttribute(
                "successMessage",
                restored
                        ? "Staff account restored and updated successfully."
                        : "Staff account created successfully."
        );
        request.setAttribute("formMode", "create");
        request.setAttribute(
                "actorIsSeedAdmin",
                actor != null && actor.isSeedAdmin()
        );
        request.setAttribute("enteredPhone", "+60 ");

        request.getRequestDispatcher(PAGE)
                .forward(request, response);
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
}

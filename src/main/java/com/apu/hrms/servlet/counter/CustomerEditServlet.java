package com.apu.hrms.servlet.counter;

import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
import com.apu.hrms.facade.UserFacade;
import com.apu.hrms.util.PasswordUtil;
import com.apu.hrms.util.PhoneUtil;
import com.apu.hrms.util.ValidationUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@WebServlet("/counter/customers/edit")
public class CustomerEditServlet extends HttpServlet {

    private static final String PAGE =
            "/WEB-INF/views/counter/customer-form.jsp";

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        User customer = loadCustomer(request);
        if (customer == null) {
            response.sendRedirect(
                    request.getContextPath()
                            + "/counter/customers?error="
                            + encode("Customer not found.")
            );
            return;
        }

        fillForm(request, customer);
        request.setAttribute("formMode", "edit");
        request.setAttribute("customerId", customer.getId());
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

        User customer = loadCustomer(request);
        if (customer == null) {
            response.sendRedirect(
                    request.getContextPath()
                            + "/counter/customers?error="
                            + encode("Customer not found.")
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

        Map<String, String> errors = ValidationUtil.newErrorMap();

        ValidationUtil.requireText(errors, "name", name, "Name is required.");
        ValidationUtil.validatePassword(errors, password, false);
        ValidationUtil.validateGender(errors, gender);
        ValidationUtil.validatePhone(errors, phoneStored);
        ValidationUtil.validateIc(errors, ic);
        ValidationUtil.validateEmail(errors, email);
        ValidationUtil.requireText(errors, "address", address, "Address is required.");

        if (!errors.containsKey("email")
                && userFacade.existsByEmailExcludingId(email, customer.getId())) {
            errors.put("email", "Email is already registered.");
        }

        if (!errors.containsKey("ic")
                && userFacade.existsByIcExcludingId(ic, customer.getId())) {
            errors.put("ic", "IC is already registered.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("formMode", "edit");
            request.setAttribute("customerId", customer.getId());
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
                    address
            );
            request.getRequestDispatcher(PAGE)
                    .forward(request, response);
            return;
        }

        customer.setName(name);
        customer.setGender(gender);
        customer.setPhone(phoneStored);
        customer.setIc(ic);
        customer.setEmail(email);
        customer.setAddress(address);
        customer.setRole(UserRole.CUSTOMER);

        if (password != null && !password.isBlank()) {
            customer.setPasswordHash(PasswordUtil.hashPassword(password));
        }

        userFacade.update(customer);

        response.sendRedirect(
                request.getContextPath()
                        + "/counter/customers?success="
                        + encode("Customer updated.")
        );
    }

    private User loadCustomer(HttpServletRequest request) {
        Long id = parseId(request.getParameter("id"));
        if (id == null) {
            return null;
        }

        User user = userFacade.findActiveById(id);
        if (user == null || user.getRole() != UserRole.CUSTOMER) {
            return null;
        }
        return user;
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

    private void fillForm(HttpServletRequest request, User customer) {
        preserveInput(
                request,
                customer.getName(),
                customer.getGender(),
                PhoneUtil.formatForDisplay(customer.getPhone()),
                customer.getIc(),
                customer.getEmail(),
                customer.getAddress()
        );
    }

    private void preserveInput(
            HttpServletRequest request,
            String name,
            String gender,
            String phone,
            String ic,
            String email,
            String address
    ) {
        request.setAttribute("enteredName", name);
        request.setAttribute("enteredGender", gender);
        request.setAttribute("enteredPhone", phone);
        request.setAttribute("enteredIc", ic);
        request.setAttribute("enteredEmail", email);
        request.setAttribute("enteredAddress", address);
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}

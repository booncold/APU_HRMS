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
import java.util.Map;

@WebServlet("/counter/customers/new")
public class CustomerRegistrationServlet extends HttpServlet {

    private static final String PAGE =
            "/WEB-INF/views/counter/customer-form.jsp";

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setAttribute("formMode", "create");
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
        ValidationUtil.validatePassword(errors, password, true);
        ValidationUtil.validateGender(errors, gender);
        ValidationUtil.validatePhone(errors, phoneStored);
        ValidationUtil.validateIc(errors, ic);
        ValidationUtil.validateEmail(errors, email);
        ValidationUtil.requireText(errors, "address", address, "Address is required.");

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

        User customer = new User();
        customer.setName(name);
        customer.setPasswordHash(PasswordUtil.hashPassword(password));
        customer.setGender(gender);
        customer.setPhone(phoneStored);
        customer.setIc(ic);
        customer.setEmail(email);
        customer.setAddress(address);
        customer.setRole(UserRole.CUSTOMER);
        customer.setSeedAdmin(false);
        customer.setDeleted(false);

        boolean restored =
                userFacade.createOrRestore(customer);

        request.setAttribute(
                "successMessage",
                restored
                        ? "Customer account restored and updated successfully."
                        : "Customer account created successfully."
        );
        request.setAttribute("formMode", "create");
        request.setAttribute("enteredPhone", "+60 ");

        request.getRequestDispatcher(PAGE)
                .forward(request, response);
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
}

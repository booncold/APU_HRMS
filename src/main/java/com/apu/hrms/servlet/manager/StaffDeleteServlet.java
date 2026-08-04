package com.apu.hrms.servlet.manager;

import com.apu.hrms.entity.User;
import com.apu.hrms.facade.UserFacade;
import com.apu.hrms.util.SessionUtil;
import com.apu.hrms.util.StaffPermissionUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/manager/staff/delete")
public class StaffDeleteServlet extends HttpServlet {

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Long actorId =
                SessionUtil.getLoggedInUserId(request);
        User actor =
                userFacade.findActiveById(actorId);

        Long targetId =
                parseId(request.getParameter("id"));

        User target =
                targetId == null
                        ? null
                        : userFacade.findActiveById(targetId);

        String redirect;

        if (actor == null || target == null) {
            redirect = buildRedirect(
                    request,
                    null,
                    "Staff member not found."
            );
        } else if (!StaffPermissionUtil.canDeleteStaff(actor, target)) {
            redirect = buildRedirect(
                    request,
                    null,
                    "You are not allowed to delete this staff account."
            );
        } else {
            userFacade.softDelete(target);
            redirect = buildRedirect(
                    request,
                    "Staff account deleted.",
                    null
            );
        }

        response.sendRedirect(redirect);
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

    private String buildRedirect(
            HttpServletRequest request,
            String success,
            String error
    ) {
        StringBuilder url = new StringBuilder(
                request.getContextPath() + "/manager/staff"
        );

        if (success != null) {
            url.append("?success=")
                    .append(encode(success));
        } else if (error != null) {
            url.append("?error=")
                    .append(encode(error));
        }

        return url.toString();
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}

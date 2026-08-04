package com.apu.hrms.servlet.manager;

import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/manager/staff")
public class StaffListServlet extends HttpServlet {

    private static final String PAGE =
            "/WEB-INF/views/manager/staff-list.jsp";

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        // Always load full staff list; filtering is done live in the browser.
        List<User> staffList = userFacade.findAllStaff();

        List<User> managers = new ArrayList<>();
        List<User> counterStaff = new ArrayList<>();
        List<User> housekeepers = new ArrayList<>();

        for (User staff : staffList) {
            if (staff.getRole() == UserRole.MANAGER) {
                managers.add(staff);
            } else if (staff.getRole() == UserRole.COUNTER_STAFF) {
                counterStaff.add(staff);
            } else if (staff.getRole() == UserRole.HOUSEKEEPER) {
                housekeepers.add(staff);
            }
        }

        User actor =
                userFacade.findActiveById(
                        SessionUtil.getLoggedInUserId(request)
                );

        Map<Long, Boolean> canEditMap = new HashMap<>();
        Map<Long, Boolean> canDeleteMap = new HashMap<>();

        for (User staff : staffList) {
            canEditMap.put(
                    staff.getId(),
                    StaffPermissionUtil.canModifyStaff(actor, staff)
            );
            canDeleteMap.put(
                    staff.getId(),
                    StaffPermissionUtil.canDeleteStaff(actor, staff)
            );
        }

        request.setAttribute("managers", managers);
        request.setAttribute("counterStaff", counterStaff);
        request.setAttribute("housekeepers", housekeepers);
        request.setAttribute("totalStaffCount", staffList.size());
        request.setAttribute("canEditMap", canEditMap);
        request.setAttribute("canDeleteMap", canDeleteMap);
        request.setAttribute("successMessage", request.getParameter("success"));
        request.setAttribute("errorMessage", request.getParameter("error"));

        request.getRequestDispatcher(PAGE)
                .forward(request, response);
    }
}

package com.apu.hrms.servlet.housekeeper;

import com.apu.hrms.entity.CleaningTask;
import com.apu.hrms.entity.User;
import com.apu.hrms.facade.CleaningTaskFacade;
import com.apu.hrms.facade.UserFacade;
import com.apu.hrms.util.SessionUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/housekeeper/tasks")
public class HousekeeperTaskServlet extends HttpServlet {

    private static final String PAGE = "/WEB-INF/views/housekeeper/task-list.jsp";

    @EJB
    private CleaningTaskFacade cleaningTaskFacade;

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        User me = loadHousekeeper(request);
        if (me == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<CleaningTask> openTasks = cleaningTaskFacade.findAssignedByHousekeeper(me);
        List<CleaningTask> allMine = cleaningTaskFacade.findByHousekeeper(me);

        request.setAttribute("openTasks", openTasks);
        request.setAttribute("allTasks", allMine);
        request.setAttribute("successMessage", request.getParameter("success"));
        request.setAttribute("errorMessage", request.getParameter("error"));

        request.getRequestDispatcher(PAGE).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String ctx = request.getContextPath();
        Long housekeeperId = SessionUtil.getLoggedInUserId(request);
        Long taskId = parseId(request.getParameter("taskId"));

        try {
            CleaningTask task = cleaningTaskFacade.completeTask(taskId, housekeeperId);
            String msg = "Completed cleaning for room "
                    + task.getRoom().getRoomNumber()
                    + ". Room is now available.";
            response.sendRedirect(
                    ctx + "/housekeeper/tasks?success=" + encode(msg)
            );
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(
                    ctx + "/housekeeper/tasks?error=" + encode(ex.getMessage())
            );
        }
    }

    private User loadHousekeeper(HttpServletRequest request) {
        Long id = SessionUtil.getLoggedInUserId(request);
        if (id == null) {
            return null;
        }
        return userFacade.findActiveById(id);
    }

    private Long parseId(String raw) {
        try {
            return Long.valueOf(raw);
        } catch (Exception ex) {
            return null;
        }
    }

    private String encode(String value) {
        return URLEncoder.encode(
                value == null ? "" : value,
                StandardCharsets.UTF_8
        );
    }
}

package com.apu.hrms.servlet.counter;

import com.apu.hrms.entity.CleaningTask;
import com.apu.hrms.entity.Room;
import com.apu.hrms.entity.User;
import com.apu.hrms.facade.CleaningTaskFacade;
import com.apu.hrms.util.SessionUtil;
import jakarta.ejb.EJB;
import jakarta.ejb.EJBException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/counter/assign-cleaning")
public class CounterAssignCleaningServlet extends HttpServlet {

    private static final String PAGE = "/WEB-INF/views/counter/assign-cleaning.jsp";

    @EJB
    private CleaningTaskFacade cleaningTaskFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        List<Room> dirtyRooms = cleaningTaskFacade.findRoomsAwaitingAssignment();
        List<User> availableHousekeepers = cleaningTaskFacade.findAvailableHousekeepers();
        List<CleaningTask> openAndRecent = cleaningTaskFacade.findAllDetailed();

        request.setAttribute("dirtyRooms", dirtyRooms);
        request.setAttribute("availableHousekeepers", availableHousekeepers);
        request.setAttribute("taskList", openAndRecent);
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
        Long actorId = SessionUtil.getLoggedInUserId(request);
        Long roomId = parseId(request.getParameter("roomId"));
        Long housekeeperId = parseId(request.getParameter("housekeeperId"));
        String notes = request.getParameter("notes");

        try {
            CleaningTask task = cleaningTaskFacade.assignTask(
                    roomId,
                    housekeeperId,
                    actorId,
                    notes
            );
            String msg = "Assigned room " + task.getRoom().getRoomNumber()
                    + " to " + task.getHousekeeper().getName() + ".";
            response.sendRedirect(
                    ctx + "/counter/assign-cleaning?success=" + encode(msg)
            );
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(
                    ctx + "/counter/assign-cleaning?error=" + encode(ex.getMessage())
            );
        } catch (EJBException ex) {
            String businessMessage = findBusinessMessage(ex);
            if (businessMessage == null) {
                throw new ServletException("Unable to assign cleaning task.", ex);
            }
            response.sendRedirect(
                    ctx + "/counter/assign-cleaning?error=" + encode(businessMessage)
            );
        }
    }

    private String findBusinessMessage(Throwable throwable) {
        Throwable current = throwable;
        while (current != null) {
            if (current instanceof IllegalArgumentException) {
                return current.getMessage();
            }
            current = current.getCause();
        }
        return null;
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

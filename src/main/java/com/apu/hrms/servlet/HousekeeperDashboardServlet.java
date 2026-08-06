package com.apu.hrms.servlet;

import com.apu.hrms.entity.CleaningTask;
import com.apu.hrms.entity.Room;
import com.apu.hrms.entity.RoomStatus;
import com.apu.hrms.entity.User;
import com.apu.hrms.facade.CleaningTaskFacade;
import com.apu.hrms.facade.RoomFacade;
import com.apu.hrms.facade.UserFacade;
import com.apu.hrms.util.SessionUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/housekeeper/dashboard")
public class HousekeeperDashboardServlet extends HttpServlet {

    private static final String DASHBOARD_PAGE =
            "/WEB-INF/views/housekeeper/dashboard.jsp";

    @EJB
    private RoomFacade roomFacade;

    @EJB
    private CleaningTaskFacade cleaningTaskFacade;

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        Long housekeeperId = SessionUtil.getLoggedInUserId(request);
        User housekeeper = housekeeperId == null
                ? null
                : userFacade.findActiveById(housekeeperId);
        if (housekeeper == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Room> rooms = roomFacade.findAllActive();
        List<CleaningTask> openTasks =
                cleaningTaskFacade.findAssignedByHousekeeper(housekeeper);

        Map<Integer, List<Room>> roomsByFloor = new LinkedHashMap<>();
        for (int floor = 5; floor >= 1; floor--) {
            roomsByFloor.put(floor, new ArrayList<>());
        }

        Map<Long, Boolean> cleaningRoomIds = new HashMap<>();
        Map<Long, CleaningTask> myTasksByRoomId = new HashMap<>();
        Map<Integer, Boolean> affectedFloors = new HashMap<>();

        for (Room room : rooms) {
            roomsByFloor
                    .computeIfAbsent(room.getFloor(), ignored -> new ArrayList<>())
                    .add(room);
            if (room.getStatus() == RoomStatus.NEEDS_CLEANING) {
                cleaningRoomIds.put(room.getId(), true);
                affectedFloors.put(room.getFloor(), true);
            }
        }

        for (CleaningTask task : openTasks) {
            if (task.getRoom() != null && task.getRoom().getId() != null) {
                myTasksByRoomId.put(task.getRoom().getId(), task);
            }
        }

        request.setAttribute("floorNumbers", List.of(5, 4, 3, 2, 1));
        request.setAttribute("roomsByFloor", roomsByFloor);
        request.setAttribute("cleaningRoomIds", cleaningRoomIds);
        request.setAttribute("myTasksByRoomId", myTasksByRoomId);
        request.setAttribute("openTasks", openTasks);
        request.setAttribute("cleaningRoomCount", cleaningRoomIds.size());
        request.setAttribute("myOpenTaskCount", openTasks.size());
        request.setAttribute("affectedFloorCount", affectedFloors.size());

        request.getRequestDispatcher(DASHBOARD_PAGE)
                .forward(request, response);
    }
}

package com.apu.hrms.servlet.manager;

import com.apu.hrms.entity.BookingRoom;
import com.apu.hrms.entity.Room;
import com.apu.hrms.entity.RoomStatus;
import com.apu.hrms.entity.RoomType;
import com.apu.hrms.facade.BookingFacade;
import com.apu.hrms.facade.RoomFacade;
import com.apu.hrms.util.ValidationUtil;
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

@WebServlet("/manager/rooms")
public class RoomListServlet extends HttpServlet {

    private static final String PAGE =
            "/WEB-INF/views/manager/room-list.jsp";

    @EJB
    private RoomFacade roomFacade;

    @EJB
    private BookingFacade bookingFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        RoomType typeFilter = parseType(request.getParameter("type"));
        Integer floorFilter = parseFloor(request.getParameter("floor"));
        RoomStatus statusFilter = parseStatus(request.getParameter("status"));

        List<Room> rooms =
                roomFacade.search(typeFilter, floorFilter, statusFilter);

        List<Room> standardRooms = new ArrayList<>();
        List<Room> vipRooms = new ArrayList<>();
        List<Room> presidentialRooms = new ArrayList<>();

        for (Room room : rooms) {
            switch (room.getRoomType()) {
                case STANDARD -> standardRooms.add(room);
                case VIP -> vipRooms.add(room);
                case PRESIDENTIAL -> presidentialRooms.add(room);
            }
        }

        Map<Long, BookingRoom> activeRoomBookings = new HashMap<>();
        for (BookingRoom bookingRoom : bookingFacade.findActiveRoomBookings()) {
            if (bookingRoom.getRoom() != null
                    && bookingRoom.getRoom().getId() != null) {
                activeRoomBookings.putIfAbsent(
                        bookingRoom.getRoom().getId(),
                        bookingRoom
                );
            }
        }

        request.setAttribute("standardRooms", standardRooms);
        request.setAttribute("vipRooms", vipRooms);
        request.setAttribute("presidentialRooms", presidentialRooms);
        request.setAttribute("activeRoomBookings", activeRoomBookings);
        request.setAttribute("totalRoomCount", rooms.size());
        request.setAttribute("filterType", typeFilter == null ? "" : typeFilter.name());
        request.setAttribute("filterFloor", floorFilter == null ? "" : String.valueOf(floorFilter));
        request.setAttribute("filterStatus", statusFilter == null ? "" : statusFilter.name());
        request.setAttribute("successMessage", request.getParameter("success"));
        request.setAttribute("errorMessage", request.getParameter("error"));
        request.setAttribute("roomTypes", RoomType.values());
        request.setAttribute("roomStatuses", RoomStatus.values());

        request.getRequestDispatcher(PAGE)
                .forward(request, response);
    }

    private RoomType parseType(String raw) {
        String value = ValidationUtil.trim(raw);
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return RoomType.valueOf(value);
        } catch (IllegalArgumentException exception) {
            return null;
        }
    }

    private RoomStatus parseStatus(String raw) {
        String value = ValidationUtil.trim(raw);
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return RoomStatus.valueOf(value);
        } catch (IllegalArgumentException exception) {
            return null;
        }
    }

    private Integer parseFloor(String raw) {
        String value = ValidationUtil.trim(raw);
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            int floor = Integer.parseInt(value);
            return (floor >= 1 && floor <= 5) ? floor : null;
        } catch (NumberFormatException exception) {
            return null;
        }
    }
}

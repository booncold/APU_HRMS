package com.apu.hrms.servlet.customer;

import com.apu.hrms.entity.BookingOrder;
import com.apu.hrms.entity.Room;
import com.apu.hrms.entity.RoomStatus;
import com.apu.hrms.entity.RoomType;
import com.apu.hrms.entity.User;
import com.apu.hrms.facade.BookingFacade;
import com.apu.hrms.facade.RoomFacade;
import com.apu.hrms.facade.UserFacade;
import com.apu.hrms.util.SessionUtil;
import com.apu.hrms.util.ValidationUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

@WebServlet("/customer/book")
public class CustomerBookServlet extends HttpServlet {

    private static final String FORM_PAGE =
            "/WEB-INF/views/customer/booking-form.jsp";
    private static final String PAYMENT_PAGE =
            "/WEB-INF/views/counter/payment-detail.jsp";

    @EJB
    private BookingFacade bookingFacade;

    @EJB
    private RoomFacade roomFacade;

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        prepareForm(request);
        request.getRequestDispatcher(FORM_PAGE)
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = ValidationUtil.trim(request.getParameter("action"));

        if ("pay".equalsIgnoreCase(action)) {
            handlePay(request, response);
            return;
        }

        handlePreview(request, response);
    }

    private void handlePreview(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        Map<String, String> errors = ValidationUtil.newErrorMap();

        String checkInRaw = ValidationUtil.trim(request.getParameter("checkInDate"));
        String nightsRaw = ValidationUtil.trim(request.getParameter("nights"));
        String[] roomIdParams = request.getParameterValues("roomIds");

        LocalDate checkIn = null;
        int nights = 0;
        List<Long> roomIds = new ArrayList<>();

        try {
            checkIn = LocalDate.parse(checkInRaw);
            LocalDate today = LocalDate.now();
            if (checkIn.isBefore(today) || checkIn.isAfter(today.plusDays(5))) {
                errors.put("checkInDate", "Check-in must be today through the next 5 days.");
            }
        } catch (Exception exception) {
            errors.put("checkInDate", "Valid check-in date is required.");
        }

        try {
            nights = Integer.parseInt(nightsRaw);
            if (nights < 1 || nights > 30) {
                errors.put("nights", "Nights must be between 1 and 30.");
            }
        } catch (Exception exception) {
            errors.put("nights", "Nights must be a number.");
        }

        if (roomIdParams != null) {
            for (String raw : roomIdParams) {
                try {
                    roomIds.add(Long.valueOf(raw));
                } catch (NumberFormatException ignored) {
                }
            }
        }
        if (roomIds.isEmpty()) {
            errors.put("roomIds", "Select at least one available room.");
        }

        List<Room> rooms = new ArrayList<>();
        List<BigDecimal> lineTotals = new ArrayList<>();
        BigDecimal grandTotal = BigDecimal.ZERO;
        StringBuilder csv = new StringBuilder();

        if (errors.isEmpty()) {
            for (Long id : roomIds) {
                Room room = roomFacade.find(id);
                if (room == null || room.isDeleted()
                        || room.getStatus() != RoomStatus.AVAILABLE) {
                    errors.put("roomIds", "One or more selected rooms are no longer available.");
                    break;
                }
                BigDecimal line =
                        room.getCurrentPrice().multiply(BigDecimal.valueOf(nights));
                rooms.add(room);
                lineTotals.add(line);
                grandTotal = grandTotal.add(line);
                if (csv.length() > 0) {
                    csv.append(',');
                }
                csv.append(id);
            }
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("formError", "Please fix the highlighted fields.");
            request.setAttribute("enteredCheckIn", checkInRaw);
            request.setAttribute("enteredNights", nightsRaw);
            request.setAttribute("enteredRoomIds", roomIds);
            prepareForm(request);
            request.getRequestDispatcher(FORM_PAGE)
                    .forward(request, response);
            return;
        }

        User customer =
                userFacade.findActiveById(
                        SessionUtil.getLoggedInUserId(request)
                );

        request.setAttribute("customer", customer);
        request.setAttribute("checkInDate", checkIn);
        request.setAttribute("checkOutDate", checkIn.plusDays(nights));
        request.setAttribute("nights", nights);
        request.setAttribute("selectedRooms", rooms);
        request.setAttribute("lineTotals", lineTotals);
        request.setAttribute("grandTotal", grandTotal);
        request.setAttribute("roomIdsCsv", csv.toString());
        request.setAttribute("paymentMethod", "CARD");
        request.setAttribute("bookingRole", "customer");
        request.setAttribute(
                "payActionUrl",
                request.getContextPath() + "/customer/book"
        );
        request.setAttribute(
                "cancelUrl",
                request.getContextPath() + "/customer/book"
        );

        request.getRequestDispatcher(PAYMENT_PAGE)
                .forward(request, response);
    }

    private void handlePay(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        User customer =
                userFacade.findActiveById(
                        SessionUtil.getLoggedInUserId(request)
                );

        try {
            LocalDate checkIn = LocalDate.parse(
                    ValidationUtil.trim(request.getParameter("checkInDate"))
            );
            int nights = Integer.parseInt(
                    ValidationUtil.trim(request.getParameter("nights"))
            );
            List<Long> roomIds = parseRoomIds(
                    ValidationUtil.trim(request.getParameter("roomIds"))
            );
            String method = ValidationUtil.trim(request.getParameter("paymentMethod"));

            BookingOrder order = bookingFacade.createConfirmedBooking(
                    customer,
                    customer,
                    null,
                    checkIn,
                    nights,
                    roomIds,
                    method
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/customer/receipts/view?orderId="
                            + order.getId()
                            + "&success="
                            + URLEncoder.encode(
                                    "Payment successful. Your booking is confirmed.",
                                    StandardCharsets.UTF_8
                            )
            );
        } catch (Exception exception) {
            request.setAttribute(
                    "formError",
                    exception.getMessage() == null
                            ? "Unable to complete payment."
                            : exception.getMessage()
            );
            prepareForm(request);
            request.getRequestDispatcher(FORM_PAGE)
                    .forward(request, response);
        }
    }

    private void prepareForm(HttpServletRequest request) {
        List<Room> availableRooms = roomFacade.findAvailable();
        List<Room> standardRooms = new ArrayList<>();
        List<Room> vipRooms = new ArrayList<>();
        List<Room> presidentialRooms = new ArrayList<>();

        for (Room room : availableRooms) {
            if (room.getRoomType() == RoomType.STANDARD) {
                standardRooms.add(room);
            } else if (room.getRoomType() == RoomType.VIP) {
                vipRooms.add(room);
            } else if (room.getRoomType() == RoomType.PRESIDENTIAL) {
                presidentialRooms.add(room);
            }
        }

        request.setAttribute("availableRooms", availableRooms);
        request.setAttribute("standardRooms", standardRooms);
        request.setAttribute("vipRooms", vipRooms);
        request.setAttribute("presidentialRooms", presidentialRooms);
        request.setAttribute(
                "standardPrice",
                lowestAvailablePrice(standardRooms, RoomType.STANDARD)
        );
        request.setAttribute(
                "vipPrice",
                lowestAvailablePrice(vipRooms, RoomType.VIP)
        );
        request.setAttribute(
                "presidentialPrice",
                lowestAvailablePrice(presidentialRooms, RoomType.PRESIDENTIAL)
        );

        LocalDate today = LocalDate.now();
        LocalDate maxCheckIn = today.plusDays(5);
        request.setAttribute("today", today.toString());
        request.setAttribute("maxCheckIn", maxCheckIn.toString());
        if (request.getAttribute("enteredCheckIn") == null) {
            String requestedDate = ValidationUtil.trim(
                    request.getParameter("checkInDate")
            );
            try {
                LocalDate parsed = LocalDate.parse(requestedDate);
                request.setAttribute(
                        "enteredCheckIn",
                        parsed.isBefore(today) || parsed.isAfter(maxCheckIn)
                                ? today.toString()
                                : parsed.toString()
                );
            } catch (Exception ignored) {
                request.setAttribute("enteredCheckIn", today.toString());
            }
        }
        if (request.getAttribute("enteredNights") == null) {
            String requestedNights = ValidationUtil.trim(
                    request.getParameter("nights")
            );
            try {
                int parsed = Integer.parseInt(requestedNights);
                request.setAttribute(
                        "enteredNights",
                        parsed >= 1 && parsed <= 30 ? String.valueOf(parsed) : "1"
                );
            } catch (Exception ignored) {
                request.setAttribute("enteredNights", "1");
            }
        }
    }

    private BigDecimal lowestAvailablePrice(
            List<Room> rooms,
            RoomType roomType
    ) {
        return rooms.stream()
                .map(Room::getCurrentPrice)
                .min(Comparator.naturalOrder())
                .orElse(roomType.getDefaultPrice());
    }

    private List<Long> parseRoomIds(String csv) {
        List<Long> ids = new ArrayList<>();
        if (csv == null || csv.isBlank()) {
            return ids;
        }
        for (String part : csv.split(",")) {
            String trimmed = part.trim();
            if (!trimmed.isEmpty()) {
                ids.add(Long.valueOf(trimmed));
            }
        }
        return ids;
    }
}

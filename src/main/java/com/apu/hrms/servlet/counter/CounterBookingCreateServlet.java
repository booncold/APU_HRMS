package com.apu.hrms.servlet.counter;

import com.apu.hrms.entity.BookingOrder;
import com.apu.hrms.entity.Room;
import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
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
import java.util.List;

@WebServlet("/counter/bookings/new")
public class CounterBookingCreateServlet extends HttpServlet {

    private static final String FORM_PAGE =
            "/WEB-INF/views/counter/booking-form.jsp";
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

        prepareFormDefaults(request);
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

        PreviewData preview = buildPreview(request);
        if (!preview.errors.isEmpty()) {
            request.setAttribute("errors", preview.errors);
            request.setAttribute("formError", preview.errors.get("form"));
            repopulateForm(request, preview);
            prepareFormDefaults(request);
            request.getRequestDispatcher(FORM_PAGE)
                    .forward(request, response);
            return;
        }

        request.setAttribute("customer", preview.customer);
        request.setAttribute("checkInDate", preview.checkInDate);
        request.setAttribute("checkOutDate", preview.checkOutDate);
        request.setAttribute("nights", preview.nights);
        request.setAttribute("selectedRooms", preview.rooms);
        request.setAttribute("lineTotals", preview.lineTotals);
        request.setAttribute("grandTotal", preview.grandTotal);
        request.setAttribute("roomIdsCsv", preview.roomIdsCsv);
        request.setAttribute("paymentMethod", "CASH");
        request.setAttribute("bookingRole", "counter");
        request.setAttribute(
                "payActionUrl",
                request.getContextPath() + "/counter/bookings/new"
        );
        request.setAttribute(
                "cancelUrl",
                request.getContextPath() + "/counter/bookings/new"
        );

        request.getRequestDispatcher(PAYMENT_PAGE)
                .forward(request, response);
    }

    private void handlePay(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        User counter =
                userFacade.findActiveById(
                        SessionUtil.getLoggedInUserId(request)
                );

        try {
            Long customerId = Long.valueOf(
                    ValidationUtil.trim(request.getParameter("customerId"))
            );
            User customer = userFacade.findActiveById(customerId);
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
                    counter,
                    counter,
                    checkIn,
                    nights,
                    roomIds,
                    method
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/counter/receipts/view?orderId="
                            + order.getId()
                            + "&success="
                            + URLEncoder.encode(
                                    "Payment successful. Booking confirmed.",
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
            prepareFormDefaults(request);
            request.getRequestDispatcher(FORM_PAGE)
                    .forward(request, response);
        }
    }

    private void prepareFormDefaults(HttpServletRequest request) {
        request.setAttribute("customers", userFacade.findAllCustomers());
        request.setAttribute("availableRooms", roomFacade.findAvailable());
        request.setAttribute("today", LocalDate.now().toString());
        request.setAttribute(
                "maxCheckIn",
                LocalDate.now().plusDays(5).toString()
        );
        if (request.getAttribute("enteredCheckIn") == null) {
            request.setAttribute("enteredCheckIn", LocalDate.now().toString());
        }
        if (request.getAttribute("enteredNights") == null) {
            request.setAttribute("enteredNights", "1");
        }
    }

    private PreviewData buildPreview(HttpServletRequest request) {
        PreviewData data = new PreviewData();
        data.errors = ValidationUtil.newErrorMap();

        String customerIdRaw = ValidationUtil.trim(request.getParameter("customerId"));
        String checkInRaw = ValidationUtil.trim(request.getParameter("checkInDate"));
        String nightsRaw = ValidationUtil.trim(request.getParameter("nights"));
        String[] roomIdParams = request.getParameterValues("roomIds");

        data.enteredCustomerId = customerIdRaw;
        data.enteredCheckIn = checkInRaw;
        data.enteredNights = nightsRaw;

        if (customerIdRaw == null || customerIdRaw.isBlank()) {
            data.errors.put("customerId", "Customer is required.");
        } else {
            try {
                data.customer = userFacade.findActiveById(Long.valueOf(customerIdRaw));
                if (data.customer == null
                        || data.customer.getRole() != UserRole.CUSTOMER) {
                    data.errors.put("customerId", "Invalid customer.");
                }
            } catch (NumberFormatException exception) {
                data.errors.put("customerId", "Invalid customer.");
            }
        }

        try {
            data.checkInDate = LocalDate.parse(checkInRaw);
            LocalDate today = LocalDate.now();
            if (data.checkInDate.isBefore(today)
                    || data.checkInDate.isAfter(today.plusDays(5))) {
                data.errors.put(
                        "checkInDate",
                        "Check-in must be today through the next 5 days."
                );
            }
        } catch (Exception exception) {
            data.errors.put("checkInDate", "Valid check-in date is required.");
        }

        try {
            data.nights = Integer.parseInt(nightsRaw);
            if (data.nights < 1 || data.nights > 30) {
                data.errors.put("nights", "Nights must be between 1 and 30.");
            }
        } catch (Exception exception) {
            data.errors.put("nights", "Nights must be a number.");
        }

        List<Long> roomIds = new ArrayList<>();
        if (roomIdParams != null) {
            for (String raw : roomIdParams) {
                try {
                    roomIds.add(Long.valueOf(raw));
                } catch (NumberFormatException ignored) {
                    // skip invalid
                }
            }
        }
        if (roomIds.isEmpty()) {
            data.errors.put("roomIds", "Select at least one available room.");
        }

        data.rooms = new ArrayList<>();
        data.lineTotals = new ArrayList<>();
        data.grandTotal = BigDecimal.ZERO;
        data.selectedRoomIds = roomIds;

        if (data.errors.isEmpty()) {
            data.checkOutDate = data.checkInDate.plusDays(data.nights);
            StringBuilder csv = new StringBuilder();
            for (Long id : roomIds) {
                Room room = roomFacade.find(id);
                if (room == null || room.isDeleted()
                        || room.getStatus() != com.apu.hrms.entity.RoomStatus.AVAILABLE) {
                    data.errors.put(
                            "roomIds",
                            "One or more selected rooms are no longer available."
                    );
                    break;
                }
                BigDecimal line =
                        room.getCurrentPrice()
                                .multiply(BigDecimal.valueOf(data.nights));
                data.rooms.add(room);
                data.lineTotals.add(line);
                data.grandTotal = data.grandTotal.add(line);
                if (csv.length() > 0) {
                    csv.append(',');
                }
                csv.append(id);
            }
            data.roomIdsCsv = csv.toString();
        }

        if (!data.errors.isEmpty() && !data.errors.containsKey("form")) {
            data.errors.put("form", "Please fix the highlighted fields.");
        }

        return data;
    }

    private void repopulateForm(HttpServletRequest request, PreviewData preview) {
        request.setAttribute("enteredCustomerId", preview.enteredCustomerId);
        request.setAttribute("enteredCheckIn", preview.enteredCheckIn);
        request.setAttribute("enteredNights", preview.enteredNights);
        request.setAttribute("enteredRoomIds", preview.selectedRoomIds);
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

    private static class PreviewData {
        User customer;
        LocalDate checkInDate;
        LocalDate checkOutDate;
        int nights;
        List<Room> rooms;
        List<BigDecimal> lineTotals;
        BigDecimal grandTotal;
        String roomIdsCsv;
        String enteredCustomerId;
        String enteredCheckIn;
        String enteredNights;
        List<Long> selectedRoomIds;
        java.util.Map<String, String> errors;
    }
}

package com.apu.hrms.facade;

import com.apu.hrms.entity.BookingOrder;
import com.apu.hrms.entity.BookingRoom;
import com.apu.hrms.entity.BookingRoomStatus;
import com.apu.hrms.entity.OrderStatus;
import com.apu.hrms.entity.Payment;
import com.apu.hrms.entity.PaymentStatus;
import com.apu.hrms.entity.Room;
import com.apu.hrms.entity.RoomStatus;
import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ThreadLocalRandom;

/**
 * Booking workflows: create + full prepay + occupy rooms,
 * check-in / check-out (M5). Cancel expands in later milestones.
 */
@Stateless
public class BookingFacade {

    private static final int MAX_CHECK_IN_OFFSET_DAYS = 5;

    @PersistenceContext
    private EntityManager entityManager;

    public void create(BookingOrder order) {
        entityManager.persist(order);
    }

    public BookingOrder update(BookingOrder order) {
        return entityManager.merge(order);
    }

    public BookingOrder find(Long id) {
        return entityManager.find(BookingOrder.class, id);
    }

    /**
     * Loads order with rooms, payment, and customer for receipt / detail views.
     * <p>
     * Strict JPQL disallows aliases on FETCH joins (e.g. {@code JOIN FETCH o.rooms br}),
     * so associations are fetched without aliases and then initialized in-session.
     */
    public BookingOrder findDetailed(Long id) {
        try {
            BookingOrder order = entityManager
                    .createQuery(
                            "SELECT DISTINCT o FROM BookingOrder o "
                                    + "LEFT JOIN FETCH o.rooms "
                                    + "LEFT JOIN FETCH o.payment "
                                    + "LEFT JOIN FETCH o.customer "
                                    + "LEFT JOIN FETCH o.counterStaff "
                                    + "WHERE o.id = :id",
                            BookingOrder.class
                    )
                    .setParameter("id", id)
                    .getSingleResult();

            // Touch lazy fields needed by receipt / detail JSPs while EM is open.
            if (order.getCustomer() != null) {
                order.getCustomer().getName();
            }
            if (order.getCounterStaff() != null) {
                order.getCounterStaff().getName();
            }
            if (order.getPayment() != null) {
                order.getPayment().getReceiptNo();
            }
            if (order.getRooms() != null) {
                order.getRooms().forEach(br -> {
                    br.getRoomNumberSnapshot();
                    if (br.getRoom() != null) {
                        br.getRoom().getRoomNumber();
                    }
                });
            }
            return order;
        } catch (NoResultException exception) {
            return null;
        }
    }

    public BookingOrder findByOrderNo(String orderNo) {
        try {
            return entityManager
                    .createQuery(
                            "SELECT o FROM BookingOrder o WHERE o.orderNo = :orderNo",
                            BookingOrder.class
                    )
                    .setParameter("orderNo", orderNo)
                    .getSingleResult();
        } catch (NoResultException exception) {
            return null;
        }
    }

    public List<BookingOrder> findAllDetailed() {
        List<BookingOrder> orders = entityManager
                .createQuery(
                        "SELECT DISTINCT o FROM BookingOrder o "
                                + "LEFT JOIN FETCH o.customer "
                                + "LEFT JOIN FETCH o.payment "
                                + "LEFT JOIN FETCH o.rooms "
                                + "ORDER BY o.createdAt DESC",
                        BookingOrder.class
                )
                .getResultList();
        // Touch collections while session is open
        orders.forEach(o -> {
            if (o.getRooms() != null) {
                o.getRooms().size();
            }
        });
        return orders;
    }

    public List<BookingOrder> findByCustomer(User customer) {
        List<BookingOrder> orders = entityManager
                .createQuery(
                        "SELECT DISTINCT o FROM BookingOrder o "
                                + "LEFT JOIN FETCH o.customer "
                                + "LEFT JOIN FETCH o.payment "
                                + "LEFT JOIN FETCH o.rooms "
                                + "WHERE o.customer = :customer "
                                + "ORDER BY o.createdAt DESC",
                        BookingOrder.class
                )
                .setParameter("customer", customer)
                .getResultList();
        orders.forEach(o -> {
            if (o.getRooms() != null) {
                o.getRooms().size();
            }
        });
        return orders;
    }

    public List<BookingOrder> findByStatus(OrderStatus status) {
        return entityManager
                .createQuery(
                        "SELECT o FROM BookingOrder o "
                                + "WHERE o.status = :status "
                                + "ORDER BY o.checkInDate",
                        BookingOrder.class
                )
                .setParameter("status", status)
                .getResultList();
    }

    public List<BookingRoom> findCheckInsForDate(LocalDate date) {
        List<BookingRoom> lines = entityManager
                .createQuery(
                        "SELECT br FROM BookingRoom br "
                                + "JOIN br.order o "
                                + "WHERE o.checkInDate = :date "
                                + "AND br.status = com.apu.hrms.entity.BookingRoomStatus.RESERVED "
                                + "AND o.status <> com.apu.hrms.entity.OrderStatus.CANCELLED "
                                + "ORDER BY br.roomNumberSnapshot",
                        BookingRoom.class
                )
                .setParameter("date", date)
                .getResultList();
        initializeBookingRooms(lines);
        return lines;
    }

    public List<BookingRoom> findActiveStays() {
        List<BookingRoom> lines = entityManager
                .createQuery(
                        "SELECT br FROM BookingRoom br "
                                + "WHERE br.status = com.apu.hrms.entity.BookingRoomStatus.CHECKED_IN "
                                + "ORDER BY br.roomNumberSnapshot",
                        BookingRoom.class
                )
                .getResultList();
        initializeBookingRooms(lines);
        return lines;
    }

    public long countAll() {
        return entityManager
                .createQuery("SELECT COUNT(o) FROM BookingOrder o", Long.class)
                .getSingleResult();
    }

    /**
     * Checks a reserved room line in. Physical room becomes OCCUPIED.
     */
    public BookingRoom checkIn(Long bookingRoomId) {
        BookingRoom line = requireBookingRoom(bookingRoomId);
        BookingOrder order = line.getOrder();

        if (order == null || order.getStatus() == OrderStatus.CANCELLED) {
            throw new IllegalArgumentException("Booking is cancelled or missing.");
        }
        if (line.getStatus() != BookingRoomStatus.RESERVED) {
            throw new IllegalArgumentException(
                    "Room " + line.getRoomNumberSnapshot() + " is not awaiting check-in."
            );
        }
        if (order.getCheckInDate() != null
                && order.getCheckInDate().isAfter(LocalDate.now())) {
            throw new IllegalArgumentException(
                    "Check-in date for this booking is "
                            + order.getCheckInDate()
                            + ". Cannot check in early."
            );
        }

        Room room = line.getRoom();
        if (room == null || room.isDeleted()) {
            throw new IllegalArgumentException("Linked room not found.");
        }

        line.setStatus(BookingRoomStatus.CHECKED_IN);
        room.setStatus(RoomStatus.OCCUPIED);
        entityManager.merge(room);
        entityManager.merge(line);

        // Ensure order rooms are loaded for status roll-up
        if (order.getRooms() != null) {
            order.getRooms().size();
        }
        refreshOrderStatus(order);
        entityManager.merge(order);

        return line;
    }

    /**
     * Checks out an occupied stay. Room becomes NEEDS_CLEANING for M6 assignment.
     */
    public BookingRoom checkOut(Long bookingRoomId) {
        BookingRoom line = requireBookingRoom(bookingRoomId);
        BookingOrder order = line.getOrder();

        if (order == null || order.getStatus() == OrderStatus.CANCELLED) {
            throw new IllegalArgumentException("Booking is cancelled or missing.");
        }
        if (line.getStatus() != BookingRoomStatus.CHECKED_IN) {
            throw new IllegalArgumentException(
                    "Room " + line.getRoomNumberSnapshot() + " is not checked in."
            );
        }

        Room room = line.getRoom();
        if (room == null || room.isDeleted()) {
            throw new IllegalArgumentException("Linked room not found.");
        }

        line.setStatus(BookingRoomStatus.CHECKED_OUT);
        room.setStatus(RoomStatus.NEEDS_CLEANING);
        entityManager.merge(room);
        entityManager.merge(line);

        if (order.getRooms() != null) {
            order.getRooms().size();
        }
        refreshOrderStatus(order);
        entityManager.merge(order);

        return line;
    }

    /**
     * Customer cancellation before any check-in.
     * All room lines must still be RESERVED. Rooms return AVAILABLE;
     * payment (if paid) becomes REFUND_PENDING (demo refund text: within 3 days).
     */
    public BookingOrder cancelBooking(Long orderId, Long customerId) {
        if (orderId == null || customerId == null) {
            throw new IllegalArgumentException("Order and customer are required.");
        }

        BookingOrder order = findDetailed(orderId);
        if (order == null) {
            throw new IllegalArgumentException("Booking not found.");
        }
        if (order.getCustomer() == null
                || !customerId.equals(order.getCustomer().getId())) {
            throw new IllegalArgumentException("You can only cancel your own bookings.");
        }
        if (order.getStatus() == OrderStatus.CANCELLED) {
            throw new IllegalArgumentException("This booking is already cancelled.");
        }

        List<BookingRoom> rooms = order.getRooms();
        if (rooms == null || rooms.isEmpty()) {
            throw new IllegalArgumentException("Booking has no rooms.");
        }

        for (BookingRoom br : rooms) {
            if (br.getStatus() != BookingRoomStatus.RESERVED
                    && br.getStatus() != BookingRoomStatus.CANCELLED) {
                throw new IllegalArgumentException(
                        "Only reserved bookings (before check-in) can be cancelled."
                );
            }
        }

        for (BookingRoom br : rooms) {
            if (br.getStatus() == BookingRoomStatus.RESERVED) {
                br.setStatus(BookingRoomStatus.CANCELLED);
                Room room = br.getRoom();
                if (room != null && !room.isDeleted()
                        && (room.getStatus() == RoomStatus.BOOKED
                        || room.getStatus() == RoomStatus.AVAILABLE)) {
                    room.setStatus(RoomStatus.AVAILABLE);
                    entityManager.merge(room);
                }
                entityManager.merge(br);
            }
        }

        order.setStatus(OrderStatus.CANCELLED);
        order.setCancelledAt(LocalDateTime.now());

        Payment payment = order.getPayment();
        if (payment != null && payment.getStatus() == PaymentStatus.PAID) {
            payment.setStatus(PaymentStatus.REFUND_PENDING);
            entityManager.merge(payment);
        }

        return entityManager.merge(order);
    }

    public boolean canCancel(BookingOrder order) {
        if (order == null || order.getStatus() == OrderStatus.CANCELLED) {
            return false;
        }
        List<BookingRoom> rooms = order.getRooms();
        if (rooms == null || rooms.isEmpty()) {
            return false;
        }
        for (BookingRoom br : rooms) {
            if (br.getStatus() != BookingRoomStatus.RESERVED
                    && br.getStatus() != BookingRoomStatus.CANCELLED) {
                return false;
            }
        }
        return rooms.stream().anyMatch(br -> br.getStatus() == BookingRoomStatus.RESERVED);
    }

    private BookingRoom requireBookingRoom(Long bookingRoomId) {
        if (bookingRoomId == null) {
            throw new IllegalArgumentException("Booking room id is required.");
        }
        BookingRoom line = entityManager.find(BookingRoom.class, bookingRoomId);
        if (line == null) {
            throw new IllegalArgumentException("Booking room line not found.");
        }
        // Touch associations
        if (line.getOrder() != null) {
            line.getOrder().getOrderNo();
            if (line.getOrder().getRooms() != null) {
                line.getOrder().getRooms().size();
            }
        }
        if (line.getRoom() != null) {
            line.getRoom().getRoomNumber();
        }
        return line;
    }

    private void refreshOrderStatus(BookingOrder order) {
        boolean anyReserved = false;
        boolean anyCheckedIn = false;
        boolean anyCheckedOut = false;

        List<BookingRoom> rooms = order.getRooms();
        if (rooms == null || rooms.isEmpty()) {
            return;
        }

        for (BookingRoom br : rooms) {
            if (br.getStatus() == null) {
                continue;
            }
            switch (br.getStatus()) {
                case RESERVED -> anyReserved = true;
                case CHECKED_IN -> anyCheckedIn = true;
                case CHECKED_OUT -> anyCheckedOut = true;
                default -> {
                    // CANCELLED line ignored for roll-up
                }
            }
        }

        if (anyReserved && anyCheckedIn) {
            order.setStatus(OrderStatus.PARTIAL_CHECKED_IN);
        } else if (anyReserved) {
            order.setStatus(OrderStatus.CONFIRMED);
        } else if (anyCheckedIn) {
            order.setStatus(OrderStatus.CHECKED_IN);
        } else if (anyCheckedOut) {
            order.setStatus(OrderStatus.CHECKED_OUT);
        }
    }

    private void initializeBookingRooms(List<BookingRoom> lines) {
        for (BookingRoom br : lines) {
            if (br.getOrder() != null) {
                br.getOrder().getOrderNo();
                if (br.getOrder().getCustomer() != null) {
                    br.getOrder().getCustomer().getName();
                }
            }
            if (br.getRoom() != null) {
                br.getRoom().getRoomNumber();
            }
            br.getRoomNumberSnapshot();
        }
    }

    /**
     * Creates a fully prepaid booking in one transaction:
     * order CONFIRMED, rooms BOOKED, payment PAID with receipt.
     */
    public BookingOrder createConfirmedBooking(
            User customer,
            User createdBy,
            User counterStaff,
            LocalDate checkInDate,
            int nights,
            List<Long> roomIds,
            String paymentMethod
    ) {
        validateParties(customer, createdBy, counterStaff);
        validateStay(checkInDate, nights);

        if (roomIds == null || roomIds.isEmpty()) {
            throw new IllegalArgumentException("Select at least one room.");
        }

        Set<Long> uniqueRoomIds = new LinkedHashSet<>(roomIds);
        List<Room> rooms = new ArrayList<>();

        for (Long roomId : uniqueRoomIds) {
            Room room = entityManager.find(Room.class, roomId, LockModeType.PESSIMISTIC_WRITE);
            if (room == null || room.isDeleted()) {
                throw new IllegalArgumentException("Room not found: " + roomId);
            }
            if (room.getStatus() != RoomStatus.AVAILABLE) {
                throw new IllegalArgumentException(
                        "Room " + room.getRoomNumber() + " is not available."
                );
            }
            rooms.add(room);
        }

        LocalDate checkOutDate = checkInDate.plusDays(nights);
        BigDecimal total = BigDecimal.ZERO;

        BookingOrder order = new BookingOrder();
        order.setOrderNo(generateOrderNo());
        order.setCustomer(customer);
        order.setCreatedBy(createdBy);
        order.setCounterStaff(counterStaff);
        order.setCheckInDate(checkInDate);
        order.setCheckOutDate(checkOutDate);
        order.setNights(nights);
        order.setStatus(OrderStatus.CONFIRMED);

        for (Room room : rooms) {
            BigDecimal pricePerNight = room.getCurrentPrice();
            BigDecimal lineTotal =
                    pricePerNight.multiply(BigDecimal.valueOf(nights));

            BookingRoom line = new BookingRoom();
            line.setRoom(room);
            line.setRoomTypeSnapshot(room.getRoomType());
            line.setRoomNumberSnapshot(room.getRoomNumber());
            line.setPricePerNightSnapshot(pricePerNight);
            line.setNights(nights);
            line.setLineTotal(lineTotal);
            line.setStatus(BookingRoomStatus.RESERVED);

            order.addRoom(line);
            total = total.add(lineTotal);

            room.setStatus(RoomStatus.BOOKED);
            entityManager.merge(room);
        }

        order.setTotalAmount(total);

        Payment payment = new Payment();
        payment.setAmount(total);
        payment.setStatus(PaymentStatus.PAID);
        payment.setMethod(
                paymentMethod == null || paymentMethod.isBlank()
                        ? "CASH"
                        : paymentMethod.trim().toUpperCase()
        );
        payment.setReceiptNo(generateReceiptNo());
        payment.setPaidAt(LocalDateTime.now());
        order.setPayment(payment);

        entityManager.persist(order);
        entityManager.flush();
        return order;
    }

    private void validateParties(User customer, User createdBy, User counterStaff) {
        if (customer == null || customer.isDeleted()
                || customer.getRole() != UserRole.CUSTOMER) {
            throw new IllegalArgumentException("A valid customer is required.");
        }
        if (createdBy == null || createdBy.isDeleted()) {
            throw new IllegalArgumentException("Creator is required.");
        }
        if (counterStaff != null
                && (counterStaff.isDeleted()
                || counterStaff.getRole() != UserRole.COUNTER_STAFF)) {
            throw new IllegalArgumentException("Invalid counter staff.");
        }
    }

    private void validateStay(LocalDate checkInDate, int nights) {
        if (checkInDate == null) {
            throw new IllegalArgumentException("Check-in date is required.");
        }
        LocalDate today = LocalDate.now();
        LocalDate latest = today.plusDays(MAX_CHECK_IN_OFFSET_DAYS);
        if (checkInDate.isBefore(today) || checkInDate.isAfter(latest)) {
            throw new IllegalArgumentException(
                    "Check-in date must be between today and the next "
                            + MAX_CHECK_IN_OFFSET_DAYS + " days."
            );
        }
        if (nights < 1 || nights > 30) {
            throw new IllegalArgumentException("Nights must be between 1 and 30.");
        }
    }

    private String generateOrderNo() {
        return generateUniqueCode("ORD-", "orderNo");
    }

    private String generateReceiptNo() {
        return generateUniqueCode("RCP-", "receiptNo");
    }

    private String generateUniqueCode(String prefix, String kind) {
        String datePart =
                LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
        for (int attempt = 0; attempt < 20; attempt++) {
            int suffix = ThreadLocalRandom.current().nextInt(1000, 10000);
            String code = prefix + datePart + "-" + suffix;
            boolean exists = "orderNo".equals(kind)
                    ? findByOrderNo(code) != null
                    : findPaymentByReceiptNo(code) != null;
            if (!exists) {
                return code;
            }
        }
        throw new IllegalStateException("Unable to generate unique " + kind + ".");
    }

    private Payment findPaymentByReceiptNo(String receiptNo) {
        try {
            return entityManager
                    .createQuery(
                            "SELECT p FROM Payment p WHERE p.receiptNo = :receiptNo",
                            Payment.class
                    )
                    .setParameter("receiptNo", receiptNo)
                    .getSingleResult();
        } catch (NoResultException exception) {
            return null;
        }
    }
}

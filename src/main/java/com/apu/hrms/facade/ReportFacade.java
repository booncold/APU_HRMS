package com.apu.hrms.facade;

import com.apu.hrms.entity.BookingRoomStatus;
import com.apu.hrms.entity.CleaningTaskStatus;
import com.apu.hrms.entity.OrderStatus;
import com.apu.hrms.entity.PaymentStatus;
import com.apu.hrms.entity.RoomStatus;
import com.apu.hrms.entity.RoomType;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Aggregation queries for manager dashboard reports (Chart.js).
 */
@Stateless
public class ReportFacade {

    @PersistenceContext
    private EntityManager entityManager;

    public long countUsers() {
        return entityManager
                .createQuery(
                        "SELECT COUNT(u) FROM User u WHERE u.deleted = false",
                        Long.class
                )
                .getSingleResult();
    }

    public long countRooms() {
        return entityManager
                .createQuery(
                        "SELECT COUNT(r) FROM Room r WHERE r.deleted = false",
                        Long.class
                )
                .getSingleResult();
    }

    public long countOrders() {
        return entityManager
                .createQuery(
                        "SELECT COUNT(o) FROM BookingOrder o",
                        Long.class
                )
                .getSingleResult();
    }

    /**
     * Current available and total room inventory for every configured room type.
     */
    public List<Map<String, Object>> roomAvailabilityByType() {
        List<Object[]> rows = entityManager
                .createQuery(
                        "SELECT r.roomType, r.status, COUNT(r) FROM Room r "
                                + "WHERE r.deleted = false "
                                + "GROUP BY r.roomType, r.status",
                        Object[].class
                )
                .getResultList();

        Map<RoomType, long[]> byType = new LinkedHashMap<>();
        for (RoomType type : RoomType.values()) {
            byType.put(type, new long[2]);
        }

        for (Object[] row : rows) {
            RoomType type = (RoomType) row[0];
            RoomStatus status = (RoomStatus) row[1];
            long count = (Long) row[2];
            long[] bucket = byType.get(type);
            if (bucket == null) {
                continue;
            }
            bucket[0] += count;
            if (status == RoomStatus.AVAILABLE) {
                bucket[1] += count;
            }
        }

        List<Map<String, Object>> inventory = new ArrayList<>();
        for (Map.Entry<RoomType, long[]> entry : byType.entrySet()) {
            long total = entry.getValue()[0];
            long available = entry.getValue()[1];
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("label", titleCaseEnum(entry.getKey().name()));
            item.put("available", available);
            item.put("total", total);
            item.put("unavailable", Math.max(total - available, 0));
            item.put("progressMax", Math.max(total, 1));
            inventory.add(item);
        }
        return inventory;
    }

    /**
     * Current submitted comments and feedbacks available for manager review.
     */
    public Map<String, Long> reviewQueueCounts() {
        Map<String, Long> counts = new LinkedHashMap<>();
        counts.put(
                "comments",
                entityManager.createQuery("SELECT COUNT(c) FROM Comment c", Long.class)
                        .getSingleResult()
        );
        counts.put(
                "feedbacks",
                entityManager.createQuery("SELECT COUNT(f) FROM Feedback f", Long.class)
                        .getSingleResult()
        );
        return counts;
    }

    /**
     * Occupancy snapshot by floor: labels + percentage (BOOKED+OCCUPIED / total).
     */
    public Map<String, Object> occupancyByFloor() {
        List<Object[]> rows = entityManager
                .createQuery(
                        "SELECT r.floor, r.status, COUNT(r) FROM Room r "
                                + "WHERE r.deleted = false "
                                + "GROUP BY r.floor, r.status "
                                + "ORDER BY r.floor",
                        Object[].class
                )
                .getResultList();

        Map<Integer, long[]> byFloor = new LinkedHashMap<>();
        for (Object[] row : rows) {
            Integer floor = (Integer) row[0];
            RoomStatus status = (RoomStatus) row[1];
            long count = (Long) row[2];
            long[] bucket = byFloor.computeIfAbsent(floor, f -> new long[2]);
            bucket[0] += count; // total
            if (status == RoomStatus.BOOKED || status == RoomStatus.OCCUPIED) {
                bucket[1] += count; // occupied-ish
            }
        }

        List<String> labels = new ArrayList<>();
        List<BigDecimal> values = new ArrayList<>();
        for (Map.Entry<Integer, long[]> e : byFloor.entrySet()) {
            labels.add("Floor " + e.getKey());
            long total = e.getValue()[0];
            long occupied = e.getValue()[1];
            BigDecimal pct = total == 0
                    ? BigDecimal.ZERO
                    : BigDecimal.valueOf(occupied * 100.0 / total)
                    .setScale(1, RoundingMode.HALF_UP);
            values.add(pct);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", labels);
        result.put("values", values);
        result.put("title", "Occupancy rate by floor (%)");
        return result;
    }

    /**
     * Occupancy by room type (same formula).
     */
    public Map<String, Object> occupancyByType() {
        List<Object[]> rows = entityManager
                .createQuery(
                        "SELECT r.roomType, r.status, COUNT(r) FROM Room r "
                                + "WHERE r.deleted = false "
                                + "GROUP BY r.roomType, r.status",
                        Object[].class
                )
                .getResultList();

        Map<RoomType, long[]> byType = new LinkedHashMap<>();
        for (RoomType type : RoomType.values()) {
            byType.put(type, new long[2]);
        }
        for (Object[] row : rows) {
            RoomType type = (RoomType) row[0];
            RoomStatus status = (RoomStatus) row[1];
            long count = (Long) row[2];
            long[] bucket = byType.get(type);
            if (bucket == null) {
                continue;
            }
            bucket[0] += count;
            if (status == RoomStatus.BOOKED || status == RoomStatus.OCCUPIED) {
                bucket[1] += count;
            }
        }

        List<String> labels = new ArrayList<>();
        List<BigDecimal> values = new ArrayList<>();
        for (Map.Entry<RoomType, long[]> e : byType.entrySet()) {
            labels.add(titleCaseEnum(e.getKey().name()));
            long total = e.getValue()[0];
            long occupied = e.getValue()[1];
            BigDecimal pct = total == 0
                    ? BigDecimal.ZERO
                    : BigDecimal.valueOf(occupied * 100.0 / total)
                    .setScale(1, RoundingMode.HALF_UP);
            values.add(pct);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", labels);
        result.put("values", values);
        result.put("title", "Occupancy rate by room type (%)");
        return result;
    }

    /**
     * Paid revenue for the last {@code days} days (inclusive of today).
     * Aggregated in Java for DB portability (no vendor DATE() function).
     */
    public Map<String, Object> revenueLastDays(int days) {
        int window = Math.max(days, 1);
        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(window - 1);
        LocalDateTime startDt = start.atStartOfDay();

        List<Object[]> rows = entityManager
                .createQuery(
                        "SELECT p.paidAt, p.amount FROM Payment p "
                                + "WHERE p.status = :status "
                                + "AND p.paidAt IS NOT NULL "
                                + "AND p.paidAt >= :start",
                        Object[].class
                )
                .setParameter("status", PaymentStatus.PAID)
                .setParameter("start", startDt)
                .getResultList();

        Map<String, BigDecimal> byDay = new LinkedHashMap<>();
        for (int i = 0; i < window; i++) {
            byDay.put(start.plusDays(i).toString(), BigDecimal.ZERO);
        }
        for (Object[] row : rows) {
            LocalDateTime paidAt = (LocalDateTime) row[0];
            if (paidAt == null) {
                continue;
            }
            String key = paidAt.toLocalDate().toString();
            BigDecimal amount = row[1] instanceof BigDecimal bd
                    ? bd
                    : BigDecimal.valueOf(((Number) row[1]).doubleValue());
            if (byDay.containsKey(key)) {
                byDay.put(
                        key,
                        byDay.get(key).add(amount).setScale(2, RoundingMode.HALF_UP)
                );
            }
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", new ArrayList<>(byDay.keySet()));
        result.put("values", new ArrayList<>(byDay.values()));
        result.put("title", "Revenue last " + window + " days (RM)");
        return result;
    }

    public Map<String, Object> bookingStatusDistribution() {
        List<Object[]> rows = entityManager
                .createQuery(
                        "SELECT o.status, COUNT(o) FROM BookingOrder o "
                                + "GROUP BY o.status",
                        Object[].class
                )
                .getResultList();

        Map<String, Long> map = new LinkedHashMap<>();
        for (OrderStatus status : OrderStatus.values()) {
            map.put(titleCaseEnum(status.name()), 0L);
        }
        for (Object[] row : rows) {
            OrderStatus status = (OrderStatus) row[0];
            map.put(titleCaseEnum(status.name()), (Long) row[1]);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", new ArrayList<>(map.keySet()));
        result.put("values", new ArrayList<>(map.values()));
        result.put("title", "Booking status distribution");
        return result;
    }

    public Map<String, Object> housekeeperCompletions() {
        List<Object[]> rows = entityManager
                .createQuery(
                        "SELECT t.housekeeper.name, COUNT(t) FROM CleaningTask t "
                                + "WHERE t.status = :status "
                                + "GROUP BY t.housekeeper.name "
                                + "ORDER BY COUNT(t) DESC",
                        Object[].class
                )
                .setParameter("status", CleaningTaskStatus.COMPLETED)
                .getResultList();

        List<String> labels = new ArrayList<>();
        List<Long> values = new ArrayList<>();
        for (Object[] row : rows) {
            labels.add(String.valueOf(row[0]));
            values.add((Long) row[1]);
        }
        if (labels.isEmpty()) {
            labels.add("No data");
            values.add(0L);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", labels);
        result.put("values", values);
        result.put("title", "Housekeeper completed tasks");
        return result;
    }

    public Map<String, Object> feedbackAndCommentCounts() {
        Map<String, Long> reviewCounts = reviewQueueCounts();
        long feedbacks = reviewCounts.get("feedbacks");
        long comments = reviewCounts.get("comments");
        long customers = entityManager
                .createQuery(
                        "SELECT COUNT(u) FROM User u "
                                + "WHERE u.deleted = false "
                                + "AND u.role = com.apu.hrms.entity.UserRole.CUSTOMER",
                        Long.class
                )
                .getSingleResult();

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", List.of("Feedbacks", "Comments", "Customers"));
        result.put("values", List.of(feedbacks, comments, customers));
        result.put("title", "Feedback / comment / customer volume");
        return result;
    }

    public Map<String, Object> summaryCards() {
        Map<String, Object> cards = new LinkedHashMap<>();
        cards.put("users", countUsers());
        cards.put("rooms", countRooms());
        cards.put("orders", countOrders());
        cards.put("activeStays", entityManager
                .createQuery(
                        "SELECT COUNT(br) FROM BookingRoom br WHERE br.status = :st",
                        Long.class
                )
                .setParameter("st", BookingRoomStatus.CHECKED_IN)
                .getSingleResult());
        cards.put("paidRevenue", entityManager
                .createQuery(
                        "SELECT COALESCE(SUM(p.amount), 0) FROM Payment p "
                                + "WHERE p.status = :st",
                        BigDecimal.class
                )
                .setParameter("st", PaymentStatus.PAID)
                .getSingleResult());
        return cards;
    }

    /**
     * Occupancy for a selected reporting window. The percentage is based on
     * occupied room nights divided by the available room-night capacity.
     */
    public Map<String, Object> occupancyByFloor(
            LocalDate periodStart,
            LocalDate periodEndExclusive
    ) {
        List<Object[]> roomRows = entityManager
                .createQuery(
                        "SELECT r.floor, COUNT(r) FROM Room r "
                                + "WHERE r.deleted = false "
                                + "GROUP BY r.floor ORDER BY r.floor",
                        Object[].class
                )
                .getResultList();

        Map<Integer, long[]> byFloor = new LinkedHashMap<>();
        for (Object[] row : roomRows) {
            byFloor.put((Integer) row[0], new long[]{(Long) row[1], 0L});
        }

        List<Object[]> stayRows = entityManager
                .createQuery(
                        "SELECT br.room.floor, o.checkInDate, o.checkOutDate "
                                + "FROM BookingRoom br JOIN br.order o "
                                + "WHERE br.room.deleted = false "
                                + "AND br.status <> :roomCancelled "
                                + "AND o.status <> :orderCancelled "
                                + "AND o.status <> :pendingPayment "
                                + "AND o.checkInDate < :periodEnd "
                                + "AND o.checkOutDate > :periodStart",
                        Object[].class
                )
                .setParameter("roomCancelled", BookingRoomStatus.CANCELLED)
                .setParameter("orderCancelled", OrderStatus.CANCELLED)
                .setParameter("pendingPayment", OrderStatus.PENDING_PAYMENT)
                .setParameter("periodStart", periodStart)
                .setParameter("periodEnd", periodEndExclusive)
                .getResultList();

        for (Object[] row : stayRows) {
            long[] bucket = byFloor.get((Integer) row[0]);
            if (bucket != null) {
                bucket[1] += overlappingNights(
                        (LocalDate) row[1],
                        (LocalDate) row[2],
                        periodStart,
                        periodEndExclusive
                );
            }
        }

        return occupancyResult(byFloor, periodStart, periodEndExclusive,
                "Occupancy rate by floor (%)");
    }

    /**
     * Room-night occupancy grouped by room tier for the selected window.
     */
    public Map<String, Object> occupancyByType(
            LocalDate periodStart,
            LocalDate periodEndExclusive
    ) {
        List<Object[]> roomRows = entityManager
                .createQuery(
                        "SELECT r.roomType, COUNT(r) FROM Room r "
                                + "WHERE r.deleted = false "
                                + "GROUP BY r.roomType",
                        Object[].class
                )
                .getResultList();

        Map<RoomType, long[]> byType = new LinkedHashMap<>();
        for (RoomType type : RoomType.values()) {
            byType.put(type, new long[2]);
        }
        for (Object[] row : roomRows) {
            long[] bucket = byType.get((RoomType) row[0]);
            if (bucket != null) {
                bucket[0] = (Long) row[1];
            }
        }

        List<Object[]> stayRows = entityManager
                .createQuery(
                        "SELECT br.roomTypeSnapshot, o.checkInDate, o.checkOutDate "
                                + "FROM BookingRoom br JOIN br.order o "
                                + "WHERE br.room.deleted = false "
                                + "AND br.status <> :roomCancelled "
                                + "AND o.status <> :orderCancelled "
                                + "AND o.status <> :pendingPayment "
                                + "AND o.checkInDate < :periodEnd "
                                + "AND o.checkOutDate > :periodStart",
                        Object[].class
                )
                .setParameter("roomCancelled", BookingRoomStatus.CANCELLED)
                .setParameter("orderCancelled", OrderStatus.CANCELLED)
                .setParameter("pendingPayment", OrderStatus.PENDING_PAYMENT)
                .setParameter("periodStart", periodStart)
                .setParameter("periodEnd", periodEndExclusive)
                .getResultList();

        for (Object[] row : stayRows) {
            long[] bucket = byType.get((RoomType) row[0]);
            if (bucket != null) {
                bucket[1] += overlappingNights(
                        (LocalDate) row[1],
                        (LocalDate) row[2],
                        periodStart,
                        periodEndExclusive
                );
            }
        }

        long periodDays = reportPeriodDays(periodStart, periodEndExclusive);
        List<String> labels = new ArrayList<>();
        List<BigDecimal> values = new ArrayList<>();
        for (Map.Entry<RoomType, long[]> entry : byType.entrySet()) {
            labels.add(titleCaseEnum(entry.getKey().name()));
            values.add(occupancyPercentage(
                    entry.getValue()[0],
                    entry.getValue()[1],
                    periodDays
            ));
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", labels);
        result.put("values", values);
        result.put("title", "Occupancy rate by room type (%)");
        return result;
    }

    /**
     * Paid revenue per day inside the selected reporting window.
     */
    public Map<String, Object> revenueByDate(
            LocalDate periodStart,
            LocalDate periodEndExclusive
    ) {
        LocalDateTime startDt = periodStart.atStartOfDay();
        LocalDateTime endDt = periodEndExclusive.atStartOfDay();

        List<Object[]> rows = entityManager
                .createQuery(
                        "SELECT p.paidAt, p.amount FROM Payment p "
                                + "WHERE p.status = :status "
                                + "AND p.paidAt IS NOT NULL "
                                + "AND p.paidAt >= :start "
                                + "AND p.paidAt < :end",
                        Object[].class
                )
                .setParameter("status", PaymentStatus.PAID)
                .setParameter("start", startDt)
                .setParameter("end", endDt)
                .getResultList();

        Map<String, BigDecimal> byDay = new LinkedHashMap<>();
        for (LocalDate date = periodStart;
             date.isBefore(periodEndExclusive);
             date = date.plusDays(1)) {
            byDay.put(date.toString(), BigDecimal.ZERO.setScale(2));
        }
        for (Object[] row : rows) {
            LocalDateTime paidAt = (LocalDateTime) row[0];
            if (paidAt == null) {
                continue;
            }
            String key = paidAt.toLocalDate().toString();
            BigDecimal amount = row[1] instanceof BigDecimal bd
                    ? bd
                    : BigDecimal.valueOf(((Number) row[1]).doubleValue());
            if (byDay.containsKey(key)) {
                byDay.put(
                        key,
                        byDay.get(key).add(amount).setScale(2, RoundingMode.HALF_UP)
                );
            }
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", new ArrayList<>(byDay.keySet()));
        result.put("values", new ArrayList<>(byDay.values()));
        result.put("title", "Paid revenue (RM)");
        return result;
    }

    /**
     * Booking orders created inside the selected reporting window.
     */
    public Map<String, Object> bookingStatusDistribution(
            LocalDate periodStart,
            LocalDate periodEndExclusive
    ) {
        List<Object[]> rows = entityManager
                .createQuery(
                        "SELECT o.status, COUNT(o) FROM BookingOrder o "
                                + "WHERE o.createdAt >= :start "
                                + "AND o.createdAt < :end "
                                + "GROUP BY o.status",
                        Object[].class
                )
                .setParameter("start", periodStart.atStartOfDay())
                .setParameter("end", periodEndExclusive.atStartOfDay())
                .getResultList();

        Map<String, Long> counts = new LinkedHashMap<>();
        for (OrderStatus status : OrderStatus.values()) {
            counts.put(titleCaseEnum(status.name()), 0L);
        }
        for (Object[] row : rows) {
            counts.put(
                    titleCaseEnum(((OrderStatus) row[0]).name()),
                    (Long) row[1]
            );
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", new ArrayList<>(counts.keySet()));
        result.put("values", new ArrayList<>(counts.values()));
        result.put("title", "Booking status distribution");
        return result;
    }

    /**
     * Cleaning tasks completed inside the selected reporting window.
     */
    public Map<String, Object> housekeeperCompletions(
            LocalDate periodStart,
            LocalDate periodEndExclusive
    ) {
        List<Object[]> rows = entityManager
                .createQuery(
                        "SELECT t.housekeeper.name, COUNT(t) FROM CleaningTask t "
                                + "WHERE t.status = :status "
                                + "AND t.completedAt >= :start "
                                + "AND t.completedAt < :end "
                                + "GROUP BY t.housekeeper.name "
                                + "ORDER BY COUNT(t) DESC",
                        Object[].class
                )
                .setParameter("status", CleaningTaskStatus.COMPLETED)
                .setParameter("start", periodStart.atStartOfDay())
                .setParameter("end", periodEndExclusive.atStartOfDay())
                .getResultList();

        List<String> labels = new ArrayList<>();
        List<Long> values = new ArrayList<>();
        for (Object[] row : rows) {
            labels.add(String.valueOf(row[0]));
            values.add((Long) row[1]);
        }
        if (labels.isEmpty()) {
            labels.add("No completed tasks");
            values.add(0L);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", labels);
        result.put("values", values);
        result.put("title", "Housekeeper completed tasks");
        return result;
    }

    /**
     * Feedbacks, comments and newly registered customers in the period.
     */
    public Map<String, Object> feedbackAndCommentCounts(
            LocalDate periodStart,
            LocalDate periodEndExclusive
    ) {
        LocalDateTime startDt = periodStart.atStartOfDay();
        LocalDateTime endDt = periodEndExclusive.atStartOfDay();

        long feedbacks = entityManager
                .createQuery(
                        "SELECT COUNT(f) FROM Feedback f "
                                + "WHERE f.createdAt >= :start AND f.createdAt < :end",
                        Long.class
                )
                .setParameter("start", startDt)
                .setParameter("end", endDt)
                .getSingleResult();
        long comments = entityManager
                .createQuery(
                        "SELECT COUNT(c) FROM Comment c "
                                + "WHERE c.createdAt >= :start AND c.createdAt < :end",
                        Long.class
                )
                .setParameter("start", startDt)
                .setParameter("end", endDt)
                .getSingleResult();
        long customers = entityManager
                .createQuery(
                        "SELECT COUNT(u) FROM User u "
                                + "WHERE u.deleted = false "
                                + "AND u.role = com.apu.hrms.entity.UserRole.CUSTOMER "
                                + "AND u.createdAt >= :start AND u.createdAt < :end",
                        Long.class
                )
                .setParameter("start", startDt)
                .setParameter("end", endDt)
                .getSingleResult();

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", List.of("Feedbacks", "Comments", "New customers"));
        result.put("values", List.of(feedbacks, comments, customers));
        result.put("title", "Engagement activity");
        return result;
    }

    /**
     * Summary values that all use the same selected reporting window.
     */
    public Map<String, Object> summaryCards(
            LocalDate periodStart,
            LocalDate periodEndExclusive
    ) {
        LocalDateTime startDt = periodStart.atStartOfDay();
        LocalDateTime endDt = periodEndExclusive.atStartOfDay();

        Map<String, Object> cards = new LinkedHashMap<>();
        cards.put("newCustomers", entityManager
                .createQuery(
                        "SELECT COUNT(u) FROM User u "
                                + "WHERE u.deleted = false "
                                + "AND u.role = com.apu.hrms.entity.UserRole.CUSTOMER "
                                + "AND u.createdAt >= :start AND u.createdAt < :end",
                        Long.class
                )
                .setParameter("start", startDt)
                .setParameter("end", endDt)
                .getSingleResult());
        cards.put("orders", entityManager
                .createQuery(
                        "SELECT COUNT(o) FROM BookingOrder o "
                                + "WHERE o.createdAt >= :start AND o.createdAt < :end",
                        Long.class
                )
                .setParameter("start", startDt)
                .setParameter("end", endDt)
                .getSingleResult());
        cards.put(
                "roomNights",
                occupiedRoomNights(periodStart, periodEndExclusive)
        );
        cards.put("completedTasks", entityManager
                .createQuery(
                        "SELECT COUNT(t) FROM CleaningTask t "
                                + "WHERE t.status = :status "
                                + "AND t.completedAt >= :start AND t.completedAt < :end",
                        Long.class
                )
                .setParameter("status", CleaningTaskStatus.COMPLETED)
                .setParameter("start", startDt)
                .setParameter("end", endDt)
                .getSingleResult());
        cards.put("paidRevenue", entityManager
                .createQuery(
                        "SELECT COALESCE(SUM(p.amount), 0) FROM Payment p "
                                + "WHERE p.status = :status "
                                + "AND p.paidAt >= :start AND p.paidAt < :end",
                        BigDecimal.class
                )
                .setParameter("status", PaymentStatus.PAID)
                .setParameter("start", startDt)
                .setParameter("end", endDt)
                .getSingleResult());
        return cards;
    }

    private Map<String, Object> occupancyResult(
            Map<Integer, long[]> buckets,
            LocalDate periodStart,
            LocalDate periodEndExclusive,
            String title
    ) {
        long periodDays = reportPeriodDays(periodStart, periodEndExclusive);
        List<String> labels = new ArrayList<>();
        List<BigDecimal> values = new ArrayList<>();
        for (Map.Entry<Integer, long[]> entry : buckets.entrySet()) {
            labels.add("Floor " + entry.getKey());
            values.add(occupancyPercentage(
                    entry.getValue()[0],
                    entry.getValue()[1],
                    periodDays
            ));
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", labels);
        result.put("values", values);
        result.put("title", title);
        return result;
    }

    private BigDecimal occupancyPercentage(
            long roomCount,
            long occupiedNights,
            long periodDays
    ) {
        long capacity = roomCount * periodDays;
        if (capacity <= 0) {
            return BigDecimal.ZERO.setScale(1);
        }
        long used = Math.min(Math.max(occupiedNights, 0), capacity);
        return BigDecimal.valueOf(used * 100.0 / capacity)
                .setScale(1, RoundingMode.HALF_UP);
    }

    private long occupiedRoomNights(
            LocalDate periodStart,
            LocalDate periodEndExclusive
    ) {
        List<Object[]> rows = entityManager
                .createQuery(
                        "SELECT o.checkInDate, o.checkOutDate "
                                + "FROM BookingRoom br JOIN br.order o "
                                + "WHERE br.room.deleted = false "
                                + "AND br.status <> :roomCancelled "
                                + "AND o.status <> :orderCancelled "
                                + "AND o.status <> :pendingPayment "
                                + "AND o.checkInDate < :periodEnd "
                                + "AND o.checkOutDate > :periodStart",
                        Object[].class
                )
                .setParameter("roomCancelled", BookingRoomStatus.CANCELLED)
                .setParameter("orderCancelled", OrderStatus.CANCELLED)
                .setParameter("pendingPayment", OrderStatus.PENDING_PAYMENT)
                .setParameter("periodStart", periodStart)
                .setParameter("periodEnd", periodEndExclusive)
                .getResultList();

        long nights = 0;
        for (Object[] row : rows) {
            nights += overlappingNights(
                    (LocalDate) row[0],
                    (LocalDate) row[1],
                    periodStart,
                    periodEndExclusive
            );
        }
        return nights;
    }

    private static long overlappingNights(
            LocalDate stayStart,
            LocalDate stayEnd,
            LocalDate periodStart,
            LocalDate periodEndExclusive
    ) {
        LocalDate overlapStart = stayStart.isAfter(periodStart)
                ? stayStart
                : periodStart;
        LocalDate overlapEnd = stayEnd.isBefore(periodEndExclusive)
                ? stayEnd
                : periodEndExclusive;
        return overlapEnd.isAfter(overlapStart)
                ? ChronoUnit.DAYS.between(overlapStart, overlapEnd)
                : 0L;
    }

    private static long reportPeriodDays(
            LocalDate periodStart,
            LocalDate periodEndExclusive
    ) {
        return Math.max(
                ChronoUnit.DAYS.between(periodStart, periodEndExclusive),
                1L
        );
    }

    private static String titleCaseEnum(String name) {
        if (name == null || name.isBlank()) {
            return "";
        }
        String[] parts = name.toLowerCase().split("_");
        StringBuilder sb = new StringBuilder();
        for (String part : parts) {
            if (part.isEmpty()) {
                continue;
            }
            if (sb.length() > 0) {
                sb.append(' ');
            }
            sb.append(Character.toUpperCase(part.charAt(0)));
            if (part.length() > 1) {
                sb.append(part.substring(1));
            }
        }
        return sb.toString();
    }
}

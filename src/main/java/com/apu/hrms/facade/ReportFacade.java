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
        long feedbacks = entityManager
                .createQuery("SELECT COUNT(f) FROM Feedback f", Long.class)
                .getSingleResult();
        long comments = entityManager
                .createQuery("SELECT COUNT(c) FROM Comment c", Long.class)
                .getSingleResult();
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

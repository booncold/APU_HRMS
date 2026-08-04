package com.apu.hrms.facade;

import com.apu.hrms.entity.BookingOrder;
import com.apu.hrms.entity.BookingRoom;
import com.apu.hrms.entity.CleaningTask;
import com.apu.hrms.entity.CleaningTaskStatus;
import com.apu.hrms.entity.Comment;
import com.apu.hrms.entity.CommentMention;
import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Stateless
public class CommentFacade {

    @PersistenceContext
    private EntityManager entityManager;

    public void create(Comment comment) {
        entityManager.persist(comment);
    }

    public Comment find(Long id) {
        return entityManager.find(Comment.class, id);
    }

    public List<Comment> findAll() {
        List<Comment> list = entityManager
                .createQuery(
                        "SELECT c FROM Comment c ORDER BY c.createdAt DESC",
                        Comment.class
                )
                .getResultList();
        list.forEach(this::initializeComment);
        return list;
    }

    public List<Comment> findByCustomer(User customer) {
        List<Comment> list = entityManager
                .createQuery(
                        "SELECT c FROM Comment c "
                                + "WHERE c.customer = :customer "
                                + "ORDER BY c.createdAt DESC",
                        Comment.class
                )
                .setParameter("customer", customer)
                .getResultList();
        list.forEach(this::initializeComment);
        return list;
    }

    /**
     * Staff that may be mentioned on a booking:
     * counter staff on the order + housekeepers who cleaned related rooms.
     */
    public List<User> findMentionableStaff(Long orderId) {
        BookingOrder order = entityManager.find(BookingOrder.class, orderId);
        if (order == null) {
            return List.of();
        }

        Map<Long, User> unique = new LinkedHashMap<>();

        if (order.getCounterStaff() != null
                && !order.getCounterStaff().isDeleted()) {
            unique.put(order.getCounterStaff().getId(), order.getCounterStaff());
            order.getCounterStaff().getName();
        }

        if (order.getRooms() != null) {
            order.getRooms().size();
            List<Long> roomIds = new ArrayList<>();
            for (BookingRoom br : order.getRooms()) {
                if (br.getRoom() != null) {
                    roomIds.add(br.getRoom().getId());
                }
            }
            if (!roomIds.isEmpty()) {
                List<CleaningTask> tasks = entityManager
                        .createQuery(
                                "SELECT t FROM CleaningTask t "
                                        + "WHERE t.room.id IN :roomIds "
                                        + "AND t.status = :status",
                                CleaningTask.class
                        )
                        .setParameter("roomIds", roomIds)
                        .setParameter("status", CleaningTaskStatus.COMPLETED)
                        .getResultList();
                for (CleaningTask task : tasks) {
                    User hk = task.getHousekeeper();
                    if (hk != null && !hk.isDeleted()) {
                        unique.put(hk.getId(), hk);
                        hk.getName();
                    }
                }
            }
        }

        return new ArrayList<>(unique.values());
    }

    public Comment submitComment(
            Long customerId,
            Long orderId,
            String content,
            List<Long> staffIds
    ) {
        if (customerId == null || orderId == null) {
            throw new IllegalArgumentException("Customer and booking are required.");
        }
        if (content == null || content.isBlank()) {
            throw new IllegalArgumentException("Comment content is required.");
        }
        String trimmed = content.trim();
        if (trimmed.length() > 2000) {
            throw new IllegalArgumentException("Comment must be at most 2000 characters.");
        }

        User customer = entityManager.find(User.class, customerId);
        if (customer == null || customer.isDeleted()
                || customer.getRole() != UserRole.CUSTOMER) {
            throw new IllegalArgumentException("Only customers can post comments.");
        }

        BookingOrder order = entityManager.find(BookingOrder.class, orderId);
        if (order == null) {
            throw new IllegalArgumentException("Booking not found.");
        }
        if (order.getCustomer() == null
                || !customerId.equals(order.getCustomer().getId())) {
            throw new IllegalArgumentException("You can only comment on your own bookings.");
        }

        Comment comment = new Comment();
        comment.setCustomer(customer);
        comment.setOrder(order);
        comment.setContent(trimmed);

        List<User> allowed = findMentionableStaff(orderId);
        Map<Long, User> allowedMap = new LinkedHashMap<>();
        for (User u : allowed) {
            allowedMap.put(u.getId(), u);
        }

        if (staffIds != null) {
            for (Long staffId : staffIds) {
                if (staffId == null) {
                    continue;
                }
                User staff = allowedMap.get(staffId);
                if (staff == null) {
                    throw new IllegalArgumentException(
                            "Selected staff cannot be mentioned for this booking."
                    );
                }
                CommentMention mention = new CommentMention();
                mention.setStaff(staff);
                comment.addMention(mention);
            }
        }

        entityManager.persist(comment);
        entityManager.flush();
        initializeComment(comment);
        return comment;
    }

    private void initializeComment(Comment comment) {
        if (comment.getCustomer() != null) {
            comment.getCustomer().getName();
        }
        if (comment.getOrder() != null) {
            comment.getOrder().getOrderNo();
        }
        if (comment.getMentions() != null) {
            for (CommentMention m : comment.getMentions()) {
                if (m.getStaff() != null) {
                    m.getStaff().getName();
                }
            }
        }
        if (comment.getCreatedAt() != null) {
            comment.getCreatedAt().toString();
        }
    }
}

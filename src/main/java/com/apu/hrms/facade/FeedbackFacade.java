package com.apu.hrms.facade;

import com.apu.hrms.entity.Feedback;
import com.apu.hrms.entity.Room;
import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.util.List;

@Stateless
public class FeedbackFacade {

    @PersistenceContext
    private EntityManager entityManager;

    public void create(Feedback feedback) {
        if (feedback.getRoom() == null) {
            throw new IllegalArgumentException("Feedback must be linked to a room.");
        }
        entityManager.persist(feedback);
    }

    public Feedback find(Long id) {
        return entityManager.find(Feedback.class, id);
    }

    public List<Feedback> findAll() {
        List<Feedback> list = entityManager
                .createQuery(
                        "SELECT f FROM Feedback f ORDER BY f.createdAt DESC",
                        Feedback.class
                )
                .getResultList();
        list.forEach(this::initializeFeedback);
        return list;
    }

    public List<Feedback> findByHousekeeper(User housekeeper) {
        List<Feedback> list = entityManager
                .createQuery(
                        "SELECT f FROM Feedback f "
                                + "WHERE f.housekeeper = :housekeeper "
                                + "ORDER BY f.createdAt DESC",
                        Feedback.class
                )
                .setParameter("housekeeper", housekeeper)
                .getResultList();
        list.forEach(this::initializeFeedback);
        return list;
    }

    public List<Feedback> findByRoom(Room room) {
        List<Feedback> list = entityManager
                .createQuery(
                        "SELECT f FROM Feedback f "
                                + "WHERE f.room = :room "
                                + "ORDER BY f.createdAt DESC",
                        Feedback.class
                )
                .setParameter("room", room)
                .getResultList();
        list.forEach(this::initializeFeedback);
        return list;
    }

    /**
     * Housekeeper submits room feedback (room is mandatory).
     */
    public Feedback submitFeedback(Long housekeeperId, Long roomId, String content) {
        if (housekeeperId == null || roomId == null) {
            throw new IllegalArgumentException("Housekeeper and room are required.");
        }
        if (content == null || content.isBlank()) {
            throw new IllegalArgumentException("Feedback content is required.");
        }
        String trimmed = content.trim();
        if (trimmed.length() > 2000) {
            throw new IllegalArgumentException("Feedback must be at most 2000 characters.");
        }

        User housekeeper = entityManager.find(User.class, housekeeperId);
        if (housekeeper == null || housekeeper.isDeleted()
                || housekeeper.getRole() != UserRole.HOUSEKEEPER) {
            throw new IllegalArgumentException("Only housekeepers can submit room feedback.");
        }

        Room room = entityManager.find(Room.class, roomId);
        if (room == null || room.isDeleted()) {
            throw new IllegalArgumentException("Room not found.");
        }

        Feedback feedback = new Feedback();
        feedback.setHousekeeper(housekeeper);
        feedback.setRoom(room);
        feedback.setContent(trimmed);
        entityManager.persist(feedback);
        entityManager.flush();
        initializeFeedback(feedback);
        return feedback;
    }

    private void initializeFeedback(Feedback feedback) {
        if (feedback.getHousekeeper() != null) {
            feedback.getHousekeeper().getName();
        }
        if (feedback.getRoom() != null) {
            feedback.getRoom().getRoomNumber();
        }
    }
}

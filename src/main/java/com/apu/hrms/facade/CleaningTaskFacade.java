package com.apu.hrms.facade;

import com.apu.hrms.entity.CleaningTask;
import com.apu.hrms.entity.CleaningTaskStatus;
import com.apu.hrms.entity.Room;
import com.apu.hrms.entity.RoomStatus;
import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.time.LocalDateTime;
import java.util.List;

@Stateless
public class CleaningTaskFacade {

    @PersistenceContext
    private EntityManager entityManager;

    public void create(CleaningTask task) {
        entityManager.persist(task);
    }

    public CleaningTask update(CleaningTask task) {
        return entityManager.merge(task);
    }

    public CleaningTask find(Long id) {
        return entityManager.find(CleaningTask.class, id);
    }

    public CleaningTask findDetailed(Long id) {
        CleaningTask task = find(id);
        if (task != null) {
            initializeTask(task);
        }
        return task;
    }

    public List<CleaningTask> findByHousekeeper(User housekeeper) {
        List<CleaningTask> tasks = entityManager
                .createQuery(
                        "SELECT t FROM CleaningTask t "
                                + "WHERE t.housekeeper = :housekeeper "
                                + "ORDER BY t.assignedAt DESC",
                        CleaningTask.class
                )
                .setParameter("housekeeper", housekeeper)
                .getResultList();
        tasks.forEach(this::initializeTask);
        return tasks;
    }

    public List<CleaningTask> findAssignedByHousekeeper(User housekeeper) {
        List<CleaningTask> tasks = entityManager
                .createQuery(
                        "SELECT t FROM CleaningTask t "
                                + "WHERE t.housekeeper = :housekeeper "
                                + "AND t.status = :status "
                                + "ORDER BY t.assignedAt",
                        CleaningTask.class
                )
                .setParameter("housekeeper", housekeeper)
                .setParameter("status", CleaningTaskStatus.ASSIGNED)
                .getResultList();
        tasks.forEach(this::initializeTask);
        return tasks;
    }

    public List<CleaningTask> findAllDetailed() {
        List<CleaningTask> tasks = entityManager
                .createQuery(
                        "SELECT t FROM CleaningTask t ORDER BY t.assignedAt DESC",
                        CleaningTask.class
                )
                .getResultList();
        tasks.forEach(this::initializeTask);
        return tasks;
    }

    public boolean hasOpenTask(User housekeeper) {
        Long count = entityManager
                .createQuery(
                        "SELECT COUNT(t) FROM CleaningTask t "
                                + "WHERE t.housekeeper = :housekeeper "
                                + "AND t.status = :status",
                        Long.class
                )
                .setParameter("housekeeper", housekeeper)
                .setParameter("status", CleaningTaskStatus.ASSIGNED)
                .getSingleResult();

        return count > 0;
    }

    public boolean hasOpenTaskForRoom(Room room) {
        if (room == null) {
            return false;
        }
        Long count = entityManager
                .createQuery(
                        "SELECT COUNT(t) FROM CleaningTask t "
                                + "WHERE t.room = :room "
                                + "AND t.status = :status",
                        Long.class
                )
                .setParameter("room", room)
                .setParameter("status", CleaningTaskStatus.ASSIGNED)
                .getSingleResult();
        return count > 0;
    }

    public List<User> findAvailableHousekeepers() {
        return entityManager
                .createQuery(
                        "SELECT u FROM User u "
                                + "WHERE u.role = com.apu.hrms.entity.UserRole.HOUSEKEEPER "
                                + "AND u.deleted = false "
                                + "AND u.id NOT IN ("
                                + "  SELECT t.housekeeper.id FROM CleaningTask t "
                                + "  WHERE t.status = com.apu.hrms.entity.CleaningTaskStatus.ASSIGNED"
                                + ") "
                                + "ORDER BY u.name",
                        User.class
                )
                .getResultList();
    }

    /**
     * Counter assigns a dirty room to a free housekeeper.
     */
    public CleaningTask assignTask(
            Long roomId,
            Long housekeeperId,
            Long assignedById,
            String notes
    ) {
        if (roomId == null || housekeeperId == null || assignedById == null) {
            throw new IllegalArgumentException("Room, housekeeper, and assigner are required.");
        }

        Room room = entityManager.find(Room.class, roomId);
        if (room == null || room.isDeleted()) {
            throw new IllegalArgumentException("Room not found.");
        }
        if (room.getStatus() != RoomStatus.NEEDS_CLEANING) {
            throw new IllegalArgumentException(
                    "Room " + room.getRoomNumber() + " does not need cleaning."
            );
        }
        if (hasOpenTaskForRoom(room)) {
            throw new IllegalArgumentException(
                    "Room " + room.getRoomNumber() + " already has an open cleaning task."
            );
        }

        User housekeeper = entityManager.find(User.class, housekeeperId);
        if (housekeeper == null || housekeeper.isDeleted()
                || housekeeper.getRole() != UserRole.HOUSEKEEPER) {
            throw new IllegalArgumentException("Select a valid housekeeper.");
        }
        if (hasOpenTask(housekeeper)) {
            throw new IllegalArgumentException(
                    housekeeper.getName() + " already has an open cleaning task."
            );
        }

        User assignedBy = entityManager.find(User.class, assignedById);
        if (assignedBy == null || assignedBy.isDeleted()) {
            throw new IllegalArgumentException("Assigner not found.");
        }

        CleaningTask task = new CleaningTask();
        task.setRoom(room);
        task.setHousekeeper(housekeeper);
        task.setAssignedBy(assignedBy);
        task.setStatus(CleaningTaskStatus.ASSIGNED);
        task.setAssignedAt(LocalDateTime.now());
        if (notes != null && !notes.isBlank()) {
            task.setNotes(notes.trim());
        }

        entityManager.persist(task);
        entityManager.flush();
        initializeTask(task);
        return task;
    }

    /**
     * Housekeeper marks task complete; room becomes AVAILABLE.
     */
    public CleaningTask completeTask(Long taskId, Long housekeeperId) {
        if (taskId == null || housekeeperId == null) {
            throw new IllegalArgumentException("Task and housekeeper are required.");
        }

        CleaningTask task = entityManager.find(CleaningTask.class, taskId);
        if (task == null) {
            throw new IllegalArgumentException("Cleaning task not found.");
        }
        if (task.getStatus() != CleaningTaskStatus.ASSIGNED) {
            throw new IllegalArgumentException("This task is already completed.");
        }
        if (task.getHousekeeper() == null
                || !housekeeperId.equals(task.getHousekeeper().getId())) {
            throw new IllegalArgumentException("You can only complete your own tasks.");
        }

        Room room = task.getRoom();
        if (room == null || room.isDeleted()) {
            throw new IllegalArgumentException("Linked room not found.");
        }

        task.setStatus(CleaningTaskStatus.COMPLETED);
        task.setCompletedAt(LocalDateTime.now());
        room.setStatus(RoomStatus.AVAILABLE);

        entityManager.merge(room);
        CleaningTask saved = entityManager.merge(task);
        initializeTask(saved);
        return saved;
    }

    private void initializeTask(CleaningTask task) {
        if (task.getRoom() != null) {
            task.getRoom().getRoomNumber();
        }
        if (task.getHousekeeper() != null) {
            task.getHousekeeper().getName();
        }
        if (task.getAssignedBy() != null) {
            task.getAssignedBy().getName();
        }
    }
}

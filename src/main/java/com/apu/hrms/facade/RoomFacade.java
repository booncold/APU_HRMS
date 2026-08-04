package com.apu.hrms.facade;

import com.apu.hrms.entity.Room;
import com.apu.hrms.entity.RoomStatus;
import com.apu.hrms.entity.RoomType;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;

import java.util.List;

@Stateless
public class RoomFacade {

    @PersistenceContext
    private EntityManager entityManager;

    public void create(Room room) {
        entityManager.persist(room);
    }

    public Room update(Room room) {
        return entityManager.merge(room);
    }

    public Room find(Long id) {
        return entityManager.find(Room.class, id);
    }

    public Room findByRoomNumber(String roomNumber) {
        try {
            return entityManager
                    .createQuery(
                            "SELECT r FROM Room r "
                                    + "WHERE r.roomNumber = :roomNumber "
                                    + "AND r.deleted = false",
                            Room.class
                    )
                    .setParameter("roomNumber", roomNumber)
                    .getSingleResult();
        } catch (NoResultException exception) {
            return null;
        }
    }

    public long countActive() {
        return entityManager
                .createQuery(
                        "SELECT COUNT(r) FROM Room r WHERE r.deleted = false",
                        Long.class
                )
                .getSingleResult();
    }

    public List<Room> findAllActive() {
        return entityManager
                .createQuery(
                        "SELECT r FROM Room r "
                                + "WHERE r.deleted = false "
                                + "ORDER BY r.floor, r.roomNumber",
                        Room.class
                )
                .getResultList();
    }

    public List<Room> findByStatus(RoomStatus status) {
        return entityManager
                .createQuery(
                        "SELECT r FROM Room r "
                                + "WHERE r.deleted = false AND r.status = :status "
                                + "ORDER BY r.floor, r.roomNumber",
                        Room.class
                )
                .setParameter("status", status)
                .getResultList();
    }

    public List<Room> findByType(RoomType roomType) {
        return entityManager
                .createQuery(
                        "SELECT r FROM Room r "
                                + "WHERE r.deleted = false AND r.roomType = :roomType "
                                + "ORDER BY r.floor, r.roomNumber",
                        Room.class
                )
                .setParameter("roomType", roomType)
                .getResultList();
    }

    public List<Room> search(
            RoomType roomType,
            Integer floor,
            RoomStatus status
    ) {
        StringBuilder jpql = new StringBuilder(
                "SELECT r FROM Room r WHERE r.deleted = false"
        );

        if (roomType != null) {
            jpql.append(" AND r.roomType = :roomType");
        }
        if (floor != null) {
            jpql.append(" AND r.floor = :floor");
        }
        if (status != null) {
            jpql.append(" AND r.status = :status");
        }

        jpql.append(" ORDER BY r.floor, r.roomNumber");

        var query = entityManager.createQuery(jpql.toString(), Room.class);

        if (roomType != null) {
            query.setParameter("roomType", roomType);
        }
        if (floor != null) {
            query.setParameter("floor", floor);
        }
        if (status != null) {
            query.setParameter("status", status);
        }

        return query.getResultList();
    }

    public List<Room> findAvailable() {
        return findByStatus(RoomStatus.AVAILABLE);
    }

    /**
     * Updates current price only. Existing booking snapshots are unaffected.
     */
    public Room updateCurrentPrice(Long roomId, java.math.BigDecimal newPrice) {
        if (roomId == null) {
            throw new IllegalArgumentException("Room id is required.");
        }
        if (newPrice == null || newPrice.signum() <= 0) {
            throw new IllegalArgumentException("Price must be greater than 0.");
        }

        Room room = find(roomId);
        if (room == null || room.isDeleted()) {
            throw new IllegalArgumentException("Room not found.");
        }

        room.setCurrentPrice(newPrice);
        return update(room);
    }

    /**
     * Sets the same current price for every active room of the given type.
     * Does not change historical booking price snapshots.
     */
    public int updatePriceByType(RoomType roomType, java.math.BigDecimal newPrice) {
        if (roomType == null) {
            throw new IllegalArgumentException("Room type is required.");
        }
        if (newPrice == null || newPrice.signum() <= 0) {
            throw new IllegalArgumentException("Price must be greater than 0.");
        }

        List<Room> rooms = findByType(roomType);
        for (Room room : rooms) {
            room.setCurrentPrice(newPrice);
            update(room);
        }
        return rooms.size();
    }
}

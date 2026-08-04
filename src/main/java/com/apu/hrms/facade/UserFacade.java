package com.apu.hrms.facade;

import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;

import java.util.List;

@Stateless
public class UserFacade {

    @PersistenceContext
    private EntityManager entityManager;

    public void create(User user) {
        entityManager.persist(user);
    }

    public User update(User user) {
        return entityManager.merge(user);
    }

    public User find(Long id) {
        return entityManager.find(User.class, id);
    }

    public User findActiveById(Long id) {
        User user = find(id);
        if (user == null || user.isDeleted()) {
            return null;
        }
        return user;
    }

    public User findByEmail(String email) {
        try {
            return entityManager
                    .createQuery(
                            "SELECT u FROM User u "
                                    + "WHERE u.email = :email AND u.deleted = false",
                            User.class
                    )
                    .setParameter("email", email)
                    .getSingleResult();
        } catch (NoResultException exception) {
            return null;
        }
    }

    /**
     * Includes soft-deleted rows (needed for unique email/ic recovery).
     */
    public User findByEmailIncludingDeleted(String email) {
        try {
            return entityManager
                    .createQuery(
                            "SELECT u FROM User u WHERE u.email = :email",
                            User.class
                    )
                    .setParameter("email", email)
                    .getSingleResult();
        } catch (NoResultException exception) {
            return null;
        }
    }

    public User findByIcIncludingDeleted(String ic) {
        try {
            return entityManager
                    .createQuery(
                            "SELECT u FROM User u WHERE u.ic = :ic",
                            User.class
                    )
                    .setParameter("ic", ic)
                    .getSingleResult();
        } catch (NoResultException exception) {
            return null;
        }
    }

    public boolean existsByRole(UserRole role) {
        Long count = entityManager
                .createQuery(
                        "SELECT COUNT(u) FROM User u "
                                + "WHERE u.role = :role AND u.deleted = false",
                        Long.class
                )
                .setParameter("role", role)
                .getSingleResult();

        return count > 0;
    }

    public boolean existsByIc(String ic) {
        Long count = entityManager
                .createQuery(
                        "SELECT COUNT(u) FROM User u "
                                + "WHERE u.ic = :ic AND u.deleted = false",
                        Long.class
                )
                .setParameter("ic", ic)
                .getSingleResult();

        return count > 0;
    }

    public boolean existsSeedAdmin() {
        Long count = entityManager
                .createQuery(
                        "SELECT COUNT(u) FROM User u "
                                + "WHERE u.seedAdmin = true AND u.deleted = false",
                        Long.class
                )
                .getSingleResult();

        return count > 0;
    }

    public long countActive() {
        return entityManager
                .createQuery(
                        "SELECT COUNT(u) FROM User u WHERE u.deleted = false",
                        Long.class
                )
                .getSingleResult();
    }

    public List<User> findByRole(UserRole role) {
        return entityManager
                .createQuery(
                        "SELECT u FROM User u "
                                + "WHERE u.role = :role AND u.deleted = false "
                                + "ORDER BY u.name",
                        User.class
                )
                .setParameter("role", role)
                .getResultList();
    }

    public List<User> findAllStaff() {
        return entityManager
                .createQuery(
                        "SELECT u FROM User u "
                                + "WHERE u.deleted = false "
                                + "AND u.role <> :customerRole "
                                + "ORDER BY u.role, u.name",
                        User.class
                )
                .setParameter("customerRole", UserRole.CUSTOMER)
                .getResultList();
    }

    public List<User> findAllCustomers() {
        return findByRole(UserRole.CUSTOMER);
    }

    public List<User> searchStaff(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return findAllStaff();
        }

        String pattern = "%" + keyword.toLowerCase().trim() + "%";

        return entityManager
                .createQuery(
                        "SELECT u FROM User u "
                                + "WHERE u.deleted = false "
                                + "AND u.role <> :customerRole "
                                + "AND (LOWER(u.name) LIKE :keyword "
                                + "OR LOWER(u.email) LIKE :keyword "
                                + "OR u.ic LIKE :keyword "
                                + "OR u.phone LIKE :keyword) "
                                + "ORDER BY u.role, u.name",
                        User.class
                )
                .setParameter("customerRole", UserRole.CUSTOMER)
                .setParameter("keyword", pattern)
                .getResultList();
    }

    public List<User> searchCustomers(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return findAllCustomers();
        }

        String pattern = "%" + keyword.toLowerCase().trim() + "%";

        return entityManager
                .createQuery(
                        "SELECT u FROM User u "
                                + "WHERE u.deleted = false "
                                + "AND u.role = :customerRole "
                                + "AND (LOWER(u.name) LIKE :keyword "
                                + "OR LOWER(u.email) LIKE :keyword "
                                + "OR u.ic LIKE :keyword "
                                + "OR u.phone LIKE :keyword) "
                                + "ORDER BY u.name",
                        User.class
                )
                .setParameter("customerRole", UserRole.CUSTOMER)
                .setParameter("keyword", pattern)
                .getResultList();
    }

    public boolean existsByIcExcludingId(String ic, Long excludeId) {
        // Include soft-deleted rows: DB unique constraint applies to all rows
        Long count = entityManager
                .createQuery(
                        "SELECT COUNT(u) FROM User u "
                                + "WHERE u.ic = :ic AND u.id <> :excludeId",
                        Long.class
                )
                .setParameter("ic", ic)
                .setParameter("excludeId", excludeId)
                .getSingleResult();

        return count > 0;
    }

    public boolean existsByEmailExcludingId(String email, Long excludeId) {
        // Include soft-deleted rows: DB unique constraint applies to all rows
        Long count = entityManager
                .createQuery(
                        "SELECT COUNT(u) FROM User u "
                                + "WHERE u.email = :email AND u.id <> :excludeId",
                        Long.class
                )
                .setParameter("email", email)
                .setParameter("excludeId", excludeId)
                .getSingleResult();

        return count > 0;
    }

    /**
     * Soft-deletes a user and frees email/IC unique constraints so the same
     * credentials can be registered again later.
     */
    public void softDelete(User user) {
        user.setDeleted(true);
        freeUniqueKeys(user);
        entityManager.merge(user);
    }

    /**
     * Creates a new user, or restores a soft-deleted row that still holds the
     * same email/IC (legacy deletes before unique keys were freed).
     *
     * @return true if an existing deleted account was restored; false if created
     */
    public boolean createOrRestore(User incoming) {
        User byEmail =
                findByEmailIncludingDeleted(incoming.getEmail());
        User byIc =
                findByIcIncludingDeleted(incoming.getIc());

        if (byEmail != null && !byEmail.isDeleted()) {
            throw new IllegalStateException("EMAIL_TAKEN");
        }
        if (byIc != null && !byIc.isDeleted()) {
            throw new IllegalStateException("IC_TAKEN");
        }

        User restoreTarget = null;
        if (byEmail != null && byEmail.isDeleted()) {
            restoreTarget = byEmail;
        } else if (byIc != null && byIc.isDeleted()) {
            restoreTarget = byIc;
        }

        if (restoreTarget != null) {
            // Email and IC may belong to two different deleted rows
            if (byEmail != null
                    && byIc != null
                    && byEmail.isDeleted()
                    && byIc.isDeleted()
                    && !byEmail.getId().equals(byIc.getId())) {
                User other =
                        restoreTarget.getId().equals(byEmail.getId())
                                ? byIc
                                : byEmail;
                freeUniqueKeys(other);
                entityManager.merge(other);
                entityManager.flush();
            }

            restoreTarget.setName(incoming.getName());
            restoreTarget.setPasswordHash(incoming.getPasswordHash());
            restoreTarget.setGender(incoming.getGender());
            restoreTarget.setPhone(incoming.getPhone());
            restoreTarget.setIc(incoming.getIc());
            restoreTarget.setEmail(incoming.getEmail());
            restoreTarget.setAddress(incoming.getAddress());
            restoreTarget.setRole(incoming.getRole());
            restoreTarget.setSeedAdmin(false);
            restoreTarget.setDeleted(false);

            entityManager.merge(restoreTarget);
            return true;
        }

        entityManager.persist(incoming);
        return false;
    }

    private void freeUniqueKeys(User user) {
        Long id = user.getId();
        String idPart =
                id == null ? String.valueOf(System.nanoTime()) : String.valueOf(id);

        // Keep values unique and within column limits
        user.setEmail("deleted." + idPart + "." + System.nanoTime() + "@deleted.local");

        // IC column length is 32; produce a unique synthetic IC-like value
        long numeric = id == null ? System.nanoTime() : id;
        String syntheticIc = String.format(
                "%06d-99-%04d",
                Math.floorMod(numeric, 1_000_000L),
                Math.floorMod(numeric, 10_000L)
        );
        user.setIc(syntheticIc);
    }
}



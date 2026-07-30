package com.apu.hrms.facade;

import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;

@Stateless
public class UserFacade {

    @PersistenceContext
    private EntityManager entityManager;

    public void create(User user) {
        entityManager.persist(user);
    }

    public User findByEmail(String email) {
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

    public boolean existsByRole(UserRole role) {
        Long count = entityManager
                .createQuery(
                        "SELECT COUNT(u) FROM User u WHERE u.role = :role",
                        Long.class
                )
                .setParameter("role", role)
                .getSingleResult();

        return count > 0;
    }

    public boolean existsByIc(String ic) {
        Long count = entityManager
                .createQuery(
                        "SELECT COUNT(u) FROM User u WHERE u.ic = :ic",
                        Long.class
                )
                .setParameter("ic", ic)
                .getSingleResult();

        return count > 0;
    }
}

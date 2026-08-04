package com.apu.hrms.facade;

import com.apu.hrms.entity.PasswordResetToken;
import com.apu.hrms.entity.User;
import com.apu.hrms.util.MailUtil;
import com.apu.hrms.util.PasswordUtil;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;

import java.time.LocalDateTime;
import java.util.UUID;

@Stateless
public class PasswordResetFacade {

    private static final int TOKEN_HOURS = 1;

    @PersistenceContext
    private EntityManager entityManager;

    public void create(PasswordResetToken token) {
        entityManager.persist(token);
    }

    public PasswordResetToken update(PasswordResetToken token) {
        return entityManager.merge(token);
    }

    public PasswordResetToken findByToken(String token) {
        try {
            return entityManager
                    .createQuery(
                            "SELECT t FROM PasswordResetToken t WHERE t.token = :token",
                            PasswordResetToken.class
                    )
                    .setParameter("token", token)
                    .getSingleResult();
        } catch (NoResultException exception) {
            return null;
        }
    }

    /**
     * Creates a one-time reset token for an active user email.
     * Returns the raw token when the user exists (for email body / dev fallback).
     * Returns null when email is unknown (caller should still show a generic message).
     */
    public String requestResetToken(String email) {
        if (email == null || email.isBlank()) {
            return null;
        }

        User user;
        try {
            user = entityManager
                    .createQuery(
                            "SELECT u FROM User u "
                                    + "WHERE u.email = :email AND u.deleted = false",
                            User.class
                    )
                    .setParameter("email", email.trim().toLowerCase())
                    .getSingleResult();
        } catch (NoResultException exception) {
            // Also try original case
            try {
                user = entityManager
                        .createQuery(
                                "SELECT u FROM User u "
                                        + "WHERE LOWER(u.email) = :email AND u.deleted = false",
                                User.class
                        )
                        .setParameter("email", email.trim().toLowerCase())
                        .getSingleResult();
            } catch (NoResultException ex2) {
                return null;
            }
        }

        PasswordResetToken token = new PasswordResetToken();
        token.setUser(user);
        token.setToken(UUID.randomUUID().toString().replace("-", ""));
        token.setExpiresAt(LocalDateTime.now().plusHours(TOKEN_HOURS));
        token.setUsed(false);
        entityManager.persist(token);
        entityManager.flush();
        return token.getToken();
    }

    /**
     * Sends reset email when SMTP is configured. Returns whether mail was sent.
     */
    public boolean sendResetEmail(String email, String resetLink) {
        return MailUtil.send(
                email,
                "APU Hotel – Password reset",
                "You requested a password reset for APU Hotel.\n\n"
                        + "Open this link within " + TOKEN_HOURS + " hour(s):\n"
                        + resetLink + "\n\n"
                        + "If you did not request this, ignore this email."
        );
    }

    public PasswordResetToken findValidToken(String tokenValue) {
        if (tokenValue == null || tokenValue.isBlank()) {
            return null;
        }
        PasswordResetToken token = findByToken(tokenValue.trim());
        if (token == null || token.isUsed()) {
            return null;
        }
        if (token.getExpiresAt() == null
                || token.getExpiresAt().isBefore(LocalDateTime.now())) {
            return null;
        }
        if (token.getUser() != null) {
            token.getUser().getEmail();
        }
        return token;
    }

    public void resetPassword(String tokenValue, String newPassword) {
        PasswordResetToken token = findValidToken(tokenValue);
        if (token == null) {
            throw new IllegalArgumentException("Invalid or expired reset link.");
        }
        if (newPassword == null || newPassword.isBlank()) {
            throw new IllegalArgumentException("New password is required.");
        }

        User user = token.getUser();
        if (user == null || user.isDeleted()) {
            throw new IllegalArgumentException("Account not found.");
        }

        user.setPasswordHash(PasswordUtil.hashPassword(newPassword));
        entityManager.merge(user);

        token.setUsed(true);
        entityManager.merge(token);
    }
}

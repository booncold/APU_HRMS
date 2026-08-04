package com.apu.hrms.facade;

import com.apu.hrms.entity.Payment;
import com.apu.hrms.entity.PaymentStatus;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;

import java.util.List;

@Stateless
public class PaymentFacade {

    @PersistenceContext
    private EntityManager entityManager;

    public void create(Payment payment) {
        entityManager.persist(payment);
    }

    public Payment update(Payment payment) {
        return entityManager.merge(payment);
    }

    public Payment find(Long id) {
        return entityManager.find(Payment.class, id);
    }

    public Payment findByReceiptNo(String receiptNo) {
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

    public List<Payment> findByStatus(PaymentStatus status) {
        return entityManager
                .createQuery(
                        "SELECT p FROM Payment p "
                                + "WHERE p.status = :status "
                                + "ORDER BY p.createdAt DESC",
                        Payment.class
                )
                .setParameter("status", status)
                .getResultList();
    }
}

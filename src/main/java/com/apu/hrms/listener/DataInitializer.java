package com.apu.hrms.listener;

import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
import com.apu.hrms.facade.UserFacade;
import com.apu.hrms.util.PasswordUtil;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;

@Singleton
@Startup
public class DataInitializer {

    @EJB
    private UserFacade userFacade;

    @PostConstruct
    public void initialize() {
        if (userFacade.existsByRole(UserRole.MANAGER)) {
            return;
        }

        User manager =
                new User();

        manager.setName("System Manager");
        manager.setPasswordHash(
                PasswordUtil.hashPassword("Manager@123")
        );
        manager.setGender("Not specified");
        manager.setPhone("0000000000");
        manager.setIc("PRE-REGISTERED-MANAGER");
        manager.setEmail("manager@apu.com");
        manager.setAddress("APU Hotel");
        manager.setRole(UserRole.MANAGER);

        userFacade.create(manager);
    }
}

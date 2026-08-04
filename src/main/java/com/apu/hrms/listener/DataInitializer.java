package com.apu.hrms.listener;

import com.apu.hrms.entity.Room;
import com.apu.hrms.entity.RoomStatus;
import com.apu.hrms.entity.RoomType;
import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;
import com.apu.hrms.facade.BookingFacade;
import com.apu.hrms.facade.RoomFacade;
import com.apu.hrms.facade.UserFacade;
import com.apu.hrms.util.PasswordUtil;
import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;

import java.time.LocalDate;
import java.util.List;

@Singleton
@Startup
public class DataInitializer {

    @EJB
    private UserFacade userFacade;

    @EJB
    private RoomFacade roomFacade;

    @EJB
    private BookingFacade bookingFacade;

    @PostConstruct
    public void initialize() {
        upgradeLegacySeedManagerIfNeeded();
        seedUsers();
        seedRooms();
        seedSampleBookings();
    }

    /**
     * Older installs used manager@apu.com without seedAdmin.
     * Promote that account when no seed admin exists yet.
     */
    private void upgradeLegacySeedManagerIfNeeded() {
        if (userFacade.existsSeedAdmin()) {
            return;
        }

        User legacyManager =
                userFacade.findByEmail("manager@apu.com");

        if (legacyManager != null
                && legacyManager.getRole() == UserRole.MANAGER) {
            legacyManager.setSeedAdmin(true);
            userFacade.update(legacyManager);
        }
    }

    private void seedUsers() {
        ensureUser(
                "System Manager",
                "Manager@123",
                "Male",
                "+60111111111",
                "900101-01-0001",
                "manager@gmail.com",
                "APU Hotel Management Office",
                UserRole.MANAGER,
                true
        );

        ensureUser(
                "Assistant Manager",
                "Manager@123",
                "Female",
                "+60111111112",
                "900102-01-0002",
                "manager2@gmail.com",
                "APU Hotel Management Office",
                UserRole.MANAGER,
                false
        );

        ensureUser(
                "Counter Staff One",
                "Counter@123",
                "Female",
                "+60122222221",
                "910201-02-0001",
                "counter1@gmail.com",
                "APU Hotel Front Desk",
                UserRole.COUNTER_STAFF,
                false
        );

        ensureUser(
                "Counter Staff Two",
                "Counter@123",
                "Male",
                "+60122222222",
                "910202-02-0002",
                "counter2@gmail.com",
                "APU Hotel Front Desk",
                UserRole.COUNTER_STAFF,
                false
        );

        for (int i = 1; i <= 5; i++) {
            ensureUser(
                    "Housekeeper " + i,
                    "House@123",
                    i % 2 == 0 ? "Male" : "Female",
                    "+6013333330" + i,
                    String.format("92030%d-03-000%d", i, i),
                    "hk" + i + "@gmail.com",
                    "APU Hotel Housekeeping",
                    UserRole.HOUSEKEEPER,
                    false
            );
        }

        for (int i = 1; i <= 10; i++) {
            ensureUser(
                    "Customer " + i,
                    "Customer@123",
                    i % 2 == 0 ? "Male" : "Female",
                    String.format("+60144444%03d", i),
                    String.format("9304%02d-04-%04d", i, i),
                    "customer" + i + "@gmail.com",
                    "Customer Address " + i + ", Kuala Lumpur",
                    UserRole.CUSTOMER,
                    false
            );
        }
    }

    private void ensureUser(
            String name,
            String rawPassword,
            String gender,
            String phone,
            String ic,
            String email,
            String address,
            UserRole role,
            boolean seedAdmin
    ) {
        User existing =
                userFacade.findByEmail(email);

        if (existing != null) {
            if (seedAdmin && !existing.isSeedAdmin()) {
                existing.setSeedAdmin(true);
                userFacade.update(existing);
            }
            return;
        }

        User user = new User();
        user.setName(name);
        user.setPasswordHash(PasswordUtil.hashPassword(rawPassword));
        user.setGender(gender);
        user.setPhone(phone);
        user.setIc(ic);
        user.setEmail(email);
        user.setAddress(address);
        user.setRole(role);
        user.setSeedAdmin(seedAdmin);
        user.setDeleted(false);

        userFacade.create(user);
    }

    /**
     * 50 rooms: floors 1-5, numbers {floor}01-{floor}10.
     * Distribution: 30 STANDARD, 15 VIP, 5 PRESIDENTIAL.
     */
    private void seedRooms() {
        if (roomFacade.countActive() > 0) {
            return;
        }

        for (int floor = 1; floor <= 5; floor++) {
            for (int unit = 1; unit <= 10; unit++) {
                RoomType type =
                        resolveRoomType(floor, unit);

                Room room = new Room();
                room.setFloor(floor);
                room.setRoomNumber(String.format("%d%02d", floor, unit));
                room.setRoomType(type);
                room.setCurrentPrice(type.getDefaultPrice());
                room.setStatus(RoomStatus.AVAILABLE);
                room.setDeleted(false);

                roomFacade.create(room);
            }
        }
    }

    private RoomType resolveRoomType(int floor, int unit) {
        // Floors 1-3: all STANDARD (30 rooms)
        if (floor <= 3) {
            return RoomType.STANDARD;
        }

        // Floor 4: all VIP (10 rooms)
        if (floor == 4) {
            return RoomType.VIP;
        }

        // Floor 5: units 1-5 VIP, units 6-10 PRESIDENTIAL
        if (unit <= 5) {
            return RoomType.VIP;
        }

        return RoomType.PRESIDENTIAL;
    }

    /**
     * Demo samples for M4–M6:
     * - today check-in ready (CONFIRMED / RESERVED / BOOKED)
     * - multi-room upcoming booking
     * - one already checked-in stay for check-out demo
     */
    private void seedSampleBookings() {
        if (bookingFacade.countAll() > 0) {
            return;
        }

        User customer1 = userFacade.findByEmail("customer1@gmail.com");
        User customer2 = userFacade.findByEmail("customer2@gmail.com");
        User customer3 = userFacade.findByEmail("customer3@gmail.com");
        User counter = userFacade.findByEmail("counter1@gmail.com");

        Room room101 = roomFacade.findByRoomNumber("101");
        Room room102 = roomFacade.findByRoomNumber("102");
        Room room103 = roomFacade.findByRoomNumber("103");
        Room room401 = roomFacade.findByRoomNumber("401");

        if (customer1 == null || customer2 == null || customer3 == null || counter == null
                || room101 == null || room102 == null || room103 == null || room401 == null) {
            return;
        }

        LocalDate today = LocalDate.now();

        try {
            // 1) Today arrival — appears on Check-in (Today)
            bookingFacade.createConfirmedBooking(
                    customer1,
                    counter,
                    counter,
                    today,
                    2,
                    List.of(room101.getId()),
                    "CASH"
            );

            // 2) Multi-room upcoming booking
            bookingFacade.createConfirmedBooking(
                    customer2,
                    customer2,
                    null,
                    today.plusDays(1),
                    1,
                    List.of(room102.getId(), room401.getId()),
                    "CARD"
            );

            // 3) Already checked-in stay — appears on Check-out list
            var inHouse = bookingFacade.createConfirmedBooking(
                    customer3,
                    counter,
                    counter,
                    today,
                    1,
                    List.of(room103.getId()),
                    "CASH"
            );
            if (inHouse.getRooms() != null && !inHouse.getRooms().isEmpty()) {
                bookingFacade.checkIn(inHouse.getRooms().get(0).getId());
            }
        } catch (RuntimeException ignored) {
            // Seed is best-effort; do not fail application startup.
        }
    }
}

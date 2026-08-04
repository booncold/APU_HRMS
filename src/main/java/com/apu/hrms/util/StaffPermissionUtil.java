package com.apu.hrms.util;

import com.apu.hrms.entity.User;
import com.apu.hrms.entity.UserRole;

/**
 * Seed manager may manage other managers (not self).
 * Non-seed managers cannot touch any manager account.
 */
public final class StaffPermissionUtil {

    private StaffPermissionUtil() {
    }

    public static boolean canCreateRole(User actor, UserRole targetRole) {
        if (actor == null || targetRole == null || targetRole == UserRole.CUSTOMER) {
            return false;
        }

        if (targetRole == UserRole.MANAGER) {
            return actor.isSeedAdmin();
        }

        return targetRole == UserRole.COUNTER_STAFF
                || targetRole == UserRole.HOUSEKEEPER;
    }

    public static boolean canModifyStaff(User actor, User target) {
        if (actor == null || target == null || target.isDeleted()) {
            return false;
        }

        if (target.getRole() == UserRole.CUSTOMER) {
            return false;
        }

        if (target.getRole() == UserRole.MANAGER) {
            if (!actor.isSeedAdmin()) {
                return false;
            }
            // Seed manager cannot delete/edit restrictions for self handled by callers for delete
            return true;
        }

        return target.getRole() == UserRole.COUNTER_STAFF
                || target.getRole() == UserRole.HOUSEKEEPER;
    }

    public static boolean canDeleteStaff(User actor, User target) {
        if (!canModifyStaff(actor, target)) {
            return false;
        }

        // Nobody can delete themselves
        if (actor.getId() != null && actor.getId().equals(target.getId())) {
            return false;
        }

        return true;
    }
}

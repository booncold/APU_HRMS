package com.apu.hrms.entity;

public enum RoomStatus {
    AVAILABLE,
    BOOKED,
    OCCUPIED,
    NEEDS_CLEANING;

    public String getDisplayName() {
        return switch (this) {
            case AVAILABLE -> "Available";
            case BOOKED -> "Booked";
            case OCCUPIED -> "Occupied";
            case NEEDS_CLEANING -> "Needs cleaning";
        };
    }
}

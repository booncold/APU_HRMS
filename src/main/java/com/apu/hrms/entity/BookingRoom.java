package com.apu.hrms.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.math.BigDecimal;

@Entity
@Table(name = "booking_rooms")
public class BookingRoom {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private BookingOrder order;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    @Enumerated(EnumType.STRING)
    @Column(name = "room_type_snapshot", nullable = false, length = 30)
    private RoomType roomTypeSnapshot;

    @Column(name = "room_number_snapshot", nullable = false, length = 10)
    private String roomNumberSnapshot;

    @Column(name = "price_per_night_snapshot", nullable = false, precision = 10, scale = 2)
    private BigDecimal pricePerNightSnapshot;

    @Column(nullable = false)
    private int nights;

    @Column(name = "line_total", nullable = false, precision = 12, scale = 2)
    private BigDecimal lineTotal;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private BookingRoomStatus status = BookingRoomStatus.RESERVED;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public BookingOrder getOrder() {
        return order;
    }

    public void setOrder(BookingOrder order) {
        this.order = order;
    }

    public Room getRoom() {
        return room;
    }

    public void setRoom(Room room) {
        this.room = room;
    }

    public RoomType getRoomTypeSnapshot() {
        return roomTypeSnapshot;
    }

    public void setRoomTypeSnapshot(RoomType roomTypeSnapshot) {
        this.roomTypeSnapshot = roomTypeSnapshot;
    }

    public String getRoomNumberSnapshot() {
        return roomNumberSnapshot;
    }

    public void setRoomNumberSnapshot(String roomNumberSnapshot) {
        this.roomNumberSnapshot = roomNumberSnapshot;
    }

    public BigDecimal getPricePerNightSnapshot() {
        return pricePerNightSnapshot;
    }

    public void setPricePerNightSnapshot(BigDecimal pricePerNightSnapshot) {
        this.pricePerNightSnapshot = pricePerNightSnapshot;
    }

    public int getNights() {
        return nights;
    }

    public void setNights(int nights) {
        this.nights = nights;
    }

    public BigDecimal getLineTotal() {
        return lineTotal;
    }

    public void setLineTotal(BigDecimal lineTotal) {
        this.lineTotal = lineTotal;
    }

    public BookingRoomStatus getStatus() {
        return status;
    }

    public void setStatus(BookingRoomStatus status) {
        this.status = status;
    }
}

package com.renhe.hospital.auth.dto;

import com.renhe.hospital.user.UserAccount;

public class UserView {

    private final Long id;
    private final String name;
    private final String phone;
    private final String idCard;
    private final String role;

    public UserView(Long id, String name, String phone, String idCard, String role) {
        this.id = id;
        this.name = name;
        this.phone = phone;
        this.idCard = idCard;
        this.role = role;
    }

    public static UserView from(UserAccount user) {
        return new UserView(user.getId(), user.getName(), user.getPhone(), user.getIdCard(), user.getRole());
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getPhone() {
        return phone;
    }

    public String getIdCard() {
        return idCard;
    }

    public String getRole() {
        return role;
    }
}

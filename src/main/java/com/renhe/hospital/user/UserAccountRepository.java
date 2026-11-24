package com.renhe.hospital.user;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserAccountRepository extends JpaRepository<UserAccount, Long> {

    Optional<UserAccount> findByPhone(String phone);

    Optional<UserAccount> findByIdCard(String idCard);

    boolean existsByPhone(String phone);

    boolean existsByIdCard(String idCard);
}

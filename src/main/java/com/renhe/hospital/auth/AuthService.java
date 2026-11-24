package com.renhe.hospital.auth;

import com.renhe.hospital.auth.dto.LoginRequest;
import com.renhe.hospital.auth.dto.RegisterRequest;
import com.renhe.hospital.auth.dto.UserView;
import com.renhe.hospital.common.BusinessException;
import com.renhe.hospital.user.Patient;
import com.renhe.hospital.user.PatientRepository;
import com.renhe.hospital.user.UserAccount;
import com.renhe.hospital.user.UserAccountRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;

@Service
public class AuthService {

    public static final String SESSION_USER_ID = "LOGIN_USER_ID";

    private final UserAccountRepository users;
    private final PatientRepository patients;
    private final PasswordEncoder passwordEncoder;

    public AuthService(UserAccountRepository users, PatientRepository patients, PasswordEncoder passwordEncoder) {
        this.users = users;
        this.patients = patients;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public UserView register(RegisterRequest request) {
        String name = request.getName().trim();
        String phone = request.getPhone().trim();
        String idCard = request.getIdCard().trim().toUpperCase(Locale.ROOT);

        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new BusinessException(40001, "两次输入的密码不一致", HttpStatus.BAD_REQUEST);
        }
        if (users.existsByPhone(phone)) {
            throw new BusinessException(40901, "该手机号已注册", HttpStatus.CONFLICT);
        }
        if (users.existsByIdCard(idCard)) {
            throw new BusinessException(40902, "该身份证号已注册", HttpStatus.CONFLICT);
        }

        UserAccount user = new UserAccount();
        user.setName(name);
        user.setPhone(phone);
        user.setIdCard(idCard);
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setRole("PATIENT");
        user.setStatus(1);
        users.save(user);

        Patient patient = new Patient();
        patient.setUserId(user.getId());
        patient.setName(name);
        patient.setRelation("本人");
        patient.setIdType("居民身份证");
        patient.setIdNo(idCard);
        patient.setPhone(phone);
        patient.setDefaultPatient(Boolean.TRUE);
        patients.save(patient);

        return UserView.from(user);
    }

    public UserView login(LoginRequest request) {
        String account = request.getAccount().trim();
        UserAccount user = users.findByPhone(account)
                .or(() -> users.findByIdCard(account.toUpperCase(Locale.ROOT)))
                .orElse(null);

        if (user == null || !passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new BusinessException(40101, "账号或密码错误", HttpStatus.UNAUTHORIZED);
        }
        if (user.getStatus() == null || user.getStatus() != 1) {
            throw new BusinessException(40301, "账号已被停用，请联系门诊服务台", HttpStatus.FORBIDDEN);
        }
        return UserView.from(user);
    }

    public UserView getById(Long userId) {
        UserAccount user = users.findById(userId)
                .orElseThrow(() -> new BusinessException(40100, "登录已失效，请重新登录", HttpStatus.UNAUTHORIZED));
        return UserView.from(user);
    }
}

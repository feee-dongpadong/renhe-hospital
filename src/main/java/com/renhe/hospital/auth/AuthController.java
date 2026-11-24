package com.renhe.hospital.auth;

import com.renhe.hospital.auth.dto.LoginRequest;
import com.renhe.hospital.auth.dto.RegisterRequest;
import com.renhe.hospital.auth.dto.UserView;
import com.renhe.hospital.common.ApiResponse;
import com.renhe.hospital.common.BusinessException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ApiResponse<UserView> register(@Valid @RequestBody RegisterRequest request) {
        return ApiResponse.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ApiResponse<UserView> login(@Valid @RequestBody LoginRequest request, HttpServletRequest httpRequest) {
        UserView user = authService.login(request);
        HttpSession session = httpRequest.getSession(true);
        session.setAttribute(AuthService.SESSION_USER_ID, user.getId());
        session.setMaxInactiveInterval(request.isRemember() ? 7 * 24 * 60 * 60 : 30 * 60);
        return ApiResponse.ok(user);
    }

    @GetMapping("/me")
    public ApiResponse<UserView> me(HttpSession session) {
        Object userId = session.getAttribute(AuthService.SESSION_USER_ID);
        if (userId == null) {
            throw new BusinessException(40100, "登录已失效，请重新登录", HttpStatus.UNAUTHORIZED);
        }
        return ApiResponse.ok(authService.getById((Long) userId));
    }

    @PostMapping("/logout")
    public ApiResponse<Void> logout(HttpSession session) {
        session.invalidate();
        return ApiResponse.ok();
    }
}

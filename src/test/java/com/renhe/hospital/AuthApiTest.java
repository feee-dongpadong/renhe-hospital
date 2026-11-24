package com.renhe.hospital;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.renhe.hospital.user.UserAccount;
import com.renhe.hospital.user.UserAccountRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.LinkedHashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AuthApiTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserAccountRepository users;

    @Autowired
    private com.renhe.hospital.user.PatientRepository patients;

    private Map<String, Object> registerBody(String name, String phone, String idCard, String password) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("name", name);
        body.put("phone", phone);
        body.put("idCard", idCard);
        body.put("password", password);
        body.put("confirmPassword", password);
        return body;
    }

    private Map<String, Object> loginBody(String account, String password) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("account", account);
        body.put("password", password);
        body.put("remember", false);
        return body;
    }

    @Test
    void registerLoginMeLogout() throws Exception {
        Map<String, Object> reg = registerBody("测试用户", "13900000001", "310101199202021234", "Test12345");

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(reg)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data.name").value("测试用户"))
                .andExpect(jsonPath("$.data.passwordHash").doesNotExist());

        UserAccount saved = users.findByPhone("13900000001").orElse(null);
        assertNotNull(saved);
        assertFalse("Test12345".equals(saved.getPasswordHash()));
        assertTrue(saved.getPasswordHash().startsWith("$2"));

        MvcResult loginResult = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(loginBody("13900000001", "Test12345"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data.name").value("测试用户"))
                .andReturn();

        MockHttpSession session = (MockHttpSession) loginResult.getRequest().getSession(false);
        assertNotNull(session);

        mockMvc.perform(get("/api/auth/me").session(session))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.phone").value("13900000001"));

        mockMvc.perform(post("/api/auth/logout").session(session))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0));

        mockMvc.perform(get("/api/auth/me").session(session))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));
    }

    @Test
    void duplicatePhoneRejected() throws Exception {
        Map<String, Object> reg = registerBody("重复用户", "13900000002", "310101199303031234", "Test12345");
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(reg)))
                .andExpect(status().isOk());

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(reg)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value(40901))
                .andExpect(jsonPath("$.message").value("该手机号已注册"));
    }

    @Test
    void duplicateIdCardRejected() throws Exception {
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(registerBody("甲用户", "13900000003", "310101199404041234", "Test12345"))))
                .andExpect(status().isOk());

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(registerBody("乙用户", "13900000004", "310101199404041234", "Test12345"))))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value(40902));
    }

    @Test
    void wrongPasswordRejected() throws Exception {
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(registerBody("丙用户", "13900000005", "310101199505051234", "Test12345"))))
                .andExpect(status().isOk());

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(loginBody("13900000005", "Wrong12345"))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40101))
                .andExpect(jsonPath("$.message").value("账号或密码错误"));
    }

    @Test
    void invalidPhoneRejected() throws Exception {
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(registerBody("丁用户", "12345", "310101199606061234", "Test12345"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(40001))
                .andExpect(jsonPath("$.message").value("请输入正确的手机号"));
    }

    @Test
    void weakPasswordRejected() throws Exception {
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(registerBody("戊用户", "13900000006", "310101199707071234", "abcdefgh"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(40001));
    }

    @Test
    void passwordMismatchRejected() throws Exception {
        Map<String, Object> body = registerBody("己用户", "13900000007", "310101199808081234", "Test12345");
        body.put("confirmPassword", "Test12346");

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("两次输入的密码不一致"));
    }

    @Test
    void loginByIdCard() throws Exception {
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(registerBody("庚用户", "13900000008", "310101199909091234", "Test12345"))))
                .andExpect(status().isOk());

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(loginBody("310101199909091234", "Test12345"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.name").value("庚用户"));
    }

    @Test
    void meWithoutSessionRejected() throws Exception {
        mockMvc.perform(get("/api/auth/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100))
                .andExpect(jsonPath("$.message").value("登录已失效，请重新登录"));
    }

    @Test
    void registrationCreatesDefaultPatient() throws Exception {
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(registerBody("就诊人用户", "13900000009", "310101200001011234", "Test12345"))))
                .andExpect(status().isOk());

        UserAccount user = users.findByPhone("13900000009").orElseThrow();
        long owned = patients.findAll().stream()
                .filter(p -> user.getId().equals(p.getUserId()))
                .count();
        assertEquals(1, owned);
        assertEquals("本人", patients.findAll().stream()
                .filter(p -> user.getId().equals(p.getUserId()))
                .findFirst().orElseThrow().getRelation());
    }

    @Test
    void disabledAccountCannotLogin() throws Exception {
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(registerBody("停用用户", "13900000010", "310101200002021234", "Test12345"))))
                .andExpect(status().isOk());

        UserAccount user = users.findByPhone("13900000010").orElseThrow();
        user.setStatus(0);
        users.save(user);

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(loginBody("13900000010", "Test12345"))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value(40301));
    }

    @Test
    void rememberMeExtendsSession() throws Exception {
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(registerBody("记住用户", "13900000011", "310101200003031234", "Test12345"))))
                .andExpect(status().isOk());

        Map<String, Object> body = loginBody("13900000011", "Test12345");
        body.put("remember", true);

        MvcResult result = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isOk())
                .andReturn();

        MockHttpSession session = (MockHttpSession) result.getRequest().getSession(false);
        assertNotNull(session);
        assertEquals(7 * 24 * 60 * 60, session.getMaxInactiveInterval());
    }

    @Test
    void idCardLoginIsCaseInsensitive() throws Exception {
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(registerBody("末位用户", "13900000012", "31010120000404123X", "Test12345"))))
                .andExpect(status().isOk());

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(loginBody("31010120000404123x", "Test12345"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.name").value("末位用户"));
    }

    @Test
    void unknownAccountRejected() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content(objectMapper.writeValueAsString(loginBody("13900009999", "Test12345"))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40101))
                .andExpect(jsonPath("$.message").value("账号或密码错误"));
    }

    @Test
    void missingStaticResourceReturnsNotFound() throws Exception {
        mockMvc.perform(get("/missing-resource.png"))
                .andExpect(status().isNotFound());
    }

    @Test
    void unsupportedMethodReturnsMethodNotAllowed() throws Exception {
        mockMvc.perform(get("/api/auth/login"))
                .andExpect(status().isMethodNotAllowed());
    }

    @Test
    void malformedJsonReturnsBadRequest() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .characterEncoding("UTF-8")
                        .content("{bad json"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(40001));
    }
}

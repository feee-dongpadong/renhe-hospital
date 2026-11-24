CREATE DATABASE IF NOT EXISTS renhe_hospital DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE renhe_hospital;

CREATE TABLE IF NOT EXISTS sys_user (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    id_card VARCHAR(32) NOT NULL,
    password_hash VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'PATIENT',
    status TINYINT NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_user_phone (phone),
    UNIQUE KEY uk_user_id_card (id_card)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS patient (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    name VARCHAR(50) NOT NULL,
    relation VARCHAR(20) NOT NULL,
    id_type VARCHAR(40) NOT NULL,
    id_no VARCHAR(40) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    is_default TINYINT NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_patient_user_id_no (user_id, id_no),
    KEY idx_patient_user (user_id),
    CONSTRAINT fk_patient_user FOREIGN KEY (user_id) REFERENCES sys_user (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS department (
    id BIGINT NOT NULL AUTO_INCREMENT,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(50) NOT NULL,
    intro VARCHAR(500) NOT NULL,
    location VARCHAR(100) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    sort_no INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_department_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS doctor (
    id BIGINT NOT NULL AUTO_INCREMENT,
    department_id BIGINT NOT NULL,
    name VARCHAR(50) NOT NULL,
    title VARCHAR(30) NOT NULL,
    years INT NOT NULL DEFAULT 0,
    good_at VARCHAR(255) NOT NULL,
    fee DECIMAL(10, 2) NOT NULL,
    status TINYINT NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_doctor_department (department_id),
    CONSTRAINT fk_doctor_department FOREIGN KEY (department_id) REFERENCES department (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS schedule (
    id BIGINT NOT NULL AUTO_INCREMENT,
    doctor_id BIGINT NOT NULL,
    work_date DATE NOT NULL,
    period VARCHAR(10) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    total_slots INT NOT NULL,
    remaining_slots INT NOT NULL,
    status TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uk_schedule_doctor_date_period (doctor_id, work_date, period),
    KEY idx_schedule_date (work_date),
    CONSTRAINT fk_schedule_doctor FOREIGN KEY (doctor_id) REFERENCES doctor (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS appointment (
    id BIGINT NOT NULL AUTO_INCREMENT,
    appointment_no VARCHAR(32) NOT NULL,
    user_id BIGINT NOT NULL,
    patient_id BIGINT NOT NULL,
    doctor_id BIGINT NOT NULL,
    schedule_id BIGINT NULL,
    visit_date DATE NOT NULL,
    period VARCHAR(10) NOT NULL,
    visit_time VARCHAR(10) NOT NULL,
    fee DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    location VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_appointment_no (appointment_no),
    KEY idx_appointment_user (user_id),
    KEY idx_appointment_patient_date (patient_id, visit_date),
    KEY idx_appointment_doctor_date (doctor_id, visit_date),
    CONSTRAINT fk_appointment_user FOREIGN KEY (user_id) REFERENCES sys_user (id),
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) REFERENCES patient (id),
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id) REFERENCES doctor (id),
    CONSTRAINT fk_appointment_schedule FOREIGN KEY (schedule_id) REFERENCES schedule (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS medical_report (
    id BIGINT NOT NULL AUTO_INCREMENT,
    patient_id BIGINT NOT NULL,
    appointment_id BIGINT NULL,
    category VARCHAR(20) NOT NULL,
    title VARCHAR(100) NOT NULL,
    dept_name VARCHAR(50) NOT NULL,
    doctor_name VARCHAR(50) NOT NULL,
    report_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'READY',
    conclusion VARCHAR(500) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_report_patient (patient_id),
    CONSTRAINT fk_report_patient FOREIGN KEY (patient_id) REFERENCES patient (id),
    CONSTRAINT fk_report_appointment FOREIGN KEY (appointment_id) REFERENCES appointment (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS payment (
    id BIGINT NOT NULL AUTO_INCREMENT,
    payment_no VARCHAR(32) NOT NULL,
    user_id BIGINT NOT NULL,
    appointment_id BIGINT NULL,
    item_type VARCHAR(20) NOT NULL,
    title VARCHAR(100) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'UNPAID',
    method VARCHAR(20) NULL,
    paid_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_payment_no (payment_no),
    KEY idx_payment_user (user_id),
    CONSTRAINT fk_payment_user FOREIGN KEY (user_id) REFERENCES sys_user (id),
    CONSTRAINT fk_payment_appointment FOREIGN KEY (appointment_id) REFERENCES appointment (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO department (id, code, name, intro, location, phone, sort_no) VALUES
(1, 'CARDIO', '心血管内科', '以高血压、冠心病、心律失常和心力衰竭的规范化诊疗为重点，设有胸痛中心、心电监测与心脏康复单元，为慢性心血管疾病患者提供长期随访管理。', '门诊楼 3 层 东区', '010-6001-3001', 1),
(2, 'RESP', '呼吸内科', '诊治慢性阻塞性肺疾病、支气管哮喘、肺部感染与肺结节，配备肺功能检查室、雾化治疗室和睡眠呼吸监测。', '门诊楼 3 层 西区', '010-6001-3002', 2),
(3, 'GASTRO', '消化内科', '覆盖胃炎、胃食管反流、消化道出血与炎症性肠病，内镜中心可开展胃肠镜检查与息肉治疗。', '门诊楼 2 层 东区', '010-6001-2001', 3),
(4, 'NEURO', '神经内科', '诊治脑血管病、头痛、眩晕、癫痫与帕金森病，设有卒中绿色通道和神经电生理检查室。', '门诊楼 4 层 东区', '010-6001-4001', 4),
(5, 'ORTHO', '骨科', '开展关节置换、运动损伤修复、脊柱疾病与骨质疏松治疗，配备康复评估门诊和支具室。', '门诊楼 2 层 西区', '010-6001-2002', 5),
(6, 'PEDIATRIC', '儿科', '提供儿童常见病、呼吸道感染、过敏与生长发育评估，设有儿童雾化区和输液区。', '门诊楼 1 层 东区', '010-6001-1001', 6),
(7, 'OBGYN', '妇产科', '提供妇科肿瘤、月经失调、围产保健与高危妊娠管理，产科设有独立诊区与胎心监护室。', '门诊楼 4 层 西区', '010-6001-4002', 7),
(8, 'OPHTHALMIC', '眼科', '诊治白内障、青光眼、眼底病与屈光不正，配备裂隙灯、眼压计与眼底照相设备。', '门诊楼 1 层 西区', '010-6001-1002', 8);

INSERT IGNORE INTO doctor (id, department_id, name, title, years, good_at, fee, status) VALUES
(1, 1, '张建国', '主任医师', 25, '高血压、冠心病、心律失常的诊治', 50.00, 1),
(2, 1, '王晓梅', '副主任医师', 16, '心力衰竭、心肌病、心脏康复', 30.00, 1),
(3, 2, '李媛', '副主任医师', 18, '慢性阻塞性肺疾病、哮喘、肺部感染', 30.00, 1),
(4, 2, '赵文博', '主任医师', 22, '肺结节、肺癌早期筛查、间质性肺病', 50.00, 1),
(5, 3, '孙志强', '主任医师', 28, '胃炎、胃食管反流、消化道出血', 50.00, 1),
(6, 3, '周敏', '主治医师', 9, '幽门螺杆菌、肠易激综合征', 20.00, 1),
(7, 4, '周明', '主任医师', 30, '脑血管病、头痛、眩晕', 50.00, 1),
(8, 4, '刘海燕', '副主任医师', 15, '癫痫、帕金森病、睡眠障碍', 30.00, 1),
(9, 5, '陈立军', '主任医师', 24, '关节置换、运动损伤、腰椎间盘突出', 50.00, 1),
(10, 5, '吴倩', '副主任医师', 13, '骨折、骨质疏松、脊柱侧弯', 30.00, 1),
(11, 6, '郑晓东', '副主任医师', 17, '小儿呼吸道感染、哮喘、过敏', 30.00, 1),
(12, 6, '林巧', '主治医师', 8, '小儿消化不良、生长发育', 20.00, 1),
(13, 7, '高洁', '主任医师', 25, '妇科肿瘤、月经失调、围产保健', 50.00, 1),
(14, 7, '苏婉', '副主任医师', 14, '产科检查、高危妊娠', 30.00, 1),
(15, 8, '马俊', '主任医师', 21, '白内障、青光眼、眼底病', 50.00, 1),
(16, 8, '李莹', '副主任医师', 12, '干眼症、屈光不正、斜弱视', 30.00, 1);

INSERT IGNORE INTO schedule (id, doctor_id, work_date, period, start_time, end_time, total_slots, remaining_slots, status) VALUES
(1, 1, '2026-11-24', 'AM', '08:00:00', '12:00:00', 20, 6, 1),
(2, 1, '2026-11-24', 'PM', '14:00:00', '17:30:00', 20, 0, 1),
(3, 1, '2026-11-25', 'AM', '08:00:00', '12:00:00', 20, 3, 1),
(4, 1, '2026-11-25', 'PM', '14:00:00', '17:30:00', 20, 8, 1),
(5, 2, '2026-11-24', 'AM', '08:00:00', '12:00:00', 20, 0, 1),
(6, 2, '2026-11-24', 'PM', '14:00:00', '17:30:00', 20, 4, 1),
(7, 2, '2026-11-25', 'AM', '08:00:00', '12:00:00', 20, 9, 1),
(8, 2, '2026-11-25', 'PM', '14:00:00', '17:30:00', 20, 2, 1);

INSERT IGNORE INTO sys_user (id, name, phone, id_card, password_hash, role, status) VALUES
(1, '李女士', '13800138000', '310101199001011234', '$2b$10$EOcbFHLczUTihIuwsOokrO1eDDrFNvfdOa8eqrdck3gOGw4N14.rG', 'PATIENT', 1);

INSERT IGNORE INTO patient (id, user_id, name, relation, id_type, id_no, phone, is_default) VALUES
(1, 1, '李女士', '本人', '居民身份证', '310101199001011234', '13800138000', 1),
(2, 1, '陈美玲', '母亲', '港澳居民来往内地通行证', 'H08912345', '13900139000', 0);

INSERT IGNORE INTO appointment (id, appointment_no, user_id, patient_id, doctor_id, schedule_id, visit_date, period, visit_time, fee, status, location) VALUES
(1, 'YY2026112400186', 1, 1, 1, 1, '2026-11-24', '上午', '08:00', 50.00, 'PENDING', '门诊楼 3 层 东区 312 诊室'),
(2, 'YY2026112400201', 1, 2, 2, 8, '2026-11-25', '下午', '14:30', 30.00, 'PENDING', '门诊楼 3 层 西区 308 诊室'),
(3, 'YY2026101500077', 1, 1, 1, NULL, '2026-10-15', '上午', '09:00', 50.00, 'COMPLETED', '门诊楼 3 层 东区 312 诊室'),
(4, 'YY2026110200032', 1, 2, 2, NULL, '2026-11-02', '下午', '15:00', 30.00, 'CANCELLED', '门诊楼 3 层 西区 308 诊室'),
(5, 'YY2026090200012', 1, 2, 1, NULL, '2026-09-02', '上午', '09:00', 50.00, 'NO_SHOW', '门诊楼 3 层 东区 312 诊室'),
(6, 'YY2026092800031', 1, 2, 2, NULL, '2026-09-28', '下午', '14:30', 30.00, 'NO_SHOW', '门诊楼 3 层 西区 308 诊室'),
(7, 'YY2026101800056', 1, 2, 1, NULL, '2026-10-18', '上午', '10:00', 50.00, 'NO_SHOW', '门诊楼 3 层 东区 312 诊室'),
(8, 'YY2026111200089', 1, 2, 1, NULL, '2026-11-12', '上午', '09:30', 50.00, 'NO_SHOW', '门诊楼 3 层 东区 312 诊室');

INSERT IGNORE INTO medical_report (id, patient_id, appointment_id, category, title, dept_name, doctor_name, report_date, status, conclusion) VALUES
(1, 1, 3, '检验', '血常规（五分类）', '检验科', '李婷', '2026-11-21', 'READY', '血常规各项指标均在参考范围内，未见明显异常。'),
(2, 1, 3, '检查', '胸部 CT（平扫）', '影像科', '刘峰', '2026-11-20', 'READY', '胸部 CT 平扫未见明显活动性病变，建议结合临床随访。'),
(3, 1, NULL, '检查', '腹部彩超', '超声科', '陈静', '2026-11-22', 'PROCESSING', '报告正在审核中。');

INSERT IGNORE INTO payment (id, payment_no, user_id, appointment_id, item_type, title, amount, status, method, paid_at) VALUES
(1, 'PAY202611240001', 1, 1, '挂号费', '门诊挂号费', 50.00, 'UNPAID', NULL, NULL),
(2, 'PAY202611230002', 1, 1, '检查费', '胸部 CT 检查费', 360.00, 'UNPAID', NULL, NULL),
(3, 'PAY202611020003', 1, 4, '挂号费', '门诊挂号费', 30.00, 'PAID', '微信支付', '2026-11-02 10:20:00'),
(4, 'PAY202611210004', 1, 3, '检验费', '血常规检验费', 45.00, 'PAID', '微信支付', '2026-11-21 09:10:00');

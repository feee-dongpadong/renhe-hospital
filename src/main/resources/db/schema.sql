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

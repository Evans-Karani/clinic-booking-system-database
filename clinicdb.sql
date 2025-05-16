USE clinicdb;

CREATE TABLE patients (
  patient_id INT NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  date_of_birth DATE NOT NULL,
  gender ENUM('Male', 'Female', 'Other') NOT NULL,
  email VARCHAR(100) UNIQUE,
  phone VARCHAR(20) NOT NULL,
  address VARCHAR(255),
  city VARCHAR(50),
  state VARCHAR(50),
  postal_code VARCHAR(20),
  emergency_contact_name VARCHAR(100),
  emergency_contact_phone VARCHAR(20),
  insurance_provider VARCHAR(100),
  insurance_policy_number VARCHAR(50),
  blood_type ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
  allergies TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (patient_id),
  INDEX idx_patient_name (last_name, first_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE specialties (
  specialty_id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (specialty_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE clinics (
  clinic_id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  address VARCHAR(255) NOT NULL,
  city VARCHAR(50) NOT NULL,
  state VARCHAR(50) NOT NULL,
  postal_code VARCHAR(20) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(100),
  website VARCHAR(255),
  opening_time TIME NOT NULL,
  closing_time TIME NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (clinic_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE medical_staff (
  staff_id INT NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  role ENUM('Doctor', 'Nurse', 'Receptionist', 'Administrator', 'Other') NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone VARCHAR(20) NOT NULL,
  clinic_id INT NOT NULL,
  license_number VARCHAR(50) UNIQUE,
  date_of_birth DATE,
  hire_date DATE NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (staff_id),
  INDEX idx_staff_name (last_name, first_name),
  CONSTRAINT fk_staff_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE staff_specialties (
  staff_id INT NOT NULL,
  specialty_id INT NOT NULL,
  certification_date DATE,
  certification_expiry DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (staff_id, specialty_id),
  CONSTRAINT fk_staffspec_staff FOREIGN KEY (staff_id) REFERENCES medical_staff(staff_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_staffspec_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE services (
  service_id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  duration_minutes INT NOT NULL,
  cost DECIMAL(10,2) NOT NULL,
  specialty_id INT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (service_id),
  CONSTRAINT fk_service_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE appointments (
  appointment_id INT NOT NULL AUTO_INCREMENT,
  patient_id INT NOT NULL,
  staff_id INT NOT NULL,
  service_id INT NOT NULL,
  clinic_id INT NOT NULL,
  appointment_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  status ENUM('Scheduled', 'Confirmed', 'Completed', 'Cancelled', 'No-Show') NOT NULL DEFAULT 'Scheduled',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (appointment_id),
  INDEX idx_appointment_datetime (appointment_date, start_time),
  INDEX idx_appointment_patient (patient_id),
  INDEX idx_appointment_staff (staff_id),
  CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_appointment_staff FOREIGN KEY (staff_id) REFERENCES medical_staff(staff_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_appointment_service FOREIGN KEY (service_id) REFERENCES services(service_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_appointment_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE medical_records (
  record_id INT NOT NULL AUTO_INCREMENT,
  patient_id INT NOT NULL,
  appointment_id INT,
  staff_id INT NOT NULL,
  diagnosis TEXT,
  treatment TEXT,
  notes TEXT,
  record_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (record_id),
  INDEX idx_record_patient (patient_id),
  INDEX idx_record_appointment (appointment_id),
  CONSTRAINT fk_record_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_record_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_record_staff FOREIGN KEY (staff_id) REFERENCES medical_staff(staff_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE prescriptions (
  prescription_id INT NOT NULL AUTO_INCREMENT,
  record_id INT NOT NULL,
  medication_name VARCHAR(100) NOT NULL,
  dosage VARCHAR(50) NOT NULL,
  frequency VARCHAR(50) NOT NULL,
  duration VARCHAR(50) NOT NULL,
  instructions TEXT,
  prescribed_date DATE NOT NULL,
  expiry_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (prescription_id),
  CONSTRAINT fk_prescription_record FOREIGN KEY (record_id) REFERENCES medical_records(record_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE billing (
  billing_id INT NOT NULL AUTO_INCREMENT,
  appointment_id INT NOT NULL,
  patient_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  insurance_coverage DECIMAL(10,2) DEFAULT 0.00,
  patient_responsibility DECIMAL(10,2) NOT NULL,
  status ENUM('Pending', 'Processed', 'Paid', 'Overdue', 'Cancelled') NOT NULL DEFAULT 'Pending',
  bill_date DATE NOT NULL,
  due_date DATE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (billing_id),
  INDEX idx_billing_appointment (appointment_id),
  INDEX idx_billing_patient (patient_id),
  CONSTRAINT fk_billing_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_billing_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE payments (
  payment_id INT NOT NULL AUTO_INCREMENT,
  billing_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Insurance', 'Online', 'Bank Transfer') NOT NULL,
  payment_date DATE NOT NULL,
  transaction_id VARCHAR(100),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (payment_id),
  INDEX idx_payment_billing (billing_id),
  CONSTRAINT fk_payment_billing FOREIGN KEY (billing_id) REFERENCES billing(billing_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE clinic_schedule (
  schedule_id INT NOT NULL AUTO_INCREMENT,
  clinic_id INT NOT NULL,
  day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
  opening_time TIME NOT NULL,
  closing_time TIME NOT NULL,
  is_closed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (schedule_id),
  UNIQUE KEY unique_clinic_day (clinic_id, day_of_week),
  CONSTRAINT fk_schedule_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE staff_schedule (
  schedule_id INT NOT NULL AUTO_INCREMENT,
  staff_id INT NOT NULL,
  day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (schedule_id),
  INDEX idx_staffschedule_staff (staff_id),
  CONSTRAINT fk_staffschedule_staff FOREIGN KEY (staff_id) REFERENCES medical_staff(staff_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO specialties (name, description) VALUES ('Cardiology', 'Heart care'), ('Pediatrics', 'Child health');


INSERT INTO clinics (name, address, city, state, postal_code, phone, opening_time, closing_time)
VALUES ('Central Clinic', '123 Health St', 'Metropolis', 'State', '12345', '123-456-7890', '08:00:00', '17:00:00');


INSERT INTO patients (first_name, last_name, date_of_birth, gender, phone)
VALUES ('John', 'Doe', '1980-05-15', 'Male', '555-1234');

INSERT INTO medical_staff (first_name, last_name, role, email, phone, clinic_id, hire_date)
VALUES ('Alice', 'Smith', 'Doctor', 'alice.smith@example.com', '555-5678', 1, '2015-06-01');

INSERT INTO staff_specialties (staff_id, specialty_id, certification_date)
VALUES (1, 1, '2016-01-01');

INSERT INTO services (name, description, duration_minutes, cost, specialty_id)
VALUES ('Heart Checkup', 'Routine heart examination', 60, 150.00, 1);



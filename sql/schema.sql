PRAGMA foreign_keys = ON;

CREATE TABLE members (
    member_id TEXT PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    joined_on TEXT NOT NULL,
    member_status TEXT NOT NULL CHECK (member_status IN ('Active', 'Inactive'))
);

CREATE TABLE membership_plans (
    plan_id TEXT PRIMARY KEY,
    plan_name TEXT NOT NULL UNIQUE,
    billing_months INTEGER NOT NULL CHECK (billing_months > 0),
    standard_price_cents INTEGER NOT NULL CHECK (standard_price_cents >= 0)
);

CREATE TABLE memberships (
    membership_id TEXT PRIMARY KEY,
    member_id TEXT NOT NULL,
    plan_id TEXT NOT NULL,
    start_date TEXT NOT NULL,
    end_date TEXT,
    membership_status TEXT NOT NULL
        CHECK (membership_status IN ('Active', 'Frozen', 'Cancelled', 'Expired')),
    agreed_price_cents INTEGER NOT NULL CHECK (agreed_price_cents >= 0),
    FOREIGN KEY (member_id) REFERENCES members (member_id),
    FOREIGN KEY (plan_id) REFERENCES membership_plans (plan_id),
    CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE payments (
    payment_id TEXT PRIMARY KEY,
    membership_id TEXT NOT NULL,
    payment_date TEXT NOT NULL,
    amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
    payment_method TEXT NOT NULL
        CHECK (payment_method IN ('Card', 'ACH', 'Cash')),
    payment_status TEXT NOT NULL
        CHECK (payment_status IN ('Completed', 'Pending', 'Failed', 'Refunded')),
    FOREIGN KEY (membership_id) REFERENCES memberships (membership_id)
);

CREATE TABLE trainers (
    trainer_id TEXT PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    specialty TEXT NOT NULL,
    active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1))
);

CREATE TABLE fitness_classes (
    class_id TEXT PRIMARY KEY,
    class_name TEXT NOT NULL,
    trainer_id TEXT NOT NULL,
    starts_at TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes BETWEEN 15 AND 180),
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    class_status TEXT NOT NULL CHECK (class_status IN ('Scheduled', 'Completed', 'Cancelled')),
    FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id)
);

CREATE TABLE class_enrollments (
    class_id TEXT NOT NULL,
    member_id TEXT NOT NULL,
    booked_at TEXT NOT NULL,
    attendance_status TEXT NOT NULL
        CHECK (attendance_status IN ('Booked', 'Attended', 'No Show', 'Cancelled')),
    PRIMARY KEY (class_id, member_id),
    FOREIGN KEY (class_id) REFERENCES fitness_classes (class_id),
    FOREIGN KEY (member_id) REFERENCES members (member_id)
);

CREATE INDEX idx_memberships_member ON memberships (member_id);
CREATE INDEX idx_memberships_status ON memberships (membership_status);
CREATE INDEX idx_payments_date_status ON payments (payment_date, payment_status);
CREATE INDEX idx_classes_start ON fitness_classes (starts_at);
CREATE INDEX idx_enrollments_member ON class_enrollments (member_id);

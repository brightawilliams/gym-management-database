INSERT INTO membership_plans VALUES
    ('PL-BASIC', 'Basic Monthly', 1, 2900),
    ('PL-PLUS', 'Plus Monthly', 1, 4900),
    ('PL-ANNUAL', 'Annual Unlimited', 12, 49900);

INSERT INTO members VALUES
    ('M001', 'Ava', 'Brooks', 'ava.brooks@example.test', '555-0101', '2026-01-10', 'Active'),
    ('M002', 'Liam', 'Carter', 'liam.carter@example.test', '555-0102', '2026-02-14', 'Active'),
    ('M003', 'Noah', 'Davis', 'noah.davis@example.test', '555-0103', '2026-03-02', 'Active'),
    ('M004', 'Mia', 'Evans', 'mia.evans@example.test', '555-0104', '2026-03-22', 'Inactive'),
    ('M005', 'Ethan', 'Foster', 'ethan.foster@example.test', '555-0105', '2026-01-05', 'Active'),
    ('M006', 'Zoe', 'Green', 'zoe.green@example.test', '555-0106', '2026-08-15', 'Active'),
    ('M007', 'Lucas', 'Hill', 'lucas.hill@example.test', '555-0107', '2026-05-18', 'Active'),
    ('M008', 'Ella', 'Irving', 'ella.irving@example.test', '555-0108', '2026-04-09', 'Inactive'),
    ('M009', 'James', 'King', 'james.king@example.test', '555-0109', '2026-07-27', 'Active'),
    ('M010', 'Nora', 'Lewis', 'nora.lewis@example.test', '555-0110', '2026-08-20', 'Active');

INSERT INTO memberships VALUES
    ('MS001', 'M001', 'PL-PLUS', '2026-06-01', NULL, 'Active', 4900),
    ('MS002', 'M002', 'PL-BASIC', '2026-07-01', NULL, 'Active', 2900),
    ('MS003', 'M003', 'PL-PLUS', '2026-05-01', NULL, 'Frozen', 4900),
    ('MS004', 'M004', 'PL-BASIC', '2026-04-01', '2026-08-10', 'Cancelled', 2900),
    ('MS005', 'M005', 'PL-ANNUAL', '2026-01-05', '2027-01-04', 'Active', 49900),
    ('MS006', 'M006', 'PL-PLUS', '2026-08-15', NULL, 'Active', 4900),
    ('MS007', 'M007', 'PL-BASIC', '2026-06-01', NULL, 'Active', 2900),
    ('MS008', 'M008', 'PL-BASIC', '2026-05-01', '2026-07-31', 'Expired', 2900),
    ('MS009', 'M009', 'PL-PLUS', '2026-08-01', NULL, 'Active', 4900),
    ('MS010', 'M010', 'PL-BASIC', '2026-08-20', NULL, 'Active', 2900);

INSERT INTO payments VALUES
    ('PY001', 'MS001', '2026-07-01', 4900, 'Card', 'Completed'),
    ('PY002', 'MS002', '2026-07-02', 2900, 'ACH', 'Completed'),
    ('PY003', 'MS003', '2026-07-03', 4900, 'Card', 'Completed'),
    ('PY004', 'MS004', '2026-07-01', 2900, 'Cash', 'Completed'),
    ('PY005', 'MS007', '2026-07-05', 2900, 'ACH', 'Completed'),
    ('PY006', 'MS008', '2026-07-06', 2900, 'Card', 'Completed'),
    ('PY007', 'MS009', '2026-08-01', 4900, 'Card', 'Completed'),
    ('PY008', 'MS001', '2026-08-01', 4900, 'Card', 'Completed'),
    ('PY009', 'MS002', '2026-08-02', 2900, 'ACH', 'Completed'),
    ('PY010', 'MS003', '2026-08-03', 4900, 'Card', 'Completed'),
    ('PY011', 'MS004', '2026-08-01', 2900, 'Card', 'Refunded'),
    ('PY012', 'MS006', '2026-08-15', 4900, 'Card', 'Completed'),
    ('PY013', 'MS007', '2026-08-05', 2900, 'ACH', 'Failed'),
    ('PY014', 'MS010', '2026-08-20', 2900, 'ACH', 'Pending');

INSERT INTO trainers VALUES
    ('TR01', 'Sofia', 'Martinez', 'Yoga and Mobility', 1),
    ('TR02', 'Marcus', 'Reed', 'HIIT and Cycling', 1),
    ('TR03', 'Danielle', 'Young', 'Strength Training', 1);

INSERT INTO fitness_classes VALUES
    ('CL001', 'Morning Yoga', 'TR01', '2026-08-05T07:00:00', 60, 8, 'Completed'),
    ('CL002', 'HIIT Express', 'TR02', '2026-08-07T18:00:00', 45, 6, 'Completed'),
    ('CL003', 'Strength Basics', 'TR03', '2026-08-10T17:30:00', 60, 5, 'Completed'),
    ('CL004', 'Evening Yoga', 'TR01', '2026-08-12T18:30:00', 60, 8, 'Completed'),
    ('CL005', 'Cycle Power', 'TR02', '2026-08-15T09:00:00', 45, 6, 'Completed'),
    ('CL006', 'Strength Circuit', 'TR03', '2026-08-20T18:00:00', 60, 5, 'Completed'),
    ('CL007', 'Morning Yoga', 'TR01', '2026-08-25T07:00:00', 60, 8, 'Completed'),
    ('CL008', 'HIIT Express', 'TR02', '2026-08-28T18:00:00', 45, 6, 'Completed');

INSERT INTO class_enrollments VALUES
    ('CL001', 'M001', '2026-08-01T10:00:00', 'Attended'),
    ('CL001', 'M002', '2026-08-01T11:00:00', 'Attended'),
    ('CL001', 'M003', '2026-08-02T09:00:00', 'No Show'),
    ('CL001', 'M005', '2026-08-02T12:00:00', 'Attended'),
    ('CL002', 'M001', '2026-08-03T10:00:00', 'Attended'),
    ('CL002', 'M005', '2026-08-03T11:00:00', 'Attended'),
    ('CL002', 'M007', '2026-08-04T08:00:00', 'No Show'),
    ('CL002', 'M009', '2026-08-04T09:00:00', 'Attended'),
    ('CL003', 'M002', '2026-08-06T13:00:00', 'Attended'),
    ('CL003', 'M005', '2026-08-06T14:00:00', 'Attended'),
    ('CL003', 'M007', '2026-08-07T12:00:00', 'Attended'),
    ('CL003', 'M009', '2026-08-07T13:00:00', 'No Show'),
    ('CL004', 'M001', '2026-08-08T10:00:00', 'Attended'),
    ('CL004', 'M002', '2026-08-08T11:00:00', 'Cancelled'),
    ('CL004', 'M003', '2026-08-09T09:00:00', 'Attended'),
    ('CL004', 'M006', '2026-08-10T09:00:00', 'Attended'),
    ('CL005', 'M001', '2026-08-11T15:00:00', 'No Show'),
    ('CL005', 'M005', '2026-08-11T16:00:00', 'Attended'),
    ('CL005', 'M007', '2026-08-12T09:00:00', 'Attended'),
    ('CL005', 'M009', '2026-08-12T10:00:00', 'Attended'),
    ('CL005', 'M010', '2026-08-20T12:00:00', 'Attended'),
    ('CL006', 'M002', '2026-08-15T10:00:00', 'Attended'),
    ('CL006', 'M005', '2026-08-15T11:00:00', 'Attended'),
    ('CL006', 'M007', '2026-08-16T10:00:00', 'No Show'),
    ('CL006', 'M009', '2026-08-16T11:00:00', 'Attended'),
    ('CL007', 'M001', '2026-08-21T08:00:00', 'Attended'),
    ('CL007', 'M006', '2026-08-21T09:00:00', 'Attended'),
    ('CL007', 'M010', '2026-08-22T10:00:00', 'No Show'),
    ('CL008', 'M005', '2026-08-23T09:00:00', 'Attended'),
    ('CL008', 'M007', '2026-08-23T10:00:00', 'Attended'),
    ('CL008', 'M009', '2026-08-24T11:00:00', 'Attended'),
    ('CL008', 'M010', '2026-08-24T12:00:00', 'Cancelled');


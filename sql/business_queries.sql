-- name: executive_summary
WITH current_memberships AS (
    SELECT *
    FROM memberships
    WHERE membership_status IN ('Active', 'Frozen')
      AND start_date <= :as_of
      AND (end_date IS NULL OR end_date >= :as_of)
), class_stats AS (
    SELECT
        SUM(CASE WHEN ce.attendance_status = 'Attended' THEN 1 ELSE 0 END) AS attended,
        SUM(CASE WHEN ce.attendance_status = 'No Show' THEN 1 ELSE 0 END) AS no_shows,
        SUM(CASE WHEN ce.attendance_status IN ('Attended', 'No Show') THEN 1 ELSE 0 END) AS decided
    FROM class_enrollments AS ce
    JOIN fitness_classes AS fc ON fc.class_id = ce.class_id
    WHERE date(fc.starts_at) BETWEEN :report_start AND :report_end
)
SELECT
    SUM(CASE WHEN membership_status = 'Active' THEN 1 ELSE 0 END) AS active_members,
    SUM(CASE WHEN membership_status = 'Frozen' THEN 1 ELSE 0 END) AS frozen_members,
    (SELECT ROUND(SUM(amount_cents) / 100.0, 2)
     FROM payments
     WHERE payment_status = 'Completed'
       AND payment_date BETWEEN :report_start AND :report_end) AS collected_revenue,
    (SELECT ROUND(100.0 * AVG(CASE WHEN payment_status = 'Completed' THEN 1.0 ELSE 0.0 END), 1)
     FROM payments
     WHERE payment_date BETWEEN :report_start AND :report_end) AS payment_success_pct,
    (SELECT ROUND(100.0 * attended / NULLIF(decided, 0), 1) FROM class_stats) AS attendance_pct
FROM current_memberships;

-- name: membership_mix
SELECT
    mp.plan_name,
    COUNT(*) AS current_members,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS share_pct,
    ROUND(SUM(ms.agreed_price_cents) / 100.0, 2) AS contracted_value
FROM memberships AS ms
JOIN membership_plans AS mp ON mp.plan_id = ms.plan_id
WHERE ms.membership_status IN ('Active', 'Frozen')
  AND ms.start_date <= :as_of
  AND (ms.end_date IS NULL OR ms.end_date >= :as_of)
GROUP BY mp.plan_id, mp.plan_name
ORDER BY current_members DESC, mp.plan_name;

-- name: payment_status
SELECT
    payment_status,
    COUNT(*) AS payment_count,
    ROUND(SUM(amount_cents) / 100.0, 2) AS amount
FROM payments
WHERE payment_date BETWEEN :report_start AND :report_end
GROUP BY payment_status
ORDER BY CASE payment_status
    WHEN 'Completed' THEN 1
    WHEN 'Pending' THEN 2
    WHEN 'Failed' THEN 3
    WHEN 'Refunded' THEN 4
END;

-- name: class_performance
SELECT
    fc.class_id,
    fc.class_name,
    t.first_name || ' ' || t.last_name AS trainer,
    fc.capacity,
    SUM(CASE WHEN ce.attendance_status IN ('Attended', 'No Show') THEN 1 ELSE 0 END) AS occupied_spots,
    SUM(CASE WHEN ce.attendance_status = 'Attended' THEN 1 ELSE 0 END) AS attended,
    SUM(CASE WHEN ce.attendance_status = 'No Show' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(100.0 * SUM(CASE WHEN ce.attendance_status IN ('Attended', 'No Show') THEN 1 ELSE 0 END)
          / fc.capacity, 1) AS utilization_pct
FROM fitness_classes AS fc
JOIN trainers AS t ON t.trainer_id = fc.trainer_id
LEFT JOIN class_enrollments AS ce ON ce.class_id = fc.class_id
WHERE date(fc.starts_at) BETWEEN :report_start AND :report_end
  AND fc.class_status = 'Completed'
GROUP BY fc.class_id, fc.class_name, trainer, fc.capacity
ORDER BY utilization_pct DESC, fc.starts_at;

-- name: trainer_workload
SELECT
    t.first_name || ' ' || t.last_name AS trainer,
    t.specialty,
    COUNT(DISTINCT fc.class_id) AS classes_led,
    SUM(CASE WHEN ce.attendance_status = 'Attended' THEN 1 ELSE 0 END) AS total_attendance
FROM trainers AS t
LEFT JOIN fitness_classes AS fc
    ON fc.trainer_id = t.trainer_id
   AND date(fc.starts_at) BETWEEN :report_start AND :report_end
   AND fc.class_status = 'Completed'
LEFT JOIN class_enrollments AS ce ON ce.class_id = fc.class_id
WHERE t.active = 1
GROUP BY t.trainer_id, trainer, t.specialty
ORDER BY classes_led DESC, trainer;

-- name: members_for_follow_up
WITH current_members AS (
    SELECT m.member_id, m.first_name, m.last_name, ms.membership_id
    FROM members AS m
    JOIN memberships AS ms ON ms.member_id = m.member_id
    WHERE ms.membership_status IN ('Active', 'Frozen')
      AND ms.start_date <= :as_of
      AND (ms.end_date IS NULL OR ms.end_date >= :as_of)
), member_activity AS (
    SELECT
        member_id,
        MAX(CASE WHEN attendance_status = 'Attended' THEN date(fc.starts_at) END) AS last_attended
    FROM class_enrollments AS ce
    JOIN fitness_classes AS fc ON fc.class_id = ce.class_id
    WHERE date(fc.starts_at) <= :as_of
    GROUP BY member_id
), payment_issues AS (
    SELECT
        membership_id,
        SUM(CASE WHEN payment_status IN ('Failed', 'Pending') THEN 1 ELSE 0 END) AS issue_count
    FROM payments
    WHERE payment_date BETWEEN :report_start AND :report_end
    GROUP BY membership_id
)
SELECT
    cm.member_id,
    cm.first_name || ' ' || cm.last_name AS member_name,
    COALESCE(ma.last_attended, 'Never') AS last_attended,
    COALESCE(pi.issue_count, 0) AS payment_issues,
    CASE
        WHEN COALESCE(pi.issue_count, 0) > 0 AND ma.last_attended IS NULL THEN 'Payment and engagement'
        WHEN COALESCE(pi.issue_count, 0) > 0 THEN 'Payment'
        ELSE 'Engagement'
    END AS follow_up_reason
FROM current_members AS cm
LEFT JOIN member_activity AS ma ON ma.member_id = cm.member_id
LEFT JOIN payment_issues AS pi ON pi.membership_id = cm.membership_id
WHERE COALESCE(pi.issue_count, 0) > 0
   OR ma.last_attended IS NULL
ORDER BY payment_issues DESC, member_name;


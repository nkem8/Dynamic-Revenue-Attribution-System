-- STEP 1: Create Indexes for Performance Optimization
--CREATE INDEX idx_user_journey_user_time ON user_journey(user_id, timestamp);
--CREATE INDEX idx_conversions_user_time ON conversions(user_id, conversion_time);

-- STEP 2: Create a Parameter Table for Attribution Model Selection
DROP TABLE IF EXISTS attribution_model_selection;
CREATE TABLE attribution_model_selection (
    model_name VARCHAR(50) PRIMARY KEY
);

-- Insert default model (change this value to switch dynamically)
INSERT INTO attribution_model_selection (model_name) VALUES ('linear');

-- STEP 3: Common User Journey Join and Ranking
WITH joined AS (
    SELECT
        uj.user_id,
        uj.timestamp AS touch_time,
        uj.channel,
        c.conversion_time,
        c.revenue
    FROM user_journey uj
    JOIN conversions c ON uj.user_id = c.user_id
    WHERE uj.timestamp <= c.conversion_time
),
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY user_id, conversion_time ORDER BY touch_time) AS touch_rank,
        COUNT(*) OVER (PARTITION BY user_id, conversion_time) AS total_touches,
        LAG(channel) OVER (PARTITION BY user_id, conversion_time ORDER BY touch_time) AS previous_channel,
        LEAD(channel) OVER (PARTITION BY user_id, conversion_time ORDER BY touch_time) AS next_channel,
        EXTRACT(EPOCH FROM (conversion_time - touch_time)) / 3600 AS hours_before_conversion
    FROM joined
),

-- STEP 4: Attribution Models
first_touch AS (
    SELECT
        user_id,
        channel,
        conversion_time,
        revenue AS revenue_contribution,
        'first_touch' AS model_name
    FROM ranked
    WHERE touch_rank = 1
),

last_touch AS (
    SELECT
        user_id,
        channel,
        conversion_time,
        revenue AS revenue_contribution,
        'last_touch' AS model_name
    FROM ranked
    WHERE touch_rank = total_touches
),

linear AS (
    SELECT
        user_id,
        channel,
        conversion_time,
        revenue / total_touches AS revenue_contribution,
        'linear' AS model_name
    FROM ranked
),

time_decay AS (
    SELECT
        user_id,
        channel,
        conversion_time,
        revenue * EXP(-0.05 * hours_before_conversion) / 
            SUM(EXP(-0.05 * hours_before_conversion)) OVER (PARTITION BY user_id, conversion_time) AS revenue_contribution,
        'time_decay' AS model_name
    FROM ranked
),

-- STEP 5: Combine All Attribution Models
all_models AS (
    SELECT * FROM first_touch
    UNION ALL
    SELECT * FROM last_touch
    UNION ALL
    SELECT * FROM linear
    UNION ALL
    SELECT * FROM time_decay
)

-- STEP 6: Select Attribution Model Dynamically
--selected_model AS (
--    SELECT model_name FROM attribution_model_selection LIMIT 1)

-- STEP 7: Output Final Attribution Table
SELECT
    a.user_id,
    a.channel,
    a.conversion_time,
    ROUND(SUM(a.revenue_contribution), 2) AS total_attributed_revenue,
    a.model_name
FROM all_models a
-- REMOVE this line:
-- JOIN selected_model sm ON a.model_name = sm.model_name
GROUP BY a.user_id, a.channel, a.conversion_time, a.model_name
ORDER BY a.user_id, total_attributed_revenue DESC;

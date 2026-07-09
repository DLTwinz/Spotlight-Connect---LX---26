-- Function to automatically log attribution upon mission completion
CREATE OR REPLACE FUNCTION log_mission_attribution()
RETURNS TRIGGER AS $$
DECLARE
    v_brand_id UUID;
    v_creator_id UUID;
    v_admin_id UUID;
BEGIN
    -- Only trigger when a mission transitions to 'claimed'
    IF NEW.status = 'claimed' AND (OLD.status IS DISTINCT FROM 'claimed') THEN
        
        -- 1. Fetch the brand_id and creator_id by joining the mission and campaign tables
        SELECT c.brand_id, c.creator_id INTO v_brand_id, v_creator_id
        FROM missions m
        JOIN campaigns c ON m.campaign_id = c.id
        WHERE m.id = NEW.mission_id
        LIMIT 1;

        -- 2. Fetch or default an admin/system identifier
        -- Adjust this query to match your specific profiles or roles table structure
        SELECT id INTO v_admin_id 
        FROM auth.users 
        WHERE raw_user_meta_data->>'role' = 'admin' 
        LIMIT 1;

        -- Fallback default system UUID if no explicit admin profile is found
        IF v_admin_id IS NULL THEN
            v_admin_id := '00000000-0000-0000-0000-000000000000';
        END IF;

        -- 3. Enforce the 4-Pillar Validation at the database level
        IF v_brand_id IS NOT NULL AND v_creator_id IS NOT NULL AND NEW.user_id IS NOT NULL THEN
            INSERT INTO attribution_ledger (admin_id, fan_id, creator_id, brand_id)
            VALUES (v_admin_id, NEW.user_id, v_creator_id, v_brand_id);
        END IF;

    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach the trigger to the user_missions table
DROP TRIGGER IF EXISTS trigger_log_mission_attribution ON user_missions;
CREATE TRIGGER trigger_log_mission_attribution
    AFTER UPDATE ON user_missions
    FOR EACH ROW
    EXECUTE FUNCTION log_mission_attribution();

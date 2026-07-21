# Live identity schema contract

## profiles
- user_id: uuid, unique
- active_role: audience | talent | business | admin
- approved: boolean
- requested_role_pending: talent | business | null
- application_status_summary: none | pending | approved | rejected
- approved_roles: jsonb array
- onboarding_complete: boolean
- is_admin: boolean
- admin_role_edit_enabled: boolean

## user_roles
- user_id: uuid
- role_key: fan | creator | brand | admin
- is_active: boolean
- granted_at: timestamptz
- granted_by: uuid | null
- unique(user_id, role_key)

## mapping
- audience -> fan
- talent -> creator
- business -> brand
- admin -> admin

## trigger rules
- active_role cannot change after signup unless admin_role_edit_enabled = true

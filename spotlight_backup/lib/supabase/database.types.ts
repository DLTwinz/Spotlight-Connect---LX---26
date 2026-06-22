export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      admin_audit_log: {
        Row: {
          action: string
          admin_user_id: string
          created_at: string
          id: string
          payload_json: Json
          target_id: string | null
          target_type: string
        }
        Insert: {
          action: string
          admin_user_id: string
          created_at?: string
          id?: string
          payload_json?: Json
          target_id?: string | null
          target_type: string
        }
        Update: {
          action?: string
          admin_user_id?: string
          created_at?: string
          id?: string
          payload_json?: Json
          target_id?: string | null
          target_type?: string
        }
        Relationships: [
          {
            foreignKeyName: "admin_audit_log_admin_user_id_fkey"
            columns: ["admin_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      admin_role_audit_logs: {
        Row: {
          action: string
          actor_is_service_role: boolean
          actor_user_id: string | null
          created_at: string
          id: number
          new_active_role: string | null
          new_approved_roles: string[] | null
          new_base_role: string | null
          old_active_role: string | null
          old_approved_roles: string[] | null
          old_base_role: string | null
          target_user_id: string
        }
        Insert: {
          action: string
          actor_is_service_role?: boolean
          actor_user_id?: string | null
          created_at?: string
          id?: never
          new_active_role?: string | null
          new_approved_roles?: string[] | null
          new_base_role?: string | null
          old_active_role?: string | null
          old_approved_roles?: string[] | null
          old_base_role?: string | null
          target_user_id: string
        }
        Update: {
          action?: string
          actor_is_service_role?: boolean
          actor_user_id?: string | null
          created_at?: string
          id?: never
          new_active_role?: string | null
          new_approved_roles?: string[] | null
          new_base_role?: string | null
          old_active_role?: string | null
          old_approved_roles?: string[] | null
          old_base_role?: string | null
          target_user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "admin_role_audit_logs_target_user_id_fkey"
            columns: ["target_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      applications: {
        Row: {
          id: string
          opportunity_id: string
          pitch_text: string | null
          status: string
          submitted_at: string
          talent_user_id: string
          updated_at: string
        }
        Insert: {
          id?: string
          opportunity_id: string
          pitch_text?: string | null
          status?: string
          submitted_at?: string
          talent_user_id: string
          updated_at?: string
        }
        Update: {
          id?: string
          opportunity_id?: string
          pitch_text?: string | null
          status?: string
          submitted_at?: string
          talent_user_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "applications_opportunity_id_fkey"
            columns: ["opportunity_id"]
            isOneToOne: false
            referencedRelation: "opportunities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "applications_talent_user_id_fkey"
            columns: ["talent_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      approvals: {
        Row: {
          created_at: string
          decision: string
          id: string
          reason: string | null
          requested_role: string | null
          reviewed_by_user_id: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          decision?: string
          id?: string
          reason?: string | null
          requested_role?: string | null
          reviewed_by_user_id?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          decision?: string
          id?: string
          reason?: string | null
          requested_role?: string | null
          reviewed_by_user_id?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "approvals_reviewed_by_user_id_fkey"
            columns: ["reviewed_by_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "approvals_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      audience_profiles: {
        Row: {
          community_visibility: string
          created_at: string
          id: string
          interest_tags: string[]
          supporter_bio: string | null
          supporter_name: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          community_visibility?: string
          created_at?: string
          id?: string
          interest_tags?: string[]
          supporter_bio?: string | null
          supporter_name?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          community_visibility?: string
          created_at?: string
          id?: string
          interest_tags?: string[]
          supporter_bio?: string | null
          supporter_name?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "audience_profiles_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      behavior_graph_events: {
        Row: {
          actor_user_id: string
          created_at: string
          event_type: string
          event_weight: number
          id: string
          target_id: string
          target_type: string
        }
        Insert: {
          actor_user_id: string
          created_at?: string
          event_type: string
          event_weight?: number
          id?: string
          target_id: string
          target_type: string
        }
        Update: {
          actor_user_id?: string
          created_at?: string
          event_type?: string
          event_weight?: number
          id?: string
          target_id?: string
          target_type?: string
        }
        Relationships: [
          {
            foreignKeyName: "behavior_graph_events_actor_user_id_fkey"
            columns: ["actor_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      business_profiles: {
        Row: {
          business_type: string | null
          company_name: string | null
          created_at: string
          id: string
          industry_tags: string[]
          team_size: string | null
          updated_at: string
          user_id: string
          verification_state: string
        }
        Insert: {
          business_type?: string | null
          company_name?: string | null
          created_at?: string
          id?: string
          industry_tags?: string[]
          team_size?: string | null
          updated_at?: string
          user_id: string
          verification_state?: string
        }
        Update: {
          business_type?: string | null
          company_name?: string | null
          created_at?: string
          id?: string
          industry_tags?: string[]
          team_size?: string | null
          updated_at?: string
          user_id?: string
          verification_state?: string
        }
        Relationships: [
          {
            foreignKeyName: "business_profiles_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      campaign_missions: {
        Row: {
          campaign_id: string
          created_at: string
          mission_id: string
          sort_order: number
        }
        Insert: {
          campaign_id: string
          created_at?: string
          mission_id: string
          sort_order?: number
        }
        Update: {
          campaign_id?: string
          created_at?: string
          mission_id?: string
          sort_order?: number
        }
        Relationships: [
          {
            foreignKeyName: "campaign_missions_campaign_id_fkey"
            columns: ["campaign_id"]
            isOneToOne: false
            referencedRelation: "campaigns"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "campaign_missions_mission_id_fkey"
            columns: ["mission_id"]
            isOneToOne: false
            referencedRelation: "missions"
            referencedColumns: ["id"]
          },
        ]
      }
      campaign_participants: {
        Row: {
          campaign_id: string
          created_at: string
          id: string
          participant_role: string
          status: string
          updated_at: string
          user_id: string
        }
        Insert: {
          campaign_id: string
          created_at?: string
          id?: string
          participant_role: string
          status?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          campaign_id?: string
          created_at?: string
          id?: string
          participant_role?: string
          status?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "campaign_participants_campaign_id_fkey"
            columns: ["campaign_id"]
            isOneToOne: false
            referencedRelation: "campaigns"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "campaign_participants_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      campaigns: {
        Row: {
          budget_range: string | null
          business_user_id: string
          created_at: string
          description: string | null
          eligibility_json: Json
          end_at: string | null
          end_date: string | null
          ends_at: string | null
          featured_rank: number | null
          hero_image_url: string | null
          id: string
          objective_type: string | null
          owner_user_id: string | null
          primary_actions: string[]
          primary_audience: string | null
          priority: number
          reward_json: Json
          slug: string | null
          start_at: string | null
          start_date: string | null
          starts_at: string | null
          status: string
          summary: string | null
          title: string
          updated_at: string
          visibility: string
        }
        Insert: {
          budget_range?: string | null
          business_user_id: string
          created_at?: string
          description?: string | null
          eligibility_json?: Json
          end_at?: string | null
          end_date?: string | null
          ends_at?: string | null
          featured_rank?: number | null
          hero_image_url?: string | null
          id?: string
          objective_type?: string | null
          owner_user_id?: string | null
          primary_actions?: string[]
          primary_audience?: string | null
          priority?: number
          reward_json?: Json
          slug?: string | null
          start_at?: string | null
          start_date?: string | null
          starts_at?: string | null
          status?: string
          summary?: string | null
          title: string
          updated_at?: string
          visibility?: string
        }
        Update: {
          budget_range?: string | null
          business_user_id?: string
          created_at?: string
          description?: string | null
          eligibility_json?: Json
          end_at?: string | null
          end_date?: string | null
          ends_at?: string | null
          featured_rank?: number | null
          hero_image_url?: string | null
          id?: string
          objective_type?: string | null
          owner_user_id?: string | null
          primary_actions?: string[]
          primary_audience?: string | null
          priority?: number
          reward_json?: Json
          slug?: string | null
          start_at?: string | null
          start_date?: string | null
          starts_at?: string | null
          status?: string
          summary?: string | null
          title?: string
          updated_at?: string
          visibility?: string
        }
        Relationships: [
          {
            foreignKeyName: "campaigns_business_user_id_fkey"
            columns: ["business_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      comments: {
        Row: {
          author_id: string
          body: string
          created_at: string
          id: string
          post_id: string
          updated_at: string
        }
        Insert: {
          author_id: string
          body: string
          created_at?: string
          id?: string
          post_id: string
          updated_at?: string
        }
        Update: {
          author_id?: string
          body?: string
          created_at?: string
          id?: string
          post_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "comments_author_id_fkey"
            columns: ["author_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "comments_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "posts"
            referencedColumns: ["id"]
          },
        ]
      }
      community_roles: {
        Row: {
          created_at: string
          description: string | null
          id: string
          name: string
          role_scope: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          id?: string
          name: string
          role_scope?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: string
          name?: string
          role_scope?: string
        }
        Relationships: []
      }
      creator_payout_profiles: {
        Row: {
          created_at: string
          display_name: string
          payout_handle: string
          payout_method: string
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          display_name?: string
          payout_handle?: string
          payout_method?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          display_name?: string
          payout_handle?: string
          payout_method?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "creator_payout_profiles_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      creator_subscriptions: {
        Row: {
          created_at: string
          creator_user_id: string
          plan_id: string | null
          status: string
          subscriber_user_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          creator_user_id: string
          plan_id?: string | null
          status?: string
          subscriber_user_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          creator_user_id?: string
          plan_id?: string | null
          status?: string
          subscriber_user_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "creator_subscriptions_creator_user_id_fkey"
            columns: ["creator_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "creator_subscriptions_plan_id_fkey"
            columns: ["plan_id"]
            isOneToOne: false
            referencedRelation: "subscription_plans"
            referencedColumns: ["plan_id"]
          },
          {
            foreignKeyName: "creator_subscriptions_subscriber_user_id_fkey"
            columns: ["subscriber_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      early_access_requests: {
        Row: {
          created_at: string
          desired_role: string | null
          email: string
          id: string
          name: string | null
          note: string | null
          review_note: string | null
          status: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          desired_role?: string | null
          email: string
          id?: string
          name?: string | null
          note?: string | null
          review_note?: string | null
          status?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          desired_role?: string | null
          email?: string
          id?: string
          name?: string | null
          note?: string | null
          review_note?: string | null
          status?: string
          updated_at?: string
        }
        Relationships: []
      }
      early_access_unlocks: {
        Row: {
          created_at: string
          id: string
          target_id: string | null
          unlock_status: string
          unlock_type: string
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          target_id?: string | null
          unlock_status?: string
          unlock_type: string
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          target_id?: string | null
          unlock_status?: string
          unlock_type?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "early_access_unlocks_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      feature_policies: {
        Row: {
          created_at: string
          id: string
          is_enabled: boolean
          policy: Json
          role_key: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          is_enabled?: boolean
          policy: Json
          role_key: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          is_enabled?: boolean
          policy?: Json
          role_key?: string
          updated_at?: string
        }
        Relationships: []
      }
      feature_policy_audit: {
        Row: {
          action: string
          actor_user_id: string | null
          after: Json | null
          before: Json | null
          created_at: string
          entity_key: string
          entity_type: string
          id: string
          updated_at: string
        }
        Insert: {
          action: string
          actor_user_id?: string | null
          after?: Json | null
          before?: Json | null
          created_at?: string
          entity_key: string
          entity_type: string
          id?: string
          updated_at?: string
        }
        Update: {
          action?: string
          actor_user_id?: string | null
          after?: Json | null
          before?: Json | null
          created_at?: string
          entity_key?: string
          entity_type?: string
          id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "feature_policy_audit_actor_user_id_fkey"
            columns: ["actor_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      group_members: {
        Row: {
          created_at: string
          group_id: string
          id: string
          role: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          group_id: string
          id?: string
          role?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          group_id?: string
          id?: string
          role?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "group_members_group_id_fkey"
            columns: ["group_id"]
            isOneToOne: false
            referencedRelation: "groups"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "group_members_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      group_memberships: {
        Row: {
          group_id: string
          joined_at: string
          role: string
          user_id: string
        }
        Insert: {
          group_id: string
          joined_at?: string
          role?: string
          user_id: string
        }
        Update: {
          group_id?: string
          joined_at?: string
          role?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "group_memberships_group_id_fkey"
            columns: ["group_id"]
            isOneToOne: false
            referencedRelation: "groups"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "group_memberships_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      groups: {
        Row: {
          created_at: string
          created_by_user_id: string
          description: string
          id: string
          name: string
          updated_at: string
          visibility: string
        }
        Insert: {
          created_at?: string
          created_by_user_id: string
          description?: string
          id?: string
          name: string
          updated_at?: string
          visibility?: string
        }
        Update: {
          created_at?: string
          created_by_user_id?: string
          description?: string
          id?: string
          name?: string
          updated_at?: string
          visibility?: string
        }
        Relationships: [
          {
            foreignKeyName: "groups_created_by_user_id_fkey"
            columns: ["created_by_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      kill_switches: {
        Row: {
          created_at: string
          id: string
          is_enabled: boolean
          key: string
          reason: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          is_enabled?: boolean
          key: string
          reason?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          is_enabled?: boolean
          key?: string
          reason?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      live_sessions: {
        Row: {
          broadcast_method: string
          broadcaster_display_name: string | null
          broadcaster_user_id: string | null
          campaign_id: string | null
          created_at: string
          description: string
          ended_at: string | null
          external_stream_url: string | null
          host_user_id: string
          id: string
          livekit_room: string | null
          room_name: string
          rtmp_ingest_url: string | null
          rtmp_stream_key: string | null
          scheduled_for: string
          started_at: string | null
          status: string
          title: string
          updated_at: string
        }
        Insert: {
          broadcast_method?: string
          broadcaster_display_name?: string | null
          broadcaster_user_id?: string | null
          campaign_id?: string | null
          created_at?: string
          description?: string
          ended_at?: string | null
          external_stream_url?: string | null
          host_user_id: string
          id?: string
          livekit_room?: string | null
          room_name: string
          rtmp_ingest_url?: string | null
          rtmp_stream_key?: string | null
          scheduled_for: string
          started_at?: string | null
          status?: string
          title?: string
          updated_at?: string
        }
        Update: {
          broadcast_method?: string
          broadcaster_display_name?: string | null
          broadcaster_user_id?: string | null
          campaign_id?: string | null
          created_at?: string
          description?: string
          ended_at?: string | null
          external_stream_url?: string | null
          host_user_id?: string
          id?: string
          livekit_room?: string | null
          room_name?: string
          rtmp_ingest_url?: string | null
          rtmp_stream_key?: string | null
          scheduled_for?: string
          started_at?: string | null
          status?: string
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "live_sessions_broadcaster_user_id_fkey"
            columns: ["broadcaster_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "live_sessions_campaign_id_fkey"
            columns: ["campaign_id"]
            isOneToOne: false
            referencedRelation: "campaigns"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "live_sessions_host_user_id_fkey"
            columns: ["host_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      message_threads: {
        Row: {
          created_at: string
          last_message_preview: string | null
          last_read_at_by_user_id: Json
          last_sender_user_id: string | null
          opportunity_id: string | null
          participant_emails: Json
          participant_names: Json
          participant_user_ids: string[]
          thread_id: string
          unread_counts: Json
          updated_at: string
        }
        Insert: {
          created_at?: string
          last_message_preview?: string | null
          last_read_at_by_user_id?: Json
          last_sender_user_id?: string | null
          opportunity_id?: string | null
          participant_emails?: Json
          participant_names?: Json
          participant_user_ids: string[]
          thread_id: string
          unread_counts?: Json
          updated_at?: string
        }
        Update: {
          created_at?: string
          last_message_preview?: string | null
          last_read_at_by_user_id?: Json
          last_sender_user_id?: string | null
          opportunity_id?: string | null
          participant_emails?: Json
          participant_names?: Json
          participant_user_ids?: string[]
          thread_id?: string
          unread_counts?: Json
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "message_threads_last_sender_user_id_fkey"
            columns: ["last_sender_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      messages: {
        Row: {
          body: string
          created_at: string
          id: string
          sender_name: string
          sender_user_id: string
          thread_id: string
        }
        Insert: {
          body: string
          created_at?: string
          id?: string
          sender_name?: string
          sender_user_id: string
          thread_id: string
        }
        Update: {
          body?: string
          created_at?: string
          id?: string
          sender_name?: string
          sender_user_id?: string
          thread_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "messages_sender_user_id_fkey"
            columns: ["sender_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "messages_thread_id_fkey"
            columns: ["thread_id"]
            isOneToOne: false
            referencedRelation: "message_threads"
            referencedColumns: ["thread_id"]
          },
        ]
      }
      milestones: {
        Row: {
          active: boolean
          badge_reward_code: string | null
          category: string
          code: string | null
          created_at: string
          description: string
          id: string
          key: string
          prestige_reward: number
          requirements_json: Json
          reward_json: Json
          tier_unlock: string | null
          title: string
          updated_at: string
        }
        Insert: {
          active?: boolean
          badge_reward_code?: string | null
          category?: string
          code?: string | null
          created_at?: string
          description?: string
          id?: string
          key: string
          prestige_reward?: number
          requirements_json?: Json
          reward_json?: Json
          tier_unlock?: string | null
          title: string
          updated_at?: string
        }
        Update: {
          active?: boolean
          badge_reward_code?: string | null
          category?: string
          code?: string | null
          created_at?: string
          description?: string
          id?: string
          key?: string
          prestige_reward?: number
          requirements_json?: Json
          reward_json?: Json
          tier_unlock?: string | null
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      missions: {
        Row: {
          action_type: string | null
          badge_reward_code: string | null
          campaign_id: string | null
          category: string | null
          created_at: string
          description: string
          eligibility_min_tier: string | null
          eligibility_role: string | null
          end_at: string | null
          icon_key: string
          id: string
          mission_type: Database["public"]["Enums"]["mission_type"]
          prestige_reward: number
          repeat_interval: string | null
          repeatable: boolean
          requirements_json: Json
          requires_manual_review: boolean
          reward_json: Json
          short_label: string | null
          start_at: string | null
          status: Database["public"]["Enums"]["mission_status"]
          subtitle: string
          target_metric: string
          target_value: number
          tier_progress_weight: number
          time_window: string | null
          title: string
          updated_at: string
          visibility: string
          visible_from: string | null
          visible_until: string | null
        }
        Insert: {
          action_type?: string | null
          badge_reward_code?: string | null
          campaign_id?: string | null
          category?: string | null
          created_at?: string
          description?: string
          eligibility_min_tier?: string | null
          eligibility_role?: string | null
          end_at?: string | null
          icon_key?: string
          id?: string
          mission_type: Database["public"]["Enums"]["mission_type"]
          prestige_reward?: number
          repeat_interval?: string | null
          repeatable?: boolean
          requirements_json?: Json
          requires_manual_review?: boolean
          reward_json?: Json
          short_label?: string | null
          start_at?: string | null
          status?: Database["public"]["Enums"]["mission_status"]
          subtitle?: string
          target_metric: string
          target_value: number
          tier_progress_weight?: number
          time_window?: string | null
          title: string
          updated_at?: string
          visibility?: string
          visible_from?: string | null
          visible_until?: string | null
        }
        Update: {
          action_type?: string | null
          badge_reward_code?: string | null
          campaign_id?: string | null
          category?: string | null
          created_at?: string
          description?: string
          eligibility_min_tier?: string | null
          eligibility_role?: string | null
          end_at?: string | null
          icon_key?: string
          id?: string
          mission_type?: Database["public"]["Enums"]["mission_type"]
          prestige_reward?: number
          repeat_interval?: string | null
          repeatable?: boolean
          requirements_json?: Json
          requires_manual_review?: boolean
          reward_json?: Json
          short_label?: string | null
          start_at?: string | null
          status?: Database["public"]["Enums"]["mission_status"]
          subtitle?: string
          target_metric?: string
          target_value?: number
          tier_progress_weight?: number
          time_window?: string | null
          title?: string
          updated_at?: string
          visibility?: string
          visible_from?: string | null
          visible_until?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "missions_campaign_id_fkey"
            columns: ["campaign_id"]
            isOneToOne: false
            referencedRelation: "campaigns"
            referencedColumns: ["id"]
          },
        ]
      }
      monetization_transactions: {
        Row: {
          amount_usd: number
          created_at: string
          from_user_id: string
          metadata: Json | null
          to_user_id: string
          transaction_id: string
          type: string
          updated_at: string
        }
        Insert: {
          amount_usd?: number
          created_at?: string
          from_user_id: string
          metadata?: Json | null
          to_user_id: string
          transaction_id: string
          type: string
          updated_at?: string
        }
        Update: {
          amount_usd?: number
          created_at?: string
          from_user_id?: string
          metadata?: Json | null
          to_user_id?: string
          transaction_id?: string
          type?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "monetization_transactions_from_user_id_fkey"
            columns: ["from_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "monetization_transactions_to_user_id_fkey"
            columns: ["to_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      notifications: {
        Row: {
          body: string
          created_at: string
          entity_id: string | null
          entity_type: string | null
          id: string
          read: boolean
          title: string
          type: string
          user_id: string
        }
        Insert: {
          body: string
          created_at?: string
          entity_id?: string | null
          entity_type?: string | null
          id?: string
          read?: boolean
          title: string
          type: string
          user_id: string
        }
        Update: {
          body?: string
          created_at?: string
          entity_id?: string | null
          entity_type?: string | null
          id?: string
          read?: boolean
          title?: string
          type?: string
          user_id?: string
        }
        Relationships: []
      }
      opportunities: {
        Row: {
          approval_required: boolean
          business_user_id: string
          category: string
          compensation_type: string
          created_at: string
          description: string
          id: string
          location_type: string
          published_at: string | null
          status: string
          title: string
          updated_at: string
        }
        Insert: {
          approval_required?: boolean
          business_user_id: string
          category: string
          compensation_type: string
          created_at?: string
          description: string
          id?: string
          location_type: string
          published_at?: string | null
          status?: string
          title: string
          updated_at?: string
        }
        Update: {
          approval_required?: boolean
          business_user_id?: string
          category?: string
          compensation_type?: string
          created_at?: string
          description?: string
          id?: string
          location_type?: string
          published_at?: string | null
          status?: string
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "opportunities_business_user_id_fkey"
            columns: ["business_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      opportunity_applications: {
        Row: {
          applicant_user_id: string
          availability: string
          business_note: string
          created_at: string
          id: string
          opportunity_id: string
          pitch: string
          portfolio_links: string[]
          status: string
          updated_at: string
        }
        Insert: {
          applicant_user_id: string
          availability?: string
          business_note?: string
          created_at?: string
          id?: string
          opportunity_id: string
          pitch?: string
          portfolio_links?: string[]
          status?: string
          updated_at?: string
        }
        Update: {
          applicant_user_id?: string
          availability?: string
          business_note?: string
          created_at?: string
          id?: string
          opportunity_id?: string
          pitch?: string
          portfolio_links?: string[]
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "opportunity_applications_opportunity_id_fkey"
            columns: ["opportunity_id"]
            isOneToOne: false
            referencedRelation: "opportunities"
            referencedColumns: ["id"]
          },
        ]
      }
      opportunity_saves: {
        Row: {
          created_at: string
          opportunity_id: string
          user_id: string
        }
        Insert: {
          created_at?: string
          opportunity_id: string
          user_id: string
        }
        Update: {
          created_at?: string
          opportunity_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "opportunity_saves_opportunity_id_fkey"
            columns: ["opportunity_id"]
            isOneToOne: false
            referencedRelation: "opportunities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "opportunity_saves_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      portfolio_items: {
        Row: {
          created_at: string
          description: string | null
          id: string
          links: Json
          media_urls: Json
          title: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          id?: string
          links?: Json
          media_urls?: Json
          title?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: string
          links?: Json
          media_urls?: Json
          title?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "portfolio_items_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      portfolios: {
        Row: {
          created_at: string
          credits: Json
          day_rate_usd: number | null
          genres: string[]
          headline: string
          links: Json
          location: string
          media: string[]
          role: string
          skills: string[]
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          credits?: Json
          day_rate_usd?: number | null
          genres?: string[]
          headline?: string
          links?: Json
          location?: string
          media?: string[]
          role?: string
          skills?: string[]
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          credits?: Json
          day_rate_usd?: number | null
          genres?: string[]
          headline?: string
          links?: Json
          location?: string
          media?: string[]
          role?: string
          skills?: string[]
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "portfolios_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      post_comments: {
        Row: {
          author_id: string
          created_at: string
          id: string
          post_id: string
          text: string
        }
        Insert: {
          author_id: string
          created_at?: string
          id?: string
          post_id: string
          text: string
        }
        Update: {
          author_id?: string
          created_at?: string
          id?: string
          post_id?: string
          text?: string
        }
        Relationships: [
          {
            foreignKeyName: "post_comments_author_id_fkey"
            columns: ["author_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "post_comments_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "posts"
            referencedColumns: ["id"]
          },
        ]
      }
      post_reactions: {
        Row: {
          created_at: string
          post_id: string
          reaction: Database["public"]["Enums"]["post_reaction_type"]
          user_id: string
        }
        Insert: {
          created_at?: string
          post_id: string
          reaction: Database["public"]["Enums"]["post_reaction_type"]
          user_id: string
        }
        Update: {
          created_at?: string
          post_id?: string
          reaction?: Database["public"]["Enums"]["post_reaction_type"]
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "post_reactions_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "posts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "post_reactions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      post_saves: {
        Row: {
          created_at: string
          post_id: string
          user_id: string
        }
        Insert: {
          created_at?: string
          post_id: string
          user_id: string
        }
        Update: {
          created_at?: string
          post_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "post_saves_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "posts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "post_saves_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      posts: {
        Row: {
          author_id: string
          comment_count: number
          created_at: string
          group_id: string | null
          id: string
          like_count: number
          repost_count: number
          repost_of_post_id: string | null
          tags: string[]
          text: string
          updated_at: string
        }
        Insert: {
          author_id: string
          comment_count?: number
          created_at?: string
          group_id?: string | null
          id?: string
          like_count?: number
          repost_count?: number
          repost_of_post_id?: string | null
          tags?: string[]
          text: string
          updated_at?: string
        }
        Update: {
          author_id?: string
          comment_count?: number
          created_at?: string
          group_id?: string | null
          id?: string
          like_count?: number
          repost_count?: number
          repost_of_post_id?: string | null
          tags?: string[]
          text?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "posts_author_id_fkey"
            columns: ["author_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "posts_repost_of_post_id_fkey"
            columns: ["repost_of_post_id"]
            isOneToOne: false
            referencedRelation: "posts"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          active_role: string
          application_status_summary: string
          approved: boolean
          approved_roles: Json
          avatar_url: string | null
          bio: string | null
          cover_photo: string | null
          cover_url: string | null
          created_at: string
          display_name: string
          id: string
          is_public: boolean
          location: string | null
          onboarding_complete: boolean
          profile_photo: string | null
          requested_role_pending: string | null
          updated_at: string
          user_id: string
          username: string | null
          website_url: string | null
        }
        Insert: {
          active_role?: string
          application_status_summary?: string
          approved?: boolean
          approved_roles?: Json
          avatar_url?: string | null
          bio?: string | null
          cover_photo?: string | null
          cover_url?: string | null
          created_at?: string
          display_name?: string
          id?: string
          is_public?: boolean
          location?: string | null
          onboarding_complete?: boolean
          profile_photo?: string | null
          requested_role_pending?: string | null
          updated_at?: string
          user_id: string
          username?: string | null
          website_url?: string | null
        }
        Update: {
          active_role?: string
          application_status_summary?: string
          approved?: boolean
          approved_roles?: Json
          avatar_url?: string | null
          bio?: string | null
          cover_photo?: string | null
          cover_url?: string | null
          created_at?: string
          display_name?: string
          id?: string
          is_public?: boolean
          location?: string | null
          onboarding_complete?: boolean
          profile_photo?: string | null
          requested_role_pending?: string | null
          updated_at?: string
          user_id?: string
          username?: string | null
          website_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "profiles_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      reward_accounts: {
        Row: {
          created_at: string
          current_tier_id: string | null
          id: string
          points_balance: number
          status_points: number
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          current_tier_id?: string | null
          id?: string
          points_balance?: number
          status_points?: number
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          current_tier_id?: string | null
          id?: string
          points_balance?: number
          status_points?: number
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "reward_accounts_current_tier_id_fkey"
            columns: ["current_tier_id"]
            isOneToOne: false
            referencedRelation: "reward_tiers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reward_accounts_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      reward_badges: {
        Row: {
          badge_type: string
          created_at: string
          description: string | null
          id: string
          image_url: string | null
          name: string
        }
        Insert: {
          badge_type: string
          created_at?: string
          description?: string | null
          id?: string
          image_url?: string | null
          name: string
        }
        Update: {
          badge_type?: string
          created_at?: string
          description?: string | null
          id?: string
          image_url?: string | null
          name?: string
        }
        Relationships: []
      }
      reward_catalog: {
        Row: {
          created_at: string
          description: string | null
          id: string
          points_cost: number
          reward_type: string
          status: string
          tier_required_id: string | null
          title: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          id?: string
          points_cost?: number
          reward_type: string
          status?: string
          tier_required_id?: string | null
          title: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: string
          points_cost?: number
          reward_type?: string
          status?: string
          tier_required_id?: string | null
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "reward_catalog_tier_required_id_fkey"
            columns: ["tier_required_id"]
            isOneToOne: false
            referencedRelation: "reward_tiers"
            referencedColumns: ["id"]
          },
        ]
      }
      reward_redemptions: {
        Row: {
          created_at: string
          id: string
          redemption_status: string
          reward_catalog_id: string
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          redemption_status?: string
          reward_catalog_id: string
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          redemption_status?: string
          reward_catalog_id?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "reward_redemptions_reward_catalog_id_fkey"
            columns: ["reward_catalog_id"]
            isOneToOne: false
            referencedRelation: "reward_catalog"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reward_redemptions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      reward_tiers: {
        Row: {
          created_at: string
          description: string | null
          id: string
          min_status_points: number
          name: string
          perks_summary: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          id?: string
          min_status_points?: number
          name: string
          perks_summary?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: string
          min_status_points?: number
          name?: string
          perks_summary?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      reward_transactions: {
        Row: {
          created_at: string
          id: string
          points_amount: number
          reward_account_id: string
          source_id: string | null
          source_type: string
          transaction_type: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          points_amount: number
          reward_account_id: string
          source_id?: string | null
          source_type: string
          transaction_type: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          points_amount?: number
          reward_account_id?: string
          source_id?: string | null
          source_type?: string
          transaction_type?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "reward_transactions_reward_account_id_fkey"
            columns: ["reward_account_id"]
            isOneToOne: false
            referencedRelation: "reward_accounts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reward_transactions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      rewards: {
        Row: {
          created_at: string
          description: string | null
          id: string
          image_url: string | null
          kind: string | null
          metadata: Json
          title: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          id?: string
          image_url?: string | null
          kind?: string | null
          metadata?: Json
          title: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: string
          image_url?: string | null
          kind?: string | null
          metadata?: Json
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      role_applications: {
        Row: {
          created_at: string
          id: string
          note: string | null
          requested_role: string
          status: string
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          note?: string | null
          requested_role: string
          status?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          note?: string | null
          requested_role?: string
          status?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "role_applications_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      stories: {
        Row: {
          author_display_name: string
          author_id: string
          author_primary_role: string
          background_seed: number | null
          caption: string
          created_at: string
          expires_at: string
          id: string
        }
        Insert: {
          author_display_name: string
          author_id: string
          author_primary_role: string
          background_seed?: number | null
          caption?: string
          created_at?: string
          expires_at: string
          id?: string
        }
        Update: {
          author_display_name?: string
          author_id?: string
          author_primary_role?: string
          background_seed?: number | null
          caption?: string
          created_at?: string
          expires_at?: string
          id?: string
        }
        Relationships: [
          {
            foreignKeyName: "stories_author_id_fkey"
            columns: ["author_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      story_seen: {
        Row: {
          seen_at: string
          story_id: string
          user_id: string
        }
        Insert: {
          seen_at?: string
          story_id: string
          user_id: string
        }
        Update: {
          seen_at?: string
          story_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "story_seen_story_id_fkey"
            columns: ["story_id"]
            isOneToOne: false
            referencedRelation: "stories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "story_seen_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      studio_sessions: {
        Row: {
          created_at: string
          ended_at: string | null
          host_id: string
          id: string
          room_name: string | null
          started_at: string | null
          status: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          ended_at?: string | null
          host_id: string
          id?: string
          room_name?: string | null
          started_at?: string | null
          status?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          ended_at?: string | null
          host_id?: string
          id?: string
          room_name?: string | null
          started_at?: string | null
          status?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "studio_sessions_host_id_fkey"
            columns: ["host_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      subscription_plans: {
        Row: {
          created_at: string
          feature_bullets: string[]
          plan_id: string
          price_usd_monthly: number
          subtitle: string
          title: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          feature_bullets?: string[]
          plan_id: string
          price_usd_monthly?: number
          subtitle?: string
          title: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          feature_bullets?: string[]
          plan_id?: string
          price_usd_monthly?: number
          subtitle?: string
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      support_actions: {
        Row: {
          action_type: string
          action_value: number | null
          created_at: string
          id: string
          target_business_id: string | null
          target_user_id: string | null
          user_id: string
          verified_status: string
        }
        Insert: {
          action_type: string
          action_value?: number | null
          created_at?: string
          id?: string
          target_business_id?: string | null
          target_user_id?: string | null
          user_id: string
          verified_status?: string
        }
        Update: {
          action_type?: string
          action_value?: number | null
          created_at?: string
          id?: string
          target_business_id?: string | null
          target_user_id?: string | null
          user_id?: string
          verified_status?: string
        }
        Relationships: [
          {
            foreignKeyName: "support_actions_target_business_id_fkey"
            columns: ["target_business_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "support_actions_target_user_id_fkey"
            columns: ["target_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "support_actions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      support_challenge_participants: {
        Row: {
          challenge_id: string
          created_at: string
          id: string
          progress_value: number
          status: string
          updated_at: string
          user_id: string
        }
        Insert: {
          challenge_id: string
          created_at?: string
          id?: string
          progress_value?: number
          status?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          challenge_id?: string
          created_at?: string
          id?: string
          progress_value?: number
          status?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "support_challenge_participants_challenge_id_fkey"
            columns: ["challenge_id"]
            isOneToOne: false
            referencedRelation: "support_challenges"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "support_challenge_participants_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      support_challenges: {
        Row: {
          challenge_type: string
          created_at: string
          description: string | null
          id: string
          reward_type: string
          reward_value: string | null
          status: string
          title: string
          updated_at: string
        }
        Insert: {
          challenge_type: string
          created_at?: string
          description?: string | null
          id?: string
          reward_type: string
          reward_value?: string | null
          status?: string
          title: string
          updated_at?: string
        }
        Update: {
          challenge_type?: string
          created_at?: string
          description?: string | null
          id?: string
          reward_type?: string
          reward_value?: string | null
          status?: string
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      supporter_rooms: {
        Row: {
          access_rule: string
          created_at: string
          id: string
          owner_user_id: string
          room_type: string
          status: string
          tier_required_id: string | null
          title: string
          updated_at: string
        }
        Insert: {
          access_rule: string
          created_at?: string
          id?: string
          owner_user_id: string
          room_type: string
          status?: string
          tier_required_id?: string | null
          title: string
          updated_at?: string
        }
        Update: {
          access_rule?: string
          created_at?: string
          id?: string
          owner_user_id?: string
          room_type?: string
          status?: string
          tier_required_id?: string | null
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "supporter_rooms_owner_user_id_fkey"
            columns: ["owner_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "supporter_rooms_tier_required_id_fkey"
            columns: ["tier_required_id"]
            isOneToOne: false
            referencedRelation: "reward_tiers"
            referencedColumns: ["id"]
          },
        ]
      }
      talent_profiles: {
        Row: {
          availability_status: string
          categories: string[]
          created_at: string
          id: string
          portfolio_status: string
          rate_range: string | null
          skills: string[]
          stage_name: string | null
          updated_at: string
          user_id: string
          verification_state: string
        }
        Insert: {
          availability_status?: string
          categories?: string[]
          created_at?: string
          id?: string
          portfolio_status?: string
          rate_range?: string | null
          skills?: string[]
          stage_name?: string | null
          updated_at?: string
          user_id: string
          verification_state?: string
        }
        Update: {
          availability_status?: string
          categories?: string[]
          created_at?: string
          id?: string
          portfolio_status?: string
          rate_range?: string | null
          skills?: string[]
          stage_name?: string | null
          updated_at?: string
          user_id?: string
          verification_state?: string
        }
        Relationships: [
          {
            foreignKeyName: "talent_profiles_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      user_badges: {
        Row: {
          awarded_at: string
          badge_id: string
          id: string
          user_id: string
        }
        Insert: {
          awarded_at?: string
          badge_id: string
          id?: string
          user_id: string
        }
        Update: {
          awarded_at?: string
          badge_id?: string
          id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_badges_badge_id_fkey"
            columns: ["badge_id"]
            isOneToOne: false
            referencedRelation: "reward_badges"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_badges_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      user_campaign_memberships: {
        Row: {
          campaign_id: string
          created_at: string
          id: string
          joined_at: string
          updated_at: string
          user_id: string
        }
        Insert: {
          campaign_id: string
          created_at?: string
          id?: string
          joined_at?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          campaign_id?: string
          created_at?: string
          id?: string
          joined_at?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_campaign_memberships_campaign_id_fkey"
            columns: ["campaign_id"]
            isOneToOne: false
            referencedRelation: "campaigns"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_campaign_memberships_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      user_community_roles: {
        Row: {
          assigned_by_user_id: string | null
          community_role_id: string
          created_at: string
          id: string
          status: string
          updated_at: string
          user_id: string
        }
        Insert: {
          assigned_by_user_id?: string | null
          community_role_id: string
          created_at?: string
          id?: string
          status?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          assigned_by_user_id?: string | null
          community_role_id?: string
          created_at?: string
          id?: string
          status?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_community_roles_assigned_by_user_id_fkey"
            columns: ["assigned_by_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_community_roles_community_role_id_fkey"
            columns: ["community_role_id"]
            isOneToOne: false
            referencedRelation: "community_roles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_community_roles_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      user_follows: {
        Row: {
          created_at: string
          follower_user_id: string
          following_user_id: string
        }
        Insert: {
          created_at?: string
          follower_user_id: string
          following_user_id: string
        }
        Update: {
          created_at?: string
          follower_user_id?: string
          following_user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_follows_follower_user_id_fkey"
            columns: ["follower_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_follows_following_user_id_fkey"
            columns: ["following_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      user_milestones: {
        Row: {
          achieved_at: string | null
          claimed_at: string | null
          created_at: string
          id: string
          milestone_id: string
          prestige_earned: number
          source_event_id: string | null
          unlocked_at: string
          updated_at: string
          user_id: string
          visible_on_profile: boolean
        }
        Insert: {
          achieved_at?: string | null
          claimed_at?: string | null
          created_at?: string
          id?: string
          milestone_id: string
          prestige_earned?: number
          source_event_id?: string | null
          unlocked_at?: string
          updated_at?: string
          user_id: string
          visible_on_profile?: boolean
        }
        Update: {
          achieved_at?: string | null
          claimed_at?: string | null
          created_at?: string
          id?: string
          milestone_id?: string
          prestige_earned?: number
          source_event_id?: string | null
          unlocked_at?: string
          updated_at?: string
          user_id?: string
          visible_on_profile?: boolean
        }
        Relationships: [
          {
            foreignKeyName: "user_milestones_milestone_id_fkey"
            columns: ["milestone_id"]
            isOneToOne: false
            referencedRelation: "milestones"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_milestones_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      user_mission_progress: {
        Row: {
          completed_at: string | null
          created_at: string
          id: string
          mission_id: string
          progress: Json
          started_at: string | null
          status: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          completed_at?: string | null
          created_at?: string
          id?: string
          mission_id: string
          progress?: Json
          started_at?: string | null
          status?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          completed_at?: string | null
          created_at?: string
          id?: string
          mission_id?: string
          progress?: Json
          started_at?: string | null
          status?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_mission_progress_mission_id_fkey"
            columns: ["mission_id"]
            isOneToOne: false
            referencedRelation: "missions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_mission_progress_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      user_missions: {
        Row: {
          campaign_id: string | null
          claimed_at: string | null
          completed_at: string | null
          created_at: string
          current_value: number
          expires_at: string | null
          id: string
          last_progress_at: string | null
          mission_id: string
          prestige_earned: number
          progress_target: number
          progress_value: number
          started_at: string | null
          status: Database["public"]["Enums"]["mission_status"]
          target_value: number
          updated_at: string
          user_id: string
        }
        Insert: {
          campaign_id?: string | null
          claimed_at?: string | null
          completed_at?: string | null
          created_at?: string
          current_value?: number
          expires_at?: string | null
          id?: string
          last_progress_at?: string | null
          mission_id: string
          prestige_earned?: number
          progress_target?: number
          progress_value?: number
          started_at?: string | null
          status?: Database["public"]["Enums"]["mission_status"]
          target_value?: number
          updated_at?: string
          user_id: string
        }
        Update: {
          campaign_id?: string | null
          claimed_at?: string | null
          completed_at?: string | null
          created_at?: string
          current_value?: number
          expires_at?: string | null
          id?: string
          last_progress_at?: string | null
          mission_id?: string
          prestige_earned?: number
          progress_target?: number
          progress_value?: number
          started_at?: string | null
          status?: Database["public"]["Enums"]["mission_status"]
          target_value?: number
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_missions_mission_id_fkey"
            columns: ["mission_id"]
            isOneToOne: false
            referencedRelation: "missions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_missions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      user_progression: {
        Row: {
          campaigns_participated: number
          created_at: string
          current_tier: string
          milestones_completed: number
          missions_completed: number
          momentum_score: number
          next_tier_mission_requirements: Json | null
          next_tier_prestige_required: number | null
          prestige_this_season: number
          prestige_total: number
          updated_at: string
          user_id: string
        }
        Insert: {
          campaigns_participated?: number
          created_at?: string
          current_tier?: string
          milestones_completed?: number
          missions_completed?: number
          momentum_score?: number
          next_tier_mission_requirements?: Json | null
          next_tier_prestige_required?: number | null
          prestige_this_season?: number
          prestige_total?: number
          updated_at?: string
          user_id: string
        }
        Update: {
          campaigns_participated?: number
          created_at?: string
          current_tier?: string
          milestones_completed?: number
          missions_completed?: number
          momentum_score?: number
          next_tier_mission_requirements?: Json | null
          next_tier_prestige_required?: number | null
          prestige_this_season?: number
          prestige_total?: number
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_progression_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      user_rewards: {
        Row: {
          created_at: string
          granted_at: string
          granted_by: string | null
          id: string
          metadata: Json
          reward_id: string
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          granted_at?: string
          granted_by?: string | null
          id?: string
          metadata?: Json
          reward_id: string
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          granted_at?: string
          granted_by?: string | null
          id?: string
          metadata?: Json
          reward_id?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_rewards_granted_by_fkey"
            columns: ["granted_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_rewards_reward_id_fkey"
            columns: ["reward_id"]
            isOneToOne: false
            referencedRelation: "rewards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_rewards_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      users: {
        Row: {
          active_role: string
          application_status_summary: string
          approved_roles: string[]
          base_role: string
          cover_photo: string | null
          created_at: string
          display_name: string
          email: string | null
          id: string
          onboarding_complete: boolean
          profile_photo: string | null
          requested_role_pending: string | null
          updated_at: string
          username: string
        }
        Insert: {
          active_role?: string
          application_status_summary?: string
          approved_roles?: string[]
          base_role?: string
          cover_photo?: string | null
          created_at?: string
          display_name?: string
          email?: string | null
          id: string
          onboarding_complete?: boolean
          profile_photo?: string | null
          requested_role_pending?: string | null
          updated_at?: string
          username: string
        }
        Update: {
          active_role?: string
          application_status_summary?: string
          approved_roles?: string[]
          base_role?: string
          cover_photo?: string | null
          created_at?: string
          display_name?: string
          email?: string | null
          id?: string
          onboarding_complete?: boolean
          profile_photo?: string | null
          requested_role_pending?: string | null
          updated_at?: string
          username?: string
        }
        Relationships: []
      }
    }
    Views: {
      approval_review_queue: {
        Row: {
          active_role: string | null
          application_status_summary: string | null
          approval_created_at: string | null
          approval_id: string | null
          approval_updated_at: string | null
          approved: boolean | null
          approved_roles: Json | null
          decision: string | null
          display_name: string | null
          onboarding_complete: boolean | null
          reason: string | null
          requested_role: string | null
          requested_role_pending: string | null
          reviewed_by_user_id: string | null
          user_id: string | null
          username: string | null
        }
        Relationships: [
          {
            foreignKeyName: "approvals_reviewed_by_user_id_fkey"
            columns: ["reviewed_by_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "approvals_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      pending_approvals: {
        Row: {
          application_id: string | null
          created_at: string | null
          display_name: string | null
          email: string | null
          note: string | null
          requested_role: string | null
          status: string | null
          updated_at: string | null
          user_id: string | null
          username: string | null
        }
        Relationships: [
          {
            foreignKeyName: "role_applications_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Functions: {
      admin_approve_role_request: {
        Args: { p_approval_id: string; p_reason?: string }
        Returns: undefined
      }
      check_early_access_status: {
        Args: { p_email: string }
        Returns: {
          found: boolean
          review_note: string
          status: string
          updated_at: string
        }[]
      }
      current_user_is_admin: { Args: never; Returns: boolean }
      current_user_is_approved_business: { Args: never; Returns: boolean }
      current_user_is_approved_talent: { Args: never; Returns: boolean }
      enqueue_notification: {
        Args: {
          p_body: string
          p_entity_id?: string
          p_title: string
          p_type: string
          p_user_id: string
        }
        Returns: undefined
      }
      get_feature_policy: { Args: { role: string }; Returns: Json }
      is_admin: { Args: never; Returns: boolean }
      is_group_member: { Args: { p_group_id: string }; Returns: boolean }
      is_primary_admin: { Args: never; Returns: boolean }
      is_thread_participant: {
        Args: { tid: string; uid: string }
        Returns: boolean
      }
      recalc_post_counts: { Args: { p_post_id: string }; Returns: undefined }
      set_user_admin: {
        Args: { p_is_admin?: boolean; p_user_id: string }
        Returns: undefined
      }
    }
    Enums: {
      campaign_status: "draft" | "scheduled" | "active" | "ended" | "archived"
      mission_action_type:
        | "post_created"
        | "post_engaged"
        | "comment_posted"
        | "live_started"
        | "live_attended"
        | "opportunity_applied"
        | "campaign_joined"
        | "profile_completed"
        | "streak_day_completed"
      mission_category:
        | "onboarding"
        | "presence"
        | "engagement"
        | "consistency"
        | "opportunity"
        | "collaboration"
        | "supporter"
        | "live"
        | "other"
      mission_status:
        | "locked"
        | "available"
        | "active"
        | "claimable"
        | "completed"
        | "expired"
        | "archived"
      mission_time_window: "daily" | "weekly" | "campaign" | "lifetime"
      mission_type:
        | "daily"
        | "weekly"
        | "milestone"
        | "onboarding"
        | "campaign"
        | "creator_growth"
        | "fan_engagement"
        | "business_participation"
        | "live"
      post_reaction_type: "like" | "repost"
      user_mission_status:
        | "locked"
        | "available"
        | "in_progress"
        | "completed"
        | "claimed"
        | "expired"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      campaign_status: ["draft", "scheduled", "active", "ended", "archived"],
      mission_action_type: [
        "post_created",
        "post_engaged",
        "comment_posted",
        "live_started",
        "live_attended",
        "opportunity_applied",
        "campaign_joined",
        "profile_completed",
        "streak_day_completed",
      ],
      mission_category: [
        "onboarding",
        "presence",
        "engagement",
        "consistency",
        "opportunity",
        "collaboration",
        "supporter",
        "live",
        "other",
      ],
      mission_status: [
        "locked",
        "available",
        "active",
        "claimable",
        "completed",
        "expired",
        "archived",
      ],
      mission_time_window: ["daily", "weekly", "campaign", "lifetime"],
      mission_type: [
        "daily",
        "weekly",
        "milestone",
        "onboarding",
        "campaign",
        "creator_growth",
        "fan_engagement",
        "business_participation",
        "live",
      ],
      post_reaction_type: ["like", "repost"],
      user_mission_status: [
        "locked",
        "available",
        "in_progress",
        "completed",
        "claimed",
        "expired",
      ],
    },
  },
} as const

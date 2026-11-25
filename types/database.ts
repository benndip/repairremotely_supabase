
export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[]

export type Database = {
  
  "graphql_public": {
          Tables: {
            [_ in never]: never
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            "graphql":
{ Args: { "extensions"?: Json,"operationName"?: string,"query"?: string,"variables"?: Json }; Returns: Json
                           }
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        },"public": {
          Tables: {
            "kyc": {
                  Row: {
                    "back_id_image": string | null,"created_at": string,"front_facing_image": string | null,"front_id_image": string | null,"id": string,"reviewed_at": string | null,"reviewed_by": string | null,"status": Database["public"]['Enums']["kyc_status"],"updated_at": string,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "back_id_image"?: string | null,"created_at"?: string,"front_facing_image"?: string | null,"front_id_image"?: string | null,"id"?: string,"reviewed_at"?: string | null,"reviewed_by"?: string | null,"status"?: Database["public"]['Enums']["kyc_status"],"updated_at"?: string,"user_id": string
                  }
                  Update: {
                    "back_id_image"?: string | null,"created_at"?: string,"front_facing_image"?: string | null,"front_id_image"?: string | null,"id"?: string,"reviewed_at"?: string | null,"reviewed_by"?: string | null,"status"?: Database["public"]['Enums']["kyc_status"],"updated_at"?: string,"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "kyc_reviewed_by_fkey"
      columns: ["reviewed_by"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "kyc_user_id_fkey"
      columns: ["user_id"]
isOneToOne: true
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    }
                  ]
                },"laptops_for_rent": {
                  Row: {
                    "any_known_issues": string | null,"brand": string | null,"comes_with_charger": boolean,"condition": Database["public"]['Enums']["laptop_condition"],"created_at": string,"currency": string,"description": string | null,"id": string,"image_four": string | null,"image_one": string | null,"image_three": string | null,"image_two": string | null,"is_available": boolean,"keyboard_type": string | null,"location": string | null,"model": string | null,"name": string | null,"operating_system": string | null,"processor": string | null,"ram": string | null,"shop_id": string | null,"storage": string | null,"storage_type": Database["public"]['Enums']["storage_drive_type"] | null,"updated_at": string,"user_id": string,"weekly_rate": number
                  }
                  ComputedFields: never
                  Insert: {
                    "any_known_issues"?: string | null,"brand"?: string | null,"comes_with_charger"?: boolean,"condition"?: Database["public"]['Enums']["laptop_condition"],"created_at"?: string,"currency"?: string,"description"?: string | null,"id"?: string,"image_four"?: string | null,"image_one"?: string | null,"image_three"?: string | null,"image_two"?: string | null,"is_available"?: boolean,"keyboard_type"?: string | null,"location"?: string | null,"model"?: string | null,"name"?: string | null,"operating_system"?: string | null,"processor"?: string | null,"ram"?: string | null,"shop_id"?: string | null,"storage"?: string | null,"storage_type"?: Database["public"]['Enums']["storage_drive_type"] | null,"updated_at"?: string,"user_id": string,"weekly_rate"?: number
                  }
                  Update: {
                    "any_known_issues"?: string | null,"brand"?: string | null,"comes_with_charger"?: boolean,"condition"?: Database["public"]['Enums']["laptop_condition"],"created_at"?: string,"currency"?: string,"description"?: string | null,"id"?: string,"image_four"?: string | null,"image_one"?: string | null,"image_three"?: string | null,"image_two"?: string | null,"is_available"?: boolean,"keyboard_type"?: string | null,"location"?: string | null,"model"?: string | null,"name"?: string | null,"operating_system"?: string | null,"processor"?: string | null,"ram"?: string | null,"shop_id"?: string | null,"storage"?: string | null,"storage_type"?: Database["public"]['Enums']["storage_drive_type"] | null,"updated_at"?: string,"user_id"?: string,"weekly_rate"?: number
                  }
                  Relationships: [
                    {
      foreignKeyName: "laptops_for_rent_shop_id_fkey"
      columns: ["shop_id"]
isOneToOne: false
      referencedRelation: "shops"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "laptops_for_rent_user_id_fkey"
      columns: ["user_id"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    }
                  ]
                },"laptops_for_sale": {
                  Row: {
                    "brand": string | null,"condition": Database["public"]['Enums']["laptop_condition"],"created_at": string,"currency": string,"graphics_card": string | null,"id": string,"is_available": boolean,"lowest_amount": number | null,"model": string | null,"model_3d_url": string | null,"name": string | null,"negotiable": boolean,"operating_system": string | null,"price": number,"processor": string | null,"processor_speed": string | null,"quarter": string | null,"ram": string | null,"shipping_available": boolean,"shipping_cost": number | null,"shop_id": string | null,"storage": string | null,"storage_type": Database["public"]['Enums']["storage_drive_type"] | null,"town": string | null,"updated_at": string,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "brand"?: string | null,"condition"?: Database["public"]['Enums']["laptop_condition"],"created_at"?: string,"currency"?: string,"graphics_card"?: string | null,"id"?: string,"is_available"?: boolean,"lowest_amount"?: number | null,"model"?: string | null,"model_3d_url"?: string | null,"name"?: string | null,"negotiable"?: boolean,"operating_system"?: string | null,"price": number,"processor"?: string | null,"processor_speed"?: string | null,"quarter"?: string | null,"ram"?: string | null,"shipping_available"?: boolean,"shipping_cost"?: number | null,"shop_id"?: string | null,"storage"?: string | null,"storage_type"?: Database["public"]['Enums']["storage_drive_type"] | null,"town"?: string | null,"updated_at"?: string,"user_id": string
                  }
                  Update: {
                    "brand"?: string | null,"condition"?: Database["public"]['Enums']["laptop_condition"],"created_at"?: string,"currency"?: string,"graphics_card"?: string | null,"id"?: string,"is_available"?: boolean,"lowest_amount"?: number | null,"model"?: string | null,"model_3d_url"?: string | null,"name"?: string | null,"negotiable"?: boolean,"operating_system"?: string | null,"price"?: number,"processor"?: string | null,"processor_speed"?: string | null,"quarter"?: string | null,"ram"?: string | null,"shipping_available"?: boolean,"shipping_cost"?: number | null,"shop_id"?: string | null,"storage"?: string | null,"storage_type"?: Database["public"]['Enums']["storage_drive_type"] | null,"town"?: string | null,"updated_at"?: string,"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "laptops_for_sale_shop_id_fkey"
      columns: ["shop_id"]
isOneToOne: false
      referencedRelation: "shops"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "laptops_for_sale_user_id_fkey"
      columns: ["user_id"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    }
                  ]
                },"profiles": {
                  Row: {
                    "address": string | null,"avatar_url": string | null,"created_at": string,"email": string | null,"first_name": string | null,"id": string,"last_name": string | null,"phone_number": string | null,"role": Database["public"]['Enums']["user_role"],"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "address"?: string | null,"avatar_url"?: string | null,"created_at"?: string,"email"?: string | null,"first_name"?: string | null,"id": string,"last_name"?: string | null,"phone_number"?: string | null,"role"?: Database["public"]['Enums']["user_role"],"updated_at"?: string
                  }
                  Update: {
                    "address"?: string | null,"avatar_url"?: string | null,"created_at"?: string,"email"?: string | null,"first_name"?: string | null,"id"?: string,"last_name"?: string | null,"phone_number"?: string | null,"role"?: Database["public"]['Enums']["user_role"],"updated_at"?: string
                  }
                  Relationships: [
                    
                  ]
                },"repairer_calls": {
                  Row: {
                    "created_at": string,"id": string,"repair_id": string | null,"repairer_id": string,"status": Database["public"]['Enums']["call_status"],"updated_at": string,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"id"?: string,"repair_id"?: string | null,"repairer_id": string,"status"?: Database["public"]['Enums']["call_status"],"updated_at"?: string,"user_id": string
                  }
                  Update: {
                    "created_at"?: string,"id"?: string,"repair_id"?: string | null,"repairer_id"?: string,"status"?: Database["public"]['Enums']["call_status"],"updated_at"?: string,"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "repairer_calls_repair_id_fkey"
      columns: ["repair_id"]
isOneToOne: false
      referencedRelation: "repairs"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "repairer_calls_repairer_id_fkey"
      columns: ["repairer_id"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "repairer_calls_user_id_fkey"
      columns: ["user_id"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    }
                  ]
                },"repairs": {
                  Row: {
                    "city": string | null,"country": string | null,"created_at": string,"description": string | null,"id": string,"image_one": string | null,"image_two": string | null,"quarter": string | null,"status": Database["public"]['Enums']["repair_status"],"updated_at": string,"user_id": string,"video_url": string | null,"voice_url": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "city"?: string | null,"country"?: string | null,"created_at"?: string,"description"?: string | null,"id"?: string,"image_one"?: string | null,"image_two"?: string | null,"quarter"?: string | null,"status"?: Database["public"]['Enums']["repair_status"],"updated_at"?: string,"user_id": string,"video_url"?: string | null,"voice_url"?: string | null
                  }
                  Update: {
                    "city"?: string | null,"country"?: string | null,"created_at"?: string,"description"?: string | null,"id"?: string,"image_one"?: string | null,"image_two"?: string | null,"quarter"?: string | null,"status"?: Database["public"]['Enums']["repair_status"],"updated_at"?: string,"user_id"?: string,"video_url"?: string | null,"voice_url"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "repairs_user_id_fkey"
      columns: ["user_id"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    }
                  ]
                },"reviews": {
                  Row: {
                    "created_at": string,"id": string,"notes": string | null,"number_of_stars": number,"shop_id": string,"updated_at": string,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"id"?: string,"notes"?: string | null,"number_of_stars": number,"shop_id": string,"updated_at"?: string,"user_id": string
                  }
                  Update: {
                    "created_at"?: string,"id"?: string,"notes"?: string | null,"number_of_stars"?: number,"shop_id"?: string,"updated_at"?: string,"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "reviews_shop_id_fkey"
      columns: ["shop_id"]
isOneToOne: false
      referencedRelation: "shops"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "reviews_user_id_fkey"
      columns: ["user_id"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    }
                  ]
                },"shops": {
                  Row: {
                    "avatar_url": string | null,"created_at": string,"email": string | null,"id": string,"latitude": number | null,"logo_url": string | null,"longitude": number | null,"name": string,"phone": string | null,"physical_address": string | null,"quarter": string | null,"shop_image_url": string | null,"town": string | null,"updated_at": string,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "avatar_url"?: string | null,"created_at"?: string,"email"?: string | null,"id"?: string,"latitude"?: number | null,"logo_url"?: string | null,"longitude"?: number | null,"name": string,"phone"?: string | null,"physical_address"?: string | null,"quarter"?: string | null,"shop_image_url"?: string | null,"town"?: string | null,"updated_at"?: string,"user_id": string
                  }
                  Update: {
                    "avatar_url"?: string | null,"created_at"?: string,"email"?: string | null,"id"?: string,"latitude"?: number | null,"logo_url"?: string | null,"longitude"?: number | null,"name"?: string,"phone"?: string | null,"physical_address"?: string | null,"quarter"?: string | null,"shop_image_url"?: string | null,"town"?: string | null,"updated_at"?: string,"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "shops_user_id_fkey"
      columns: ["user_id"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    }
                  ]
                },"user_bought_laptops": {
                  Row: {
                    "created_at": string,"id": string,"laptop_for_sale_id": string,"payment_method": Database["public"]['Enums']["payment_method"],"status": Database["public"]['Enums']["purchase_status"],"updated_at": string,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"id"?: string,"laptop_for_sale_id": string,"payment_method": Database["public"]['Enums']["payment_method"],"status"?: Database["public"]['Enums']["purchase_status"],"updated_at"?: string,"user_id": string
                  }
                  Update: {
                    "created_at"?: string,"id"?: string,"laptop_for_sale_id"?: string,"payment_method"?: Database["public"]['Enums']["payment_method"],"status"?: Database["public"]['Enums']["purchase_status"],"updated_at"?: string,"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "user_bought_laptops_laptop_for_sale_id_fkey"
      columns: ["laptop_for_sale_id"]
isOneToOne: false
      referencedRelation: "laptops_for_sale"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "user_bought_laptops_user_id_fkey"
      columns: ["user_id"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    }
                  ]
                },"user_rented_laptops": {
                  Row: {
                    "amount": number | null,"back_id": string | null,"created_at": string,"duration": number,"face_id_1": string | null,"face_id_2": string | null,"front_id": string | null,"id": string,"rented_laptop_id": string,"status": Database["public"]['Enums']["rental_status"],"updated_at": string,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "amount"?: number | null,"back_id"?: string | null,"created_at"?: string,"duration": number,"face_id_1"?: string | null,"face_id_2"?: string | null,"front_id"?: string | null,"id"?: string,"rented_laptop_id": string,"status"?: Database["public"]['Enums']["rental_status"],"updated_at"?: string,"user_id": string
                  }
                  Update: {
                    "amount"?: number | null,"back_id"?: string | null,"created_at"?: string,"duration"?: number,"face_id_1"?: string | null,"face_id_2"?: string | null,"front_id"?: string | null,"id"?: string,"rented_laptop_id"?: string,"status"?: Database["public"]['Enums']["rental_status"],"updated_at"?: string,"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "user_rented_laptops_rented_laptop_id_fkey"
      columns: ["rented_laptop_id"]
isOneToOne: false
      referencedRelation: "laptops_for_rent"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "user_rented_laptops_user_id_fkey"
      columns: ["user_id"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    }
                  ]
                }
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            "current_user_role":
{ Args: Record<PropertyKey, never>; Returns: Database["public"]['Enums']["user_role"]
                           },
"is_staff":
{ Args: Record<PropertyKey, never>; Returns: boolean
                           }
          }
          Enums: {
            "call_status": "initiated"|"accepted"|"completed"|"cancelled","kyc_status": "pending"|"approved"|"rejected","laptop_condition": "new"|"used","payment_method": "OM"|"MoMo"|"cash","purchase_status": "pending"|"paid"|"completed"|"cancelled","rental_status": "pending"|"active"|"completed"|"cancelled","repair_status": "open"|"assigned"|"in_progress"|"completed"|"cancelled","storage_drive_type": "HDD"|"SSD"|"NVMe","user_role": "user"|"repairer"|"admin"|"super-admin"
          }
          CompositeTypes: {
            [_ in never]: never
          }
        }
}

type DatabaseWithoutInternals = Omit<Database, '__InternalSupabase'>

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
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
  ? (DefaultSchema["Tables"] & DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
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
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
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
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
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
    : never = never
> = DefaultSchemaEnumNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
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
    : never = never
> = PublicCompositeTypeNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
  ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
  : never

export const Constants = {
  "graphql_public": {
          Enums: {
            
          }
        },"public": {
          Enums: {
            "call_status": ["initiated", "accepted", "completed", "cancelled"],"kyc_status": ["pending", "approved", "rejected"],"laptop_condition": ["new", "used"],"payment_method": ["OM", "MoMo", "cash"],"purchase_status": ["pending", "paid", "completed", "cancelled"],"rental_status": ["pending", "active", "completed", "cancelled"],"repair_status": ["open", "assigned", "in_progress", "completed", "cancelled"],"storage_drive_type": ["HDD", "SSD", "NVMe"],"user_role": ["user", "repairer", "admin", "super-admin"]
          }
        }
} as const

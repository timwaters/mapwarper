class Activity < Audit
   #Audit lives in vendor/plugins/acts_as_audited/lib/audit.rb

  def uname
    if username.to_s == "--- :false\n"
      uname = nil
    else 
      uname = username 
    end
    uname
  end
 def activity_action
   action.gsub(/\W/, "").titleize

 end
   def summary
      summ  = ""
      if changes && auditable_type == "Map"
         if changes["status"] && changes["status"] != "status"
            map_action  =  Map::STATUS[changes["status"]]
            case map_action
            when :unloaded
               summ = "Map was unloaded"
            when :loading
               summ = "Map started loading from library"
            when :available
               summ = "Map became available"
            when :warping
               summ = "Map started rectification process"
            when :warped
               summ = "Map successfully rectified"
            when :published
               summ = "Map successfully published"
            else
               summ =""
            end

         end #status

         if changes["mask_status"] && changes["status"] != "mask_status"
            mask_action = Map::MASK_STATUS[changes["mask_status"]]
            case mask_action
            when :unmasked
               summ = "Map was unmasked"
            when :masking
               summ = "Map started masking process"
            when :masked
               summ = "Map successfully masked"
            else
               summ = ""
            end

         end # mask_status

      end #Map

      summ
   end


end

module AuditsHelper
  
  
  def formatted_action(action)
    action.gsub(/\W/, "").titleize
  end

  def summary(audit)
    summ  = ""
    if audit.changes && audit.auditable_type == "Map"
      changes = audit.audited_changes

      if changes && changes["status"] && changes["status"] != "status"
        if changes["status"].class == Array && changes["status"][1]
          map_action  = Map::STATUS[changes["status"][1]]
        elsif changes["status"].class == Fixnum
          map_action =  Map::STATUS[changes["status"]]
        else
          map_action = :missing
        end
        
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

      if changes && changes["mask_status"] && changes["status"] != "mask_status"
        
        if changes["mask_status"].class == Array && changes["mask_status"][1]
          mask_action  = Map::MASK_STATUS[changes["mask_status"][1]]
        elsif changes["mask_status"].class == Fixnum
          map_action =  Map::MASK_STATUS[changes["mask_status"]]
        else
          mask_action = :missing
        end
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

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
        elsif changes["status"].class == Integer
          map_action =  Map::STATUS[changes["status"]]
        else
          map_action = :missing
        end
        
        case map_action
        when :unloaded
          summ = t('audits.helper.summary.unloaded')
        when :loading
          summ = t('audits.helper.summary.loading')
        when :available
          summ = t('audits.helper.summary.available')
        when :warping
          summ = t('audits.helper.summary.warping')
        when :warped
          summ = t('audits.helper.summary.warped')
        when :published
          summ = t('audits.helper.summary.published')
        else
          summ =""
        end

      end #status

      if changes && changes["mask_status"] && changes["status"] != "mask_status"
        
        if changes["mask_status"].class == Array && changes["mask_status"][1]
          mask_action  = Map::MASK_STATUS[changes["mask_status"][1]]
        elsif changes["mask_status"].class == Integer
          map_action =  Map::MASK_STATUS[changes["mask_status"]]
        else
          mask_action = :missing
        end
        case mask_action
        when :unmasked
          summ = t('audits.helper.summary.unmasked')
        when :masking
          summ = t('audits.helper.summary.masking')
        when :masked
          summ = t('audits.helper.summary.masked')
        else
          summ = ""
        end

      end # mask_status
      
    end #Map

    summ
  end
  
end

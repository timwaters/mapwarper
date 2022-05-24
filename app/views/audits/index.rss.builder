xml.channel do
  xml.title @title
  xml.description "Feed for recent activity"
  xml.link formatted_activity_url
  for audit in @audits

    if audit.auditable_type.downcase == "map" 
      typename = "Map"
    elsif audit.auditable_type.downcase == "gcp" 
      typename = "Control Point" 
    end 

    xml.item do
      if audit.user && audit.user.login
        changed_by = "  by " + audit.user.login.capitalize 
      else
        changed_by = " by -- "
      end

      xml.title typename + ' ' + audit.auditable_id.to_s + " changed" + changed_by
      
      xml.description "Action: "+ audit.action.gsub(/\W/, "")  + "\n" + summary(audit) +  "\n Version: "+ audit.version.to_s 
        
      xml.pubDate audit.created_at.to_s(:rfc822)
      xml.link activity_details_url(:id => audit)

      xml.guid
    end

  end
end

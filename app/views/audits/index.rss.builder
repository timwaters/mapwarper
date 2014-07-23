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
      if audit.uname
        changed_by = "  by " + audit.uname.capitalize 
      else
        changed_by = " by -- "
      end

        xml.title typename + ' ' + audit.auditable_id.to_s + " changed" + changed_by
      
        xml.description "Action: "+ audit.action.gsub(/\W/, "")  + "<br /> " + audit.summary +  "<br />Version: "+ audit.version.to_s 
        
        xml.pubDate audit.created_at.to_s(:rfc822)
        xml.link activity_details_url(:id => audit)

        xml.guid
      end

    end
  end

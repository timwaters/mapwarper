#
# Example controller for use with digitizer to give subtypes depending on a the param parent type
#
class DigitizeController < ApplicationController
 #TODO add in other json files instead of static?
  def subtype
    parent_type = params[:query]
    #TODO move this into a db table and do query this way
    subtypes = [
      {"parentType" => "Residential", "id" => "Apartments", "label" => "Apartments"},
      {"parentType" => "Residential", "id" =>  "Houses", "label" => "Houses"},
      {"parentType" => "Worship", "id" => "Church", "label" => "Church"},
      {"parentType" => "Worship", "id" => "Synagogue", "label" => "Synagogue"},
      {"parentType" => "Educational", "id" => "School", "label" => "School"},
      {"parentType" => "Educational", "id" => "Library", "label" => "Library"},
      {"parentType" => "Commercial", "id" => "Hotel", "label" => "Hotel"},
      {"parentType" => "Commercial", "id" => "Bank", "label" => "Bank"},
      {"parentType" => "Commercial", "id" => "Shop", "label" => "Shop"},
      {"parentType" => "Commercial", "id" => "Gallery", "label" => "Gallery"},
      {"parentType" => "Commercial", "id" => "Pharmacy", "label" => "Pharmacy"},
      {"parentType" => "Commercial", "id" => "Cobbler", "label" => "Cobbler"},
      {"parentType" => "Industrial", "id" => "Office", "label" => "Office"},
      {"parentType" => "Industrial", "id" => "Saw Mill", "label" => "Saw Mill"},
      {"parentType" => "Industrial", "id" => "Distillery", "label" => "Distillery"},
      {"parentType" => "Industrial", "id" => "Lumber Yard", "label" => "Lumber Yard"},
      {"parentType" => "Industrial", "id" => "Warehouse", "label" => "Warehouse"},
      {"parentType" => "Industrial", "id" => "Storehouse", "label" => "Storehouse"},
      {"parentType" => "Industrial", "id" => "Gas Works", "label" => "Gas Works"},
      {"parentType" => "Industrial", "id" => "Foundary", "label" => "Foundary"},
      {"parentType" => "Industrial", "id" => "Paper Mill", "label" => "Paper Mill"},
      {"parentType" => "Industrial", "id" => "Textile Mill", "label" => "Textile Mill"},
      {"parentType" => "Industrial", "id" => "Locomotive Works", "label" => "Locomotive Works"},
      {"parentType" => "Industrial", "id" => "Brewery", "label" => "Brewery"},
      {"parentType" => "Industrial", "id" => "Factory", "label" => "Factory"},
      {"parentType" => "Industrial", "id" => "Manufactory", "label" => "Manufactory"},
      {"parentType" => "Industrial", "id" => "Paint Shop", "label" => "Paint Shop"},
      {"parentType" => "Industrial", "id" => "Rope Walk", "label" => "Rope Walk"},
      {"parentType" => "Industrial", "id" => "Slaughter House", "label" => "Slaughter House"},
      {"parentType" => "Health", "id" => "Hospital", "label" => "Hospital"},
      {"parentType" => "Health", "id" => "Asylum Insane", "label" => "Asylum (Insane)"},
      {"parentType" => "Health", "id" => "Asylum Inebriate", "label" => "Asylum (Inebriate)"},
      {"parentType" => "Health", "id" => "Asylum Orphan", "label" => "Asylum (Orphan)"},
      {"parentType" => "Health", "id" => "Almshouse", "label" => "Almshouse"},
      {"parentType" => "Health", "id" => "Quarantine", "label" => "Quarantine"},
      {"parentType" => "Health", "id" => "Sanatorium", "label" => "Sanatorium"},
      {"parentType" => "Transport", "id" => "Toll House", "label" => "Toll House"},
      {"parentType" => "Transport", "id" => "Toll Gate", "label" => "Toll Gate"},
      {"parentType" => "Transport", "id" => "Railroad System", "label" => "Railroad System"},
      {"parentType" => "Transport", "id" => "Railroad Depot", "label" => "Railroad Depot"},
      {"parentType" => "Transport", "id" => "Subway Platform", "label" => "Subway Platform"},
      {"parentType" => "Transport", "id" => "Freight House", "label" => "Freight House"},
      {"parentType" => "Transport", "id" => "Docks", "label" => "Docks"},
      {"parentType" => "Military", "id" => "Armory", "label" => "Armory"},
      {"parentType" => "Military", "id" => "Battery", "label" => "Battery"},
      {"parentType" => "Military", "id" => "Fortification", "label" => "Fortification"}

    ]
   
    filtered_subtypes = []
    if !parent_type.nil?
      subtypes.each do | subtype |
        if subtype["parentType"] == parent_type
          filtered_subtypes << subtype
        end
      end
    else
      filtered_subtypes = subtypes
    end

#    jsontext = '{"root": [
#{"parentType": "Residential", "id": "Apartments", "label": "Apartments"},
#{"parentType": "Residential", "id": "Houses", "label": "Houses"},
#{"parentType": "Worship", "id": "Church", "label": "Church"},
#{"parentType": "Worship", "id": "Synagogue", "label": "Synagogue"}
#]}'
    respond_to do |format|
      format.json {render :json => {:root =>filtered_subtypes}}
    end
  end




  end

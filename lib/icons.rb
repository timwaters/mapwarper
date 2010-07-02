require 'rubygems'
require 'RMagick'
include Magick
			
icon_width = 14
icon_height = 22

i=0
350.times do 
  icon = Magick::ImageList.new("../public/images/plain.png")
  txtlayer = Magick::Draw.new
  pointsize = 14
  pointsize = 11 if i > 99
  txtlayer.annotate(icon, 0,0, -0.7,-5, i.to_s) {

    self.font = 'AvantGarde-Demi'
    self.fill = 'black'
    self.stroke = 'transparent'
    self.pointsize = pointsize
    self.font_weight = BoldWeight
    self.gravity = CenterGravity
  }



  icon.scale!(icon_width, icon_height)
  icon.format = "png32"
	icon.write("../public/images/icons/"+i.to_s+".png") 
 
  i +=1
  #  txtlayer.draw(icon)
  #   icon.display
  #icon.format = "png32"
end
# end



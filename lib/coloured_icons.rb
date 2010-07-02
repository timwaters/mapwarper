 require 'rubygems'
 require 'RMagick'
 include Magick
 icon_width = 14
 icon_height = 22

 ["green","orange", "red"].each do | ourcolor | 
 p ourcolor
 i=0
 150.times do 
 icon = Magick::ImageList.new("../public/images/plain_#{ourcolor}.png")
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
	icon.write("../public/images/icons/"+i.to_s+"_#{ourcolor}.png") 
 
  i +=1
 end
 end



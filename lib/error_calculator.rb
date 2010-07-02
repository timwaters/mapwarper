#A module to assist in calculation RMS error of the control points and the map
#adapted to ruby by tim waters and based on bsd licenced code
#oldmapsonline.org Klokan Petr Pridal gcps2wld.py (new BSD licence)
#takes in an enumeration of control points, and returns them with error attribute
#and returns the rms of the whole lot

module ErrorCalculator


  def calc_error(gcps)
    
    if gcps.size > 3
      begin
        dest_set = Array.new
        source_set = Array.new

        gcps.each do |gcp|
          dest_set << [gcp.x, gcp.y]
          source_set << [gcp.lon, gcp.lat]
          #  gcp.x.to_s + " "+ gcp.y.to_s + " "+ gcp.lon.to_s + " "+ gcp.lat.to_s
        end

        number_of_points = Math_my.min( dest_set.size ,source_set.size)

        cx_dst, cy_dst, cx_src, cy_src = 0,0,0,0

        0.upto(number_of_points-1) do  | i |
          cx_dst += dest_set[i][0]
          cy_dst += dest_set[i][1]
          cx_src += source_set[i][0]
          cy_src += source_set[i][1]
        end

        cx_dst /= number_of_points
        cy_dst /= number_of_points
        cx_src /= number_of_points
        cy_src /= number_of_points

        x = Matrix[* dest_set.map { |dst| [dst[0] - cx_dst] } ].transpose
        y = Matrix[* dest_set.map { |dst| [dst[1] - cy_dst] } ].transpose
        aa = Matrix[* source_set.map { |src| [1.0, src[0]-cx_src, src[1]-cy_src] } ]
        at = aa.transpose

        q = (at * aa).inverse
        a = q * (at * x.transpose)
        b = q * (at * y.transpose)

        a1 = a[1,0]
        a2 = a[2,0]
        a3 = b[1,0]
        a4 = b[2,0]

        w = [a1, a3, a2, a4, cx_dst - a1*cx_src - a2*cy_src, cy_dst - a3*cx_src - a4*cy_src ]
        proj_set = Array.new
        source_set.each do |x,y|
          p = Array.new
          p << ( w[4] + w[0]*x + w[2]*y )
          p << ( w[5] + w[1]*x + w[3]*y )
          proj_set << p
        end

        errs = Array.new

        0.upto(dest_set.size-1) do  | i |

          x,y = dest_set[i]
          px,py = proj_set[i]
          minx = Math_my.min( x, px)
          maxx = Math_my.max( x, px)
          miny = Math_my.min( y, py)
          maxy = Math_my.max( y, py)
          sx = maxx - minx
          sy = maxy - miny
          err = Math.sqrt( sx*sx + sy*sy )
          errs << err
          #error for gcp
          #puts err
        end
        #now get sqrt for all

        sqerrs = errs.map{|err| err*err }
        sumerrs = sqerrs.inject(0) { |s,v| s += v }

        rmse = Math.sqrt( sumerrs / errs.size)
        # puts "RMSE = " +rmse.inspect

        count = 0
        gcps.each do |gcp|
          #error for gcp
          gcp.error = errs[count]
          count += 1
        end
        error = rmse #rms error for map
      rescue ExceptionForMatrix::ErrNotRegular => whoops
      Rails.logger.error("error in matrix: " + whoops)
        gcps.each do |gcp|
          gcp.error = 0.0
        end
        error = 0.0

      end
    else
      Rails.logger.info("not enough gcps for calc")
      gcps.each do |gcp|
        gcp.error = 0.0
      end
      #not enough or no gcps to do calculation
      error = 0.0
    end
    return gcps, error
  end

end
  #tiny helper module for ruby min and max used when calculating rms transformation error
  module Math_my
    def self.min(a,b)
      a <= b ? a : b
    end
    def self.max(a,b)
      a >= b ? a : b
    end
  end

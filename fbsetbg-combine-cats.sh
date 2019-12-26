out="$HOME/tmp/combine-out"
in="$HOME/images/wallpapers/deviant/apofiss-cats"
mkdir -p $out 2>/dev/null 


function two1980 {
	ls -1 $in/*{jpg,png} 2>/dev/null | sort -R | head -n25
}

border=orange
border=0f0e0e
bg=darkorange
bg=\#8a4400
border=\#8a4400

v=170e05
bg=\#$v
border=\#$v

v=
bg=\#170e05
border=\#170e05


convert `two1980` -gravity south  -resize 600x375 -bordercolor $border -border 1x1 -background $bg +append -quality 85 $out/row1.jpg
convert `two1980` -gravity center -resize 600x375 -bordercolor $border -border 1x1 -background $bg +append -quality 85 $out/row2.jpg
convert `two1980` -gravity north  -resize 600x375 -bordercolor $border -border 1x1 -background $bg +append -quality 85 $out/row3.jpg
convert $out/row{1,2,3}.jpg -background black -append $out/multi-row.jpg
echo $out/multi-row.jpg
#convert $out/multi-row.jpg -resize 3840x2160^ -gravity center -crop  3840x2160+0+0 $out/final.jpg

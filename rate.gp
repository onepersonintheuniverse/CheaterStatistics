set term pngcairo size 1920,1080
set palette defined (400 "#808080", 1200 "#00ff00", 1400 "#00ffff", 1600 "#0000ff", 1900 "#7f00ff", 2100 "#ffaf00", 2300 "#ff7f00", 2400 "#ff3f00", 2600 "#ff0000", 3000 "#7f0000")
set cbrange [400:3000]
set xrange [300:3000]
set style fill solid

mu = system("awk '{ print $1 }' < ms.dat")+0
sigma = system("awk '{ print $2 }' < ms.dat")+0
scale = system("awk '{ print $3 }' < ms.dat")+0

f(x) = 1/(sigma*sqrt(2*pi))*exp(-((x-mu)/sigma)**2/2)

plot 'rate.dat' with boxes fc palette, scale*f(x)/f(mu) with lines lc 'black'

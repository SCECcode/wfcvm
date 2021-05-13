c  surface.h   contains reference surface numbers
c i3 number x,y pairs in model edge
c numsur number reference surfaces
c isurmx  max number surfaces for a pt
c ilahi, ilohi max number lat, lon points in surface depth files
c nedmx  max number pairs of points in surface edge files
         parameter(numsur=3,ilahi=560,ilohi=250,i3=126,isurmx=3)
         common /rsurfs/ rlosur(numsur,ilohi), rlasur(numsur,ilahi),
     1   nlosur(numsur), nlasur(numsur), rsuval(numsur,ilohi,ilahi)

c include file genpro.h
c contains soil generic profile info
c numgen = number generic profiles
c rmxdep = max depth of generic profiles
c numptge2 = number total pts in each generic profile
         parameter (numgen=18,mxptgen=5330)
         common /genstuff/ rmxdep(numgen),numptge2(numgen),
     1   rdepgen(numgen,mxptgen), rvsgen(numgen,mxptgen)

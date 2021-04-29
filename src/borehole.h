c borehole include file
c contains info on geotechnical (near surface)
c boreholes
           parameter (numbh=229,maxbh=421)
           common /boring/ rlatbh(numbh),rlonbh(numbh),isotype(numbh)
     1     ,numptbh(numbh),rdepbh(numbh,maxbh),
     2     rvs(numbh,maxbh),rvp(numbh,maxbh),rbhdmx(numbh),rmaxbh
